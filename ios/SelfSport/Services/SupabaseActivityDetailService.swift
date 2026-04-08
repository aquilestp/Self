import Foundation
import Supabase

final class SupabaseActivityDetailService {
    private let table = "strava_activity_details"

    private func currentUserId() async -> String? {
        try? await supabase.auth.session.user.id.uuidString
    }

    func fetchCachedDetail(stravaActivityId: Int) async throws -> StravaActivityDetail? {
        guard let userId = await currentUserId() else { return nil }

        let rows: [SupabaseActivityDetailRow] = try await supabase
            .from(table)
            .select()
            .eq("user_id", value: userId)
            .eq("strava_activity_id", value: stravaActivityId)
            .limit(1)
            .execute()
            .value

        guard let row = rows.first else { return nil }

        guard let data = row.detailJson.data(using: .utf8) else { return nil }
        return try JSONDecoder().decode(StravaActivityDetail.self, from: data)
    }

    func deleteDetail(stravaActivityId: Int) async throws {
        guard let userId = await currentUserId() else { return }

        try await supabase
            .from(table)
            .delete()
            .eq("user_id", value: userId)
            .eq("strava_activity_id", value: stravaActivityId)
            .execute()
    }

    func upsertDetail(_ detail: StravaActivityDetail) async throws {
        guard let userId = await currentUserId() else { return }

        let jsonData = try JSONEncoder().encode(detail)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }

        let row = SupabaseActivityDetailRow(
            id: nil,
            userId: userId,
            stravaActivityId: detail.id,
            detailJson: jsonString,
            fetchedAt: nil
        )

        try await supabase
            .from(table)
            .upsert(row, onConflict: "user_id,strava_activity_id")
            .execute()
    }
}
