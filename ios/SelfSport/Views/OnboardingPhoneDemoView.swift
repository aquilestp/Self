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
    private var errorObservation: NSKeyValueObservation?
    var isReady: Bool = false
    private var onReady: (() -> Void)?
    private var retryCount: Int = 0
    private let maxRetries: Int = 3

    private static let remoteURL = URL(string: "https://r2-pub.rork.com/attachments/d1hbppe43o59ckb7fvhvb.mov")!

    func preload() {
        guard queuePlayer == nil else { return }
        setupStreamingPlayer()
    }

    private func setupStreamingPlayer() {
        statusObservation?.invalidate()
        errorObservation?.invalidate()
        queuePlayer?.pause()
        playerLooper?.disableLooping()

        let asset = AVURLAsset(url: Self.remoteURL, options: [
            "AVURLAssetHTTPHeaderFieldsKey": ["Accept": "*/*"],
            AVURLAssetPreferPreciseDurationAndTimingKey: false
        ])

        let templateItem = AVPlayerItem(asset: asset)
        templateItem.preferredForwardBufferDuration = 2

        let player = AVQueuePlayer(items: [templateItem])
        player.isMuted = true
        player.actionAtItemEnd = .advance
        player.automaticallyWaitsToMinimizeStalling = true

        let looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(asset: asset))

        statusObservation = templateItem.observe(\.status, options: [.initial, .new]) { [weak self] observedItem, _ in
            guard let self else { return }
            Task { @MainActor in
                switch observedItem.status {
                case .readyToPlay:
                    self.isReady = true
                    self.onReady?()
                case .failed:
                    self.handlePlaybackError()
                default:
                    break
                }
            }
        }

        errorObservation = player.observe(\.status, options: [.new]) { [weak self] observedPlayer, _ in
            guard let self else { return }
            Task { @MainActor in
                if observedPlayer.status == .failed {
                    self.handlePlaybackError()
                }
            }
        }

        queuePlayer = player
        playerLooper = looper
        player.play()
    }

    private func handlePlaybackError() {
        guard retryCount < maxRetries else { return }
        retryCount += 1
        let delay = retryCount
        Task {
            try? await Task.sleep(for: .seconds(delay))
            setupStreamingPlayer()
        }
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
        errorObservation?.invalidate()
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
