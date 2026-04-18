import Foundation

struct UserProfile: Codable, Sendable, Identifiable {
    let id: UUID
    var fullName: String?
    var email: String?
    var avatarUrl: String?
    var createdAt: String?
    var lastSeenAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case lastSeenAt = "last_seen_at"
    }
}
