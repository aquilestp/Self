import Foundation
import Supabase

nonisolated struct SupabaseStravaTokenRow: Codable, Sendable {
    let userId: String
    let stravaAthleteId: Int?
    let accessToken: String
    let refreshToken: String
    let expiresAt: Int
    let updatedAt: String?
    let apnsToken: String?

    nonisolated enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case stravaAthleteId = "strava_athlete_id"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case updatedAt = "updated_at"
        case apnsToken = "apns_token"
    }
}

final class SupabaseTokenService {
    private let table = "strava_tokens"

    private func currentUserId() async -> String? {
        try? await supabase.auth.session.user.id.uuidString
    }

    func syncTokens(accessToken: String, refreshToken: String, expiresAt: Int, athleteId: Int? = nil) async {
        guard let userId = await currentUserId() else {
            print("[TokenSync] ERROR: No Supabase user session — cannot sync tokens")
            return
        }
        print("[TokenSync] Syncing tokens for user: \(userId), athleteId: \(athleteId?.description ?? "nil")")

        let existingApns = await fetchExistingAPNsToken(userId: userId)
        let apns = NotificationService.shared.resolvedToken() ?? existingApns
        print("[TokenSync] Preserving apns_token: \(apns?.prefix(16).description ?? "nil")")

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

        if let apns {
            data["apns_token"] = .string(apns)
        }

        do {
            try await supabase
                .from(table)
                .upsert(data, onConflict: "user_id")
                .execute()
            print("[TokenSync] SUCCESS: Tokens synced to Supabase (apns_token preserved)")
        } catch {
            print("[TokenSync] ERROR: Upsert failed — \(error)")
        }
    }

    func syncAPNsToken(_ apnsToken: String) async {
        guard let userId = await currentUserId() else {
            print("[TokenSync] No Supabase session yet — APNs token saved locally, will retry later")
            return
        }

        print("[TokenSync] Updating apns_token for user: \(userId)")

        do {
            try await supabase
                .from(table)
                .update(["apns_token": AnyJSON.string(apnsToken), "updated_at": AnyJSON.string(ISO8601DateFormatter().string(from: Date()))])
                .eq("user_id", value: userId)
                .execute()
            print("[TokenSync] SUCCESS: APNs token updated via UPDATE")
        } catch {
            print("[TokenSync] UPDATE failed (row may not exist yet): \(error)")
        }
    }

    func ensureAPNsTokenSynced() async {
        guard let token = NotificationService.shared.resolvedToken() else {
            print("[TokenSync] No APNs token available to sync")
            return
        }
        await syncAPNsToken(token)
    }

    func deleteTokens() async {
        guard let userId = await currentUserId() else {
            print("[TokenSync] ERROR: No Supabase user session — cannot delete tokens")
            return
        }
        print("[TokenSync] Deleting tokens for user: \(userId)")
        do {
            try await supabase
                .from(table)
                .delete()
                .eq("user_id", value: userId)
                .execute()
        } catch {
            print("[TokenSync] ERROR: Delete failed — \(error)")
        }
    }

    private func fetchExistingAPNsToken(userId: String) async -> String? {
        do {
            let rows: [SupabaseStravaTokenRow] = try await supabase
                .from(table)
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            return rows.first?.apnsToken
        } catch {
            print("[TokenSync] Could not fetch existing apns_token: \(error)")
            return nil
        }
    }
}
