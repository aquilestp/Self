import Foundation
import Supabase

@MainActor
@Observable
final class AIQuotaService {
    static let shared = AIQuotaService()

    static let imageLimit: Int = 10
    static let videoLimit: Int = 2
    static let windowDays: Int = 30

    private(set) var imagesUsed: Int = 0
    private(set) var videosUsed: Int = 0
    private(set) var oldestImageDate: Date? = nil
    private(set) var oldestVideoDate: Date? = nil
    private(set) var isLoading: Bool = false
    var lastError: String? = nil
    var lastDebugInfo: String? = nil

    var imagesRemaining: Int { max(0, Self.imageLimit - imagesUsed) }
    var videosRemaining: Int { max(0, Self.videoLimit - videosUsed) }

    var hasImageQuota: Bool { imagesRemaining > 0 }
    var hasVideoQuota: Bool { videosRemaining > 0 }

    func nextSlotDate(for kind: AIGenerationKind) -> Date? {
        let oldest = kind == .image ? oldestImageDate : oldestVideoDate
        guard let oldest else { return nil }
        return Calendar.current.date(byAdding: .day, value: Self.windowDays, to: oldest)
    }

    func daysUntilNextSlot(for kind: AIGenerationKind) -> Int {
        guard let next = nextSlotDate(for: kind) else { return 0 }
        let interval = next.timeIntervalSince(Date())
        if interval <= 0 { return 0 }
        return max(1, Int(ceil(interval / 86_400)))
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        guard let userId = try? await supabase.auth.session.user.id.uuidString else {
            imagesUsed = 0
            videosUsed = 0
            oldestImageDate = nil
            oldestVideoDate = nil
            return
        }

        let cutoff = Date().addingTimeInterval(-Double(Self.windowDays) * 86_400)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoFallback = ISO8601DateFormatter()
        isoFallback.formatOptions = [.withInternetDateTime]
        let cutoffStr = isoFormatter.string(from: cutoff)

        async let images: [Date] = fetchDates(userId: userId, kind: .image, since: cutoffStr, formatter: isoFormatter, fallback: isoFallback)
        async let videos: [Date] = fetchDates(userId: userId, kind: .video, since: cutoffStr, formatter: isoFormatter, fallback: isoFallback)

        let imgDates = await images
        let vidDates = await videos

        imagesUsed = imgDates.count
        videosUsed = vidDates.count
        oldestImageDate = imgDates.min()
        oldestVideoDate = vidDates.min()
    }

    private func fetchDates(userId: String, kind: AIGenerationKind, since: String, formatter: ISO8601DateFormatter, fallback: ISO8601DateFormatter) async -> [Date] {
        do {
            let rows: [AIGenerationDateRow] = try await supabase
                .from("ai_generations")
                .select("created_at")
                .eq("user_id", value: userId)
                .eq("kind", value: kind.rawValue)
                .gte("created_at", value: since)
                .execute()
                .value

            return rows.compactMap { formatter.date(from: $0.createdAt) ?? fallback.date(from: $0.createdAt) }
        } catch {
            print("[AIQuota] Failed to fetch \(kind.rawValue) dates: \(error)")
            return []
        }
    }

    @discardableResult
    func recordUsage(_ kind: AIGenerationKind) async -> Bool {
        lastError = nil
        lastDebugInfo = nil
        let userId: String
        do {
            userId = try await supabase.auth.session.user.id.uuidString
        } catch {
            let msg = "[AIQuota] No authenticated Supabase session — cannot record \(kind.rawValue). Error: \(error)"
            print(msg)
            lastError = "Not signed in to Supabase. Please sign in again."
            lastDebugInfo = "No session: \(error.localizedDescription)"
            return false
        }
        print("[AIQuota] Recording \(kind.rawValue) usage for user \(userId)")
        do {
            let row = AIGenerationInsertRow(userId: userId, kind: kind.rawValue)
            let response = try await supabase
                .from("ai_generations")
                .insert(row, returning: .representation)
                .select()
                .execute()
            print("[AIQuota] Insert response status=\(response.status), data bytes=\(response.data.count)")
            let bodyStr = String(data: response.data, encoding: .utf8) ?? "<no body>"
            print("[AIQuota] Insert body: \(bodyStr)")
            lastDebugInfo = "OK status=\(response.status) user=\(userId.prefix(8)) body=\(bodyStr.prefix(120))"
            await refresh()
            print("[AIQuota] After refresh: imagesUsed=\(imagesUsed), videosUsed=\(videosUsed)")
            return true
        } catch {
            let msg = "[AIQuota] Failed to insert \(kind.rawValue): \(error) | localized: \(error.localizedDescription)"
            print(msg)
            lastError = error.localizedDescription
            lastDebugInfo = "Insert failed user=\(userId.prefix(8)) err=\(String(describing: error))"
            return false
        }
    }
}

nonisolated enum AIQuotaError: Error, LocalizedError, Sendable {
    case quotaExceeded(kind: AIGenerationKind)

    nonisolated var errorDescription: String? {
        switch self {
        case .quotaExceeded(let kind):
            return kind == .image ? "You reached your monthly image limit." : "You reached your monthly video limit."
        }
    }
}
