import SwiftUI

struct GoogleMarkView: View {
    var body: some View {
        Text("G")
            .font(.title2.weight(.bold))
            .foregroundStyle(
                AngularGradient(
                    colors: [.blue, .green, .yellow, .red, .blue],
                    center: .center
                )
            )
            .frame(width: 28, height: 28)
            .accessibilityHidden(true)
    }
}
