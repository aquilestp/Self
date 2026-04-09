import SwiftUI

struct WordmarkView: View {
    @ScaledMetric(relativeTo: .largeTitle) private var scale: CGFloat = 2.75
    @ScaledMetric(relativeTo: .largeTitle) private var verticalPadding: CGFloat = 28

    var body: some View {
        Text("self")
            .font(.system(.largeTitle, design: .serif, weight: .regular).width(.compressed))
            .italic()
            .tracking(-1.2)
            .foregroundStyle(.white.opacity(0.96))
            .scaleEffect(scale)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Self")
    }
}
