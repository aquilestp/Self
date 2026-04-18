import Foundation

nonisolated struct SupabaseActivityDetailRow: Codable, Sendable {
    let id: String?
    let userId: String
    let stravaActivityId: Int
    let detailJson: String
    let fetchedAt: String?

    nonisolated enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case stravaActivityId = "strava_activity_id"
        case detailJson = "detail_json"
        case fetchedAt = "fetched_at"
    }
}
