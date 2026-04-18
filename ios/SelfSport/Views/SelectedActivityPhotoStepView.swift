import PhotosUI
import SwiftUI
import UIKit

struct SelectedActivityPhotoStepView: View {
    let activity: ActivityHighlight
    let onGoBack: () -> Void

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhoto: UIImage?
    @State private var isLoadingPhoto: Bool = false

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                topSummary
                    .padding(.top, 12)

                mainContent
                    .padding(.top, max(32, proxy.size.height * 0.05))
                    .padding(.horizontal, 24)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.black)
        }
        .background(Color.black)
        .safeAreaInset(edge: .bottom) {
            bottomBackButton
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                await loadPhoto(from: newValue)
            }
        }
    }

    private var topSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SELECTED ACTIVITY")
                .font(.system(size: 12, weight: .regular, design: .default))
                .tracking(2.8)
                .foregroundStyle(Color.white.opacity(0.56))
                .padding(.horizontal, 24)

            SelectedActivitySummaryCard(activity: activity)
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Text("Pick your photo")
                    .font(.system(size: 28, weight: .regular, design: .serif).italic())
                    .foregroundStyle(Color.white.opacity(0.96))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)

                Text("Choose an image to create your shareable moment")
                    .font(.callout)
                    .foregroundStyle(Color.white.opacity(0.30))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            StepProgressView()
                .padding(.top, 40)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                photoAccessButtonLabel
            }
            .buttonStyle(.plain)
            .padding(.top, 36)

            Group {
                if let selectedPhoto {
                    VStack(spacing: 10) {
                        Image(uiImage: selectedPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 84, height: 84)
                            .clipShape(.rect(cornerRadius: 24))
                            .overlay {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                            }

                        Text("Photo selected")
                            .font(.footnote)
                            .foregroundStyle(Color.white.opacity(0.46))
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "lock")
                            .font(.footnote)
                            .foregroundStyle(Color.white.opacity(0.18))

                        Text("Your photos never leave your device")
                            .font(.footnote)
                            .foregroundStyle(Color.white.opacity(0.18))
                    }
                }
            }
            .padding(.top, 32)
            .frame(height: 104, alignment: .top)
        }
        .frame(maxWidth: .infinity)
    }

    private var photoAccessButtonLabel: some View {
        HStack(spacing: 12) {
            if isLoadingPhoto {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.black)
            } else {
                Image(systemName: selectedPhoto == nil ? "photo.on.rectangle.angled" : "checkmark.circle")
                    .font(.headline)
                    .foregroundStyle(.black)
            }

            Text(selectedPhoto == nil ? "Allow Photo Access" : "Choose Another Photo")
                .font(.headline)
                .foregroundStyle(.black)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(.white, in: .capsule)
    }

    private var bottomBackButton: some View {
        Button(action: onGoBack) {
            Text("Go back")
                .font(.body)
                .foregroundStyle(Color.white.opacity(0.34))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else {
            return
        }

        isLoadingPhoto = true
        defer {
            isLoadingPhoto = false
        }

        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            selectedPhoto = image
        }
    }
}

private struct SelectedActivitySummaryCard: View {
    let activity: ActivityHighlight

    var body: some View {
        ZStack(alignment: .center) {
            LinearGradient(
                colors: [
                    activity.backgroundTop.opacity(0.96),
                    Color(red: 0.16, green: 0.14, blue: 0.13),
                    activity.backgroundBottom.opacity(0.98)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            summaryRouteLine
                .padding(.leading, 112)
                .padding(.trailing, 86)
                .padding(.vertical, 20)
                .opacity(0.30)

            HStack(spacing: 12) {
                Image(systemName: activity.summarySymbol)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.84))
                    .frame(width: 32, alignment: .center)

                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.primaryStat)
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundStyle(Color.white.opacity(0.96))
                        .minimumScaleFactor(0.9)

                    Text("\(activity.title) · \(activity.date)")
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.42))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 8)

                HStack(spacing: 16) {
                    metricColumn(title: "Pace", value: activity.pace)
                    metricColumn(title: "Time", value: activity.duration)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 84)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.03))
                .frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.03))
                .frame(height: 1)
        }
    }

    private var summaryRouteLine: some View {
        GeometryReader { proxy in
            Path { path in
                guard let firstPoint = activity.linePoints.first else {
                    return
                }

                path.move(to: CGPoint(x: firstPoint.x * proxy.size.width, y: firstPoint.y * proxy.size.height))

                for point in activity.linePoints.dropFirst() {
                    path.addLine(to: CGPoint(x: point.x * proxy.size.width, y: point.y * proxy.size.height))
                }
            }
            .stroke(activity.accent.opacity(0.28), style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
        }
    }

    private func metricColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.white.opacity(0.42))

            Text(value)
                .font(.system(size: 18, weight: .regular, design: .default))
                .foregroundStyle(Color.white.opacity(0.96))
                .minimumScaleFactor(0.8)
        }
    }
}

private struct StepProgressView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            stepItem(title: "Activity", icon: "checkmark", state: .complete)
            connector
            stepItem(title: "Select", icon: "photo.on.rectangle", state: .active)
            connector
            stepItem(title: "Personalize", icon: "sparkles", state: .upcoming)
            connector
            stepItem(title: "Share", icon: "share", state: .upcoming)
        }
        .frame(maxWidth: .infinity)
    }

    private var connector: some View {
        Rectangle()
            .fill(Color.white.opacity(0.14))
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 6)
            .padding(.top, 30)
    }

    private func stepItem(title: String, icon: String, state: StepState) -> some View {
        VStack(spacing: 10) {
            ZStack {
                switch state {
                case .complete:
                    Circle()
                        .fill(Color(red: 0.17, green: 0.14, blue: 0.12))
                        .frame(width: 62, height: 62)
                        .overlay {
                            Circle()
                                .stroke(Color(red: 0.63, green: 0.55, blue: 0.48), lineWidth: 3)
                        }

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(Color(red: 0.76, green: 0.68, blue: 0.60))
                case .active:
                    Circle()
                        .stroke(Color(red: 0.63, green: 0.55, blue: 0.48), lineWidth: 2.5)
                        .frame(width: 66, height: 66)

                    Circle()
                        .fill(Color(red: 0.10, green: 0.10, blue: 0.10))
                        .frame(width: 54, height: 54)
                        .overlay {
                            Circle()
                                .stroke(Color(red: 0.63, green: 0.55, blue: 0.48), lineWidth: 1.5)
                        }

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(Color(red: 0.76, green: 0.68, blue: 0.60))
                case .upcoming:
                    Circle()
                        .fill(Color.white.opacity(0.07))
                        .frame(width: 62, height: 62)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.46))
                }
            }
            .frame(width: 66, height: 66)

            Text(title)
                .font(.footnote)
                .foregroundStyle(state == .upcoming ? Color.white.opacity(0.46) : Color(red: 0.72, green: 0.67, blue: 0.62))
                .minimumScaleFactor(0.8)
        }
        .frame(width: 70)
    }
}

private nonisolated enum StepState {
    case complete
    case active
    case upcoming
}

#Preview {
    SelectedActivityPhotoStepView(
        activity: ActivityHighlight(
            id: "run",
            title: "Running",
            date: "Mar 22",
            distance: "5.2 km",
            pace: "5'32\"",
            duration: "28:41",
            systemImage: "figure.run",
            summarySymbol: "shoeprints.fill",
            accent: Color(red: 0.70, green: 0.64, blue: 0.57),
            backgroundTop: Color(red: 0.14, green: 0.14, blue: 0.16),
            backgroundBottom: Color(red: 0.03, green: 0.03, blue: 0.05),
            linePoints: [
                CGPoint(x: 0.12, y: 0.65), CGPoint(x: 0.20, y: 0.58), CGPoint(x: 0.28, y: 0.56),
                CGPoint(x: 0.36, y: 0.48), CGPoint(x: 0.45, y: 0.43), CGPoint(x: 0.53, y: 0.46),
                CGPoint(x: 0.60, y: 0.40), CGPoint(x: 0.68, y: 0.44), CGPoint(x: 0.78, y: 0.34),
                CGPoint(x: 0.86, y: 0.28)
            ],
            hasRealRoute: true,
            hasDistance: true,
            startDate: nil,
            activityName: "Morning Run",
            activityType: "Run",
            elapsedTime: "30:12",
            elevationGain: "45 m",
            maxSpeed: "4'18\"/km",
            averageHeartrate: "152 bpm",
            distanceRaw: 5200,
            movingTimeRaw: 1721,
            elapsedTimeRaw: 1812
        ),
        onGoBack: {}
    )
    .preferredColorScheme(.dark)
}
