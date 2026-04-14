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
    static let shared = SupabaseTokenService()
    private let table = "strava_tokens"

    private func currentUserId() async -> String? {
        let uid = try? await supabase.auth.session.user.id.uuidString
        print("[TokenSync] currentUserId = \(uid ?? "nil")")
        return uid
    }

    func syncTokens(accessToken: String, refreshToken: String, expiresAt: Int, athleteId: Int? = nil) async {
        guard let userId = await currentUserId() else {
            print("[TokenSync] ❌ No session — cannot sync Strava tokens")
            return
        }

        let apns = NotificationService.shared.resolvedToken()
        print("[TokenSync] syncTokens — user=\(userId.prefix(8)), athleteId=\(athleteId?.description ?? "nil"), apns=\(apns?.prefix(16).description ?? "NIL")")

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
            print("[TokenSync] ✅ syncTokens UPSERT success (apns=\(apns != nil ? "included" : "NOT included"))")
        } catch {
            print("[TokenSync] ❌ syncTokens UPSERT failed: \(error)")
        }
    }

    func syncAPNsTokenToDB() async {
        guard let apns = NotificationService.shared.resolvedToken() else {
            print("[TokenSync] syncAPNsTokenToDB — no APNs token available")
            return
        }

        guard let userId = await currentUserId() else {
            print("[TokenSync] syncAPNsTokenToDB — no Supabase session, will retry later")
            return
        }

        print("[TokenSync] syncAPNsTokenToDB — user=\(userId.prefix(8)), apns=\(apns.prefix(16))...")

        let existing = await fetchExistingRow(userId: userId)

        if existing != nil {
            if existing?.apnsToken == apns {
                print("[TokenSync] ✅ APNs token already matches in DB — no update needed")
                return
            }
            do {
                try await supabase
                    .from(table)
                    .update([
                        "apns_token": AnyJSON.string(apns),
                        "updated_at": AnyJSON.string(ISO8601DateFormatter().string(from: Date()))
                    ])
                    .eq("user_id", value: userId)
                    .execute()
                print("[TokenSync] ✅ APNs token UPDATED in existing row")
            } catch {
                print("[TokenSync] ❌ APNs token UPDATE failed: \(error)")
            }
        } else {
            print("[TokenSync] ⚠️ No strava_tokens row exists yet for user — APNs token saved locally, will be included when Strava connects")
        }
    }

    func ensureAPNsTokenSynced(retries: Int = 5, delaySeconds: Int = 2) async {
        for attempt in 1...retries {
            let token = NotificationService.shared.resolvedToken()
            print("[TokenSync] ensureAPNsTokenSynced attempt \(attempt)/\(retries) — token=\(token?.prefix(16).description ?? "NIL")")

            if token != nil {
                await syncAPNsTokenToDB()
                return
            }

            if attempt < retries {
                print("[TokenSync] Waiting \(delaySeconds)s before retry...")
                try? await Task.sleep(for: .seconds(delaySeconds))
            }
        }
        print("[TokenSync] ❌ ensureAPNsTokenSynced FAILED after \(retries) attempts — APNs token never obtained")
        print("[TokenSync] ❌ registrationError=\(NotificationService.shared.registrationError ?? "none")")
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

    private func fetchExistingRow(userId: String) async -> SupabaseStravaTokenRow? {
        do {
            let rows: [SupabaseStravaTokenRow] = try await supabase
                .from(table)
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            let row = rows.first
            print("[TokenSync] fetchExistingRow — found=\(row != nil), apns=\(row?.apnsToken?.prefix(16).description ?? "NIL")")
            return row
        } catch {
            print("[TokenSync] fetchExistingRow error: \(error)")
            return nil
        }
    }
}
