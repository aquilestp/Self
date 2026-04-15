import SwiftUI

struct WhatsAppTextScrollPicker: View {
    let presets: [String]
    let currentText: String
    let onSelectPreset: (String) -> Void

    var body: some View {
        VStack(spacing: 6) {
            VerticalSnapPicker(
                items: presets,
                selectedItem: currentText,
                width: 167,
                visibleItems: 5,
                onSelect: onSelectPreset
            ) { text, isSelected in
                Text(text)
                    .font(.system(size: isSelected ? 12 : 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.45))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 4)
            }
        }
    }
}
