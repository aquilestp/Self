import SwiftUI

struct AIQuotaBadge: View {
    let kind: AIGenerationKind
    let used: Int
    let limit: Int
    var onTap: (() -> Void)? = nil

    private var remaining: Int { max(0, limit - used) }
    private var progress: Double {
        guard limit > 0 else { return 0 }
        return min(1.0, Double(used) / Double(limit))
    }

    private var tint: Color {
        if remaining == 0 { return Color(red: 0.95, green: 0.40, blue: 0.40) }
        if remaining <= (kind == .image ? 3 : 1) { return Color(red: 0.98, green: 0.72, blue: 0.30) }
        return .white.opacity(0.92)
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 7) {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.15), lineWidth: 2)
                        .frame(width: 16, height: 16)
                    Circle()
                        .trim(from: 0, to: max(0.001, 1 - progress))
                        .stroke(tint, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 16, height: 16)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
                Text("\(remaining) of \(limit) left")
                    .font(.system(size: 12, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(tint)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.10), in: .capsule)
            .overlay(
                Capsule().stroke(.white.opacity(0.15), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}
