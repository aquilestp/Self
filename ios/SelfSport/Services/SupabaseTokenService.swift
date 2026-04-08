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
        guard let userId = await currentUserId() else { return }

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
        } catch {
            // Silent — tokens still work locally via Keychain
        }
    }

    func syncAPNsToken(_ apnsToken: String) async {
        guard let userId = await currentUserId() else { return }

        let data: [String: AnyJSON] = [
            "user_id": .string(userId),
            "apns_token": .string(apnsToken),
            "updated_at": .string(ISO8601DateFormatter().string(from: Date())),
        ]

        do {
            try await supabase
                .from(table)
                .upsert(data, onConflict: "user_id")
                .execute()
        } catch {
        }
    }

    func deleteTokens() async {
        guard let userId = await currentUserId() else { return }
        do {
            try await supabase
                .from(table)
                .delete()
                .eq("user_id", value: userId)
                .execute()
        } catch {
            // Silent
        }
    }
}
