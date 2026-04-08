import Foundation

nonisolated struct EditStylePrompt: Codable, Sendable {
    let id: String
    let styleKey: String
    let promptTemplate: String
    let isActive: Bool

    nonisolated enum CodingKeys: String, CodingKey {
        case id
        case styleKey = "style_key"
        case promptTemplate = "prompt_template"
        case isActive = "is_active"
    }
}

nonisolated struct GrokEditResponse: Codable, Sendable {
    let imageBase64: String?
    let error: String?

    nonisolated enum CodingKeys: String, CodingKey {
        case imageBase64 = "image_base64"
        case error
    }
}
