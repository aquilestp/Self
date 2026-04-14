import SwiftUI
import Supabase

@main
struct SelfSportApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        FontRegistration.registerCustomFonts()
        BackgroundRefreshService.register()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if url.scheme == "selfsport" && url.host == "strava-callback" {
                        return
                    }
                    Task {
                        try? await supabase.auth.session(from: url)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    BackgroundRefreshService.scheduleNextRefresh()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    Task {
                        print("[App] 🔄 Foreground — re-registering for push + syncing APNs token")
                        NotificationService.shared.printDiagnostics()
                        await NotificationService.shared.reRegisterForPush()
                        try? await Task.sleep(for: .seconds(2))
                        print("[App] 🔄 Post re-register token: \(NotificationService.shared.resolvedToken()?.prefix(16).description ?? "NIL")")
                        await SupabaseTokenService.shared.syncAPNsTokenToDB()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: apnsTokenDidChangeNotification)) { notification in
                    if let token = notification.object as? String {
                        print("[App] 🔔 APNs token CHANGED — \(token.prefix(16))... — syncing to DB immediately")
                        Task {
                            await SupabaseTokenService.shared.syncAPNsTokenToDB()
                        }
                    }
                }
                .task {
                    try? await Task.sleep(for: .seconds(3))
                    print("[App] 🚀 Initial delayed sync (3s after launch)")
                    NotificationService.shared.printDiagnostics()
                    await SupabaseTokenService.shared.syncAPNsTokenToDB()
                }
        }
    }
}
