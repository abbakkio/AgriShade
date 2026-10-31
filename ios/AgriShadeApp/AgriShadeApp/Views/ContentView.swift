import SwiftUI

public struct ContentView: View {
    @StateObject private var diagnosticService = FoliarDiagnosticService()
    @State private var selectedImage: UIImage? = nil
    @State private var activePicker: ActiveMediaPicker? = nil

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Cell 6 Diagnostic Dashboard replaces basic preview when analysis is available
                    if let cell6 = diagnosticService.cell6Output,
                       let report = diagnosticService.currentReport {
                        Cell6DiagnosticDashboard(
                            output: cell6,
                            topLabel: report.topCandidate.rawLabel,
                            topConf: report.topCandidate.probability * 100.0,
                            isGated: report.isGated
                        )
                        .padding(.horizontal)
                    } else {
                        // Initial Photo Placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.secondarySystemBackground))
                                .frame(height: 300)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: selectedImage == nil ? [6] : []))
                                        .foregroundColor(Color.secondary.opacity(0.3))
                                )

                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 300)
                                    .cornerRadius(20)
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 48))
                                        .foregroundColor(.green)

                                    Text("Capture or Upload Leaf Specimen")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text("AgriShade AI runs 4-stage pathology diagnostics: Sensor Frame, Foliar Crop, CLAHE, and Lesion Heatmap.")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 24)
                                }
                            }

                            if diagnosticService.isAnalyzing {
                                ZStack {
                                    Color.black.opacity(0.4)
                                        .cornerRadius(20)

                                    VStack(spacing: 10) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(1.4)
                                        Text("Running Cell 6 Pathology Pipeline on ANE...")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Action Buttons (Take Photo & Gallery)
                    HStack(spacing: 16) {
                        Button {
                            activePicker = .camera
                        } label: {
                            Label("Take Photo", systemImage: "camera.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }

                        Button {
                            activePicker = .photoLibrary
                        } label: {
                            Label("Gallery", systemImage: "photo.on.rectangle.angled")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.tertiarySystemBackground))
                                .foregroundColor(.primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal)

                    // Error Message
                    if let err = diagnosticService.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(err)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                    }

                    // Diagnostic Report Card (Confidence 0..100%, Agronomic Advisory)
                    if let report = diagnosticService.currentReport {
                        DiagnosticReportCard(report: report)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("AgriShade Pathology")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedImage != nil || diagnosticService.cell6Output != nil {
                        Button("Clear") {
                            selectedImage = nil
                            diagnosticService.currentReport = nil
                            diagnosticService.cell6Output = nil
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(item: $activePicker) { picker in
                switch picker {
                case .camera:
                    CameraPicker(selectedImage: $selectedImage)
                case .photoLibrary:
                    ModernPhotoPicker(selectedImage: $selectedImage)
                }
            }
            .onChange(of: selectedImage) { newImg in
                if let img = newImg {
                    Task {
                        await diagnosticService.analyze(image: img)
                    }
                }
            }
        }
    }
}
