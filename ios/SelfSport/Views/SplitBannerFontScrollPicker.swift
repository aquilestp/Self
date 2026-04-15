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
        }

    }
}
