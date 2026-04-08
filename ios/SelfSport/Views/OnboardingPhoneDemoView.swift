import SwiftUI
import AVFoundation
import UIKit

struct OnboardingPhoneDemoView: View {
    let maxWidth: CGFloat
    let preloadedCoordinator: OnboardingVideoCoordinator?

    @State private var isVideoReady: Bool = false

    init(maxWidth: CGFloat = 300, preloadedCoordinator: OnboardingVideoCoordinator? = nil) {
        self.maxWidth = maxWidth
        self.preloadedCoordinator = preloadedCoordinator
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
                    preloadedCoordinator: preloadedCoordinator
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

@MainActor
final class OnboardingVideoCoordinator: NSObject {
    var queuePlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    private var statusObservation: NSKeyValueObservation?
    var isReady: Bool = false
    private var onReady: (() -> Void)?

    func preload() {
        guard queuePlayer == nil else { return }

        guard let url = Bundle.main.url(forResource: "OnboardingConnectDemo", withExtension: "mov") else {
            return
        }

        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        item.preferredForwardBufferDuration = 0

        let player = AVQueuePlayer(items: [item])
        player.isMuted = true
        player.actionAtItemEnd = .advance
        player.automaticallyWaitsToMinimizeStalling = false

        let looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(asset: asset))

        statusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] observedItem, _ in
            guard let self else { return }
            Task { @MainActor in
                if observedItem.status == .readyToPlay {
                    self.isReady = true
                    self.onReady?()
                }
            }
        }

        queuePlayer = player
        playerLooper = looper
        player.play()
    }

    func attachAndPlay(to view: OnboardingPlayerUIView, onReady: @escaping () -> Void) {
        view.playerLayer.videoGravity = .resizeAspectFill
        view.playerLayer.player = queuePlayer
        self.onReady = onReady

        if isReady {
            onReady()
        }
        queuePlayer?.play()
    }

    func stop() {
        queuePlayer?.pause()
        playerLooper?.disableLooping()
        statusObservation?.invalidate()
    }
}

struct OnboardingLoopingVideoPlayer: UIViewRepresentable {
    @Binding var isReady: Bool
    let preloadedCoordinator: OnboardingVideoCoordinator?

    func makeUIView(context: Context) -> OnboardingPlayerUIView {
        let view = OnboardingPlayerUIView()
        if let coordinator = preloadedCoordinator {
            coordinator.attachAndPlay(to: view) {
                isReady = true
            }
        }
        return view
    }

    func updateUIView(_ uiView: OnboardingPlayerUIView, context: Context) {
    }
}

final class OnboardingPlayerUIView: UIView {
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
