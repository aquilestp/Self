import Foundation
import Supabase

struct WidgetPopularityRow: Codable, Sendable {
    let widgetType: String
    let useCount: Int

    enum CodingKeys: String, CodingKey {
        case widgetType = "widget_type"
        case useCount = "use_count"
    }
}

struct UserWidgetRecentRow: Codable, Sendable {
    let userId: String
    let widgetType: String
    let lastUsedAt: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case widgetType = "widget_type"
        case lastUsedAt = "last_used_at"
    }
}

struct UserWidgetRecentUpsert: Codable, Sendable {
    let userId: String
    let widgetType: String
    let lastUsedAt: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case widgetType = "widget_type"
        case lastUsedAt = "last_used_at"
    }
}

final class WidgetPopularityService {
    private func currentUserId() async -> String? {
        try? await supabase.auth.session.user.id.uuidString
    }

    func fetchPopularity() async -> [String: Int] {
        do {
            let rows: [WidgetPopularityRow] = try await supabase
                .from("widget_popularity")
                .select()
                .execute()
                .value
            var result: [String: Int] = [:]
            for row in rows {
                result[row.widgetType] = row.useCount
            }
            return result
        } catch {
            print("[WidgetPopularity] fetchPopularity error: \(error)")
            return [:]
        }
    }

    func fetchUserRecents() async -> [String: Date] {
        guard let userId = await currentUserId() else { return [:] }
        do {
            let rows: [UserWidgetRecentRow] = try await supabase
                .from("user_widget_recents")
                .select()
                .eq("user_id", value: userId)
                .order("last_used_at", ascending: false)
                .execute()
                .value
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            var result: [String: Date] = [:]
            for row in rows {
                if let date = formatter.date(from: row.lastUsedAt) {
                    result[row.widgetType] = date
                }
            }
            return result
        } catch {
            print("[WidgetPopularity] fetchUserRecents error: \(error)")
            return [:]
        }
    }

    func trackWidgetUsage(widgetTypes: [String]) async {
        guard let userId = await currentUserId(), !widgetTypes.isEmpty else { return }

        do {
            try await supabase.rpc("increment_widget_popularity", params: ["p_widget_types": widgetTypes])
                .execute()
        } catch {
            print("[WidgetPopularity] increment error: \(error)")
        }

        let now = ISO8601DateFormatter().string(from: Date())
        let upserts = widgetTypes.map { type in
            UserWidgetRecentUpsert(userId: userId, widgetType: type, lastUsedAt: now)
        }
        do {
            try await supabase
                .from("user_widget_recents")
                .upsert(upserts, onConflict: "user_id,widget_type")
                .execute()
        } catch {
            print("[WidgetPopularity] upsert recents error: \(error)")
        }
    }
}
