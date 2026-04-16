import SwiftUI

struct ActivityHighlightCard: View {
    let activity: ActivityHighlight
    var isCompact: Bool = false

    var body: some View {
        let cardWidth: CGFloat = (UIScreen.main.bounds.width - 40) * (isCompact ? 0.52 : 0.603)
        let cardHeight: CGFloat = isCompact ? 368 : 481

        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [activity.backgroundTop, activity.backgroundBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    cardTexture
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(activity.date)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundStyle(Color.white.opacity(0.36))

                    Spacer()

                    if let tag = activity.dayTag {
                        Text(tag)
                            .font(.system(size: 11, weight: .semibold, design: .default))
                            .foregroundStyle(tag == "Today" ? Color.white.opacity(0.90) : Color.white.opacity(0.56))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(tag == "Today" ? Color.white.opacity(0.16) : Color.white.opacity(0.08))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(tag == "Today" ? 0.14 : 0.06), lineWidth: 0.5)
                            )
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                Spacer(minLength: 0)

                if activity.hasRealRoute {
                    routeLine
                        .padding(.horizontal, 10)
                        .offset(y: -18)
                } else {
                    activityTypeIcon
                        .padding(.horizontal, 20)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: activity.systemImage)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.76))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.primaryStat)
                            .font(.system(size: 26, weight: .regular, design: .serif))
                            .foregroundStyle(Color.white.opacity(0.96))

                        if !activity.secondaryStats.isEmpty {
                            Text(activity.secondaryStats)
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundStyle(Color.white.opacity(0.44))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .shadow(color: .black.opacity(0.30), radius: 22, x: 0, y: 14)
        .contentShape(.rect(cornerRadius: 28))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activity.title), \(activity.date), \(activity.primaryStat), pace \(activity.pace), duration \(activity.duration)")
    }

    private var cardTexture: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white.opacity(0.04), .clear, Color.black.opacity(0.30)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [activity.accent.opacity(0.12), .clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 220
            )

            Canvas { context, size in
                let verticalLines: Int = 10
                let horizontalLines: Int = 16

                for index in 0..<verticalLines {
                    let x: CGFloat = size.width * CGFloat(index) / CGFloat(verticalLines)
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(Color.white.opacity(0.03)), lineWidth: 1)
                }

                for index in 0..<horizontalLines {
                    let y: CGFloat = size.height * CGFloat(index) / CGFloat(horizontalLines)
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(Color.white.opacity(0.02)), lineWidth: 1)
                }
            }
            .clipShape(.rect(cornerRadius: 28))
        }
        .clipShape(.rect(cornerRadius: 28))
    }

    private var routeLine: some View {
        GeometryReader { proxy in
            let padding: CGFloat = 0.02
            let rawPoints = activity.linePoints
            let points: [CGPoint] = {
                guard rawPoints.count >= 2 else { return [] }
                let xs = rawPoints.map(\.x)
                let ys = rawPoints.map(\.y)
                guard let minX = xs.min(), let maxX = xs.max(),
                      let minY = ys.min(), let maxY = ys.max() else { return [] }
                let routeW = maxX - minX
                let routeH = maxY - minY
                let availW = proxy.size.width * (1 - 2 * padding)
                let availH = proxy.size.height * (1 - 2 * padding)
                let scale: CGFloat
                if routeW < 0.001 && routeH < 0.001 {
                    scale = 1
                } else if routeW < 0.001 {
                    scale = availH / routeH
                } else if routeH < 0.001 {
                    scale = availW / routeW
                } else {
                    scale = min(availW / routeW, availH / routeH)
                }
                let centerX = (minX + maxX) / 2
                let centerY = (minY + maxY) / 2
                return rawPoints.map { pt in
                    let x = (pt.x - centerX) * scale + proxy.size.width / 2
                    let y = (pt.y - centerY) * scale + proxy.size.height / 2
                    return CGPoint(x: x, y: y)
                }
            }()

            let routePath = Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }

            routePath
                .stroke(activity.accent.opacity(0.18), style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round))
                .blur(radius: 6)

            routePath
                .stroke(activity.accent.opacity(0.40), style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))

            routePath
                .stroke(Color.white.opacity(0.92), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

            if let first = points.first, let last = points.last {
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .position(first)

                Circle()
                    .fill(activity.accent)
                    .frame(width: 7, height: 7)
                    .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 1.5))
                    .position(last)
            }
        }
        .frame(height: isCompact ? 140 : 240)
    }

    private var activityTypeIcon: some View {
        ZStack {
            Circle()
                .fill(activity.accent.opacity(0.10))
                .frame(width: isCompact ? 88 : 132, height: isCompact ? 88 : 132)

            Image(systemName: activity.systemImage)
                .font(.system(size: isCompact ? 38 : 57, weight: .light))
                .foregroundStyle(activity.accent.opacity(0.70))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CreatePostCard: View {
    let isLoading: Bool
    let onStart: () -> Void
    let onNewFromPhoto: () -> Void

    private let cardWidth: CGFloat = (UIScreen.main.bounds.width - 40) * 0.603
    private let cardHeight: CGFloat = 481
    private let accent = Color(red: 0.92, green: 0.86, blue: 0.72)

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.13, blue: 0.11),
                            Color(red: 0.05, green: 0.04, blue: 0.03)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(accent.opacity(0.22), lineWidth: 1)
                }
                .overlay {
                    RadialGradient(
                        colors: [accent.opacity(0.16), .clear],
                        center: .topTrailing,
                        startRadius: 12,
                        endRadius: 240
                    )
                    .clipShape(.rect(cornerRadius: 28))
                }

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(accent.opacity(0.10))
                        .frame(width: 120, height: 120)

                    Image(systemName: "sparkles")
                        .font(.system(size: 46, weight: .light))
                        .foregroundStyle(accent.opacity(0.92))
                }
                .padding(.bottom, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Create a post")
                        .font(.system(size: 24, weight: .regular, design: .serif).italic())
                        .foregroundStyle(Color.white.opacity(0.98))

                    Text("Pick a workout template, drop your photo and share it.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.48))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 18)

                Button(action: onStart) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(.black)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                        }

                        Text(isLoading ? "Loading\u{2026}" : "Start")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(accent, in: .capsule)
                }
                .buttonStyle(.plain)
                .disabled(isLoading)

                Button(action: onNewFromPhoto) {
                    HStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 12, weight: .medium))
                        Text("New post from photo")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Color.white.opacity(0.70))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
                .padding(.top, 4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(width: cardWidth, height: cardHeight)
        .shadow(color: .black.opacity(0.30), radius: 22, x: 0, y: 14)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Create a post")
    }
}

struct BringActivitiesCard: View {
    let onTap: () -> Void

    private let cardWidth: CGFloat = (UIScreen.main.bounds.width - 40) * 0.603
    private let cardHeight: CGFloat = 481
    private let accent = Color(red: 0.60, green: 0.82, blue: 0.72)

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.08, green: 0.13, blue: 0.11),
                            Color(red: 0.03, green: 0.05, blue: 0.04)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(accent.opacity(0.18), lineWidth: 1)
                }
                .overlay {
                    RadialGradient(
                        colors: [accent.opacity(0.10), .clear],
                        center: .topLeading,
                        startRadius: 10,
                        endRadius: 220
                    )
                    .clipShape(.rect(cornerRadius: 28))
                }

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(accent.opacity(0.08))
                        .frame(width: 120, height: 120)

                    ZStack {
                        Image(systemName: "figure.run")
                            .font(.system(size: 34, weight: .ultraLight))
                            .foregroundStyle(accent.opacity(0.55))
                            .offset(x: 10, y: -4)

                        Image(systemName: "applewatch.side.right")
                            .font(.system(size: 22, weight: .ultraLight))
                            .foregroundStyle(accent.opacity(0.35))
                            .offset(x: -16, y: 12)
                    }
                }
                .padding(.bottom, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Bring your activities")
                        .font(.system(size: 22, weight: .regular, design: .serif).italic())
                        .foregroundStyle(Color.white.opacity(0.92))

                    Text("Connect Strava, COROS or Garmin to build posts with your real data.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.38))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 20)

                Button(action: onTap) {
                    HStack(spacing: 8) {
                        Image(systemName: "link")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Explore options")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(accent, in: .capsule)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .frame(width: cardWidth, height: cardHeight)
        .shadow(color: .black.opacity(0.30), radius: 22, x: 0, y: 14)
        .contentShape(.rect(cornerRadius: 28))
    }
}

struct ConnectProvidersSheet: View {
    let isConnecting: Bool
    let onConnectStrava: () -> Void
    @Environment(\.dismiss) private var dismiss

    private let stravaOrange = Color(red: 0.99, green: 0.32, blue: 0.14)
    private let corosRed = Color(red: 0.85, green: 0.12, blue: 0.15)
    private let garminBlue = Color(red: 0.0, green: 0.47, blue: 0.78)

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("Connect a service")
                    .font(.system(size: 22, weight: .regular, design: .serif).italic())
                    .foregroundStyle(Color.white.opacity(0.96))

                Text("Import your real activities, routes and stats")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.40))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 28)
            .padding(.bottom, 28)

            VStack(spacing: 12) {
                providerRow(
                    name: "Strava",
                    subtitle: "Import real activities, routes and stats",
                    systemImage: "figure.run",
                    accent: stravaOrange,
                    isComingSoon: false,
                    isConnecting: isConnecting,
                    onConnect: {
                        dismiss()
                        onConnectStrava()
                    }
                )

                providerRow(
                    name: "COROS",
                    subtitle: "Sync workouts from your COROS watch",
                    systemImage: "applewatch.side.right",
                    accent: corosRed,
                    isComingSoon: true,
                    isConnecting: false,
                    onConnect: {}
                )

                providerRow(
                    name: "Garmin",
                    subtitle: "Import activities from Garmin Connect",
                    systemImage: "location.north.circle",
                    accent: garminBlue,
                    isComingSoon: true,
                    isConnecting: false,
                    onConnect: {}
                )
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 0)

            Button(action: { dismiss() }) {
                Text("Not now")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.40))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
        .padding(.bottom, 12)
    }

    private func providerRow(
        name: String,
        subtitle: String,
        systemImage: String,
        accent: Color,
        isComingSoon: Bool,
        isConnecting: Bool,
        onConnect: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(accent.opacity(0.80))
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.92))

                    if isComingSoon {
                        Text("Soon")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(0.6)
                            .foregroundStyle(Color.white.opacity(0.40))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.07), in: Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 0.5))
                    }
                }

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.34))
            }

            Spacer(minLength: 0)

            if !isComingSoon {
                Button(action: onConnect) {
                    HStack(spacing: 6) {
                        if isConnecting {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.75)
                        } else {
                            Image(systemName: "link")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        Text(isConnecting ? "Connecting" : "Connect")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(accent, in: .capsule)
                }
                .buttonStyle(.plain)
                .disabled(isConnecting)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.07), lineWidth: 0.5)
                )
        )
    }
}

struct ConnectStravaCard: View {
    let isConnecting: Bool
    let onConnect: () -> Void

    private let cardWidth: CGFloat = (UIScreen.main.bounds.width - 40) * 0.603
    private let cardHeight: CGFloat = 481
    private let stravaOrange = Color(red: 0.99, green: 0.32, blue: 0.14)

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.10, blue: 0.06),
                            Color(red: 0.06, green: 0.04, blue: 0.03)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(stravaOrange.opacity(0.20), lineWidth: 1)
                }
                .overlay {
                    RadialGradient(
                        colors: [stravaOrange.opacity(0.10), .clear],
                        center: .topTrailing,
                        startRadius: 10,
                        endRadius: 200
                    )
                    .clipShape(.rect(cornerRadius: 28))
                }

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Image(systemName: "figure.run")
                    .font(.system(size: 42, weight: .ultraLight))
                    .foregroundStyle(stravaOrange.opacity(0.50))
                    .padding(.bottom, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Connect Strava")
                        .font(.system(size: 22, weight: .regular, design: .serif).italic())
                        .foregroundStyle(Color.white.opacity(0.96))

                    Text("Import your real activities, routes and stats")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.40))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 20)

                Button(action: onConnect) {
                    HStack(spacing: 8) {
                        if isConnecting {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "link")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        Text(isConnecting ? "Connecting..." : "Connect")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(stravaOrange, in: .capsule)
                }
                .buttonStyle(.plain)
                .disabled(isConnecting)
            }
            .padding(20)
        }
        .frame(width: cardWidth, height: cardHeight)
        .shadow(color: .black.opacity(0.30), radius: 22, x: 0, y: 14)
    }
}

struct LoadingActivityCard: View {
    @State private var shimmer: Bool = false

    private let cardWidth: CGFloat = (UIScreen.main.bounds.width - 40) * 0.603
    private let cardHeight: CGFloat = 481

    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(white: 0.12), Color(white: 0.06)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            }
            .overlay {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer()
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(shimmer ? 0.08 : 0.04))
                        .frame(width: 80, height: 12)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(shimmer ? 0.10 : 0.06))
                        .frame(width: 120, height: 20)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(shimmer ? 0.06 : 0.03))
                        .frame(width: 100, height: 12)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: cardWidth, height: cardHeight)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    shimmer = true
                }
            }
    }
}

struct EmptyActivitiesCard: View {
    let onDisconnect: () -> Void

    private let cardWidth: CGFloat = (UIScreen.main.bounds.width - 40) * 0.603
    private let cardHeight: CGFloat = 481

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.12), Color(white: 0.04)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Image(systemName: "figure.run.circle")
                    .font(.system(size: 36, weight: .ultraLight))
                    .foregroundStyle(Color.white.opacity(0.30))
                    .padding(.bottom, 16)

                Text("No activities yet")
                    .font(.system(size: 20, weight: .regular, design: .serif).italic())
                    .foregroundStyle(Color.white.opacity(0.80))
                    .padding(.bottom, 6)

                Text("Record an activity on Strava, then pull to refresh.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.36))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 20)

                Button(action: onDisconnect) {
                    Text("Disconnect Strava")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.50))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .frame(width: cardWidth, height: cardHeight)
        .shadow(color: .black.opacity(0.30), radius: 22, x: 0, y: 14)
    }
}

struct ConnectProviderCard: View {
    let providerName: String
    let subtitle: String
    let systemImage: String
    let accentColor: Color
    let gradientTop: Color
    let gradientBottom: Color
    let onConnect: () -> Void

    private let cardWidth: CGFloat = (UIScreen.main.bounds.width - 40) * 0.603
    private let cardHeight: CGFloat = 481

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [gradientTop, gradientBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(accentColor.opacity(0.20), lineWidth: 1)
                }
                .overlay {
                    RadialGradient(
                        colors: [accentColor.opacity(0.10), .clear],
                        center: .topTrailing,
                        startRadius: 10,
                        endRadius: 200
                    )
                    .clipShape(.rect(cornerRadius: 28))
                }

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Image(systemName: systemImage)
                    .font(.system(size: 42, weight: .ultraLight))
                    .foregroundStyle(accentColor.opacity(0.50))
                    .padding(.bottom, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Connect \(providerName)")
                        .font(.system(size: 22, weight: .regular, design: .serif).italic())
                        .foregroundStyle(Color.white.opacity(0.96))

                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.40))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 20)

                Button(action: onConnect) {
                    HStack(spacing: 8) {
                        Image(systemName: "link")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Connect")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(accentColor, in: .capsule)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .frame(width: cardWidth, height: cardHeight)
        .shadow(color: .black.opacity(0.30), radius: 22, x: 0, y: 14)
    }
}

struct ComingSoonSheet: View {
    let providerName: String
    @Environment(\.dismiss) private var dismiss

    private var accentColor: Color {
        providerName == "COROS"
            ? Color(red: 0.85, green: 0.12, blue: 0.15)
            : Color(red: 0.0, green: 0.47, blue: 0.78)
    }

    private var icon: String {
        providerName == "COROS" ? "applewatch.side.right" : "location.north.circle"
    }

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 72, height: 72)

                Image(systemName: icon)
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(accentColor)
            }
            .padding(.top, 8)

            VStack(spacing: 10) {
                Text("\(providerName) integration")
                    .font(.system(size: 22, weight: .regular, design: .serif).italic())
                    .foregroundStyle(Color.white.opacity(0.96))

                Text("Coming soon")
                    .font(.system(size: 15, weight: .medium))
                    .tracking(1.6)
                    .foregroundStyle(accentColor.opacity(0.80))

                Text("We're working on bringing \(providerName) support. Stay tuned.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.44))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Button(action: { dismiss() }) {
                Text("Got it")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white.opacity(0.10), in: .capsule)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}

struct LoadMoreCard: View {
    let isLoading: Bool

    private let cardWidth: CGFloat = (UIScreen.main.bounds.width - 40) * 0.603
    private let cardHeight: CGFloat = 481

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.10), Color(white: 0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                }

            VStack(spacing: 16) {
                if isLoading {
                    ProgressView()
                        .tint(Color.white.opacity(0.50))
                        .scaleEffect(1.1)
                } else {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 28, weight: .ultraLight))
                        .foregroundStyle(Color.white.opacity(0.30))
                }

                Text(isLoading ? "Loading..." : "More activities")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.36))
            }
        }
        .frame(width: cardWidth, height: cardHeight)
    }
}

struct DashboardTabBar: View {
    @Binding var selectedTab: DashboardTab

    var body: some View {
        HStack(spacing: 0) {
            tabItem(
                tab: .share,
                symbol: "s.circle.fill",
                title: "Share",
                isMuted: false
            )

            tabItem(
                tab: .challenges,
                symbol: "trophy",
                title: "Challenges",
                isMuted: true,
                badge: "SOON"
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 9)
        .padding(.bottom, 7)
        .frame(maxWidth: .infinity)
        .background(
            Color.black.opacity(0.94)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 0.5)
        }
    }

    private func tabItem(
        tab: DashboardTab,
        symbol: String,
        title: String,
        isMuted: Bool,
        badge: String? = nil
    ) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 3.5) {
                ZStack {
                    Image(systemName: symbol)
                        .font(.system(size: 20, weight: isSelected ? .medium : .regular))

                    if let badge {
                        Text(badge)
                            .font(.system(size: 8, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(Color.black)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1.5)
                            .background(Color.white.opacity(0.6), in: Capsule())
                            .offset(x: 18, y: -9)
                    }
                }
                .foregroundStyle(isSelected ? Color.white.opacity(0.95) : Color.white.opacity(isMuted ? 0.24 : 0.40))

                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(isSelected ? Color.white.opacity(0.88) : Color.white.opacity(isMuted ? 0.22 : 0.34))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct DashboardPlaceholderView: View {
    let eyebrow: String
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(eyebrow)
                .font(.footnote.weight(.medium))
                .tracking(3)
                .foregroundStyle(Color.white.opacity(0.34))

            Text(title)
                .font(.system(size: 48, weight: .regular, design: .serif).italic())
                .foregroundStyle(Color.white.opacity(0.95))

            Text(message)
                .font(.title3)
                .foregroundStyle(Color.white.opacity(0.48))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 24)
        .padding(.top, 36)
        .padding(.bottom, 140)
        .background(Color.black)
        .toolbar(.hidden, for: .navigationBar)
    }
}
