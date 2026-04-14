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
                        print("[App] Foreground — re-registering for push + syncing APNs token")
                        await NotificationService.shared.reRegisterForPush()
                        try? await Task.sleep(for: .seconds(1))
                        await SupabaseTokenService.shared.syncAPNsTokenToDB()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: apnsTokenDidChangeNotification)) { notification in
                    if let token = notification.object as? String {
                        print("[App] APNs token changed notification — syncing to DB: \(token.prefix(16))...")
                        Task {
                            await SupabaseTokenService.shared.syncAPNsTokenToDB()
                        }
                    }
                }
                .task {
                    try? await Task.sleep(for: .seconds(3))
                    print("[App] Initial delayed APNs sync — token=\(NotificationService.shared.resolvedToken()?.prefix(16).description ?? "NIL")")
                    await SupabaseTokenService.shared.syncAPNsTokenToDB()
                }
        }
    }
}
