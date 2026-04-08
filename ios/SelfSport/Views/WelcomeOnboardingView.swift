import SwiftUI

private enum WelcomeOnboardingStep: Int, CaseIterable, Identifiable {
    case intro
    case canvas
    case connect

    var id: Int { rawValue }

    var buttonTitle: String {
        switch self {
        case .connect:
            return "Continue"
        default:
            return "Next"
        }
    }
}

private struct OnboardingWidgetSpec: Identifiable {
    let id: Int
    let type: StatWidgetType
    let finalOffset: CGSize
    let entryOffset: CGSize
    let finalRotation: Angle
    let entryRotation: Angle
    let scale: CGFloat
    let delay: Double
    let colorStyle: WidgetColorStyle
    let usesGlass: Bool
    let floatOffset: CGFloat
}

struct WelcomeOnboardingView: View {
    let onComplete: () -> Void

    @State private var currentStep: WelcomeOnboardingStep = .intro

    var body: some View {
        ZStack {
            onboardingBackground

            VStack(spacing: 0) {
                HStack {
                    if currentStep != .intro {
                        Button {
                            withAnimation(.snappy(duration: 0.42, extraBounce: 0.02)) {
                                if let prev = WelcomeOnboardingStep(rawValue: currentStep.rawValue - 1) {
                                    currentStep = prev
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.64))
                                .frame(width: 36, height: 36)
                                .background(.white.opacity(0.08), in: .circle)
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                    Spacer()
                }
                .frame(height: 36)
                .animation(.snappy(duration: 0.32), value: currentStep)
                .padding(.top, 10)

                progressHeader

                Spacer(minLength: 28)

                ZStack {
                    if currentStep == .intro {
                        WelcomeIntroStepView()
                            .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
                    }

                    if currentStep == .canvas {
                        WelcomeCanvasStepView()
                            .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
                    }

                    if currentStep == .connect {
                        WelcomeConnectStepView()
                            .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .animation(.snappy(duration: 0.42, extraBounce: 0.02), value: currentStep)

                Spacer(minLength: 24)

                Button(action: advance) {
                    HStack(spacing: 10) {
                        Text(currentStep.buttonTitle)
                            .font(.headline)

                        Image(systemName: currentStep == .connect ? "arrow.right.circle.fill" : "arrow.right")
                            .font(.headline)
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white, in: .capsule)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 22)
        }
        .background(.black)
        .ignoresSafeArea()
    }

    private var onboardingBackground: some View {
        Rectangle()
            .fill(.black)
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 280, height: 280)
                    .blur(radius: 110)
                    .offset(x: -110, y: -80)
            }
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(red: 0.99, green: 0.32, blue: 0.14).opacity(0.12))
                    .frame(width: 300, height: 300)
                    .blur(radius: 130)
                    .offset(x: 120, y: 90)
            }
            .overlay {
                LinearGradient(
                    colors: [Color.white.opacity(0.04), .clear, Color.white.opacity(0.03)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
    }

    private var progressHeader: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                ForEach(WelcomeOnboardingStep.allCases) { step in
                    Capsule(style: .continuous)
                        .fill(step == currentStep ? Color.white.opacity(0.94) : Color.white.opacity(0.14))
                        .frame(width: step == currentStep ? 28 : 8, height: 8)
                }
            }

            Spacer()

            Text("\(currentStep.rawValue + 1)/\(WelcomeOnboardingStep.allCases.count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.48))
                .monospacedDigit()
        }
    }

    private func advance() {
        if let nextStep = WelcomeOnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        } else {
            onComplete()
        }
    }
}

private struct WelcomeIntroStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("self")
                .font(.system(.title, design: .serif, weight: .bold).width(.compressed))
                .italic()
                .foregroundStyle(.white.opacity(0.96))

            VStack(alignment: .leading, spacing: 14) {
                Text("Turn every workout into a designed story.")
                    .font(.system(size: 42, weight: .regular, design: .serif).italic())
                    .foregroundStyle(.white)
                    .lineSpacing(-4)
                    .minimumScaleFactor(0.85)

                Text("Build shareable layouts with bold stats, quiet detail and motion that feels intentional.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.64))
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "square.on.square")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.82))
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Compose with real workout data")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.94))

                        Text("Distance, pace, time and effort become design elements — not screenshots.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.54))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.82))
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Made for premium-looking shares")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.94))

                        Text("A restrained dark canvas, elegant type and flexible stat cards give every export a cleaner finish.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.54))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(22)
            .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 28))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            }

            Spacer(minLength: 0)
        }
    }
}

private struct WelcomeCanvasStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Stats settle into the canvas.")
                .font(.system(size: 40, weight: .regular, design: .serif).italic())
                .foregroundStyle(.white)
                .lineSpacing(-4)
                .minimumScaleFactor(0.85)

            Text("Drop in distance, pace and effort cards, then move them until the composition feels right.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.64))
                .fixedSize(horizontal: false, vertical: true)

            WelcomeCanvasAnimationView()
                .padding(.top, 10)

            Spacer(minLength: 0)
        }
    }
}

private struct WelcomeConnectStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Next, bring in your activities.")
                .font(.system(size: 40, weight: .regular, design: .serif).italic())
                .foregroundStyle(.white)
                .lineSpacing(-4)
                .minimumScaleFactor(0.85)

            Text("Right after this, you’ll connect a source and choose the workout you want to turn into a post.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.64))
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 12) {
                WelcomeProviderPreviewRow(
                    systemImage: "figure.run",
                    title: "Strava",
                    subtitle: "Import activities, routes and photos",
                    accent: Color(red: 0.99, green: 0.32, blue: 0.14)
                )

                WelcomeProviderPreviewRow(
                    systemImage: "location.north.circle",
                    title: "Garmin",
                    subtitle: "Bring in workouts from Garmin Connect",
                    accent: Color.white.opacity(0.76)
                )

                WelcomeProviderPreviewRow(
                    systemImage: "applewatch.side.right",
                    title: "COROS",
                    subtitle: "Sync sessions from your watch",
                    accent: Color.white.opacity(0.76)
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                Label("Shown once on a fresh install", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.74))

                Label("Connection cards appear after this intro", systemImage: "arrow.forward.circle")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.54))
            }
            .padding(.top, 6)

            Spacer(minLength: 0)
        }
    }
}

private struct WelcomeProviderPreviewRow: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let accent: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.14))
                    .frame(width: 44, height: 44)

                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.94))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.48))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.28))
        }
        .padding(16)
        .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}

private struct WelcomeCanvasAnimationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasSettled: Bool = false
    @State private var isFloating: Bool = false

    private let sampleActivity: ActivityHighlight = ActivityHighlight(
        id: "welcome-preview",
        title: "Morning Run",
        date: "APR 8 · 7:14 AM",
        distance: "10.2 KM",
        pace: "4:38 /KM",
        duration: "47:12",
        systemImage: "figure.run",
        summarySymbol: "sparkles",
        accent: Color(red: 0.99, green: 0.32, blue: 0.14),
        backgroundTop: Color(red: 0.18, green: 0.10, blue: 0.06),
        backgroundBottom: Color(red: 0.06, green: 0.04, blue: 0.03),
        linePoints: [
            CGPoint(x: 0.08, y: 0.80),
            CGPoint(x: 0.19, y: 0.52),
            CGPoint(x: 0.32, y: 0.66),
            CGPoint(x: 0.50, y: 0.34),
            CGPoint(x: 0.70, y: 0.58),
            CGPoint(x: 0.90, y: 0.22)
        ],
        hasRealRoute: false,
        hasDistance: true,
        startDate: nil,
        activityName: "Morning Run",
        activityType: "Run",
        elapsedTime: "48:03",
        elevationGain: "182 M",
        maxSpeed: "3:56 /KM",
        averageHeartrate: "154",
        distanceRaw: 10200,
        movingTimeRaw: 2832,
        elapsedTimeRaw: 2883
    )

    private let widgets: [OnboardingWidgetSpec] = [
        OnboardingWidgetSpec(
            id: 0,
            type: .distance,
            finalOffset: CGSize(width: -92, height: -92),
            entryOffset: CGSize(width: -250, height: -210),
            finalRotation: .degrees(-5),
            entryRotation: .degrees(-18),
            scale: 1.0,
            delay: 0.00,
            colorStyle: WidgetColorStyle(palette: .classic, colorIndex: 0),
            usesGlass: true,
            floatOffset: -4
        ),
        OnboardingWidgetSpec(
            id: 1,
            type: .distPace,
            finalOffset: CGSize(width: 78, height: -18),
            entryOffset: CGSize(width: 260, height: -180),
            finalRotation: .degrees(6),
            entryRotation: .degrees(18),
            scale: 1.0,
            delay: 0.10,
            colorStyle: WidgetColorStyle(palette: .classic, colorIndex: 1),
            usesGlass: true,
            floatOffset: 5
        ),
        OnboardingWidgetSpec(
            id: 2,
            type: .fullStats,
            finalOffset: CGSize(width: -62, height: 84),
            entryOffset: CGSize(width: -260, height: 220),
            finalRotation: .degrees(-3),
            entryRotation: .degrees(-14),
            scale: 0.96,
            delay: 0.18,
            colorStyle: WidgetColorStyle(palette: .classic, colorIndex: 0),
            usesGlass: true,
            floatOffset: -5
        ),
        OnboardingWidgetSpec(
            id: 3,
            type: .stack,
            finalOffset: CGSize(width: 104, height: 108),
            entryOffset: CGSize(width: 260, height: 210),
            finalRotation: .degrees(4),
            entryRotation: .degrees(14),
            scale: 0.94,
            delay: 0.28,
            colorStyle: WidgetColorStyle(palette: .classic, colorIndex: 5),
            usesGlass: true,
            floatOffset: 4
        )
    ]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.10), Color(white: 0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                }
                .overlay {
                    WelcomeCanvasGrid()
                        .clipShape(.rect(cornerRadius: 32))
                }
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("CANVAS")
                            .font(.caption.weight(.semibold))
                            .tracking(2.4)
                            .foregroundStyle(.white.opacity(0.34))

                        Text("Preview")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.88))
                    }
                    .padding(18)
                }

            ForEach(widgets) { widget in
                StatWidgetContentView(
                    type: widget.type,
                    activity: sampleActivity,
                    colorStyle: widget.colorStyle,
                    useGlassBackground: widget.usesGlass
                )
                .shadow(color: .black.opacity(0.34), radius: 22, x: 0, y: 14)
                .scaleEffect(currentScale(for: widget))
                .rotationEffect(hasSettled ? widget.finalRotation : widget.entryRotation)
                .offset(currentOffset(for: widget))
                .opacity(hasSettled ? 1 : 0)
                .animation(reduceMotion ? nil : .spring(duration: 0.9, bounce: 0.24).delay(widget.delay), value: hasSettled)
                .animation(reduceMotion ? nil : .easeInOut(duration: 2.6).delay(widget.delay).repeatForever(autoreverses: true), value: isFloating)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 370)
        .task {
            await runAnimation()
        }
    }

    private func currentScale(for widget: OnboardingWidgetSpec) -> CGFloat {
        let restingScale: CGFloat = hasSettled ? widget.scale : widget.scale * 0.80
        let floatingAdjustment: CGFloat = isFloating ? 0.015 : -0.015
        return hasSettled ? restingScale + floatingAdjustment : restingScale
    }

    private func currentOffset(for widget: OnboardingWidgetSpec) -> CGSize {
        let baseOffset = hasSettled ? widget.finalOffset : widget.entryOffset
        let verticalFloat = hasSettled ? (isFloating ? widget.floatOffset : -widget.floatOffset) : 0
        return CGSize(width: baseOffset.width, height: baseOffset.height + verticalFloat)
    }

    @MainActor
    private func runAnimation() async {
        hasSettled = false
        isFloating = false

        guard !reduceMotion else {
            hasSettled = true
            return
        }

        try? await Task.sleep(for: .milliseconds(180))
        hasSettled = true
        try? await Task.sleep(for: .seconds(1.6))
        isFloating = true
    }
}

private struct WelcomeCanvasGrid: View {
    var body: some View {
        Canvas { context, size in
            var gridPath = Path()

            let columns: Int = 4
            let rows: Int = 5
            let stroke = StrokeStyle(lineWidth: 1, lineCap: .round)
            let gridColor = Color.white.opacity(0.05)

            for index in 1..<columns {
                let x = size.width * CGFloat(index) / CGFloat(columns)
                gridPath.move(to: CGPoint(x: x, y: 0))
                gridPath.addLine(to: CGPoint(x: x, y: size.height))
            }

            for index in 1..<rows {
                let y = size.height * CGFloat(index) / CGFloat(rows)
                gridPath.move(to: CGPoint(x: 0, y: y))
                gridPath.addLine(to: CGPoint(x: size.width, y: y))
            }

            context.stroke(gridPath, with: .color(gridColor), style: stroke)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    WelcomeOnboardingView(onComplete: {})
        .preferredColorScheme(.dark)
}
