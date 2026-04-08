import Foundation
import Supabase

final class SupabaseActivityService {
    private let table = "strava_activities"

    private func currentUserId() async -> String? {
        try? await supabase.auth.session.user.id.uuidString
    }

    func fetchCachedActivities(limit: Int = 20, offset: Int = 0) async throws -> [StravaActivity] {
        guard let userId = await currentUserId() else { return [] }

        let rows: [SupabaseActivityRow] = try await supabase
            .from(table)
            .select()
            .eq("user_id", value: userId)
            .order("start_date_local", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value

        return rows.map { $0.toStravaActivity() }
    }

    func latestActivityDate() async throws -> String? {
        guard let userId = await currentUserId() else { return nil }

        let rows: [SupabaseActivityRow] = try await supabase
            .from(table)
            .select()
            .eq("user_id", value: userId)
            .order("start_date_local", ascending: false)
            .limit(1)
            .execute()
            .value

        return rows.first?.startDateLocal
    }

    func oldestActivityDate() async throws -> String? {
        guard let userId = await currentUserId() else { return nil }

        let rows: [SupabaseActivityRow] = try await supabase
            .from(table)
            .select()
            .eq("user_id", value: userId)
            .order("start_date_local", ascending: true)
            .limit(1)
            .execute()
            .value

        return rows.first?.startDateLocal
    }

    func cachedCount() async throws -> Int {
        guard let userId = await currentUserId() else { return 0 }

        let rows: [SupabaseActivityRow] = try await supabase
            .from(table)
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        return rows.count
    }

    func upsertActivities(_ activities: [StravaActivity]) async throws {
        guard let userId = await currentUserId(), !activities.isEmpty else { return }

        let rows = activities.map { SupabaseActivityRow.from(stravaActivity: $0, userId: userId) }

        try await supabase
            .from(table)
            .upsert(rows, onConflict: "user_id,strava_activity_id")
            .execute()
    }

    func deleteActivity(stravaActivityId: Int) async throws {
        guard let userId = await currentUserId() else { return }

        try await supabase
            .from(table)
            .delete()
            .eq("user_id", value: userId)
            .eq("strava_activity_id", value: stravaActivityId)
            .execute()
    }

    func deleteAllForCurrentUser() async throws {
        guard let userId = await currentUserId() else { return }

        try await supabase
            .from(table)
            .delete()
            .eq("user_id", value: userId)
            .execute()
    }
}
