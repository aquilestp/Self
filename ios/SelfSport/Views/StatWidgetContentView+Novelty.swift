import SwiftUI

// MARK: - Medal & WhatsApp supporting shapes

struct AncestralLaurelWreath: View {
    let radius: CGFloat
    let leafCount: Int
    let color: Color

    var body: some View {
        ZStack {
            ForEach(0..<leafCount, id: \.self) { i in
                let side: CGFloat = i < leafCount / 2 ? -1 : 1
                let idx = i < leafCount / 2 ? i : i - leafCount / 2
                let totalPerSide = leafCount / 2
                let t = Double(idx) / Double(max(totalPerSide - 1, 1))
                let baseAngle = side < 0 ? (-70.0 + t * 140.0) : (180.0 + 70.0 - t * 140.0)
                let rad = baseAngle * .pi / 180
                let x = cos(rad) * radius
                let y = sin(rad) * radius
                AncestralLeafShape()
                    .fill(color)
                    .frame(width: 6, height: 14)
                    .rotationEffect(.degrees(baseAngle + (side < 0 ? 90 : -90)))
                    .offset(x: x, y: y)
            }
        }
    }
}

struct AncestralLeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.move(to: CGPoint(x: w * 0.5, y: 0))
        p.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control: CGPoint(x: w * 1.1, y: h * 0.45)
        )
        p.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control: CGPoint(x: w * -0.1, y: h * 0.45)
        )
        return p
    }
}

struct AncestralStarRing: View {
    let radius: CGFloat
    let count: Int
    let starSize: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle = (360.0 / Double(count)) * Double(i) - 90
                let rad = angle * .pi / 180
                Image(systemName: "star.fill")
                    .font(.system(size: starSize, weight: .bold))
                    .foregroundStyle(color)
                    .offset(x: cos(rad) * radius, y: sin(rad) * radius)
            }
        }
    }
}

struct MedalStarDots: View {
    let radius: CGFloat
    let count: Int
    let dotSize: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle = (360.0 / Double(count)) * Double(i)
                let rad = angle * .pi / 180
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)
                    .offset(x: cos(rad) * radius, y: sin(rad) * radius)
            }
        }
    }
}

struct MedalCurvedText: View {
    let text: String
    let radius: CGFloat
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    let kerning: CGFloat
    let clockwise: Bool
    let arcSpan: Double
    let color: Color

    private var chars: [Character] { Array(text) }
    private var count: Int { chars.count }
    private var anglePerChar: Double { arcSpan / Double(max(count - 1, 1)) }
    private var startAngle: Double { clockwise ? (-90.0 - arcSpan / 2) : (90.0 + arcSpan / 2) }

    private func angle(for i: Int) -> Double {
        clockwise ? startAngle + Double(i) * anglePerChar : startAngle - Double(i) * anglePerChar
    }

    var body: some View {
        ZStack {
            if count > 0 {
                ForEach(0..<count, id: \.self) { i in
                    let a = angle(for: i)
                    let rad = a * .pi / 180
                    Text(String(chars[i]))
                        .font(.system(size: fontSize, weight: fontWeight, design: .default))
                        .foregroundStyle(color)
                        .rotationEffect(.degrees(clockwise ? a + 90 : a - 90))
                        .offset(x: cos(rad) * radius, y: sin(rad) * radius)
                }
            }
        }
    }
}

struct MedalBannerView: View {
    let text: String
    let goldDark: Color
    let goldBright: Color
    let goldShine: Color
    let textColor: Color

    var body: some View {
        ZStack {
            MedalBannerShape()
                .fill(
                    LinearGradient(
                        colors: [goldBright, goldShine, goldBright],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 105, height: 18)
                .shadow(color: goldDark.opacity(0.4), radius: 1, x: 0, y: 1)

            MedalBannerShape()
                .strokeBorder(goldDark.opacity(0.35), lineWidth: 0.5)
                .frame(width: 105, height: 18)

            Text(text)
                .font(.system(size: 7, weight: .bold, design: .default))
                .tracking(0.8)
                .foregroundStyle(textColor.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }
}

struct MedalBannerShape: InsettableShape {
    var inset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: inset, dy: inset)
        let foldW: CGFloat = 6
        let foldH: CGFloat = 3
        var p = Path()
        p.move(to: CGPoint(x: r.minX + foldW, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - foldW, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.midY))
        p.addLine(to: CGPoint(x: r.maxX - foldW, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX + foldW, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.midY))
        p.closeSubpath()

        p.move(to: CGPoint(x: r.minX + foldW, y: r.minY))
        p.addLine(to: CGPoint(x: r.minX + foldW + foldH, y: r.midY))
        p.addLine(to: CGPoint(x: r.minX + foldW, y: r.maxY))

        p.move(to: CGPoint(x: r.maxX - foldW, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - foldW - foldH, y: r.midY))
        p.addLine(to: CGPoint(x: r.maxX - foldW, y: r.maxY))

        return p
    }

    func inset(by amount: CGFloat) -> MedalBannerShape {
        MedalBannerShape(inset: inset + amount)
    }
}

struct WhatsAppBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cr: CGFloat = 16
        let tailW: CGFloat = 8
        let tailH: CGFloat = 12
        var p = Path()
        let mainRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width - tailW, height: rect.height)
        p.addRoundedRect(in: mainRect, cornerSize: CGSize(width: cr, height: cr))
        p.move(to: CGPoint(x: mainRect.maxX - 2, y: mainRect.maxY - 8))
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: mainRect.maxY + tailH - 8),
            control: CGPoint(x: mainRect.maxX + 2, y: mainRect.maxY - 2)
        )
        p.addQuadCurve(
            to: CGPoint(x: mainRect.maxX - 6, y: mainRect.maxY),
            control: CGPoint(x: mainRect.maxX - 1, y: mainRect.maxY + 2)
        )
        return p
    }
}

// MARK: - StatWidgetContentView Novelty Extensions

extension StatWidgetContentView {

    private static let waTimeFormatter = CachedDateFormatters.timeShort

    // MARK: - whatsappMessageWidget

    var whatsappMessageWidget: some View {
        let timeText = activity.startDate.map { Self.waTimeFormatter.string(from: $0) } ?? "9:54 PM"
        let waGreen = Color(red: 0.00, green: 0.45, blue: 0.34)
        let waBubbleGreen = Color(red: 0.00, green: 0.37, blue: 0.33)
        let waCheckBlue = Color(red: 0.33, green: 0.75, blue: 0.98)
        let waTimeColor = Color.white.opacity(0.55)

        return VStack(alignment: .trailing, spacing: 2) {
            Text(whatsappText)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 3) {
                Text(timeText)
                    .font(.system(size: 11))
                    .foregroundStyle(waTimeColor)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(waCheckBlue)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(waCheckBlue)
                            .offset(x: 4)
                    )
                    .padding(.trailing, 4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .fixedSize()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(waBubbleGreen)
        )
    }

    // MARK: - Notes helpers

    private var notesIsMiles: Bool { notesUnitFilter == .miles }

    private var notesDistanceText: String {
        ActivityFormatting.distanceWithUnit(activity.distanceRaw, unit: notesIsMiles ? .miles : .km, kmFormat: "%.1f km", miFormat: "%.1f mi")
    }

    private var notesPaceText: String {
        guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
        return ActivityFormatting.paceSpaced(distanceRaw: activity.distanceRaw, movingTimeRaw: activity.movingTimeRaw, unit: notesIsMiles ? .miles : .km)
    }

    private var notesDateText: String {
        if let d = activity.startDate {
            return CachedDateFormatters.notesDate.string(from: d)
        }
        return activity.date
    }

    private var notesBodyText: String {
        var lines: [String] = []
        if activity.hasDistance {
            lines.append("Pace: \(notesPaceText)")
        }
        lines.append("Duration: \(activity.duration)")
        lines.append(notesDateText)
        return lines.joined(separator: "\n")
    }

    // MARK: - notesScreenshotWidget

    var notesScreenshotWidget: some View {
        let notesOrange = Color(red: 1.0, green: 0.65, blue: 0.0)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                HStack(spacing: 3) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(notesOrange)
                    Text("workout notes")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(notesOrange)
                }
                Spacer()
                if activity.hasDistance {
                    HStack(spacing: 4) {
                        Text(notesDistanceText)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(notesOrange)
                        Image(systemName: "figure.run")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(notesOrange)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Rectangle()
                .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                .frame(height: 0.5)
                .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(notesBodyText)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.57))
                    .lineLimit(3)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .frame(width: 260)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 4)
        )
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Ancestral Medal helpers

    private var ancestralIsMiles: Bool { ancestralUnitFilter == .miles }

    private var ancestralDistanceText: String {
        ActivityFormatting.distanceValue(activity.distanceRaw, unit: ancestralIsMiles ? .miles : .km)
    }

    private var ancestralUnitLabel: String { ancestralIsMiles ? "MI" : "KM" }

    private var ancestralPaceText: String {
        guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
        return ActivityFormatting.paceSpaced(distanceRaw: activity.distanceRaw, movingTimeRaw: activity.movingTimeRaw, unit: ancestralIsMiles ? .miles : .km)
    }

    private var ancestralDateText: String {
        if let d = activity.startDate {
            return CachedDateFormatters.medalDate.string(from: d).uppercased()
        }
        return activity.date.uppercased()
    }

    // MARK: - ancestralMedalWidget

    var ancestralMedalWidget: some View {
        let bronzeDark = Color(red: 0.54, green: 0.40, blue: 0.14)
        let goldDeep = Color(red: 0.83, green: 0.68, blue: 0.21)
        let goldBright = Color(red: 0.93, green: 0.79, blue: 0.28)
        let goldLight = Color(red: 0.98, green: 0.91, blue: 0.55)
        let goldShine = Color(red: 1.0, green: 0.97, blue: 0.78)
        let engraveColor = Color(red: 0.12, green: 0.08, blue: 0.02)

        let medalSize: CGFloat = 210
        let halfSize = medalSize / 2

        let bodyGradient = RadialGradient(
            colors: [goldShine, goldLight, goldBright, goldDeep, bronzeDark.opacity(0.9)],
            center: .init(x: 0.38, y: 0.32),
            startRadius: 4,
            endRadius: medalSize * 0.52
        )
        let rimGradient = AngularGradient(
            colors: [bronzeDark, goldDeep, goldShine, goldBright, bronzeDark, goldDeep, goldShine, goldDeep, bronzeDark],
            center: .center
        )
        let innerRimGradient = AngularGradient(
            colors: [bronzeDark.opacity(0.7), goldBright.opacity(0.4), bronzeDark.opacity(0.7), goldBright.opacity(0.4), bronzeDark.opacity(0.7)],
            center: .center
        )

        let hasSubMetrics = (ancestralShowPace && activity.hasDistance) || ancestralShowTime

        let engraveGradient = LinearGradient(
            colors: [
                Color(red: 0.83, green: 0.68, blue: 0.21),
                Color(red: 0.54, green: 0.40, blue: 0.14)
            ],
            startPoint: .top,
            endPoint: .bottom
        )

        return ZStack {
            Circle()
                .fill(rimGradient)
                .frame(width: medalSize, height: medalSize)
                .shadow(color: .black.opacity(0.55), radius: 10, x: 0, y: 5)
                .shadow(color: bronzeDark.opacity(0.9), radius: 3, x: 0, y: 2)

            Circle()
                .fill(bodyGradient)
                .frame(width: medalSize - 16, height: medalSize - 16)

            Circle()
                .strokeBorder(innerRimGradient, lineWidth: 2)
                .frame(width: medalSize - 16, height: medalSize - 16)

            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [bronzeDark.opacity(0.5), goldBright.opacity(0.25), bronzeDark.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
                .frame(width: medalSize - 26, height: medalSize - 26)

            Circle()
                .strokeBorder(bronzeDark.opacity(0.15), lineWidth: 0.5)
                .frame(width: medalSize - 34, height: medalSize - 34)

            AncestralLaurelWreath(radius: halfSize - 22, leafCount: 18, color: bronzeDark.opacity(0.2))

            AncestralStarRing(radius: halfSize - 16, count: 12, starSize: 3.5, color: bronzeDark.opacity(0.12))

            MedalCurvedText(
                text: "✦  M Y   F I R S T  ✦",
                radius: halfSize - 30,
                fontSize: 9,
                fontWeight: .heavy,
                kerning: 0.4,
                clockwise: true,
                arcSpan: 160,
                color: engraveColor.opacity(0.7)
            )

            MedalCurvedText(
                text: "A C H I E V E M E N T",
                radius: halfSize - 28,
                fontSize: 6.5,
                fontWeight: .bold,
                kerning: 0.3,
                clockwise: false,
                arcSpan: 110,
                color: engraveColor.opacity(0.35)
            )

            VStack(spacing: 0) {
                Text(ancestralDistanceText)
                    .font(.system(size: 48, weight: .black, design: .serif))
                    .foregroundStyle(engraveGradient)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .shadow(color: goldShine.opacity(0.5), radius: 0.5, x: 0, y: 1)
                    .shadow(color: bronzeDark.opacity(0.6), radius: 1, x: 0, y: -0.5)

                Text(ancestralUnitLabel)
                    .font(.system(size: 11, weight: .heavy, design: .serif))
                    .tracking(6)
                    .foregroundStyle(engraveColor.opacity(0.45))
                    .padding(.top, -4)
                    .padding(.bottom, 3)

                if hasSubMetrics {
                    HStack(spacing: 0) {
                        if ancestralShowPace, activity.hasDistance {
                            Text(ancestralPaceText)
                                .font(.system(size: 8, weight: .semibold, design: .serif))
                                .foregroundStyle(engraveColor.opacity(0.38))
                        }
                        if ancestralShowPace && activity.hasDistance && ancestralShowTime {
                            Text("  ·  ")
                                .font(.system(size: 6, weight: .black, design: .serif))
                                .foregroundStyle(engraveColor.opacity(0.2))
                        }
                        if ancestralShowTime {
                            Text(activity.duration)
                                .font(.system(size: 8, weight: .semibold, design: .serif))
                                .foregroundStyle(engraveColor.opacity(0.38))
                        }
                    }
                    .padding(.bottom, 3)
                }

                MedalBannerView(
                    text: ancestralDateText,
                    goldDark: bronzeDark,
                    goldBright: goldBright,
                    goldShine: goldShine,
                    textColor: engraveColor
                )
            }
            .frame(width: medalSize - 56)
            .offset(y: 5)
        }
        .frame(width: medalSize + 10, height: medalSize + 10)
        .drawingGroup()
    }
}
