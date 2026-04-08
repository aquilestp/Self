import SwiftUI

struct DynamicCityOverlay: View, Equatable {
    let size: CGSize
    let overlayURL: URL?

    static func == (lhs: DynamicCityOverlay, rhs: DynamicCityOverlay) -> Bool {
        lhs.size == rhs.size && lhs.overlayURL == rhs.overlayURL
    }

    var body: some View {
        if let url = overlayURL {
            Color.clear
                .frame(width: size.width, height: size.height)
                .overlay {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: size.width)
                                .allowsHitTesting(false)
                        case .failure:
                            EmptyView()
                        case .empty:
                            ProgressView()
                                .tint(.white.opacity(0.4))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                .clipShape(.rect)
                .allowsHitTesting(false)
        }
    }
}
