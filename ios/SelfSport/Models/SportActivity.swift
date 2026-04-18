import Foundation

struct SportActivity: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let duration: String
    let intensity: String
    let systemImage: String

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        duration: String,
        intensity: String,
        systemImage: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.intensity = intensity
        self.systemImage = systemImage
    }
}
