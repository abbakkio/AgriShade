import SwiftUI

public struct CloudSyncSheet: View {
    @ObservedObject var syncService: CloudSyncService
    @Environment(\.dismiss) private var dismiss

    // Auth Form State
    @State private var authMode: AuthMode = .login
    @State private var usernameInput: String = ""
    @State private var emailInput: String = ""
    @State private var fullNameInput: String = ""
    @State private var passwordInput: String = ""
    @State private var isSubmitting: Bool = false
    @State private var authFeedbackMessage: String? = nil
    @State private var authFeedbackIsError: Bool = false

    // Collapsed developer toggle
    @State private var showDevSettings: Bool = false

    public enum AuthMode: String, CaseIterable, Identifiable {
        case login = "Log In"
        case register = "Sign Up"
        public var id: String { rawValue }
    }

    public init(syncService: CloudSyncService = .shared) {
        self.syncService = syncService
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if syncService.isLoggedIn, let user = syncService.currentUser {
                        // =====================================================
                        // 1. LOGGED IN STATE: CLEAN PROFILE & SYNC STATUS
                        // =====================================================
                        VStack(spacing: 18) {
                            // Avatar & Name
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.15))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.green)
                            }

                            VStack(spacing: 4) {
                                Text(user.fullName)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)

                                Text("@\(user.username) • \(user.email)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Text("Cloud Connected")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                }
                                .padding(.top, 4)
                            }

                            Divider()

                            // Sync Status Card
                            HStack(spacing: 14) {
                                StatusStatBox(
                                    title: "On Device",
                                    value: "\(syncService.pendingCount)",
                                    subtitle: syncService.pendingCount > 0 ? "Pending Upload" : "All Synced",
                                    color: syncService.pendingCount > 0 ? .orange : .secondary
                                )

                                StatusStatBox(
                                    title: "In Cloud",
                                    value: "\(syncService.syncedCount)",
                                    subtitle: "Securely Synced",
                                    color: .green
                                )
                            }

                            // Sync Action Button
                            Button {
                                Task {
                                    await syncService.syncPendingScans()
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    if syncService.isSyncing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 6)
                                        Text("Syncing to Cloud...")
                                            .font(.headline)
                                    } else {
                                        Image(systemName: syncService.pendingCount > 0 ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill")
                                        Text(syncService.pendingCount > 0 ? "Sync Now (\(syncService.pendingCount))" : "All Data Synced")
                                            .font(.headline)
                                    }
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 14)
                                .background(syncService.pendingCount > 0 ? Color.green : Color.secondary.opacity(0.4))
                                .cornerRadius(14)
                            }
                            .buttonStyle(.plain)
                            .disabled(syncService.pendingCount == 0 || syncService.isSyncing)

                            if let msg = syncService.lastSyncMessage {
                                Text(msg)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            if let err = syncService.lastSyncError {
                                HStack(alignment: .top, spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text(err)
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(10)
                                .background(Color.orange.opacity(0.12))
                                .cornerRadius(10)
                            }

                            // Logout Button
                            Button(role: .destructive) {
                                syncService.logout()
                            } label: {
                                Text("Sign Out")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .padding(.top, 6)
                            }
                        }
                        .padding(20)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(20)

                    } else {
                        // =====================================================
                        // 2. GUEST STATE: OPTIONAL LOGIN / REGISTRATION
                        // =====================================================
                        VStack(spacing: 16) {
                            // Friendly Header
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.12))
                                    .frame(width: 64, height: 64)
                                Image(systemName: "icloud.and.arrow.up.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.green)
                            }

                            VStack(spacing: 6) {
                                Text("Cloud Backup & Sync")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)

                                Text("Sign in to securely backup crop photos and field inspection history in the cloud.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 10)
                            }

                            // Segmented Switcher (Log In / Sign Up)
                            Picker("Mode", selection: $authMode) {
                                ForEach(AuthMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.vertical, 4)

                            // Form Fields
                            VStack(spacing: 12) {
                                if authMode == .register {
                                    TextField("Full Name", text: $fullNameInput)
                                        .textContentType(.name)
                                        .padding(12)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(10)

                                    TextField("Email Address", text: $emailInput)
                                        .textContentType(.emailAddress)
                                        .keyboardType(.emailAddress)
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.never)
                                        .padding(12)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(10)
                                }

                                TextField("Username", text: $usernameInput)
                                    .textContentType(.username)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)

                                SecureField("Password", text: $passwordInput)
                                    .textContentType(authMode == .login ? .password : .newPassword)
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                            }

                            // Feedback message
                            if let fb = authFeedbackMessage {
                                Text(fb)
                                    .font(.caption)
                                    .foregroundColor(authFeedbackIsError ? .red : .green)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                            }

                            // Submit Button
                            Button {
                                handleAuthSubmit()
                            } label: {
                                HStack {
                                    Spacer()
                                    if isSubmitting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 6)
                                    }
                                    Text(authMode == .login ? "Log In" : "Create Account")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 14)
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            .disabled(isSubmitting || usernameInput.isEmpty || passwordInput.isEmpty)

                            // Gentle Disclaimer (No pressure)
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Sign-in is optional. Real-time camera inference and disease detection run 100% on-device without internet or registration.")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)
                            }
                            .padding(.top, 4)
                        }
                        .padding(20)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(20)
                    }

                    // =========================================================
                    // 3. COLLAPSED DEVELOPER SETTINGS (Hidden from normal farmers)
                    // =========================================================
                    DisclosureGroup(isExpanded: $showDevSettings) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Server: \(syncService.backendURL)")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            HStack(spacing: 8) {
                                Button("Render Cloud") {
                                    syncService.backendURL = "https://agrishade.onrender.com"
                                }
                                .font(.caption2)
                                .buttonStyle(.bordered)

                                Button("Mac Local (Wi-Fi)") {
                                    syncService.backendURL = "http://192.168.0.181:8000"
                                }
                                .font(.caption2)
                                .buttonStyle(.bordered)
                            }

                            Text("Device: \(syncService.deviceSerial)")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            HStack {
                                Button("Reset to Defaults") {
                                    syncService.resetToDefaults()
                                }
                                .font(.caption2)
                                .foregroundColor(.red)

                                Spacer()

                                Button("Clear Synced Scans") {
                                    syncService.clearSynced()
                                }
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 6)
                    } label: {
                        Text("Developer Settings")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                }
                .padding()
            }
            .navigationTitle("Cloud & Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func handleAuthSubmit() {
        guard !usernameInput.isEmpty, !passwordInput.isEmpty else { return }
        isSubmitting = true
        authFeedbackMessage = nil

        Task {
            if authMode == .login {
                let res = await syncService.login(username: usernameInput, password: passwordInput)
                isSubmitting = false
                authFeedbackMessage = res.message
                authFeedbackIsError = !res.success
                if res.success {
                    // Auto dismiss on successful login after brief pause
                    try? await Task.sleep(nanoseconds: 600_000_000)
                    dismiss()
                }
            } else {
                let res = await syncService.register(
                    username: usernameInput,
                    email: emailInput,
                    password: passwordInput,
                    fullName: fullNameInput.isEmpty ? usernameInput : fullNameInput
                )
                isSubmitting = false
                authFeedbackMessage = res.message
                authFeedbackIsError = !res.success
                if res.success {
                    try? await Task.sleep(nanoseconds: 600_000_000)
                    dismiss()
                }
            }
        }
    }
}

private struct StatusStatBox: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
