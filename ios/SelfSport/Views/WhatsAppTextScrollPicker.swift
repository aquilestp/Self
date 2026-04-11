import SwiftUI

struct WhatsAppTextScrollPicker: View {
    let presets: [String]
    let currentText: String
    let onSelectPreset: (String) -> Void
    let onEditTapped: () -> Void

    private let itemHeight: CGFloat = 36
    private let visibleItems: Int = 5
    private let editItemId: String = "__wa_edit__"

    @State private var scrolledID: String?
    @State private var lastSelectedId: String?

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    private var allItemIds: [String] {
        presets + [editItemId]
    }

    var body: some View {
        let totalHeight: CGFloat = itemHeight * CGFloat(visibleItems)

        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                Color.clear.frame(height: itemHeight * 2)

                ForEach(allItemIds, id: \.self) { itemId in
                    itemRow(itemId: itemId)
                        .frame(height: itemHeight)
                        .id(itemId)
                }

                Color.clear.frame(height: itemHeight * 2)
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrolledID, anchor: .center)
        .scrollTargetBehavior(.viewAligned)
        .frame(height: totalHeight)
        .frame(width: 180)
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
            let initialId: String
            if let idx = presets.firstIndex(of: currentText) {
                initialId = presets[idx]
            } else if presets.contains(currentText) {
                initialId = currentText
            } else {
                initialId = presets.first ?? editItemId
            }
            scrolledID = initialId
            lastSelectedId = initialId
        }
        .onChange(of: scrolledID) { _, newValue in
            guard let newValue, newValue != lastSelectedId else { return }
            lastSelectedId = newValue
            haptic.impactOccurred()

            if newValue == editItemId {
                onEditTapped()
            } else {
                onSelectPreset(newValue)
            }
        }
    }

    @ViewBuilder
    private func itemRow(itemId: String) -> some View {
        let isSelected = scrolledID == itemId
        let isCustomActive = itemId == editItemId && !presets.contains(currentText)

        Group {
            if itemId == editItemId {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Edit")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(isSelected || isCustomActive ? .white : .white.opacity(0.5))
            } else {
                Text(itemId)
                    .font(.system(size: isSelected ? 13 : 11, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.45))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 10)
        .background(
            Group {
                if isSelected {
                    Capsule()
                        .fill(Color(red: 0.00, green: 0.37, blue: 0.33))
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                        )
                }
            }
        )
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}
