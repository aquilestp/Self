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

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    private var currentOffset: CGFloat {
        -CGFloat(selectedIndex) * itemHeight + dragOffset
    }

    var body: some View {
        let totalHeight: CGFloat = itemHeight * CGFloat(visibleItems)
        let centerY: CGFloat = totalHeight / 2

        ZStack {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                let y = centerY + CGFloat(idx) * itemHeight + currentOffset - itemHeight / 2
                let distFromCenter = abs(y - centerY + itemHeight / 2)
                let maxDist = totalHeight / 2
                let normalizedDist = min(distFromCenter / maxDist, 1.0)
                let isSelected = idx == selectedIndex && dragOffset == 0

                rowContent(item, isSelected)
                    .frame(height: itemHeight)
                    .frame(width: width, alignment: .trailing)
                    .opacity(1.0 - normalizedDist * 0.8)
                    .position(x: width / 2, y: y)
            }
        }
        .frame(width: width, height: totalHeight)
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
                    let newIndex = max(0, min(items.count - 1, selectedIndex + clampedSteps))

                    let previousIndex = selectedIndex
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        dragOffset = 0
                        selectedIndex = newIndex
                    }

                    if newIndex != previousIndex {
                        haptic.impactOccurred()
                        onSelect(items[newIndex])
                    }
                }
        )
        .onAppear {
            if let idx = items.firstIndex(of: selectedItem) {
                selectedIndex = idx
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            if let idx = items.firstIndex(of: newValue) {
                guard idx != selectedIndex else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    selectedIndex = idx
                }
            }
        }
    }
}
