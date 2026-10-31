import Foundation
import UIKit
import CoreML

@MainActor
public final class FoliarDiagnosticService: ObservableObject {
    @Published public var isAnalyzing: Bool = false
    @Published public var currentReport: PathologyReport? = nil
    @Published public var cell6Output: Cell6PipelineOutput? = nil
    @Published public var errorMessage: String? = nil

    private var net: AgriShadeNet?

    public init() {
        setupCoreMLModel()
    }

    private func setupCoreMLModel() {
        if let modelURL = Bundle.main.url(forResource: "AgriShadeNet", withExtension: "mlmodelc") ??
                          Bundle.main.url(forResource: "AgriShadeNet", withExtension: "mlpackage") {
            do {
                let config = MLModelConfiguration()
                config.computeUnits = .all
                self.net = try AgriShadeNet(contentsOf: modelURL, configuration: config)
                print("[✓] AgriShadeNet CoreML model loaded successfully.")
            } catch {
                print("[!] Failed to initialize AgriShadeNet: \(error)")
            }
        }
    }

    public func analyze(image: UIImage) async {
        isAnalyzing = true
        errorMessage = nil

        guard let net = self.net else {
            setupCoreMLModel()
            guard let retry = self.net else {
                self.errorMessage = "AgriShadeNet Core ML model could not be loaded."
                self.isAnalyzing = false
                return
            }
            await runInference(with: retry, image: image)
            return
        }

        await runInference(with: net, image: image)
    }

    private func runInference(with net: AgriShadeNet, image: UIImage) async {
        let fixedImg = image.fixOrientation()

        // STAGE 0: Fast Out-Of-Distribution (OOD) Foliar Leaf Validation
        let foliarCheck = FoliarValidator.validate(image: fixedImg)

        guard let cg = fixedImg.cgImage else {
            self.errorMessage = "Could not obtain CGImage."
            self.isAnalyzing = false
            return
        }

        do {
            // AgriShadeNetInput convenience initializer takes CGImage and automatically resizes & normalizes to 224x224 CVPixelBuffer
            let input = try AgriShadeNetInput(input_leafWith: cg)
            let output = try net.prediction(input: input)

            let rawProbs: [String: Double] = output.classLabel_probs

            if rawProbs.isEmpty {
                self.errorMessage = "Prediction output did not contain class probabilities."
                self.isAnalyzing = false
                return
            }

            // Ensure probabilities are normalized
            var normalizedProbs: [String: Double] = [:]
            let sumRaw = rawProbs.values.reduce(0.0, +)
            let maxRaw = rawProbs.values.max() ?? 0.0

            if abs(sumRaw - 1.0) < 0.05 && maxRaw <= 1.0 {
                normalizedProbs = rawProbs
            } else {
                var expSum = 0.0
                var expValues: [String: Double] = [:]
                for (k, v) in rawProbs {
                    let ev = exp(v - maxRaw)
                    expValues[k] = ev
                    expSum += ev
                }
                for (k, ev) in expValues {
                    normalizedProbs[k] = expSum > 0 ? (ev / expSum) : 0.0
                }
            }

            // Sort candidates descending
            let sorted = normalizedProbs.sorted(by: { $0.value > $1.value })
            var candidates: [PathologyCandidate] = []

            for (lbl, prob) in sorted.prefix(5) {
                let (crop, disease) = BotanicalTaxonomy.parseRawLabel(lbl)
                let boundedProb = min(1.0, max(0.0, prob))
                let pctStr = String(format: "%.1f%%", boundedProb * 100.0)
                candidates.append(PathologyCandidate(
                    rawLabel: lbl,
                    cropName: crop,
                    diseaseName: disease,
                    probability: boundedProb,
                    percentageString: pctStr
                ))
            }

            guard let top1 = candidates.first else {
                self.errorMessage = "Could not parse top diagnosis candidate."
                self.isAnalyzing = false
                return
            }

            let top1Conf = top1.probability * 100.0
            let top2Conf = candidates.count > 1 ? candidates[1].probability * 100.0 : 0.0
            let confidenceMargin = top1Conf - top2Conf

            // Shannon Entropy (in nats) matching AgriShade Cell 6
            var entropy: Double = 0.0
            for (_, p) in normalizedProbs {
                if p > 1e-12 {
                    entropy -= p * log(p)
                }
            }
            let maxEntropy = log(Double(normalizedProbs.count))
            let normalizedEntropy = maxEntropy > 0 ? (entropy / maxEntropy) : 0.0

            let top3Crops = candidates.prefix(3).map { $0.cropName }
            let cropConflict = Set(top3Crops).count >= 3
            let rawCrop = top1.rawLabel.components(separatedBy: "___").first ?? top1.cropName
            let dominantTaxon = BotanicalTaxonomy.taxon(for: rawCrop)

            // Decision Gating Thresholds matching AgriShade Cell 6
            let CONFIDENCE_THRESHOLD = 65.0
            let ENTROPY_THRESHOLD = 1.75
            let MARGIN_THRESHOLD = 15.0

            var gatingReasons: [String] = []

            // If foliar check failed (user took photo of desk, person, floor, etc.)
            let isNonLeaf = !foliarCheck.isFoliageDetected
            if isNonLeaf, let reason = foliarCheck.rejectionReason {
                gatingReasons.append(reason)
            }

            if top1Conf < CONFIDENCE_THRESHOLD {
                gatingReasons.append("Confidence score (\(String(format: "%.1f", top1Conf))%) is below the \(Int(CONFIDENCE_THRESHOLD))% clinical threshold.")
            }
            if entropy > ENTROPY_THRESHOLD {
                gatingReasons.append("Shannon entropy (\(String(format: "%.2f", entropy)) nats) indicates multi-disease ambiguity.")
            }
            if confidenceMargin < MARGIN_THRESHOLD {
                gatingReasons.append("Narrow margin (\(String(format: "%.1f", confidenceMargin))%) between top candidates.")
            }
            if cropConflict {
                gatingReasons.append("Genera conflict: candidates span unrelated crop families (\(top3Crops.joined(separator: ", "))).")
            }

            let isGated = !gatingReasons.isEmpty || isNonLeaf
            let advisory = AdvisoryDatabase.advisory(for: top1.rawLabel)

            self.currentReport = PathologyReport(
                topCandidate: top1,
                candidates: Array(candidates.prefix(3)),
                dominantTaxon: dominantTaxon,
                dominantCrop: top1.cropName,
                confidenceMargin: confidenceMargin,
                entropy: entropy,
                normalizedEntropy: normalizedEntropy,
                cropConflict: cropConflict,
                isGated: isGated,
                isNonLeafObject: isNonLeaf,
                gatingReasons: gatingReasons,
                advisory: advisory,
                timestamp: Date()
            )

            // Generate full Cell 6 Diagnostic Views ((a), (b), (c), (d))
            self.cell6Output = Cell6DiagnosticPipeline.process(
                image: fixedImg,
                topLabel: top1.rawLabel,
                confidencePct: top1Conf,
                isGated: isGated
            )

        } catch {
            self.errorMessage = "Diagnostic inference failed: \(error.localizedDescription)"
        }

        self.isAnalyzing = false
    }
}
