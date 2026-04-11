import Foundation

nonisolated struct VideoStylePrompt: Codable, Sendable, Identifiable {
    let id: String
    let styleKey: String
    let displayName: String
    let promptTemplate: String
    let icon: String
    let isActive: Bool
    let sortOrder: Int

    nonisolated enum CodingKeys: String, CodingKey {
        case id
        case styleKey = "style_key"
        case displayName = "display_name"
        case promptTemplate = "prompt_template"
        case icon
        case isActive = "is_active"
        case sortOrder = "sort_order"
    }
}
