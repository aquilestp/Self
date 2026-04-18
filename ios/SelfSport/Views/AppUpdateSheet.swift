import SwiftUI

struct AppUpdateSheet: View {
    let config: AppUpdateConfig
    let onLater: () -> Void
    let onUpdate: () -> Void

    @State private var appeared: Bool = false
    @State private var iconBounce: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            iconSection
                .padding(.bottom, 32)

            titleSection
                .padding(.bottom, 28)

            itemsSection
                .padding(.bottom, 44)

            Spacer()

            buttons
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.06))
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            Task {
                try? await Task.sleep(for: .seconds(0.55))
                iconBounce += 1
            }
        }
    }

    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 88, height: 88)

            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 110, height: 110)

            Image(systemName: "sparkles")
                .font(.system(size: 44, weight: .light))
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.white, Color.white.opacity(0.35))
                .symbolEffect(.bounce.byLayer, value: iconBounce)
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.7)
        .animation(.spring(response: 0.55, dampingFraction: 0.72), value: appeared)
    }

    private var titleSection: some View {
        VStack(spacing: 10) {
            Text(config.title)
                .font(.system(size: 30, weight: .bold, design: .default))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            if let subtitle = config.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.45))
                    .multilineTextAlignment(.center)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .animation(.easeOut(duration: 0.45).delay(0.1), value: appeared)
    }

    private var itemsSection: some View {
        let validItems = Array(config.items.prefix(4))
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(validItems.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .frame(width: 20, height: 20)
                        .background(Color.white.opacity(0.08), in: Circle())
                        .padding(.top, 1)

                    Text(item)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.80))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
                .padding(.vertical, 11)

                if index < validItems.count - 1 {
                    Divider()
                        .background(Color.white.opacity(0.07))
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.07), lineWidth: 0.5)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.45).delay(0.18), value: appeared)
    }

    private var buttons: some View {
        VStack(spacing: 14) {
            Button(action: onUpdate) {
                Text("Update Now")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 15))
            }
            .buttonStyle(.plain)

            Button(action: onLater) {
                Text("Later")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.38))
            }
            .buttonStyle(.plain)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.45).delay(0.24), value: appeared)
    }
}

#Preview {
    AppUpdateSheet(
        config: AppUpdateConfig(
            id: 1,
            isActive: true,
            title: "What's New ✨",
            subtitle: "Version 2.1",
            items: [
                "Unified Elapsed + Moving time widget",
                "Activity switcher from canvas",
                "City location smart modal",
                "Performance improvements"
            ]
        ),
        onLater: {},
        onUpdate: {}
    )
    .preferredColorScheme(.dark)
}
