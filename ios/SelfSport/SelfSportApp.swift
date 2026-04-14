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
                        await SupabaseTokenService().ensureAPNsTokenSynced()
                    }
                }
                .task {
                    try? await Task.sleep(for: .seconds(2))
                    await SupabaseTokenService().ensureAPNsTokenSynced()
                }
        }
    }
}
