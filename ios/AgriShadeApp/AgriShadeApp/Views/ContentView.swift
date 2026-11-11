import SwiftUI

public struct ContentView: View {
    @StateObject private var diagnosticService = FoliarDiagnosticService()
    @ObservedObject private var syncService: CloudSyncService = .shared
    @State private var selectedImage: UIImage? = nil
    @State private var activePicker: ActiveMediaPicker? = nil
    @State private var showSyncSheet: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    // =========================================================
                    // 1. SIMPLE, ELEGANT CLOUD STATUS BANNER (No tech jargon)
                    // =========================================================
                    Button {
                        showSyncSheet = true
                    } label: {
                        HStack(spacing: 12) {
                            if syncService.isLoggedIn {
                                Image(systemName: "checkmark.icloud.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Cloud: \(syncService.currentUser?.fullName ?? "Connected")")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)

                                    Text(syncService.pendingCount > 0 ? "\(syncService.pendingCount) scan(s) pending upload" : "All results saved to cloud")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Image(systemName: "icloud")
                                    .font(.title2)
                                    .foregroundColor(.blue)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Offline Mode")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)

                                    Text("Data saved on device. Tap to sign in to cloud.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            if syncService.isLoggedIn && syncService.pendingCount > 0 {
                                Text("Sync Now")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.green)
                                    .clipShape(Capsule())
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(14)
                        .background(syncService.isLoggedIn ? Color.green.opacity(0.08) : Color(.secondarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(syncService.isLoggedIn ? Color.green.opacity(0.2) : Color.clear, lineWidth: 1)
                        )
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    // =========================================================
                    // 2. LEAF PHOTO SCANNER OR CELL 6 PATHOLOGY VIEW
                    // =========================================================
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
                        // Friendly Photo Placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.secondarySystemBackground))
                                .frame(height: 260)

                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 260)
                                    .cornerRadius(20)
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "leaf.circle.fill")
                                        .font(.system(size: 56))
                                        .foregroundColor(.green)

                                    Text("Foliar Disease Diagnostic")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text("Take a photo of a crop leaf to instantly identify foliar pathology and view calibrated chemical treatment protocols.")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 28)
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
                                        Text("Running diagnostic model...")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Action Buttons (Take Photo & Gallery)
                    HStack(spacing: 14) {
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
                            Label("From Gallery", systemImage: "photo.on.rectangle.angled")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.tertiarySystemBackground))
                                .foregroundColor(.primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                )
                                .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal)

                    // Error Message (if any)
                    if let err = diagnosticService.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(err)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                    }

                    // Diagnostic Report Card
                    if let report = diagnosticService.currentReport {
                        DiagnosticReportCard(report: report)
                            .padding(.horizontal)
                    }

                    // =========================================================
                    // 3. RECENT FIELD SCANS (Clean & Minimalist)
                    // =========================================================
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Scan History")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            if syncService.bufferedScans.isEmpty {
                                Button {
                                    syncService.addDemoScan()
                                } label: {
                                    Label("Sample Leaf", systemImage: "plus.circle")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                            }
                        }

                        if syncService.bufferedScans.isEmpty {
                            Text("No scan history yet. Take a photo or select a leaf from the gallery above.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(syncService.bufferedScans.prefix(4)) { scan in
                                    HStack(spacing: 12) {
                                        Image(systemName: scan.synced ? "checkmark.circle.fill" : "clock.fill")
                                            .foregroundColor(scan.synced ? .green : .orange)
                                            .font(.title3)

                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(spacing: 6) {
                                                Text(scan.cropType)
                                                    .font(.subheadline)
                                                    .fontWeight(.bold)
                                                Text("•")
                                                    .foregroundColor(.secondary)
                                                Text(scan.diseaseLabel)
                                                    .font(.subheadline)
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)
                                            }

                                            HStack(spacing: 8) {
                                                Text(friendlySeverity(scan.severityLevel))
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(severityColor(scan.severityLevel).opacity(0.15))
                                                    .foregroundColor(severityColor(scan.severityLevel))
                                                    .cornerRadius(4)

                                                Text(scan.capturedAt.formatted(date: .omitted, time: .shortened))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }

                                        Spacer()

                                        Text(scan.synced ? "In Cloud" : "On Device")
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundColor(scan.synced ? .green : .secondary)
                                    }
                                    .padding(12)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                }

                                if syncService.bufferedScans.count > 4 {
                                    Button {
                                        showSyncSheet = true
                                    } label: {
                                        Text("Show All (\(syncService.bufferedScans.count)) →")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.top, 4)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("AgriShade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Clear button on trailing if photo analyzed
                ToolbarItem(placement: .navigationBarLeading) {
                    if selectedImage != nil || diagnosticService.cell6Output != nil {
                        Button("Clear") {
                            selectedImage = nil
                            diagnosticService.currentReport = nil
                            diagnosticService.cell6Output = nil
                        }
                        .foregroundColor(.secondary)
                    }
                }

                // Profile / Login Button on Trailing
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSyncSheet = true
                    } label: {
                        if syncService.isLoggedIn, let user = syncService.currentUser {
                            HStack(spacing: 4) {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(.green)
                                Text(user.fullName.components(separatedBy: " ").first ?? user.username)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "person.circle")
                                Text("Log In")
                                    .font(.subheadline)
                            }
                        }
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
            .sheet(isPresented: $showSyncSheet) {
                CloudSyncSheet(syncService: syncService)
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

    private func friendlySeverity(_ severity: String) -> String {
        switch severity.lowercased() {
        case "healthy": return "Healthy"
        case "critical": return "Critical"
        case "severe": return "High Risk"
        case "moderate": return "Moderate"
        default: return "Low Risk"
        }
    }

    private func severityColor(_ severity: String) -> Color {
        switch severity.lowercased() {
        case "healthy": return .green
        case "critical": return .red
        case "severe": return .orange
        case "moderate": return .yellow
        default: return .blue
        }
    }
}
