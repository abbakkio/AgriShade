import SwiftUI

public struct DiagnosticReportCard: View {
    public let report: PathologyReport
    @State private var showFullAdvisory: Bool = true

    public var body: some View {
        VStack(spacing: 16) {
            // SCENARIO 1: Non-Leaf Object Detected
            if report.isNonLeafObject {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.metering.unknown")
                            .font(.title2)
                            .foregroundColor(.red)
                        Text("No Plant Leaf Detected")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }

                    Text("The specimen does not contain botanical foliar tissue. AgriShade only analyzes agricultural plant leaves.")
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Frame a single flat leaf blade covering >70% of the screen.")
                        Text("• Avoid capturing rooms, screens, desk surfaces, or people.")
                        Text("• Ensure daylight illumination on the leaf surface.")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.12))
                .cornerRadius(14)
            }
            // SCENARIO 2: Unsupported Ornamental / Non-Target Plant (Fixes Spider Plant / Ficus bug)
            else if report.isUnsupportedSpecies {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("Unsupported Botanical Species")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }

                    Text("This specimen does not match any of the 14 supported agricultural crop families. It appears to be an ornamental houseplant or wild flora.")
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Supported Crops: Apple, Blueberry, Cherry, Corn, Grape, Orange, Peach, Pepper, Potato, Raspberry, Soybean, Squash, Strawberry, Tomato.")
                        Text("• For houseplants (e.g. Spider Plant, Ficus, Peace Lily), consult botanical extension services.")
                        Text("• Chemical pesticide advice has been safely suppressed.")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(14)
            }
            // SCENARIO 3: Supported Agricultural Crop Detected
            else {
                // Header Diagnosis Badge
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(report.dominantCrop.uppercased())
                            .font(.caption)
                            .fontWeight(.heavy)
                            .foregroundColor(.secondary)

                        Text(report.topCandidate.diseaseName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text(report.dominantTaxon)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(report.topCandidate.percentageString)
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(confidenceColor)

                        Text(report.isGated ? "Uncertain" : "Confidence")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(confidenceColor.opacity(0.12))
                    .cornerRadius(10)
                }

                // Dual Metrology: Crop Match vs Pathology Certainty
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "leaf.circle.fill")
                            .foregroundColor(.green)
                        Text("Host Crop: \(report.cropMatch.cropName)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Text("Species Match: \(report.cropMatch.percentageString)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

                Divider()

                // Fail-safe Warning if Gated
                if report.isGated {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.shield.fill")
                                .foregroundColor(.orange)
                            Text("Fail-Safe Safety Lock Engaged")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }

                        Text("Specimen analysis indicated elevated uncertainty. Chemical advice is locked to avoid phytotoxicity.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(report.gatingReasons, id: \.self) { reason in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                Text(reason)
                                    .font(.caption2)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }

                // Top Candidates Breakdown
                VStack(alignment: .leading, spacing: 8) {
                    Text("Differential Hypotheses")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ForEach(report.candidates) { candidate in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(candidate.diseaseName)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                Text(candidate.cropName)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.2))
                                        .frame(height: 6)
                                    Capsule()
                                        .fill(Color.green)
                                        .frame(width: max(4, geo.size.width * CGFloat(candidate.probability)), height: 6)
                                }
                            }
                            .frame(width: 80, height: 6)

                            Text(candidate.percentageString)
                                .font(.caption)
                                .fontWeight(.bold)
                                .frame(width: 44, alignment: .trailing)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Agronomic Prescription Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: report.advisory.isHealthy ? "leaf.fill" : "cross.case.fill")
                            .foregroundColor(report.advisory.isHealthy ? .green : .red)
                        Text("Agronomic Prescription")
                            .font(.subheadline)
                            .fontWeight(.bold)

                        Spacer()

                        Button {
                            withAnimation { showFullAdvisory.toggle() }
                        } label: {
                            Image(systemName: showFullAdvisory ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if showFullAdvisory {
                        VStack(alignment: .leading, spacing: 8) {
                            PrescriptionRow(
                                icon: "bolt.heart.fill",
                                title: "Clinical Status",
                                text: report.advisory.status,
                                color: .blue
                            )

                            PrescriptionRow(
                                icon: "arrow.right.circle.fill",
                                title: "Immediate Action",
                                text: report.advisory.action,
                                color: .indigo
                            )

                            if !report.isGated {
                                PrescriptionRow(
                                    icon: "flask.fill",
                                    title: "Chemical Protocol",
                                    text: report.advisory.chemical,
                                    color: .red
                                )
                            }

                            PrescriptionRow(
                                icon: "drop.fill",
                                title: "Organic Remedy",
                                text: report.advisory.organic,
                                color: .green
                            )

                            PrescriptionRow(
                                icon: "hand.sparkles.fill",
                                title: "Canopy Hygiene",
                                text: report.advisory.hygiene,
                                color: .teal
                            )
                        }
                        .transition(.opacity)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    private var confidenceColor: Color {
        if report.isGated { return .orange }
        let conf = report.topCandidate.probability
        if conf >= 0.80 { return .green }
        if conf >= 0.65 { return .orange }
        return .red
    }
}

private struct PrescriptionRow: View {
    let icon: String
    let title: String
    let text: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundColor(color)
                .frame(width: 20)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Text(text)
                    .font(.footnote)
                    .foregroundColor(.primary)
            }
        }
    }
}
