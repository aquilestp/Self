import SwiftUI

struct StyledCanvasText: View {
    let text: String
    let styleType: TextStyleType
    let styleColor: Color
    var maxWidth: CGFloat = .infinity

    var body: some View {
        Text(text)
            .font(styleType.swiftUIFont)
            .italic(styleType.isItalic)
            .foregroundStyle(styleColor)
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
            .frame(maxWidth: maxWidth)
            .fixedSize(horizontal: false, vertical: true)
    }
}
