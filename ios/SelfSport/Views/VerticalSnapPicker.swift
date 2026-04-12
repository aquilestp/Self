import SwiftUI

struct VerticalSnapPicker<Item: Hashable, RowContent: View>: View {
    let items: [Item]
    let selectedItem: Item
    let width: CGFloat
    let visibleItems: Int
    let onSelect: (Item) -> Void
    @ViewBuilder let rowContent: (Item, Bool) -> RowContent

    private let itemHeight: CGFloat = 40

    @State private var scrolledIndex: Int?
    @State private var hapticTrigger: Int = 0

    private let haptic = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        let totalHeight: CGFloat = itemHeight * CGFloat(visibleItems)
        let verticalMargin: CGFloat = (totalHeight - itemHeight) / 2

        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                    let isSelected = idx == scrolledIndex
                    rowContent(item, isSelected)
                        .frame(width: width, height: itemHeight, alignment: .trailing)
                        .opacity(isSelected ? 1.0 : 0.35)
                        .scaleEffect(isSelected ? 1.0 : 0.92)
                        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
                        .id(idx)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrolledIndex, anchor: .center)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.vertical, verticalMargin)
        .scrollIndicators(.hidden)
        .frame(width: width, height: totalHeight)
        .onChange(of: scrolledIndex) { _, newIndex in
            guard let newIndex,
                  newIndex >= 0,
                  newIndex < items.count else { return }
            let newItem = items[newIndex]
            guard newItem != selectedItem else { return }
            hapticTrigger += 1
            onSelect(newItem)
        }
        .sensoryFeedback(.impact(weight: .medium, intensity: 0.85), trigger: hapticTrigger)
        .onAppear {
            haptic.prepare()
            if let idx = items.firstIndex(of: selectedItem) {
                scrolledIndex = idx
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            if let idx = items.firstIndex(of: newValue) {
                guard idx != scrolledIndex else { return }
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    scrolledIndex = idx
                }
            }
        }
    }
}
