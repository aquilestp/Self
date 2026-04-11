import SwiftUI

struct BVTEffectScrollPicker: View {
    let currentEffect: BVTEffect
    let onSelectEffect: (BVTEffect) -> Void

    private let itemHeight: CGFloat = 40
    private let visibleItems: Int = 5

    @State private var scrolledID: Int?
    @State private var lastSelectedId: Int?

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        let totalHeight: CGFloat = itemHeight * CGFloat(visibleItems)
        let allEffects = BVTEffect.allCases

        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                Color.clear.frame(height: itemHeight * 2)

                ForEach(allEffects) { effect in
                    effectRow(effect: effect)
                        .frame(height: itemHeight)
                        .id(effect.id)
                }

                Color.clear.frame(height: itemHeight * 2)
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrolledID, anchor: .center)
        .scrollTargetBehavior(.viewAligned)
        .frame(height: totalHeight)
        .frame(width: 130)
        .mask(
            VStack(spacing: 0) {
                LinearGradient(colors: [.clear, .white], startPoint: .top, endPoint: .bottom)
                    .frame(height: itemHeight * 1.5)
                Rectangle().fill(.white)
                LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: itemHeight * 1.5)
            }
        )
        .onAppear {
            scrolledID = currentEffect.id
            lastSelectedId = currentEffect.id
        }
        .onChange(of: scrolledID) { _, newValue in
            guard let newValue, newValue != lastSelectedId else { return }
            lastSelectedId = newValue
            if let effect = BVTEffect(rawValue: newValue) {
                haptic.impactOccurred()
                onSelectEffect(effect)
            }
        }
    }

    @ViewBuilder
    private func effectRow(effect: BVTEffect) -> some View {
        let isSelected = scrolledID == effect.id

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
        .frame(width: 130, alignment: .center)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}
