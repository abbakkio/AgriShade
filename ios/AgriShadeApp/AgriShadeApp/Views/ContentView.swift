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
                                    Text("Облако: \(syncService.currentUser?.fullName ?? "Подключено")")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)

                                    Text(syncService.pendingCount > 0 ? "\(syncService.pendingCount) сканов ожидает отправки" : "Все результаты сохранены в облаке")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Image(systemName: "icloud")
                                    .font(.title2)
                                    .foregroundColor(.blue)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Локальный режим")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)

                                    Text("Данные на телефоне. Нажмите для входа в облако.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            if syncService.isLoggedIn && syncService.pendingCount > 0 {
                                Text("Синхронизировать")
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

                                    Text("Проверка здоровья листа")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text("Сфотографируйте лист растения, чтобы мгновенно определить болезнь и получить рекомендации по лечению.")
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
                                        Text("Определение диагноза...")
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
                            Label("Сделать фото", systemImage: "camera.fill")
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
                            Label("Из галереи", systemImage: "photo.on.rectangle.angled")
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
                            Text("История проверок")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            if syncService.bufferedScans.isEmpty {
                                Button {
                                    syncService.addDemoScan()
                                } label: {
                                    Label("Пример листа", systemImage: "plus.circle")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                            }
                        }

                        if syncService.bufferedScans.isEmpty {
                            Text("История пуста. Сделайте фото или выберите лист из галереи выше.")
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

                                        Text(scan.synced ? "В облаке" : "На телефоне")
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
                                        Text("Показать все (\(syncService.bufferedScans.count)) →")
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
                        Button("Очистить") {
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
                                Text("Войти")
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
        case "healthy": return "В норме"
        case "critical": return "Опасно"
        case "severe": return "Высокий риск"
        case "moderate": return "Средний"
        default: return "Низкий"
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
