import SwiftUI

public enum Cell6ViewTab: String, CaseIterable, Identifiable {
    case sensorFrame = "Sensor Frame"
    case zoomedBlade = "Zoomed Blade"
    case clahe = "CIE-LAB CLAHE"
    case lesionOverlay = "Lesion Overlay"

    public var id: String { rawValue }

    public var stepLetter: String {
        switch self {
        case .sensorFrame: return "(a)"
        case .zoomedBlade: return "(b)"
        case .clahe: return "(c)"
        case .lesionOverlay: return "(d)"
        }
    }

    public func title(output: Cell6PipelineOutput, topLabel: String, topConf: Double, isGated: Bool) -> String {
        switch self {
        case .sensorFrame:
            return "(a) Sensor Frame\n[Target Frame: \(output.frameDimensions.width)x\(output.frameDimensions.height)]"
        case .zoomedBlade:
            return "(b) Zoomed Foliar Blade\n[\(output.bladeDimensions.width)x\(output.bladeDimensions.height) (\(String(format: "%.2f", output.zoomFactor))x Zoom)]"
        case .clahe:
            return "(c) CIE-LAB CLAHE\n[Shadows & Glare Normalized]"
        case .lesionOverlay:
            let tag = isGated ? "[UNCERTAIN / GATED]" : "[CLINICALLY VALIDATED]"
            return "(d) Lesion Attention Overlay\n\(topLabel) (\(String(format: "%.1f", topConf))%)\n\(tag)"
        }
    }

    public func image(from output: Cell6PipelineOutput) -> UIImage {
        switch self {
        case .sensorFrame: return output.sensorFrameWithHUD
        case .zoomedBlade: return output.zoomedFoliarBlade
        case .clahe: return output.claheNormalized
        case .lesionOverlay: return output.lesionAttentionOverlay
        }
    }
}

public struct Cell6DiagnosticDashboard: View {
    public let output: Cell6PipelineOutput
    public let topLabel: String
    public let topConf: Double
    public let isGated: Bool

    @State private var selectedTab: Cell6ViewTab = .lesionOverlay
    @State private var isQuadGridMode: Bool = false

    public var body: some View {
        VStack(spacing: 14) {
            // Header bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "waveform.path.ecg")
                        .foregroundColor(.green)
                    Text("Cell 6 Diagnostic Dashboard")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }

                Spacer()

                Button {
                    withAnimation { isQuadGridMode.toggle() }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isQuadGridMode ? "rectangle.fill.on.rectangle.fill" : "square.grid.2x2.fill")
                        Text(isQuadGridMode ? "Single View" : "4-Panel HUD")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
            }

            if isQuadGridMode {
                // Exact 4-Panel layout matching Cell 6 screenshot: (a), (b), (c), (d)
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        cellCard(tab: .sensorFrame)
                        cellCard(tab: .zoomedBlade)
                    }
                    HStack(spacing: 8) {
                        cellCard(tab: .clahe)
                        cellCard(tab: .lesionOverlay)
                    }
                }
            } else {
                // Interactive Single View with Segmented Picker
                VStack(spacing: 12) {
                    Picker("Diagnostic View", selection: $selectedTab) {
                        ForEach(Cell6ViewTab.allCases) { tab in
                            Text("\(tab.stepLetter) \(tab.rawValue)").tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Active Image Display
                    ZStack(alignment: .bottomLeading) {
                        Image(uiImage: selectedTab.image(from: output))
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 280)
                            .cornerRadius(12)
                            .shadow(radius: 4)

                        // Title Banner matching notebook subplot titles
                        Text(selectedTab.title(output: output, topLabel: topLabel, topConf: topConf, isGated: isGated))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(6)
                            .padding(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    @ViewBuilder
    private func cellCard(tab: Cell6ViewTab) -> some View {
        VStack(spacing: 4) {
            Image(uiImage: tab.image(from: output))
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 140)
                .cornerRadius(8)

            Text(tab.title(output: output, topLabel: topLabel, topConf: topConf, isGated: isGated))
                .font(.system(size: 8, weight: .bold))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .foregroundColor(.primary)
                .frame(height: 34)
        }
        .padding(6)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
