import SwiftUI

struct RaceOverlay_Bib: View, Equatable {
    let size: CGSize

    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("BIB")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.4))
                    Text("2847")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.white.opacity(0.06))
                .clipShape(.rect(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
                .padding(.trailing, 24)
                .padding(.top, 60)
            }
            Spacer()
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}

struct RaceOverlay_Finisher: View, Equatable {
    let size: CGSize
    let activity: ActivityHighlight

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 6) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.5))
                Text("FINISHER")
                    .font(.system(size: 14, weight: .black))
                    .tracking(6)
                    .foregroundStyle(.white.opacity(0.7))
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 60, height: 1)
                Text(activity.duration)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                Text(activity.primaryStat)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(.black.opacity(0.3))
            .background(.ultraThinMaterial.opacity(0.3))
            .padding(.bottom, 40)
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}

struct RaceOverlay_Medal: View, Equatable {
    let size: CGSize
    let activity: ActivityHighlight

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.85, green: 0.75, blue: 0.45).opacity(0.4),
                                    Color(red: 0.65, green: 0.55, blue: 0.30).opacity(0.2)
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.80, blue: 0.50).opacity(0.5),
                                    Color(red: 0.70, green: 0.60, blue: 0.35).opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 80, height: 80)
                    VStack(spacing: 1) {
                        Image(systemName: "medal.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(red: 0.90, green: 0.80, blue: 0.50).opacity(0.7))
                        Text(activity.primaryStat)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(.trailing, 28)
                .padding(.bottom, 80)
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}

struct RaceOverlay_Route: View, Equatable {
    let size: CGSize
    let activity: ActivityHighlight

    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("RACE ROUTE")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.4))

                    Path { path in
                        let w: CGFloat = 120
                        let h: CGFloat = 40
                        let pts = activity.linePoints
                        guard let first = pts.first else { return }
                        path.move(to: CGPoint(x: first.x * w, y: first.y * h))
                        for pt in pts.dropFirst() {
                            path.addLine(to: CGPoint(x: pt.x * w, y: pt.y * h))
                        }
                    }
                    .stroke(activity.accent.opacity(0.5), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: 120, height: 40)

                    HStack(spacing: 12) {
                        splitLabel(km: "1", time: "5'28\"")
                        splitLabel(km: "3", time: "5'35\"")
                        splitLabel(km: "5", time: "5'30\"")
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.black.opacity(0.3))
                .background(.ultraThinMaterial.opacity(0.2))
                .clipShape(.rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                )
                .padding(.leading, 20)
                .padding(.bottom, 40)
                Spacer()
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }

    private func splitLabel(km: String, time: String) -> some View {
        VStack(spacing: 1) {
            Text("K\(km)")
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
            Text(time)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

struct RaceOverlay_Poster: View, Equatable {
    let size: CGSize
    let activity: ActivityHighlight

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 8) {
                    Text(activity.title.uppercased())
                        .font(.system(size: 28, weight: .black, design: .serif))
                        .tracking(4)
                        .foregroundStyle(.white.opacity(0.12))
                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 80, height: 1)
                    Text(activity.date.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.10))
                    Text(activity.primaryStat)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.15))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}
