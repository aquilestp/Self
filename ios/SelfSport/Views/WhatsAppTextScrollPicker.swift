import SwiftUI

struct WhatsAppTextScrollPicker: View {
    let presets: [String]
    let currentText: String
    let onSelectPreset: (String) -> Void

    private let itemHeight: CGFloat = 33.5
    private let visibleItems: Int = 5

    @State private var scrolledID: String?
    @State private var lastSelectedId: String?

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        let totalHeight: CGFloat = itemHeight * CGFloat(visibleItems)

        VStack(spacing: 6) {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    Color.clear.frame(height: itemHeight * 2)

                    ForEach(presets, id: \.self) { preset in
                        presetRow(text: preset)
                            .frame(height: itemHeight)
                            .id(preset)
                    }

                    Color.clear.frame(height: itemHeight * 2)
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrolledID, anchor: .center)
            .scrollTargetBehavior(.viewAligned)
            .frame(height: totalHeight)
            .frame(width: 167)
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
                if presets.contains(currentText) {
                    initialId = currentText
                } else {
                    initialId = presets.first ?? ""
                }
                scrolledID = initialId
                lastSelectedId = initialId
            }
            .onChange(of: scrolledID) { _, newValue in
                guard let newValue, newValue != lastSelectedId else { return }
                lastSelectedId = newValue
                haptic.impactOccurred()
                onSelectPreset(newValue)
            }

        }
    }

    @ViewBuilder
    private func presetRow(text: String) -> some View {
        let isSelected = scrolledID == text

        Text(text)
            .font(.system(size: isSelected ? 12 : 10, weight: isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? .white : .white.opacity(0.45))
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 11)
            .padding(.vertical, 4)
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
            .frame(width: 167, alignment: .trailing)
            .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}
