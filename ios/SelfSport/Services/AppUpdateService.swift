import Foundation
import Supabase

@MainActor
@Observable
final class AppUpdateService {
    static let shared = AppUpdateService()

    private(set) var config: AppUpdateConfig?
    private let dismissedKeyPrefix = "app_update_dismissed_v"

    var shouldShowUpdate: Bool {
        guard let config, config.isActive, !config.items.isEmpty else { return false }
        return !wasDismissedForThisUpdate
    }

    private var wasDismissedForThisUpdate: Bool {
        guard let config else { return false }
        return UserDefaults.standard.bool(forKey: "\(dismissedKeyPrefix)\(config.id)")
    }

    func fetch() async {
        do {
            let rows: [AppUpdateConfig] = try await supabase
                .from("app_updates")
                .select()
                .eq("id", value: 1)
                .limit(1)
                .execute()
                .value
            config = rows.first
        } catch {
            config = nil
        }
    }

    func dismissForToday() {
        guard let config else { return }
        UserDefaults.standard.set(true, forKey: "\(dismissedKeyPrefix)\(config.id)")
    }
}
