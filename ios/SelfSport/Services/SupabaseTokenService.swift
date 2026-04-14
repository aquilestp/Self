import Foundation
import Supabase

nonisolated struct SupabaseStravaTokenRow: Codable, Sendable {
    let userId: String
    let stravaAthleteId: Int?
    let accessToken: String
    let refreshToken: String
    let expiresAt: Int
    let updatedAt: String?
    nonisolated enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case stravaAthleteId = "strava_athlete_id"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case updatedAt = "updated_at"
    }
}

final class SupabaseTokenService {
    static let shared = SupabaseTokenService()
    private let table = "strava_tokens"
    private func currentUserId() async -> String? {
        let uid = try? await supabase.auth.session.user.id.uuidString
        print("[TokenSync] currentUserId = \(uid ?? "NIL — no Supabase session")")
        return uid
    }

    func syncTokens(accessToken: String, refreshToken: String, expiresAt: Int, athleteId: Int? = nil) async {
        guard let userId = await currentUserId() else {
            print("[TokenSync] ❌ No session — cannot sync Strava tokens")
            return
        }

        print("[TokenSync] syncTokens — user=\(userId.prefix(8)), athleteId=\(athleteId?.description ?? "nil")")

        var data: [String: AnyJSON] = [
            "user_id": .string(userId),
            "access_token": .string(accessToken),
            "refresh_token": .string(refreshToken),
            "expires_at": .integer(expiresAt),
            "updated_at": .string(ISO8601DateFormatter().string(from: Date())),
        ]

        if let athleteId {
            data["strava_athlete_id"] = .integer(athleteId)
        }

        do {
            try await supabase
                .from(table)
                .upsert(data, onConflict: "user_id")
                .execute()
            print("[TokenSync] ✅ syncTokens UPSERT OK")
        } catch {
            print("[TokenSync] ❌ syncTokens UPSERT failed: \(error)")
        }
    }

    func deleteTokens() async {
        guard let userId = await currentUserId() else {
            print("[TokenSync] ❌ No session — cannot delete tokens")
            return
        }
        do {
            try await supabase
                .from(table)
                .delete()
                .eq("user_id", value: userId)
                .execute()
            print("[TokenSync] ✅ Tokens deleted for user \(userId.prefix(8))")
        } catch {
            print("[TokenSync] ❌ Delete failed: \(error)")
        }
    }


}
