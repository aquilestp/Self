import SwiftUI

struct AIQuotaBadge: View {
    let kind: AIGenerationKind
    let used: Int
    let limit: Int

    private var remaining: Int { max(0, limit - used) }

    private var iconName: String {
        kind == .image ? "photo.stack" : "video"
    }

    private var label: String {
        kind == .image ? "images" : "videos"
    }

    private var tint: Color {
        if remaining == 0 { return Color(red: 0.95, green: 0.35, blue: 0.35) }
        if remaining == 1 { return Color(red: 0.95, green: 0.7, blue: 0.25) }
        return .white.opacity(0.85)
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .semibold))
            Text("\(remaining)/\(limit) \(label)")
                .font(.system(size: 12, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.white.opacity(0.10), in: .capsule)
        .overlay(
            Capsule().stroke(.white.opacity(0.15), lineWidth: 0.5)
        )
    }
}
