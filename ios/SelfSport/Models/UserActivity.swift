import Foundation

struct UserActivity: Codable, Sendable, Identifiable {
    var id: UUID?
    let userId: UUID
    let activityType: String
    let distance: String
    let pace: String
    let duration: String
    let activityDate: String
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case activityType = "activity_type"
        case distance
        case pace
        case duration
        case activityDate = "activity_date"
        case createdAt = "created_at"
    }
}
