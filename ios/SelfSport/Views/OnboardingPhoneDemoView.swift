import SwiftUI
import UIKit

struct OnboardingPhoneDemoView: View {
    let maxWidth: CGFloat
    let gifName: String

    init(maxWidth: CGFloat = 300, gifName: String = "onboarding_demo") {
        self.maxWidth = maxWidth
        self.gifName = gifName
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 46, style: .continuous)
                .fill(.black.opacity(0.96))
                .overlay {
                    RoundedRectangle(cornerRadius: 46, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                }
                .overlay(alignment: .top) {
                    Capsule(style: .continuous)
                        .fill(.black)
                        .frame(width: 118, height: 28)
                        .padding(.top, 10)
                }
                .overlay {
                    screenSurface
                        .padding(10)
                }
        }
        .frame(maxWidth: maxWidth)
        .aspectRatio(9.0 / 19.5, contentMode: .fit)
        .shadow(color: .black.opacity(0.42), radius: 30, x: 0, y: 22)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("App demo")
    }

    private var screenSurface: some View {
        RoundedRectangle(cornerRadius: 38, style: .continuous)
            .fill(Color(white: 0.04))
            .overlay {
                AnimatedGIFView(gifName: gifName)
                    .clipShape(.rect(cornerRadius: 38))
            }
            .clipShape(.rect(cornerRadius: 38))
    }
}

struct AnimatedGIFView: UIViewRepresentable {
    let gifName: String

    init(gifName: String = "onboarding_demo") {
        self.gifName = gifName
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.clipsToBounds = true

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        if let gifURL = Bundle.main.url(forResource: gifName, withExtension: "gif"),
           let gifData = try? Data(contentsOf: gifURL),
           let source = CGImageSourceCreateWithData(gifData as CFData, nil) {
            let frameCount = CGImageSourceGetCount(source)
            var images: [UIImage] = []
            var totalDuration: Double = 0

            for i in 0..<frameCount {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: cgImage))

                    if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                       let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                        let frameDuration = (gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double)
                            ?? (gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double)
                            ?? 0.1
                        totalDuration += frameDuration
                    } else {
                        totalDuration += 0.1
                    }
                }
            }

            imageView.animationImages = images
            imageView.animationDuration = totalDuration
            imageView.animationRepeatCount = 0
            imageView.startAnimating()
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingPhoneDemoView()
            .padding(24)
    }
    .preferredColorScheme(.dark)
}
