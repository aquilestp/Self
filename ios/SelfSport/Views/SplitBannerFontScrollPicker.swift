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
                .fill(.ultraThinMaterial)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .black.opacity(0.3), location: 0.4),
                            .init(color: .black, location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: .black.opacity(0.2), location: 0.5),
                                    .init(color: .black.opacity(0.55), location: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: .white.opacity(0.12), location: 0.5),
                                    .init(color: .white.opacity(0.25), location: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 0.5
                        )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
