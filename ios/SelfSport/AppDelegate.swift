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
            print("[AppDelegate] Notification auth status on launch: \(settings.authorizationStatus.rawValue)")
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                print("[AppDelegate] Already authorized — calling registerForRemoteNotifications()")
                application.registerForRemoteNotifications()
            case .notDetermined:
                print("[AppDelegate] Not determined — requesting authorization...")
                let granted = await NotificationService.shared.requestAuthorization()
                if granted {
                    print("[AppDelegate] Granted — calling registerForRemoteNotifications()")
                    application.registerForRemoteNotifications()
                }
            default:
                print("[AppDelegate] Auth status denied/restricted — NOT registering for push")
            }
        }
        return true
    }

    nonisolated func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[AppDelegate] ✅ didRegisterForRemoteNotificationsWithDeviceToken: \(token.prefix(20))...")
        Task { @MainActor in
            NotificationService.shared.setDeviceToken(token)
            await SupabaseTokenService.shared.syncAPNsTokenToDB()
        }
    }

    nonisolated func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[AppDelegate] ❌ didFailToRegisterForRemoteNotifications: \(error.localizedDescription)")
        print("[AppDelegate] ❌ NSError domain=\((error as NSError).domain) code=\((error as NSError).code)")
        Task { @MainActor in
            NotificationService.shared.setRegistrationError(error)
        }
    }
}
