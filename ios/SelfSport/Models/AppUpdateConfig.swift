import Foundation

struct AppUpdateConfig: Codable, Sendable {
    let id: Int
    let isActive: Bool
    let title: String
    let subtitle: String?
    let items: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case isActive = "is_active"
        case title
        case subtitle
        case items
    }
}
