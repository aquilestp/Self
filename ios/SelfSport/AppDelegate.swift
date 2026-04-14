import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    nonisolated func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Task { @MainActor in
            UNUserNotificationCenter.current().delegate = NotificationService.shared
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            print("[AppDelegate] 🚀 Launch — notification auth status: \(settings.authorizationStatus.rawValue)")
            print("[AppDelegate] 🚀 Existing APNs token in memory: \(NotificationService.shared.deviceToken?.prefix(16).description ?? "NIL")")
            print("[AppDelegate] 🚀 Existing APNs token in UserDefaults: \(UserDefaults.standard.string(forKey: "saved_apns_device_token")?.prefix(16).description ?? "NIL")")
            
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                print("[AppDelegate] ✅ Already authorized — registering for remote notifications NOW")
                application.registerForRemoteNotifications()
            case .notDetermined:
                print("[AppDelegate] ❓ Not determined — requesting authorization...")
                let granted = await NotificationService.shared.requestAuthorization()
                if granted {
                    print("[AppDelegate] ✅ Granted — registering for remote notifications NOW")
                    application.registerForRemoteNotifications()
                } else {
                    print("[AppDelegate] ❌ Authorization denied by user")
                }
            default:
                print("[AppDelegate] ⛔ Auth status denied/restricted (\(settings.authorizationStatus.rawValue)) — NOT registering")
            }
        }
        return true
    }

    nonisolated func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[AppDelegate] ✅✅✅ didRegisterForRemoteNotificationsWithDeviceToken: \(token.prefix(20))...")
        print("[AppDelegate] ✅✅✅ FULL TOKEN LENGTH: \(token.count) chars")
        Task { @MainActor in
            NotificationService.shared.setDeviceToken(token)
        }
    }

    nonisolated func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        let nsError = error as NSError
        print("[AppDelegate] ❌❌❌ didFailToRegisterForRemoteNotifications")
        print("[AppDelegate] ❌❌❌ Error: \(error.localizedDescription)")
        print("[AppDelegate] ❌❌❌ Domain: \(nsError.domain), Code: \(nsError.code)")
        print("[AppDelegate] ❌❌❌ Full error: \(nsError)")
        Task { @MainActor in
            NotificationService.shared.setRegistrationError(error)
        }
    }
}
