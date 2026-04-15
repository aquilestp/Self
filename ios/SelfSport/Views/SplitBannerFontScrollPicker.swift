import SwiftUI

struct SplitBannerFontScrollPicker: View {
    let currentStyle: SplitBannerFontStyle
    let onSelectStyle: (SplitBannerFontStyle) -> Void

    private let allStyles: [SplitBannerFontStyle] = SplitBannerFontStyle.allCases.map { $0 }

    var body: some View {
        VerticalSnapPicker(
            items: allStyles,
            selectedItem: currentStyle,
            width: 130,
            visibleItems: 5,
            onSelect: onSelectStyle
        ) { style, isSelected in
            Text(style.label)
                .font(style.font(size: isSelected ? 13 : 11))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.45))
                .lineLimit(1)
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
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.black.opacity(0.4))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
