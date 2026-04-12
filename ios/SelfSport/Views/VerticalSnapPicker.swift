import SwiftUI

struct VerticalSnapPicker<Item: Equatable, RowContent: View>: View {
    let items: [Item]
    let selectedItem: Item
    let width: CGFloat
    let visibleItems: Int
    let onSelect: (Item) -> Void
    @ViewBuilder let rowContent: (Item, Bool) -> RowContent

    private let itemHeight: CGFloat = 40

    @State private var selectedIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var lastHapticIndex: Int = 0
    @State private var isDragging: Bool = false

    private let tickHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let landHaptic = UIImpactFeedbackGenerator(style: .heavy)

    private var continuousIndex: CGFloat {
        CGFloat(selectedIndex) - dragOffset / itemHeight
    }

    private var clampedContinuousIndex: CGFloat {
        let raw = continuousIndex
        if raw < 0 {
            return -rubberBand(abs(raw), maxItems: 2)
        } else if raw > CGFloat(items.count - 1) {
            let over = raw - CGFloat(items.count - 1)
            return CGFloat(items.count - 1) + rubberBand(over, maxItems: 2)
        }
        return raw
    }

    private func rubberBand(_ overshoot: CGFloat, maxItems: CGFloat) -> CGFloat {
        let dim = maxItems
        let c: CGFloat = 0.4
        return (1.0 - (1.0 / ((overshoot * c / dim) + 1.0))) * dim
    }

    private var snappedIndex: Int {
        max(0, min(items.count - 1, Int(round(clampedContinuousIndex))))
    }

    var body: some View {
        let totalHeight: CGFloat = itemHeight * CGFloat(visibleItems)
        let centerY: CGFloat = totalHeight / 2

        ZStack {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                let indexOffset = CGFloat(idx) - clampedContinuousIndex
                let y = centerY + indexOffset * itemHeight
                let distFromCenter = abs(indexOffset)
                let maxDist = CGFloat(visibleItems) / 2.0
                let normalizedDist = min(distFromCenter / maxDist, 1.0)
                let isSelected = idx == snappedIndex

                rowContent(item, isSelected)
                    .frame(height: itemHeight)
                    .frame(width: width, alignment: .trailing)
                    .opacity(1.0 - normalizedDist * 0.8)
                    .scaleEffect(1.0 - normalizedDist * 0.08)
                    .position(x: width / 2, y: y)
            }
        }
        .frame(width: width, height: totalHeight)
        .clipped()
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        tickHaptic.prepare()
                    }
                    dragOffset = value.translation.height

                    let current = snappedIndex
                    if current != lastHapticIndex {
                        tickHaptic.impactOccurred(intensity: 0.85)
                        tickHaptic.prepare()
                        lastHapticIndex = current
                    }
                }
                .onEnded { value in
                    isDragging = false
                    let velocity = value.predictedEndTranslation.height - value.translation.height
                    let currentPos = continuousIndex
                    let projected = currentPos - velocity / itemHeight
                    let targetIndex = max(0, min(items.count - 1, Int(round(projected))))

                    let previousIndex = selectedIndex
                    let distance = abs(targetIndex - selectedIndex)
                    let responseDuration = min(0.45, 0.18 + Double(distance) * 0.02)

                    withAnimation(.spring(response: responseDuration, dampingFraction: 0.78)) {
                        dragOffset = 0
                        selectedIndex = targetIndex
                    }

                    if targetIndex != previousIndex {
                        landHaptic.impactOccurred(intensity: 1.0)
                        landHaptic.prepare()
                        onSelect(items[targetIndex])
                    }

                    lastHapticIndex = targetIndex
                }
        )
        .onAppear {
            tickHaptic.prepare()
            landHaptic.prepare()
            if let idx = items.firstIndex(of: selectedItem) {
                selectedIndex = idx
                lastHapticIndex = idx
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            if let idx = items.firstIndex(of: newValue) {
                guard idx != selectedIndex else { return }
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    selectedIndex = idx
                }
                lastHapticIndex = idx
            }
        }
    }
}
