import Foundation
import Supabase

@MainActor
@Observable
final class AppUpdateService {
    static let shared = AppUpdateService()

    private(set) var config: AppUpdateConfig?
    private let dismissedKey = "app_update_dismissed_date"

    var shouldShowUpdate: Bool {
        guard let config, config.isActive, !config.items.isEmpty else { return false }
        return !wasDismissedToday
    }

    private var wasDismissedToday: Bool {
        guard let savedDate = UserDefaults.standard.object(forKey: dismissedKey) as? Date else {
            return false
        }
        return Calendar.current.isDateInToday(savedDate)
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
        UserDefaults.standard.set(Date(), forKey: dismissedKey)
    }
}
