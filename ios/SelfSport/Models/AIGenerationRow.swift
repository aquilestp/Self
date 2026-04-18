import Foundation

enum AIGenerationKind: String, Codable, Sendable {
    case image
    case video
}

struct AIGenerationRow: Codable, Sendable {
    let id: String?
    let userId: String
    let kind: String
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case kind
        case createdAt = "created_at"
    }
}

struct AIGenerationInsertRow: Codable, Sendable {
    let userId: String
    let kind: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case kind
    }
}

struct AIGenerationDateRow: Codable, Sendable {
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
    }
}
