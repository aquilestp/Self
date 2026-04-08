import SwiftUI

struct CityOverlay_Skyline: View, Equatable {
    let size: CGSize

    var body: some View {
        VStack {
            Spacer()
            Canvas { context, canvasSize in
                let baseY = canvasSize.height * 0.7
                let buildings: [(CGFloat, CGFloat, CGFloat)] = [
                    (0.05, 0.08, 0.45), (0.14, 0.06, 0.55), (0.21, 0.10, 0.38),
                    (0.32, 0.05, 0.62), (0.38, 0.12, 0.30), (0.51, 0.07, 0.50),
                    (0.59, 0.09, 0.42), (0.69, 0.06, 0.58), (0.76, 0.11, 0.35),
                    (0.85, 0.07, 0.48), (0.93, 0.08, 0.40)
                ]
                for (xPct, wPct, hPct) in buildings {
                    let x = xPct * canvasSize.width
                    let w = wPct * canvasSize.width
                    let h = hPct * canvasSize.height
                    let rect = CGRect(x: x, y: baseY - h, width: w, height: h + canvasSize.height * 0.3)
                    context.fill(Path(rect), with: .color(.white.opacity(0.06)))
                    let border = CGRect(x: x, y: baseY - h, width: w, height: 1)
                    context.fill(Path(border), with: .color(.white.opacity(0.12)))
                }
            }
            .frame(height: size.height * 0.5)
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}

struct CityOverlay_Postcard: View, Equatable {
    let size: CGSize
    let activity: ActivityHighlight

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .stroke(.white.opacity(0.25), lineWidth: 1)
                .padding(20)

            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("POSTCARD")
                            .font(.system(size: 8, weight: .bold))
                            .tracking(3)
                            .foregroundStyle(.white.opacity(0.5))
                        Text(activity.title)
                            .font(.system(size: 14, weight: .semibold, design: .serif))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(28)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(activity.date)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))
                        Text(activity.primaryStat)
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(28)
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}

struct CityOverlay_Neon: View, Equatable {
    let size: CGSize
    let activity: ActivityHighlight

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    LinearGradient(
                        colors: [.cyan.opacity(0.6), .purple.opacity(0.6), .pink.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .padding(24)
                .shadow(color: .cyan.opacity(0.3), radius: 8)

            VStack {
                Spacer()
                Text(activity.primaryStat)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.5), radius: 12)
                Text(activity.title.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .tracking(4)
                    .foregroundStyle(.pink.opacity(0.7))
                    .shadow(color: .pink.opacity(0.4), radius: 6)
                    .padding(.bottom, 40)
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}

struct CityOverlay_Stamp: View, Equatable {
    let size: CGSize
    let activity: ActivityHighlight

    var body: some View {
        VStack {
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 80, height: 80)
                    Circle()
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                        .frame(width: 70, height: 70)
                    VStack(spacing: 1) {
                        Text(activity.title.uppercased())
                            .font(.system(size: 7, weight: .bold))
                            .tracking(1.5)
                        Text(activity.primaryStat)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                        Text(activity.date.uppercased())
                            .font(.system(size: 7, weight: .medium))
                            .tracking(1)
                    }
                    .foregroundStyle(.white.opacity(0.5))
                }
                .rotationEffect(.degrees(-15))
                .padding(.trailing, 28)
                .padding(.top, 60)
            }
            Spacer()
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}

struct CityOverlay_GPS: View, Equatable {
    let size: CGSize
    let activity: ActivityHighlight

    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.4))
                        Text("40.4168° N, 3.7038° W")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.3))
                        Text("ALT 667m · \(activity.primaryStat)")
                            .font(.system(size: 9, weight: .regular, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
                .padding(.leading, 24)
                .padding(.bottom, 32)
                Spacer()
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}
