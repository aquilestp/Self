import SwiftUI
import AVKit
import Photos

struct VideoGenerationView: View {
    let previewImage: UIImage
    let onDiscard: () -> Void
    let onKeep: () -> Void

    @State private var phase: VideoGenPhase = .selectStyle
    @State private var videoLocalURL: URL? = nil
    @State private var videoTask: Task<Void, Never>? = nil
    @State private var appeared: Bool = false
    @State private var glowPhase: Bool = false
    @State private var glowColorIndex: Int = 0
    @State private var dotCount: Int = 0
    @State private var dotTimer: Timer? = nil
    @State private var glowColorTimer: Timer? = nil
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showSaved: Bool = false
    @State private var elapsedSeconds: Int = 0
    @State private var elapsedTimer: Timer? = nil
    @State private var player: AVPlayer? = nil
    @State private var playerLooper: Any? = nil
    @State private var selectedStyle: VideoStylePrompt? = nil
    @State private var isLoadingStyles: Bool = true
    @State private var quotaService = AIQuotaService.shared
    @State private var showQuotaPaywall: Bool = false

    private let videoService = GrokVideoService()
    private let glowColors: [Color] = [
        Color(red: 0.8, green: 0.65, blue: 0.2),
        Color(red: 0.2, green: 0.75, blue: 0.4),
        Color(red: 0.9, green: 0.25, blue: 0.25),
        Color(red: 0.25, green: 0.5, blue: 0.95),
        Color.white
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch phase {
            case .selectStyle:
                styleSelectionContent
            case .generating:
                generatingContent
            case .done:
                resultContent
            }
        }
        .statusBarHidden()
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            Task { await loadStyles() }
        }
        .onDisappear {
            videoTask?.cancel()
            dotTimer?.invalidate()
            elapsedTimer?.invalidate()
            glowColorTimer?.invalidate()
            player?.pause()
        }
        .alert("Error", isPresented: $showError) {
            Button("Retry") { startGeneration() }
            Button("Cancel", role: .cancel) { onDiscard() }
        } message: {
            Text(errorMessage)
        }
        .alert("Video Saved!", isPresented: $showSaved) {
            Button("OK") { onKeep() }
        } message: {
            Text("Your video has been saved to the photo library.")
        }
        .fullScreenCover(isPresented: $showQuotaPaywall) {
            AIQuotaPaywallView(
                kind: .video,
                daysUntilNextSlot: quotaService.daysUntilNextSlot(for: .video),
                onDismiss: {
                    showQuotaPaywall = false
                    onDiscard()
                }
            )
        }
    }

    // MARK: - Style Selection

    private var styleSelectionContent: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    onDiscard()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.1), in: .circle)
                }
                .buttonStyle(.plain)
                .padding(.leading, 20)
                .padding(.top, 16)
                Spacer()
                AIQuotaBadge(
                    kind: .video,
                    used: quotaService.videosUsed,
                    limit: AIQuotaService.videoLimit
                )
                .padding(.trailing, 20)
                .padding(.top, 16)
            }

            Spacer()

            ZStack {
                Image(uiImage: previewImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 40)
                    .blur(radius: 6)
                    .opacity(0.5)

                Image(uiImage: previewImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 40)
                    .clipShape(.rect(cornerRadius: 16))
            }
            .scaleEffect(appeared ? 1.0 : 0.92)
            .opacity(appeared ? 1.0 : 0.0)

            VStack(spacing: 16) {
                Text("Choose animation style")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.top, 24)

                if isLoadingStyles {
                    ProgressView()
                        .tint(.white)
                        .frame(height: 80)
                } else {
                    styleGrid
                }
            }

            Spacer()

            Button {
                startGeneration()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .bold))
                    Text(selectedStyle == nil ? "Auto Animate" : "Generate")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0.28), Color.white.opacity(0.18)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: .rect(cornerRadius: 14)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
    }

    private var styleGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                styleChip(label: "Auto", icon: "wand.and.stars", isSelected: selectedStyle == nil) {
                    selectedStyle = nil
                }

                ForEach(videoService.videoStyles) { style in
                    styleChip(
                        label: style.displayName,
                        icon: style.icon,
                        isSelected: selectedStyle?.id == style.id
                    ) {
                        if selectedStyle?.id == style.id {
                            selectedStyle = nil
                        } else {
                            selectedStyle = style
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .contentMargins(.horizontal, 0)
    }

    private func styleChip(label: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                Text(label)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isSelected ? .black : .white.opacity(0.85))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? AnyShapeStyle(.white)
                    : AnyShapeStyle(.white.opacity(0.1)),
                in: .capsule
            )
            .overlay(
                Capsule()
                    .stroke(.white.opacity(isSelected ? 0 : 0.15), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Generating

    private var generatingContent: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    videoTask?.cancel()
                    onDiscard()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.1), in: .circle)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
                .padding(.top, 16)
            }

            Spacer()

            ZStack {
                Image(uiImage: previewImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .blur(radius: 6)
                    .opacity(0.6)

                Image(uiImage: previewImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .clipShape(.rect(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderGradient, lineWidth: 2)
                            .padding(.horizontal, 24)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderGradient, lineWidth: 6)
                            .blur(radius: 12)
                            .opacity(glowPhase ? 0.8 : 0.3)
                            .padding(.horizontal, 24)
                    )
            }

            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Text("Generating video")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(String(repeating: ".", count: dotCount))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 30, alignment: .leading)
                }

                if let style = selectedStyle {
                    Text(style.displayName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Text(elapsedText)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white.opacity(0.4))
                    .monospacedDigit()
            }
            .padding(.top, 28)

            Spacer()
        }
    }

    private var borderGradient: LinearGradient {
        let color = glowColors[glowColorIndex]
        let nextColor = glowColors[(glowColorIndex + 1) % glowColors.count]
        return LinearGradient(
            colors: [color, nextColor, color.opacity(0.3)],
            startPoint: glowPhase ? .topLeading : .bottomTrailing,
            endPoint: glowPhase ? .bottomTrailing : .topLeading
        )
    }

    private var elapsedText: String {
        let mins = elapsedSeconds / 60
        let secs = elapsedSeconds % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }

    // MARK: - Result

    private var resultContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Text("AI Video")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(0.3)
            }
            .padding(.top, 60)

            Spacer()

            if let player {
                VideoPlayer(player: player)
                    .aspectRatio(9.0 / 16.0, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .clipShape(.rect(cornerRadius: 16))
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            Spacer()

            HStack(spacing: 16) {
                Button {
                    cleanupVideo()
                    onDiscard()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Discard")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white.opacity(0.1), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.white.opacity(0.12), lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)

                Button {
                    saveVideoToPhotos()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Keep")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color.white.opacity(0.28), Color.white.opacity(0.18)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: .rect(cornerRadius: 14)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
    }

    // MARK: - Logic

    private func loadStyles() async {
        await videoService.loadVideoStyles()
        isLoadingStyles = false
    }

    private func startGeneration() {
        if !quotaService.hasVideoQuota {
            showQuotaPaywall = true
            return
        }
        let prompt = selectedStyle?.promptTemplate

        withAnimation(.easeInOut(duration: 0.4)) {
            phase = .generating
        }
        elapsedSeconds = 0
        startDotAnimation()
        startElapsedTimer()
        startGlowAnimation()

        videoTask = Task {
            do {
                let requestId = try await videoService.startGeneration(image: previewImage, prompt: prompt)
                try Task.checkCancellation()

                let remoteURL = try await videoService.pollUntilDone(requestId: requestId)
                try Task.checkCancellation()

                let localURL = try await videoService.downloadVideo(from: remoteURL)
                try Task.checkCancellation()

                videoLocalURL = localURL
                dotTimer?.invalidate()
                elapsedTimer?.invalidate()
                glowColorTimer?.invalidate()

                await quotaService.recordUsage(.video)

                HapticService.notification.notificationOccurred(.success)

                setupPlayer(url: localURL)

                withAnimation(.easeInOut(duration: 0.5)) {
                    phase = .done
                }
            } catch is CancellationError {
                return
            } catch is VideoGenerationError where Task.isCancelled {
                return
            } catch {
                guard !Task.isCancelled else { return }
                HapticService.notification.notificationOccurred(.error)
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func setupPlayer(url: URL) {
        let item = AVPlayerItem(url: url)
        let avPlayer = AVQueuePlayer(playerItem: item)
        let looper = AVPlayerLooper(player: avPlayer, templateItem: item)
        playerLooper = looper
        avPlayer.play()
        player = avPlayer
    }

    private func saveVideoToPhotos() {
        guard let localURL = videoLocalURL else { return }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                Task { @MainActor in
                    errorMessage = "Photo library access is required to save the video."
                    showError = true
                }
                return
            }

            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: localURL)
            } completionHandler: { success, error in
                Task { @MainActor in
                    if success {
                        HapticService.notification.notificationOccurred(.success)
                        showSaved = true
                    } else {
                        errorMessage = error?.localizedDescription ?? "Failed to save video"
                        showError = true
                    }
                }
            }
        }
    }

    private func cleanupVideo() {
        player?.pause()
        player = nil
        playerLooper = nil
        if let url = videoLocalURL {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func startDotAnimation() {
        dotTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }

    private func startElapsedTimer() {
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowPhase = true
        }
        glowColorTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.8)) {
                glowColorIndex = (glowColorIndex + 1) % glowColors.count
            }
        }
    }
}

nonisolated enum VideoGenPhase: Sendable {
    case selectStyle
    case generating
    case done
}
