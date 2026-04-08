import SwiftUI

struct TextStyleCarousel: View {
    @Binding var selectedStyle: TextStyleType
    @State private var scrolledID: TextStyleType.ID?
    private let haptic = HapticService.light

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(TextStyleType.allCases) { style in
                    stylePreview(style: style, isSelected: style == selectedStyle)
                        .id(style.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrolledID, anchor: .center)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, UIScreen.main.bounds.width / 2 - 40)
        .scrollIndicators(.hidden)
        .padding(.vertical, 16)
        .onChange(of: scrolledID) { _, newID in
            guard let newID,
                  let newStyle = TextStyleType.allCases.first(where: { $0.id == newID }),
                  newStyle != selectedStyle else { return }
            haptic.impactOccurred()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedStyle = newStyle
            }
        }
        .onAppear {
            scrolledID = selectedStyle.id
        }
    }

    private func stylePreview(style: TextStyleType, isSelected: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(width: 72, height: 42)

            Text(style.label)
                .font(style.previewFont(size: isSelected ? 13 : 11))
                .italic(style.isItalic)
                .foregroundStyle(.white.opacity(isSelected ? 1.0 : 0.4))
                .lineLimit(1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isSelected ? Color.white.opacity(0.8) : Color.white.opacity(0.15), lineWidth: 1.5)
        )
        .scaleEffect(isSelected ? 1.15 : 0.9)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
    }
}
