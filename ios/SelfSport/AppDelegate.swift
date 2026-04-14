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
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                application.registerForRemoteNotifications()
            case .notDetermined:
                let granted = await NotificationService.shared.requestAuthorization()
                if granted {
                    application.registerForRemoteNotifications()
                }
            default:
                break
            }
        }
        return true
    }

    nonisolated func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[APNs] Device token registered: \(token.prefix(16))...")
        Task { @MainActor in
            NotificationService.shared.setDeviceToken(token)
            print("[APNs] Syncing token to Supabase...")
            await SupabaseTokenService().syncAPNsToken(token)
            print("[APNs] Token sync complete")
        }
    }

    nonisolated func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
