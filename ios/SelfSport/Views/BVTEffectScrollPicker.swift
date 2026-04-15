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
        }

    }
}
