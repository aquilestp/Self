import SwiftUI

struct TimeArcStatCell: View {
    let value: String
    let label: String
    let icon: String
    let arcProgress: Double
    let accent: Color
    let subtitle: String?

    @State private var animatedProgress: Double = 0

    private let arcLineWidth: CGFloat = 4
    private let arcSize: CGFloat = 52

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.white.opacity(0.06), style: StrokeStyle(lineWidth: arcLineWidth, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: arcSize, height: arcSize)

                Circle()
                    .trim(from: 0, to: animatedProgress * 0.75)
                    .stroke(
                        accent,
                        style: StrokeStyle(lineWidth: arcLineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                    .frame(width: arcSize, height: arcSize)
                    .shadow(color: accent.opacity(0.35), radius: 6, x: 0, y: 2)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(accent.opacity(0.70))
            }

            VStack(spacing: 3) {
                Text(value)
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(Color.white.opacity(0.92))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(Color.white.opacity(0.32))
            }

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(accent.opacity(0.60))
                    .padding(.top, -4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .onAppear {
            withAnimation(.spring(duration: 1.0, bounce: 0.15)) {
                animatedProgress = arcProgress
            }
        }
    }
}
