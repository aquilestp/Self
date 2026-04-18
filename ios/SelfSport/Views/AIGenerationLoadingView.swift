import SwiftUI

nonisolated struct ParticleItem: Sendable {
    let id: Int
    let x: CGFloat
    let radius: CGFloat
    let maxOpacity: Double
    let lifetime: Double
    let startProgress: Double
    let waveAmplitude: CGFloat
    let waveFreq: Double
    let phase: Double
}

struct AIGenerationLoadingView: View {
    let styleName: String

    @State private var pulseOuter: Bool = false
    @State private var pulseInner: Bool = false
    @State private var textPhaseIndex: Int = 0
    @State private var textOpacity: Double = 1.0
    @State private var particles: [ParticleItem] = []

    private static let cyclingTexts = [
        "Analyzing image...",
        "Applying style...",
        "Finishing touches..."
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.78)
                .ignoresSafeArea()

            TimelineView(.animation) { timeline in
                Canvas { ctx, size in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    for p in particles {
                        let raw = (now / p.lifetime + p.startProgress)
                            .truncatingRemainder(dividingBy: 1.0)
                        let y = size.height + p.radius - (size.height + p.radius * 2) * raw
                        let x = p.x + sin(now * p.waveFreq + p.phase) * p.waveAmplitude

                        let opacity: Double
                        if raw < 0.12 {
                            opacity = (raw / 0.12) * p.maxOpacity
                        } else if raw > 0.72 {
                            opacity = ((1.0 - raw) / 0.28) * p.maxOpacity
                        } else {
                            opacity = p.maxOpacity
                        }

                        ctx.fill(
                            Path(ellipseIn: CGRect(
                                x: x - p.radius,
                                y: y - p.radius,
                                width: p.radius * 2,
                                height: p.radius * 2
                            )),
                            with: .color(Color.white.opacity(max(0, opacity)))
                        )
                    }
                }
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 170, height: 170)
                        .scaleEffect(pulseOuter ? 1.0 : 0.6)
                        .opacity(pulseOuter ? 1.0 : 0.0)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: pulseOuter
                        )

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.16), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 58
                            )
                        )
                        .frame(width: 116, height: 116)
                        .scaleEffect(pulseInner ? 1.14 : 0.86)
                        .animation(
                            .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                            value: pulseInner
                        )

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 82, height: 82)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        )

                    Image(systemName: "sparkles")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(.white)
                        .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: pulseInner)
                }

                Spacer().frame(height: 40)

                VStack(spacing: 10) {
                    Text(Self.cyclingTexts[textPhaseIndex])
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .opacity(textOpacity)

                    Text(styleName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.35))
                        .tracking(1.2)
                        .textCase(.uppercase)
                }

                Spacer()
            }
        }
        .onAppear {
            setupParticles()
            pulseOuter = true
            pulseInner = true
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2.2))
                withAnimation(.easeInOut(duration: 0.28)) {
                    textOpacity = 0
                }
                try? await Task.sleep(for: .seconds(0.28))
                textPhaseIndex = (textPhaseIndex + 1) % Self.cyclingTexts.count
                withAnimation(.easeInOut(duration: 0.28)) {
                    textOpacity = 1
                }
            }
        }
    }

    private func setupParticles() {
        let screenWidth = UIScreen.main.bounds.width
        particles = (0..<24).map { i in
            ParticleItem(
                id: i,
                x: CGFloat.random(in: 0...screenWidth),
                radius: CGFloat.random(in: 1.4...4.0),
                maxOpacity: Double.random(in: 0.2...0.72),
                lifetime: Double.random(in: 3.5...8.0),
                startProgress: Double.random(in: 0...1),
                waveAmplitude: CGFloat.random(in: 5...24),
                waveFreq: Double.random(in: 0.2...0.85),
                phase: Double.random(in: 0...(Double.pi * 2))
            )
        }
    }
}
