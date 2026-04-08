import SwiftUI

struct StatTapHintView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "hand.tap")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.56))

            Text("tap stat for colors & style")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.76))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.9), in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.95), lineWidth: 0.55)
        }
        .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 5)
    }
}
