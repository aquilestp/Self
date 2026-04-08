import SwiftUI
import AVFoundation
import UIKit

struct OnboardingPhoneDemoView: View {
    let maxWidth: CGFloat

    @State private var isVideoReady: Bool = false

    init(maxWidth: CGFloat = 300) {
        self.maxWidth = maxWidth
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
        .aspectRatio(0.60, contentMode: .fit)
        .shadow(color: .black.opacity(0.42), radius: 30, x: 0, y: 22)
        .animation(.easeOut(duration: 0.18), value: isVideoReady)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("App demo video")
    }

    private var screenSurface: some View {
        RoundedRectangle(cornerRadius: 38, style: .continuous)
            .fill(Color(white: 0.04))
            .overlay {
                OnboardingLoopingVideoPlayer(
                    isReady: $isVideoReady,
                    resourceName: "OnboardingConnectDemo",
                    fileExtension: "mov"
                )
                .opacity(isVideoReady ? 1 : 0.01)
                .clipShape(.rect(cornerRadius: 38))
            }
            .overlay {
                ZStack {
                    LinearGradient(
                        colors: [Color(white: 0.07), Color(white: 0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    ProgressView()
                        .tint(.white.opacity(0.56))
                        .opacity(isVideoReady ? 0 : 1)
                }
                .clipShape(.rect(cornerRadius: 38))
                .opacity(isVideoReady ? 0 : 1)
            }
            .clipShape(.rect(cornerRadius: 38))
    }
}

struct OnboardingLoopingVideoPlayer: UIViewRepresentable {
    @Binding var isReady: Bool
    let resourceName: String
    let fileExtension: String

    func makeCoordinator() -> Coordinator {
        Coordinator(isReady: $isReady)
    }

    func makeUIView(context: Context) -> OnboardingPlayerView {
        let view = OnboardingPlayerView()
        context.coordinator.attach(
            to: view,
            resourceName: resourceName,
            fileExtension: fileExtension
        )
        return view
    }

    func updateUIView(_ uiView: OnboardingPlayerView, context: Context) {
    }

    @MainActor
    final class Coordinator: NSObject {
        private let isReady: Binding<Bool>
        private weak var playerView: OnboardingPlayerView?
        private var queuePlayer: AVQueuePlayer?
        private var playerLooper: AVPlayerLooper?
        private var statusObservation: NSKeyValueObservation?

        init(isReady: Binding<Bool>) {
            self.isReady = isReady
        }

        deinit {
            queuePlayer?.pause()
            playerLooper?.disableLooping()
            statusObservation?.invalidate()
        }

        func attach(to view: OnboardingPlayerView, resourceName: String, fileExtension: String) {
            guard queuePlayer == nil else { return }

            playerView = view
            isReady.wrappedValue = false
            view.playerLayer.videoGravity = .resizeAspectFill

            guard let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) else {
                return
            }

            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            item.preferredForwardBufferDuration = 0

            let player = AVQueuePlayer()
            player.isMuted = true
            player.actionAtItemEnd = .none
            player.automaticallyWaitsToMinimizeStalling = false
            view.playerLayer.player = player

            statusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] observedItem, _ in
                guard let self else { return }

                Task { @MainActor in
                    switch observedItem.status {
                    case .readyToPlay:
                        self.isReady.wrappedValue = true
                        self.queuePlayer?.playImmediately(atRate: 1)
                    case .failed:
                        self.isReady.wrappedValue = false
                    case .unknown:
                        break
                    @unknown default:
                        break
                    }
                }
            }

            queuePlayer = player
            playerLooper = AVPlayerLooper(player: player, templateItem: item)
            player.play()
        }
    }
}

final class OnboardingPlayerView: UIView {
    nonisolated override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        guard let playerLayer = layer as? AVPlayerLayer else {
            return AVPlayerLayer()
        }
        return playerLayer
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingPhoneDemoView()
            .padding(24)
    }
    .preferredColorScheme(.dark)
}
