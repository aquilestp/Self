import SwiftUI

struct ActivitySwitcherSheet: View {
    let activities: [ActivityHighlight]
    let currentActivityId: String
    let onPick: (ActivityHighlight) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(activities) { activity in
                        let isSelected = activity.id == currentActivityId
                        Button {
                            HapticService.medium.impactOccurred()
                            onPick(activity)
                        } label: {
                            ActivitySwitcherRow(activity: activity, isSelected: isSelected)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(white: 0.06))
            .navigationTitle("Switch Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(white: 0.06), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

private struct ActivitySwitcherRow: View {
    let activity: ActivityHighlight
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isSelected ? activity.accent.opacity(0.28) : activity.accent.opacity(0.12))
                    .frame(width: 46, height: 46)

                Image(systemName: activity.systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(activity.accent.opacity(0.92))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(activity.title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(.white.opacity(isSelected ? 1.0 : 0.88))
                    .lineLimit(1)

                Text(activity.hasDistance
                    ? "\(activity.distance)  ·  \(activity.pace)  ·  \(activity.duration)"
                    : "\(activity.duration)  ·  \(activity.date)"
                )
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(0.44))
                .lineLimit(1)
            }

            Spacer(minLength: 4)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(activity.accent)
            } else {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.28))
            }
        }
        .padding(14)
        .background(
            isSelected
                ? AnyShapeStyle(activity.accent.opacity(0.09))
                : AnyShapeStyle(Color.white.opacity(0.04)),
            in: .rect(cornerRadius: 18)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    isSelected ? activity.accent.opacity(0.28) : Color.white.opacity(0.07),
                    lineWidth: 1
                )
        }
    }
}
