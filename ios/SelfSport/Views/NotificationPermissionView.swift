import SwiftUI

struct NotificationPermissionView: View {
    let onEnable: () -> Void
    let onSkip: () -> Void

    @State private var appeared: Bool = false
    @State private var bellBounce: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            bellIcon
                .padding(.bottom, 28)

            titleSection
                .padding(.bottom, 32)

            notificationPreviews
                .padding(.bottom, 40)

            Spacer()

            buttons
                .padding(.bottom, 16)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.06))
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            Task {
                try? await Task.sleep(for: .seconds(0.6))
                bellBounce += 1
            }
        }
    }

    private var bellIcon: some View {
        Image(systemName: "bell.badge.fill")
            .font(.system(size: 56, weight: .light))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, Color(red: 1.0, green: 0.35, blue: 0.25))
            .symbolEffect(.bounce.byLayer, value: bellBounce)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
    }

    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("Stay in the loop")
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundStyle(.white)

            Text("Get notified when new activities sync,\nmilestones are hit, and more.")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var notificationPreviews: some View {
        VStack(spacing: 10) {
            notificationCard(
                icon: "figure.run",
                iconColor: Color(red: 0.25, green: 0.85, blue: 0.45),
                title: "New Activity Synced",
                body: "Morning Run · 5.2 km · 28'14\"",
                time: "now"
            )

            notificationCard(
                icon: "flame.fill",
                iconColor: Color(red: 1.0, green: 0.55, blue: 0.15),
                title: "Weekly Streak",
                body: "You've been active 5 days this week!",
                time: "2h ago"
            )

            notificationCard(
                icon: "trophy.fill",
                iconColor: Color(red: 1.0, green: 0.82, blue: 0.25),
                title: "Personal Best",
                body: "New 10K record: 48'32\" — crushed it.",
                time: "1d ago"
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private func notificationCard(
        icon: String,
        iconColor: Color,
        title: String,
        body: String,
        time: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(time)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.3))
                }
                Text(body)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.5))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
        )
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            Button(action: onEnable) {
                Text("Enable Notifications")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 1.0, green: 0.35, blue: 0.25), in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            Button(action: onSkip) {
                Text("Not now")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NotificationPermissionView(
        onEnable: {},
        onSkip: {}
    )
    .preferredColorScheme(.dark)
}
