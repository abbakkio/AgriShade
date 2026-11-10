import Foundation
import UIKit
import CryptoKit

// =============================================================================
// DATA MODELS FOR EDGE STORE-AND-FORWARD TELEMETRY SYNC
// =============================================================================

public struct BufferedScan: Identifiable, Codable, Sendable {
    public let id: UUID
    public let scanUUID: String
    public let cropType: String
    public let diseaseLabel: String
    public let confidenceScore: Double
    public let severityLevel: String
    public let latitude: Double
    public let longitude: Double
    public let capturedAt: Date
    public let imageSHA256: String
    public var synced: Bool
    public var syncedAt: Date?
    public var errorMessage: String?

    public init(
        id: UUID = UUID(),
        scanUUID: String = UUID().uuidString.lowercased(),
        cropType: String,
        diseaseLabel: String,
        confidenceScore: Double,
        severityLevel: String,
        latitude: Double,
        longitude: Double,
        capturedAt: Date = Date(),
        imageSHA256: String,
        synced: Bool = false,
        syncedAt: Date? = nil,
        errorMessage: String? = nil
    ) {
        self.id = id
        self.scanUUID = scanUUID
        self.cropType = cropType
        self.diseaseLabel = diseaseLabel
        self.confidenceScore = confidenceScore
        self.severityLevel = severityLevel
        self.latitude = latitude
        self.longitude = longitude
        self.capturedAt = capturedAt
        self.imageSHA256 = imageSHA256
        self.synced = synced
        self.syncedAt = syncedAt
        self.errorMessage = errorMessage
    }
}

public struct ServerHealthInfo: Sendable {
    public let isReachable: Bool
    public let latencyMs: Int
    public let statusMessage: String
    public let databaseInfo: String?
    public let deviceCount: Int?
    public let scanCount: Int?
}

// =============================================================================
// OPTIONAL CLOUD USER SESSION
// =============================================================================

public struct AuthUser: Codable, Sendable, Identifiable {
    public let id: Int
    public let username: String
    public let email: String
    public let fullName: String
    public let role: String

    public init(id: Int, username: String, email: String, fullName: String, role: String) {
        self.id = id
        self.username = username
        self.email = email
        self.fullName = fullName
        self.role = role
    }

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case fullName = "full_name"
        case role
    }
}

private struct LoginResponsePayload: Decodable {
    let accessToken: String
    let user: AuthUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

// =============================================================================
// CLOUD SYNC SERVICE (OFFLINE-FIRST STORE & FORWARD)
// =============================================================================

@MainActor
public final class CloudSyncService: ObservableObject {
    public static let shared = CloudSyncService()

    // MARK: - Published Properties
    @Published public private(set) var bufferedScans: [BufferedScan] = []
    @Published public private(set) var isSyncing: Bool = false
    @Published public private(set) var isCheckingHealth: Bool = false
    @Published public private(set) var lastHealthStatus: ServerHealthInfo? = nil
    @Published public private(set) var lastSyncMessage: String? = nil
    @Published public private(set) var lastSyncError: String? = nil

    // MARK: - Optional User Session
    @Published public private(set) var currentUser: AuthUser? = nil
    @Published public private(set) var authToken: String? = nil

    public var isLoggedIn: Bool {
        currentUser != nil && authToken != nil
    }

    // MARK: - Configuration (Stored in UserDefaults)
    @Published public var backendURL: String {
        didSet {
            UserDefaults.standard.set(backendURL, forKey: "agri_backend_url")
        }
    }

    @Published public var deviceSerial: String {
        didSet {
            UserDefaults.standard.set(deviceSerial, forKey: "agri_device_serial")
        }
    }

    @Published public var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "agri_api_key")
        }
    }

    @Published public var autoSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoSyncEnabled, forKey: "agri_auto_sync")
        }
    }

    public var pendingCount: Int {
        bufferedScans.filter { !$0.synced }.count
    }

    public var syncedCount: Int {
        bufferedScans.filter { $0.synced }.count
    }

    // Default Zhambyl pilot coordinates (Taraz sector)
    nonisolated public static let defaultLatitude: Double = 42.9006
    nonisolated public static let defaultLongitude: Double = 71.3789

    // Storage file URL
    private let storageURL: URL

    // MARK: - Initialization
    public init() {
        // Load settings or set defaults
        let savedURL = UserDefaults.standard.string(forKey: "agri_backend_url")
        self.backendURL = (savedURL?.isEmpty == false) ? savedURL! : "https://agrishade.onrender.com"

        let savedSerial = UserDefaults.standard.string(forKey: "agri_device_serial")
        self.deviceSerial = (savedSerial?.isEmpty == false) ? savedSerial! : "AGRI-EDGE-ZHA-007"

        let savedKey = UserDefaults.standard.string(forKey: "agri_api_key")
        self.apiKey = (savedKey?.isEmpty == false) ? savedKey! : "zha_key_007_secret"

        if UserDefaults.standard.object(forKey: "agri_auto_sync") != nil {
            self.autoSyncEnabled = UserDefaults.standard.bool(forKey: "agri_auto_sync")
        } else {
            self.autoSyncEnabled = true
        }

        // Load optional authenticated user session
        self.authToken = UserDefaults.standard.string(forKey: "agri_auth_token")
        if let userData = UserDefaults.standard.data(forKey: "agri_auth_user"),
           let user = try? JSONDecoder().decode(AuthUser.self, from: userData) {
            self.currentUser = user
        }

        // Setup persistent storage URL
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        try? fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true)
        self.storageURL = appSupport.appendingPathComponent("buffered_edge_scans.json")

        loadFromDisk()
    }

    // MARK: - Local Persistence
    private func loadFromDisk() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let loaded = try decoder.decode([BufferedScan].self, from: data)
            self.bufferedScans = loaded
        } catch {
            print("[CloudSyncService] Failed to load buffer from disk: \(error)")
        }
    }

    private func saveToDisk() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(bufferedScans)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            print("[CloudSyncService] Failed to save buffer to disk: \(error)")
        }
    }

    // MARK: - Health Check
    public func checkServerHealth() async -> ServerHealthInfo {
        isCheckingHealth = true
        let startTime = CFAbsoluteTimeGetCurrent()

        let cleanURL = backendURL.trimmingCharacters(in: CharacterSet(charactersIn: "/ "))
        guard let url = URL(string: "\(cleanURL)/health") else {
            let info = ServerHealthInfo(
                isReachable: false,
                latencyMs: 0,
                statusMessage: "Invalid server URL",
                databaseInfo: nil,
                deviceCount: nil,
                scanCount: nil
            )
            self.lastHealthStatus = info
            self.isCheckingHealth = false
            return info
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8.0

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - startTime) * 1000)

            guard let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200 else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                let info = ServerHealthInfo(
                    isReachable: false,
                    latencyMs: elapsed,
                    statusMessage: "HTTP \(code)",
                    databaseInfo: nil,
                    deviceCount: nil,
                    scanCount: nil
                )
                self.lastHealthStatus = info
                self.isCheckingHealth = false
                return info
            }

            // Parse health JSON
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let status = json["status"] as? String ?? "OK"
                let db = json["database"] as? String
                let entities = json["entities"] as? [String: Any]
                let devices = entities?["devices"] as? Int
                let scans = entities?["scans"] as? Int

                let info = ServerHealthInfo(
                    isReachable: true,
                    latencyMs: elapsed,
                    statusMessage: "Online (\(status))",
                    databaseInfo: db,
                    deviceCount: devices,
                    scanCount: scans
                )
                self.lastHealthStatus = info
                self.isCheckingHealth = false
                return info
            }

            let info = ServerHealthInfo(
                isReachable: true,
                latencyMs: elapsed,
                statusMessage: "Online",
                databaseInfo: nil,
                deviceCount: nil,
                scanCount: nil
            )
            self.lastHealthStatus = info
            self.isCheckingHealth = false
            return info
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - startTime) * 1000)
            let info = ServerHealthInfo(
                isReachable: false,
                latencyMs: elapsed,
                statusMessage: error.localizedDescription,
                databaseInfo: nil,
                deviceCount: nil,
                scanCount: nil
            )
            self.lastHealthStatus = info
            self.isCheckingHealth = false
            return info
        }
    }

    // MARK: - Enqueue In-Field Diagnostic Scan
    public func enqueue(
        report: PathologyReport,
        image: UIImage?,
        latitude: Double = defaultLatitude,
        longitude: Double = defaultLongitude
    ) {
        // Compute SHA-256 hash of image data (or fallback)
        let sha256Hex: String
        if let img = image, let jpeg = img.jpegData(compressionQuality: 0.85) {
            let digest = SHA256.hash(data: jpeg)
            sha256Hex = digest.map { String(format: "%02x", $0) }.joined()
        } else {
            let uuidData = Data(report.topCandidate.rawLabel.utf8)
            let digest = SHA256.hash(data: uuidData)
            sha256Hex = digest.map { String(format: "%02x", $0) }.joined()
        }

        // Determine severity level matching backend validator:
        // {"Healthy", "Low", "Moderate", "Severe", "Critical"}
        let severity: String
        let diseaseLow = report.topCandidate.diseaseName.lowercased()
        let prob = report.topCandidate.probability

        if report.advisory.isHealthy || diseaseLow.contains("healthy") {
            severity = "Healthy"
        } else if prob >= 0.85 && (diseaseLow.contains("blight") || diseaseLow.contains("rot") || diseaseLow.contains("virus")) {
            severity = "Critical"
        } else if prob >= 0.70 {
            severity = "Severe"
        } else if prob >= 0.50 {
            severity = "Moderate"
        } else {
            severity = "Low"
        }

        let newScan = BufferedScan(
            cropType: report.topCandidate.cropName,
            diseaseLabel: report.topCandidate.diseaseName,
            confidenceScore: prob,
            severityLevel: severity,
            latitude: latitude,
            longitude: longitude,
            capturedAt: report.timestamp,
            imageSHA256: sha256Hex,
            synced: false
        )

        bufferedScans.insert(newScan, at: 0)
        saveToDisk()

        if autoSyncEnabled {
            Task {
                await syncPendingScans()
            }
        }
    }

    // MARK: - Batch Sync Scans to Central FastAPI Backend
    @discardableResult
    public func syncPendingScans() async -> Bool {
        guard !isSyncing else { return false }
        let pending = bufferedScans.filter { !$0.synced }
        guard !pending.isEmpty else {
            lastSyncMessage = "No pending scans to sync."
            lastSyncError = nil
            return true
        }

        isSyncing = true
        lastSyncError = nil

        let cleanURL = backendURL.trimmingCharacters(in: CharacterSet(charactersIn: "/ "))
        guard let url = URL(string: "\(cleanURL)/api/v1/sync") else {
            lastSyncError = "Invalid Backend URL: \(backendURL)"
            isSyncing = false
            return false
        }

        // Prepare JSON payload matching SyncBatchRequest schema
        var scansPayload: [[String: Any]] = []
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        for scan in pending {
            let item: [String: Any] = [
                "scan_uuid": scan.scanUUID,
                "crop_type": scan.cropType,
                "disease_label": scan.diseaseLabel,
                "confidence_score": scan.confidenceScore,
                "severity_level": scan.severityLevel,
                "latitude": scan.latitude,
                "longitude": scan.longitude,
                "captured_at": isoFormatter.string(from: scan.capturedAt),
                "image_sha256": scan.imageSHA256
            ]
            scansPayload.append(item)
        }

        let bodyPayload: [String: Any] = [
            "device_serial": deviceSerial,
            "scans": scansPayload
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: bodyPayload) else {
            lastSyncError = "Failed to serialize telemetry JSON payload."
            isSyncing = false
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceSerial, forHTTPHeaderField: "X-Device-Serial")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = httpBody
        request.timeoutInterval = 15.0

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResp = response as? HTTPURLResponse else {
                lastSyncError = "Non-HTTP response received from server."
                isSyncing = false
                return false
            }

            if httpResp.statusCode == 200 {
                // Success: parse synced UUIDs
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let syncedUUIDs = json["synced_uuids"] as? [String] {
                    let syncedSet = Set(syncedUUIDs)
                    let now = Date()

                    for idx in bufferedScans.indices {
                        if syncedSet.contains(bufferedScans[idx].scanUUID) {
                            bufferedScans[idx].synced = true
                            bufferedScans[idx].syncedAt = now
                            bufferedScans[idx].errorMessage = nil
                        }
                    }

                    saveToDisk()
                    lastSyncMessage = "Successfully synced \(syncedUUIDs.count) scan(s) to cloud."
                    lastSyncError = nil
                    isSyncing = false
                    return true
                } else {
                    // Fallback if synced_uuids format was slightly different but 200
                    let now = Date()
                    for idx in bufferedScans.indices {
                        if !bufferedScans[idx].synced {
                            bufferedScans[idx].synced = true
                            bufferedScans[idx].syncedAt = now
                            bufferedScans[idx].errorMessage = nil
                        }
                    }
                    saveToDisk()
                    lastSyncMessage = "Batch accepted by server (200 OK)."
                    lastSyncError = nil
                    isSyncing = false
                    return true
                }
            } else {
                // Parse error detail from FastAPI
                var detailMsg = "HTTP \(httpResp.statusCode)"
                if let errJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let detail = errJson["detail"] as? String {
                    detailMsg = detail
                }

                // If unauthorized because device isn't seeded yet on remote
                if httpResp.statusCode == 401 && detailMsg.contains("unrecognized") {
                    detailMsg += "\n(Tip: Run database seed or verify X-Device-Serial matches backend registered devices)."
                }

                lastSyncError = detailMsg
                // Record error on the pending items
                for idx in bufferedScans.indices where !bufferedScans[idx].synced {
                    bufferedScans[idx].errorMessage = detailMsg
                }
                saveToDisk()
                isSyncing = false
                return false
            }
        } catch {
            let errStr = "Network connection failed: \(error.localizedDescription)"
            lastSyncError = errStr
            for idx in bufferedScans.indices where !bufferedScans[idx].synced {
                bufferedScans[idx].errorMessage = errStr
            }
            saveToDisk()
            isSyncing = false
            return false
        }
    }

    // MARK: - Queue Management
    public func clearSynced() {
        bufferedScans.removeAll { $0.synced }
        saveToDisk()
    }

    public func removeScan(id: UUID) {
        bufferedScans.removeAll { $0.id == id }
        saveToDisk()
    }

    public func addDemoScan(crop: String = "Tomato", disease: String = "Tomato Early Blight", severity: String = "Severe", conf: Double = 0.942) {
        let demoHash = "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"
        let scan = BufferedScan(
            cropType: crop,
            diseaseLabel: disease,
            confidenceScore: conf,
            severityLevel: severity,
            latitude: CloudSyncService.defaultLatitude,
            longitude: CloudSyncService.defaultLongitude,
            capturedAt: Date(),
            imageSHA256: demoHash,
            synced: false
        )
        bufferedScans.insert(scan, at: 0)
        saveToDisk()
        if autoSyncEnabled {
            Task {
                await syncPendingScans()
            }
        }
    }

    public func resetToDefaults() {
        backendURL = "https://agrishade.onrender.com"
        deviceSerial = "AGRI-EDGE-ZHA-007"
        apiKey = "zha_key_007_secret"
        autoSyncEnabled = true
    }

    // MARK: - Optional Cloud Account Authentication
    public func login(username: String, password: String) async -> (success: Bool, message: String) {
        let cleanURL = backendURL.trimmingCharacters(in: CharacterSet(charactersIn: "/ "))
        guard let url = URL(string: "\(cleanURL)/api/v1/auth/login") else {
            return (false, "Неверный адрес сервера")
        }

        let body: [String: Any] = ["username": username.trimmingCharacters(in: .whitespacesAndNewlines), "password": password]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            return (false, "Ошибка создания запроса")
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = httpBody
        req.timeoutInterval = 10.0

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let httpResp = resp as? HTTPURLResponse else {
                return (false, "Сервер не отвечает")
            }

            if httpResp.statusCode == 200 {
                let decoder = JSONDecoder()
                if let loginResp = try? decoder.decode(LoginResponsePayload.self, from: data) {
                    self.authToken = loginResp.accessToken
                    self.currentUser = loginResp.user
                    UserDefaults.standard.set(loginResp.accessToken, forKey: "agri_auth_token")
                    if let userEncoded = try? JSONEncoder().encode(loginResp.user) {
                        UserDefaults.standard.set(userEncoded, forKey: "agri_auth_user")
                    }
                    // Trigger sync now that user is authenticated
                    Task {
                        await syncPendingScans()
                    }
                    return (true, "Добро пожаловать, \(loginResp.user.fullName)!")
                }
            }

            // Extract error message
            if let errJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = errJson["detail"] as? String {
                if detail.lowercased().contains("invalid") {
                    return (false, "Неверный логин или пароль")
                }
                return (false, detail)
            }
            return (false, "Ошибка входа (код \(httpResp.statusCode))")
        } catch {
            return (false, "Не удалось подключиться к серверу. Проверьте интернет.")
        }
    }

    public func register(username: String, email: String, password: String, fullName: String) async -> (success: Bool, message: String) {
        let cleanURL = backendURL.trimmingCharacters(in: CharacterSet(charactersIn: "/ "))
        guard let url = URL(string: "\(cleanURL)/api/v1/auth/register") else {
            return (false, "Неверный адрес сервера")
        }

        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard cleanUsername.count >= 3 else {
            return (false, "Логин должен быть не короче 3 символов")
        }
        guard password.count >= 6 else {
            return (false, "Пароль должен быть не короче 6 символов")
        }

        let body: [String: Any] = [
            "username": cleanUsername,
            "email": cleanEmail.isEmpty ? "\(cleanUsername)@agrishade.kz" : cleanEmail,
            "password": password,
            "full_name": cleanName.isEmpty ? cleanUsername : cleanName,
            "role": "agronomist"
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            return (false, "Ошибка формирования данных")
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = httpBody
        req.timeoutInterval = 10.0

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let httpResp = resp as? HTTPURLResponse else {
                return (false, "Сервер не отвечает")
            }

            if httpResp.statusCode == 201 || httpResp.statusCode == 200 {
                // Auto-login upon successful registration
                return await login(username: cleanUsername, password: password)
            }

            if let errJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = errJson["detail"] as? String {
                if detail.contains("already exists") {
                    return (false, "Пользователь с таким логином уже существует")
                }
                return (false, detail)
            }
            return (false, "Не удалось создать аккаунт (код \(httpResp.statusCode))")
        } catch {
            return (false, "Не удалось подключиться к серверу. Проверьте интернет.")
        }
    }

    public func logout() {
        self.authToken = nil
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: "agri_auth_token")
        UserDefaults.standard.removeObject(forKey: "agri_auth_user")
    }
}
