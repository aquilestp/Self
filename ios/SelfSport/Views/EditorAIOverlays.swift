import SwiftUI
import UIKit

extension PhotoEditorView {

    func aiReviewOverlay(editedImage: UIImage) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()

            let displayImage = aiReviewShowingOriginal ? photoBeforeAIEdit : editedImage

            Image(uiImage: displayImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(aiReviewAppeared ? 1.0 : 0.92)
                .opacity(aiReviewAppeared ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.25), value: aiReviewShowingOriginal)

            VStack {
                VStack(spacing: 10) {
                    Text("AI Edit · \(aiGenerationStyle)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .tracking(0.3)

                    Button {
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: aiReviewShowingOriginal ? "eye.slash" : "eye")
                                .font(.system(size: 12, weight: .semibold))
                            Text(aiReviewShowingOriginal ? "Edited" : "Original")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(.ultraThinMaterial, in: .capsule)
                        .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 0.5))
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.15)
                            .onChanged { _ in
                                if !aiReviewShowingOriginal {
                                    hapticLight.impactOccurred()
                                    aiReviewShowingOriginal = true
                                }
                            }
                    )
                    .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                        if !pressing && aiReviewShowingOriginal {
                            hapticLight.impactOccurred()
                            aiReviewShowingOriginal = false
                        }
                    }, perform: {})
                }
                .padding(.top, 60)
                .opacity(aiReviewAppeared ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: aiReviewAppeared)

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        discardAIEdit()
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
                        acceptAIEdit()
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
                .opacity(aiReviewAppeared ? 1.0 : 0.0)
                .offset(y: aiReviewAppeared ? 0 : 30)
                .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(0.25), value: aiReviewAppeared)
            }
        }
    }

    var aiGenerationOverlay: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.15), Color.white.opacity(0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(aiPulseAnimation ? 1.15 : 0.85)
                        .opacity(aiPulseAnimation ? 0.6 : 0.3)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: aiPulseAnimation)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.25), Color.white.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)

                    Image(systemName: "sparkles")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(.white)
                        .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: aiPulseAnimation)
                }

                VStack(spacing: 8) {
                    Text("Applying \(aiGenerationStyle) style...")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("This may take a few seconds")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }

    func startAIGeneration() {
        guard let style = selectedEditStyle else { return }
        let styleKey = style.rawValue.lowercased()
        aiGenerationStyle = style.rawValue

        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            showEditStyleDrawer = false
            selectedEditStyle = nil
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            isGeneratingAI = true
            aiPulseAnimation = true
        }

        let imageToEdit: UIImage
        if includeStatsOverlay && hasCanvasContent, let captured = captureCanvas() {
            imageToEdit = captured
        } else {
            imageToEdit = currentPhoto
        }

        aiGenerationTask = Task {
            do {
                let editedImage = try await grokService.generateEditedImage(
                    photo: imageToEdit,
                    styleKey: styleKey
                )

                guard !Task.isCancelled else { return }

                HapticService.notification.notificationOccurred(.success)

                aiReviewImage = editedImage
                aiReviewShowingOriginal = false
                aiReviewAppeared = false

                withAnimation(.easeInOut(duration: 0.4)) {
                    isGeneratingAI = false
                    aiPulseAnimation = false
                    showAIReview = true
                }

                withAnimation(.spring(response: 0.5, dampingFraction: 0.78).delay(0.15)) {
                    aiReviewAppeared = true
                }
            } catch {
                guard !Task.isCancelled else { return }

                HapticService.notification.notificationOccurred(.error)

                withAnimation(.easeInOut(duration: 0.3)) {
                    isGeneratingAI = false
                    aiPulseAnimation = false
                }
                aiErrorMessage = error.localizedDescription
                showAIErrorAlert = true
            }
            aiGenerationTask = nil
        }
    }

    func startVideoGeneration() {
        let imageToCapture: UIImage
        if includeStatsOverlay && hasCanvasContent, let captured = captureCanvas() {
            imageToCapture = captured
        } else {
            imageToCapture = currentPhoto
        }

        videoPreviewImage = imageToCapture
        withAnimation(.easeInOut(duration: 0.4)) {
            showVideoGeneration = true
        }
    }

    func cancelAIGeneration() {
        aiGenerationTask?.cancel()
        aiGenerationTask = nil
        withAnimation(.easeInOut(duration: 0.3)) {
            isGeneratingAI = false
            aiPulseAnimation = false
        }
    }

    func acceptAIEdit() {
        guard let reviewImage = aiReviewImage else { return }
        HapticService.notification.notificationOccurred(.success)

        withAnimation(.easeInOut(duration: 0.35)) {
            aiEditedPhoto = reviewImage
            showAIReview = false
        }
        aiReviewImage = nil
        aiReviewShowingOriginal = false
        aiReviewAppeared = false
    }

    func discardAIEdit() {
        hapticMedium.impactOccurred()

        withAnimation(.easeInOut(duration: 0.3)) {
            showAIReview = false
        }
        aiReviewImage = nil
        aiReviewShowingOriginal = false
        aiReviewAppeared = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                drawerState = .collapsed
                showEditStyleDrawer = true
            }
        }
    }
}
