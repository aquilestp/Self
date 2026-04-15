import SwiftUI

struct BVTEffectScrollPicker: View {
    let currentEffect: BVTEffect
    let onSelectEffect: (BVTEffect) -> Void

    private let allEffects: [BVTEffect] = BVTEffect.allCases.map { $0 }

    var body: some View {
        VerticalSnapPicker(
            items: allEffects,
            selectedItem: currentEffect,
            width: 130,
            visibleItems: 5,
            onSelect: onSelectEffect
        ) { effect, isSelected in
            HStack(spacing: 6) {
                Image(systemName: effect.icon)
                    .font(.system(size: isSelected ? 12 : 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.45))
                    .frame(width: 16)
                Text(effect.label)
                    .font(.system(size: isSelected ? 12 : 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.45))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                            )
                    }
                }
            )
            .animation(.easeOut(duration: 0.15), value: isSelected)
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.black.opacity(0.4))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
