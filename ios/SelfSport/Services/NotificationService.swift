import UserNotifications
import UIKit

@Observable
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    var isAuthorized: Bool = false
    private static let apnsTokenKey = "saved_apns_device_token"
    private(set) var deviceToken: String?

    func loadPersistedToken() {
        if let saved = UserDefaults.standard.string(forKey: Self.apnsTokenKey), !saved.isEmpty {
            deviceToken = saved
            print("[APNs] Loaded persisted token from UserDefaults: \(saved.prefix(16))...")
        } else {
            print("[APNs] No persisted token in UserDefaults")
        }
    }

    func setDeviceToken(_ token: String) {
        deviceToken = token
        UserDefaults.standard.set(token, forKey: Self.apnsTokenKey)
        UserDefaults.standard.synchronize()
        print("[APNs] Token saved to memory + UserDefaults: \(token.prefix(16))...")
    }

    func resolvedToken() -> String? {
        if let t = deviceToken, !t.isEmpty { return t }
        if let t = UserDefaults.standard.string(forKey: Self.apnsTokenKey), !t.isEmpty { return t }
        return nil
    }
    var hasBeenPrompted: Bool {
        get { UserDefaults.standard.bool(forKey: "notifications_prompted") }
        set { UserDefaults.standard.set(newValue, forKey: "notifications_prompted") }
    }

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        loadPersistedToken()
        Task { await refreshAuthorizationStatus() }
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            hasBeenPrompted = true
            if granted {
                await UIApplication.shared.registerForRemoteNotifications()
            }
            return granted
        } catch {
            hasBeenPrompted = true
            return false
        }
    }

    func scheduleLocalNotification(
        title: String,
        body: String,
        identifier: String = UUID().uuidString,
        delay: TimeInterval = 0,
        badge: NSNumber? = nil
    ) async {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        if let badge { content.badge = badge }

        let trigger: UNNotificationTrigger?
        if delay > 0 {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        } else {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        }

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
        }
    }

    func removeNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func removeAllPending() {
        center.removeAllPendingNotificationRequests()
    }

    var shouldShowPermissionPrompt: Bool {
        !hasBeenPrompted && !isAuthorized
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
    }
}
