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

    private let selectionHaptic = UISelectionFeedbackGenerator()

    private func rubberBand(_ offset: CGFloat) -> CGFloat {
        let maxUp = CGFloat(selectedIndex) * itemHeight
        let maxDown = CGFloat(items.count - 1 - selectedIndex) * itemHeight
        let total = offset + CGFloat(0)

        if total > maxUp {
            let overshoot = total - maxUp
            let dampened = maxUp + overshoot * 0.25
            return dampened
        } else if -total > maxDown {
            let overshoot = -total - maxDown
            let dampened = -(maxDown + overshoot * 0.25)
            return dampened
        }
        return offset
    }

    private var effectiveOffset: CGFloat {
        -CGFloat(selectedIndex) * itemHeight + rubberBand(dragOffset)
    }

    private var closestIndexDuringDrag: Int {
        let rawIndex = CGFloat(selectedIndex) - rubberBand(dragOffset) / itemHeight
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
                let isSelected = idx == selectedIndex && dragOffset == 0

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
            DragGesture(minimumDistance: 3)
                .onChanged { value in
                    dragOffset = value.translation.height

                    let current = closestIndexDuringDrag
                    if current != lastHapticIndex {
                        selectionHaptic.selectionChanged()
                        lastHapticIndex = current
                    }
                }
                .onEnded { value in
                    let velocity = value.predictedEndTranslation.height - value.translation.height
                    let momentumOffset = rubberBand(dragOffset) + velocity * 0.15
                    let rawTarget = CGFloat(selectedIndex) - momentumOffset / itemHeight
                    let targetIndex = max(0, min(items.count - 1, Int(round(rawTarget))))

                    let previousIndex = selectedIndex
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.82)) {
                        dragOffset = 0
                        selectedIndex = targetIndex
                    }

                    if targetIndex != previousIndex {
                        onSelect(items[targetIndex])
                    }

                    lastHapticIndex = targetIndex
                }
        )
        .onAppear {
            selectionHaptic.prepare()
            if let idx = items.firstIndex(of: selectedItem) {
                selectedIndex = idx
                lastHapticIndex = idx
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            if let idx = items.firstIndex(of: newValue) {
                guard idx != selectedIndex else { return }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.82)) {
                    selectedIndex = idx
                }
                lastHapticIndex = idx
            }
        }
    }
}
