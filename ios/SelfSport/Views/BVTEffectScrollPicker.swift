import SwiftUI

struct BVTEffectScrollPicker: View {
    let currentEffect: BVTEffect
    let onSelectEffect: (BVTEffect) -> Void

    private let itemHeight: CGFloat = 40
    private let visibleItems: Int = 5

    @State private var selectedIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    private var allEffects: [BVTEffect] { BVTEffect.allCases }

    private var currentOffset: CGFloat {
        -CGFloat(selectedIndex) * itemHeight + dragOffset
    }

    var body: some View {
        let totalHeight: CGFloat = itemHeight * CGFloat(visibleItems)
        let centerY: CGFloat = totalHeight / 2

        ZStack {
            ForEach(Array(allEffects.enumerated()), id: \.element.id) { idx, effect in
                let y = centerY + CGFloat(idx) * itemHeight + currentOffset - itemHeight / 2
                let distFromCenter = abs(y - centerY + itemHeight / 2)
                let maxDist = totalHeight / 2
                let normalizedDist = min(distFromCenter / maxDist, 1.0)
                let isSelected = idx == selectedIndex && dragOffset == 0

                effectRow(effect: effect, isSelected: isSelected)
                    .frame(height: itemHeight)
                    .frame(width: 130, alignment: .trailing)
                    .opacity(1.0 - normalizedDist * 0.8)
                    .position(x: 65, y: y)
            }
        }
        .frame(width: 130, height: totalHeight)
        .clipped()
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    let projected = value.predictedEndTranslation.height
                    let steps = -round(projected / itemHeight)
                    let clampedSteps = max(-1, min(1, Int(steps)))
                    let newIndex = max(0, min(allEffects.count - 1, selectedIndex + clampedSteps))

                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        dragOffset = 0
                        selectedIndex = newIndex
                    }

                    if newIndex != selectedIndex - clampedSteps + clampedSteps {
                        haptic.impactOccurred()
                        onSelectEffect(allEffects[newIndex])
                    }
                }
        )
        .onAppear {
            if let idx = allEffects.firstIndex(of: currentEffect) {
                selectedIndex = idx
            }
        }
        .onChange(of: currentEffect) { _, newValue in
            if let idx = allEffects.firstIndex(of: newValue) {
                guard idx != selectedIndex else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    selectedIndex = idx
                }
            }
        }
    }

    @ViewBuilder
    private func effectRow(effect: BVTEffect, isSelected: Bool) -> some View {
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
}
