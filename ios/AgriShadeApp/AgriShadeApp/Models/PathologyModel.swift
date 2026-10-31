import Foundation

public struct AgronomicAdvisory: Sendable {
    public let status: String
    public let action: String
    public let chemical: String
    public let organic: String
    public let hygiene: String
    public let isHealthy: Bool
}

public struct PathologyCandidate: Identifiable, Sendable {
    public var id: String { rawLabel }
    public let rawLabel: String
    public let cropName: String
    public let diseaseName: String
    public let probability: Double // 0.0 to 1.0
    public let percentageString: String
}

public struct PathologyReport: Sendable {
    public let topCandidate: PathologyCandidate
    public let candidates: [PathologyCandidate] // Top 3
    public let dominantTaxon: String
    public let dominantCrop: String
    public let confidenceMargin: Double // Δp1 - p2 in %
    public let entropy: Double
    public let normalizedEntropy: Double // 0 to 1
    public let cropConflict: Bool
    public let isGated: Bool // True if fail-safe lock engaged or non-leaf
    public let isNonLeafObject: Bool // Explicitly true if no foliar tissue was detected
    public let gatingReasons: [String]
    public let advisory: AgronomicAdvisory
    public let timestamp: Date
}

public enum BotanicalTaxonomy {
    public static let cropFamilies: [String: String] = [
        "Apple": "Rosaceae (Malus)",
        "Blueberry": "Ericaceae (Vaccinium)",
        "Cherry_(including_sour)": "Rosaceae (Prunus)",
        "Corn_(maize)": "Poaceae (Zea mays)",
        "Grape": "Vitaceae (Vitis)",
        "Orange": "Rutaceae (Citrus)",
        "Peach": "Rosaceae (Prunus persica)",
        "Pepper,_bell": "Solanaceae (Capsicum)",
        "Potato": "Solanaceae (Solanum tuberosum)",
        "Raspberry": "Rosaceae (Rubus)",
        "Soybean": "Fabaceae (Glycine max)",
        "Squash": "Cucurbitaceae (Cucurbita)",
        "Strawberry": "Rosaceae (Fragaria)",
        "Tomato": "Solanaceae (Solanum lycopersicum)"
    ]

    public static func taxon(for crop: String) -> String {
        return cropFamilies[crop] ?? "Agricultural Angiosperm"
    }

    public static func parseRawLabel(_ raw: String) -> (crop: String, disease: String) {
        let parts = raw.components(separatedBy: "___")
        let crop = parts.first ?? raw
        let cleanCrop = crop.replacingOccurrences(of: "_", with: " ")
        if parts.count > 1 {
            let disease = parts[1]
                .replacingOccurrences(of: "_", with: " ")
                .trimmingCharacters(in: .whitespaces)
            return (cleanCrop, disease)
        }
        return (cleanCrop, "Unspecified Pathology")
    }
}

public enum AdvisoryDatabase {
    public static func advisory(for rawLabel: String) -> AgronomicAdvisory {
        let lbl = rawLabel.lowercased()

        if lbl.contains("healthy") {
            return AgronomicAdvisory(
                status: "Healthy foliar tissue detected.",
                action: "No chemical or biological intervention required.",
                chemical: "None (Preserve beneficial canopy microbiome).",
                organic: "Preventative seaweed extract or aerated compost tea.",
                hygiene: "Maintain standard drip irrigation; scout weekly during warm periods.",
                isHealthy: true
            )
        } else if lbl.contains("scorch") {
            return AgronomicAdvisory(
                status: "Foliar Leaf Scorch / Diplocarpon pathology confirmed.",
                action: "Immediate foliar spray to halt necrotic lesion progression.",
                chemical: "Captan (2.0 g/L) or Myclobutanil (0.5 ml/L) protective fungicide.",
                organic: "Copper Octanoate (liquid copper) or Bacillus subtilis biofungicide.",
                hygiene: "Prune desiccated scorched foliage; sanitize pruning shears with 70% alcohol.",
                isHealthy: false
            )
        } else if lbl.contains("early_blight") {
            return AgronomicAdvisory(
                status: "Early Blight (Alternaria solani) confirmed.",
                action: "Immediate foliar spray to halt upward canopy progression.",
                chemical: "Chlorothalonil (2.0 g/L) or Difenoconazole (0.5 ml/L).",
                organic: "Copper Hydroxide (2.0–2.5 g/L) or Bacillus subtilis biofungicide.",
                hygiene: "Prune infected lower foliage; transition strictly to drip irrigation.",
                isHealthy: false
            )
        } else if lbl.contains("late_blight") {
            return AgronomicAdvisory(
                status: "CRITICAL: Late Blight (Phytophthora infestans) water-soaked lesion.",
                action: "Emergency therapeutic systemic application within 24 hours.",
                chemical: "Metalaxyl-M + Mancozeb (2.5 g/L) or Cymoxanil curative spray.",
                organic: "Fixed Copper spray (Bordeaux mixture 1%) - preventative only.",
                hygiene: "Bag and bury/burn severely infected vines; scout downwind plots.",
                isHealthy: false
            )
        } else if lbl.contains("bacterial_spot") {
            return AgronomicAdvisory(
                status: "Bacterial Spot (Xanthomonas spp.) detected.",
                action: "Protective copper-mancozeb barrier application.",
                chemical: "Copper Hydroxide (2.0 g/L) + Mancozeb (2.0 g/L) tank mix.",
                organic: "Liquid copper octanoate or Serenade (Bacillus subtilis).",
                hygiene: "Never work in fields while leaves are wet; sanitize pruning tools.",
                isHealthy: false
            )
        } else if lbl.contains("septoria") {
            return AgronomicAdvisory(
                status: "Septoria Leaf Spot (Septoria lycopersici) detected.",
                action: "Protective multi-site fungicide spray.",
                chemical: "Chlorothalonil (2.0 g/L) or Mancozeb (2.5 g/L).",
                organic: "Copper sulfate pentahydrate or potassium bicarbonate.",
                hygiene: "Mulch heavily around plant bases to prevent soil splash.",
                isHealthy: false
            )
        } else if lbl.contains("scab") {
            return AgronomicAdvisory(
                status: "Apple Scab (Venturia inaequalis) detected.",
                action: "Protective and curative foliar fungicide.",
                chemical: "Captan (2.0 g/L) or Myclobutanil (0.4 ml/L).",
                organic: "Sulfur spray or potassium bicarbonate.",
                hygiene: "Rake and destroy fallen leaves to reduce overwintering.",
                isHealthy: false
            )
        } else if lbl.contains("rust") {
            return AgronomicAdvisory(
                status: "Rust pathology detected.",
                action: "Foliar application to halt pustule spore release.",
                chemical: "Tebuconazole (1.0 ml/L) or Azoxystrobin (0.8 ml/L).",
                organic: "Sulfur wettable powder or neem oil suspension.",
                hygiene: "Prune dense canopies to maximize air circulation.",
                isHealthy: false
            )
        } else if lbl.contains("powdery_mildew") {
            return AgronomicAdvisory(
                status: "Powdery Mildew detected.",
                action: "Contact foliar application on upper leaf surfaces.",
                chemical: "Potassium bicarbonate (3.0 g/L) or Trifloxystrobin.",
                organic: "Diluted milk spray (1:9) or cold-pressed neem oil (5 ml/L).",
                hygiene: "Avoid excessive shade; ensure adequate sun exposure and ventilation.",
                isHealthy: false
            )
        } else {
            return AgronomicAdvisory(
                status: "Foliar pathology identified.",
                action: "Apply targeted disease management protocol.",
                chemical: "Broad-spectrum protective fungicide (e.g. Copper Hydroxide 2.0 g/L).",
                organic: "Neem oil emulsion (5 mL/L) or biofungicide suspension.",
                hygiene: "Prune infected canopy areas; avoid overhead watering; improve ventilation.",
                isHealthy: false
            )
        }
    }
}
