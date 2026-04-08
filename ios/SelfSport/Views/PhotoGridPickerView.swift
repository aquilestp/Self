import Photos
import SwiftUI
import UIKit

struct PhotoGridPickerView: View {
    let activity: ActivityHighlight
    @Bindable var stravaViewModel: StravaViewModel
    let onPhotoPicked: (UIImage) -> Void
    let onGoBack: () -> Void

    @State private var photoService = PhotoLibraryService()
    @State private var selectedAsset: PHAsset?
    @State private var isLoadingFullImage: Bool = false
    @State private var thumbnailCache: [String: UIImage] = [:]

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    private let thumbnailSize = CGSize(
        width: (UIScreen.main.bounds.width / 3) * UIScreen.main.scale,
        height: (UIScreen.main.bounds.width / 3) * 1.4 * UIScreen.main.scale
    )

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            navBar

            Group {
                if photoService.needsPermission {
                    permissionPrompt
                } else if photoService.isDenied {
                    deniedView
                } else if photoService.isLoading && photoService.assets.isEmpty {
                    loadingView
                } else {
                    photoGrid
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if selectedAsset != nil {
                continueButton
                    .transition(.opacity)
            }
        }
        .background(Color.black)
        .offset(x: dragOffset)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onChanged { value in
                    if value.translation.width > 0 {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    if value.translation.width > 100 {
                        withAnimation(.snappy(duration: 0.28)) {
                            dragOffset = UIScreen.main.bounds.width
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            onGoBack()
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedAsset?.localIdentifier)
        .onAppear {
            photoService.checkStatus()
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        ZStack {
            Text("Select your pic")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)

            HStack {
                Button(action: onGoBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundStyle(Color.white.opacity(0.85))
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Permission Prompt

    private var permissionPrompt: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 110, height: 110)

                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 86, height: 86)

                Image(systemName: "photo.stack")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.60))
            }

            VStack(spacing: 10) {
                Text("Access your photos")
                    .font(.system(size: 24, weight: .regular, design: .serif).italic())
                    .foregroundStyle(Color.white.opacity(0.96))

                Text("We need access to your photo library to\nselect images for your shareable moments.")
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.40))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            Button {
                Task { await photoService.requestAccess() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Allow Photo Access")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.white, in: .capsule)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 40)

            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                Text("Your photos never leave your device")
                    .font(.caption)
            }
            .foregroundStyle(Color.white.opacity(0.20))

            Spacer()
            Spacer()
        }
    }

    // MARK: - Denied View

    private var deniedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.white.opacity(0.40))

            VStack(spacing: 8) {
                Text("Photo access denied")
                    .font(.system(size: 20, weight: .regular, design: .serif).italic())
                    .foregroundStyle(Color.white.opacity(0.90))

                Text("Enable photo access in Settings to continue.")
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.40))
            }

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 180, height: 48)
                    .background(Color.white.opacity(0.12), in: .capsule)
                    .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.5))
            }
            .buttonStyle(.plain)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .tint(Color.white.opacity(0.50))
                .scaleEffect(1.2)
            Text("Loading photos...")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.40))
            Spacer()
        }
    }

    // MARK: - Photo Grid

    private var photoGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(photoService.assets, id: \.localIdentifier) { asset in
                    PhotoThumbnailCell(
                        asset: asset,
                        isSelected: selectedAsset?.localIdentifier == asset.localIdentifier,
                        thumbnailSize: thumbnailSize,
                        cachedImage: thumbnailCache[asset.localIdentifier],
                        photoService: photoService,
                        onLoaded: { image in
                            thumbnailCache[asset.localIdentifier] = image
                        },
                        onTap: {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                if selectedAsset?.localIdentifier == asset.localIdentifier {
                                    selectedAsset = nil
                                } else {
                                    selectedAsset = asset
                                }
                            }
                            HapticService.light.impactOccurred()
                        }
                    )
                }
            }
            .padding(.bottom, selectedAsset != nil ? 90 : 0)
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            guard let asset = selectedAsset, !isLoadingFullImage else { return }
            isLoadingFullImage = true
            HapticService.medium.impactOccurred()
            Task {
                if let image = await photoService.loadFullImage(for: asset) {
                    onPhotoPicked(image)
                }
                isLoadingFullImage = false
            }
        } label: {
            HStack(spacing: 10) {
                if isLoadingFullImage {
                    ProgressView()
                        .tint(.black)
                        .scaleEffect(0.85)
                } else {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(.white, in: .capsule)
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
        .disabled(isLoadingFullImage)
        .padding(.bottom, 34)
    }
}

// MARK: - Thumbnail Cell

private struct PhotoThumbnailCell: View {
    let asset: PHAsset
    let isSelected: Bool
    let thumbnailSize: CGSize
    let cachedImage: UIImage?
    let photoService: PhotoLibraryService
    let onLoaded: (UIImage) -> Void
    let onTap: () -> Void

    @State private var thumbnail: UIImage?

    private let cellWidth: CGFloat = (UIScreen.main.bounds.width - 4) / 3
    private let cellHeight: CGFloat = ((UIScreen.main.bounds.width - 4) / 3) * 1.4

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                Color(white: 0.08)
                    .frame(width: cellWidth, height: cellHeight)
                    .overlay {
                        if let img = thumbnail ?? cachedImage {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        }
                    }
                    .clipShape(Rectangle())

                if isSelected {
                    Color.black.opacity(0.25)

                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 26, height: 26)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    .padding(6)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Circle()
                        .stroke(Color.white.opacity(0.50), lineWidth: 1.5)
                        .frame(width: 26, height: 26)
                        .padding(6)
                        .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                }
            }
            .frame(width: cellWidth, height: cellHeight)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
            )
            .scaleEffect(isSelected ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .task(id: asset.localIdentifier) {
            if cachedImage != nil {
                thumbnail = cachedImage
                return
            }
            if let img = await photoService.loadThumbnail(for: asset, targetSize: thumbnailSize) {
                thumbnail = img
                onLoaded(img)
            }
        }
    }
}
