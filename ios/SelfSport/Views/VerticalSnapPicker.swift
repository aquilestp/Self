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

    private let dragHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let snapHaptic = UIImpactFeedbackGenerator(style: .heavy)

    private func rubberBand(_ offset: CGFloat, limit: CGFloat) -> CGFloat {
        let coefficient: CGFloat = 0.55
        let dimension: CGFloat = itemHeight * CGFloat(visibleItems)
        if limit == 0 { return offset }
        let absOffset = abs(offset)
        let sign: CGFloat = offset < 0 ? -1 : 1
        let clamped = (1.0 - (1.0 / ((absOffset * coefficient / dimension) + 1.0))) * dimension
        return sign * clamped
    }

    private var maxUpOffset: CGFloat {
        CGFloat(selectedIndex) * itemHeight
    }

    private var maxDownOffset: CGFloat {
        CGFloat(items.count - 1 - selectedIndex) * itemHeight
    }

    private var dampedDragOffset: CGFloat {
        if dragOffset > maxUpOffset {
            let overshoot = dragOffset - maxUpOffset
            return maxUpOffset + rubberBand(overshoot, limit: maxUpOffset)
        } else if -dragOffset > maxDownOffset {
            let overshoot = -dragOffset - maxDownOffset
            return -(maxDownOffset + rubberBand(overshoot, limit: maxDownOffset))
        }
        return dragOffset
    }

    private var effectiveOffset: CGFloat {
        -CGFloat(selectedIndex) * itemHeight + dampedDragOffset
    }

    private var closestIndexDuringDrag: Int {
        let rawIndex = CGFloat(selectedIndex) - dampedDragOffset / itemHeight
        return max(0, min(items.count - 1, Int(round(rawIndex))))
    }

    var body: some View {
        let totalHeight: CGFloat = itemHeight * CGFloat(visibleItems)
        let centerY: CGFloat = totalHeight / 2

        ZStack {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                let y = centerY + CGFloat(idx) * itemHeight + effectiveOffset - itemHeight / 2
                let distFromCenter = abs(y - centerY + itemHeight / 2)
                let maxDist = totalHeight / 2
                let normalizedDist = min(distFromCenter / maxDist, 1.0)
                let isSelected = idx == closestIndexDuringDrag

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
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    dragOffset = value.translation.height

                    let current = closestIndexDuringDrag
                    if current != lastHapticIndex {
                        dragHaptic.impactOccurred(intensity: 0.7)
                        dragHaptic.prepare()
                        lastHapticIndex = current
                    }
                }
                .onEnded { value in
                    let velocityPts = value.velocity.height
                    let momentumItems = velocityPts / (itemHeight * 8)
                    let currentPosition = CGFloat(selectedIndex) - dampedDragOffset / itemHeight
                    let projectedPosition = currentPosition + momentumItems
                    let targetIndex = max(0, min(items.count - 1, Int(round(projectedPosition))))

                    let previousIndex = selectedIndex
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.82)) {
                        dragOffset = 0
                        selectedIndex = targetIndex
                    }

                    if targetIndex != previousIndex {
                        snapHaptic.impactOccurred(intensity: 1.0)
                        snapHaptic.prepare()
                        onSelect(items[targetIndex])
                    }

                    lastHapticIndex = targetIndex
                }
        )
        .onAppear {
            dragHaptic.prepare()
            snapHaptic.prepare()
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
