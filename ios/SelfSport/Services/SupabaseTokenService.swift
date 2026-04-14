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
    private var pendingSyncTask: Task<Void, Never>?

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

        let apns = NotificationService.shared.resolvedToken()
        print("[TokenSync] syncTokens — user=\(userId.prefix(8)), athleteId=\(athleteId?.description ?? "nil"), apns=\(apns?.prefix(16).description ?? "⚠️ NIL")")

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
            print("[TokenSync] ✅ syncTokens UPSERT OK (apns=\(apns != nil ? "YES ✅" : "NOT INCLUDED ⚠️"))")

            if apns == nil {
                print("[TokenSync] ⚠️ Row created WITHOUT apns_token — starting aggressive retry loop")
                startPendingAPNsSync(userId: userId)
            }
        } catch {
            print("[TokenSync] ❌ syncTokens UPSERT failed: \(error)")
        }
    }

    func syncAPNsTokenToDB() async {
        let apns = NotificationService.shared.resolvedToken()
        let userId = await currentUserId()

        print("[TokenSync] syncAPNsTokenToDB — apns=\(apns?.prefix(16).description ?? "NIL"), userId=\(userId?.prefix(8).description ?? "NIL")")

        guard let apns, !apns.isEmpty else {
            print("[TokenSync] ⛔ No APNs token — nothing to sync")
            return
        }

        guard let userId else {
            print("[TokenSync] ⛔ No Supabase session — saving token locally, will sync later")
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
            print("[TokenSync] ✅ APNs token UPDATE executed for user \(userId.prefix(8))")

            let row = await fetchExistingRow(userId: userId)
            if let dbApns = row?.apnsToken, dbApns == apns {
                print("[TokenSync] ✅✅ VERIFIED: apns_token in DB matches device token")
            } else if row != nil {
                print("[TokenSync] ⚠️ Row exists but apns_token=\(row?.apnsToken?.prefix(16).description ?? "NIL") — mismatch or not saved")
            } else {
                print("[TokenSync] ⚠️ No strava_tokens row exists yet — UPDATE had no effect (expected if Strava not connected)")
            }
        } catch {
            print("[TokenSync] ❌ APNs token UPDATE failed: \(error)")
        }
    }

    func startPendingAPNsSync(userId: String) {
        pendingSyncTask?.cancel()
        pendingSyncTask = Task {
            for attempt in 1...10 {
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else { return }

                let token = NotificationService.shared.resolvedToken()
                print("[TokenSync] 🔄 Pending APNs sync attempt \(attempt)/10 — token=\(token?.prefix(16).description ?? "NIL")")

                if let token, !token.isEmpty {
                    do {
                        try await supabase
                            .from(table)
                            .update([
                                "apns_token": AnyJSON.string(token),
                                "updated_at": AnyJSON.string(ISO8601DateFormatter().string(from: Date()))
                            ])
                            .eq("user_id", value: userId)
                            .execute()
                        print("[TokenSync] ✅ Pending APNs sync SUCCESS on attempt \(attempt)")
                    } catch {
                        print("[TokenSync] ❌ Pending APNs sync UPDATE failed: \(error)")
                    }
                    return
                }

                if attempt == 5 {
                    print("[TokenSync] 🔄 Halfway through retries — forcing re-register for push")
                    await NotificationService.shared.reRegisterForPush()
                }
            }
            print("[TokenSync] ❌ Pending APNs sync EXHAUSTED 10 attempts — token never arrived")
            print("[TokenSync] ❌ registrationError=\(NotificationService.shared.registrationError ?? "none")")
            print("[TokenSync] ❌ deviceToken=\(NotificationService.shared.deviceToken?.prefix(16).description ?? "NIL")")
        }
    }

    func ensureAPNsTokenSynced(retries: Int = 10, delaySeconds: Int = 2) async {
        for attempt in 1...retries {
            let token = NotificationService.shared.resolvedToken()
            print("[TokenSync] ensureAPNsTokenSynced attempt \(attempt)/\(retries) — token=\(token?.prefix(16).description ?? "NIL")")

            if token != nil {
                await syncAPNsTokenToDB()
                return
            }

            if attempt == retries / 2 {
                print("[TokenSync] 🔄 Mid-retry — forcing re-register for push")
                await NotificationService.shared.reRegisterForPush()
            }

            if attempt < retries {
                try? await Task.sleep(for: .seconds(delaySeconds))
            }
        }
        print("[TokenSync] ❌ ensureAPNsTokenSynced FAILED after \(retries) attempts")
        print("[TokenSync] ❌ registrationError=\(NotificationService.shared.registrationError ?? "none")")
        print("[TokenSync] ❌ deviceToken in memory=\(NotificationService.shared.deviceToken?.prefix(16).description ?? "NIL")")
        print("[TokenSync] ❌ deviceToken in UserDefaults=\(UserDefaults.standard.string(forKey: "saved_apns_device_token")?.prefix(16).description ?? "NIL")")
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
