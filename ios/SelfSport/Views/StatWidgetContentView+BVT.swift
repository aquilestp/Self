import SwiftUI

extension StatWidgetContentView {

    private static let bvtDateFormatter = CachedDateFormatters.bvtDate
    private static let bvtTimeFormatter = CachedDateFormatters.timeShort

    // MARK: - blurredVerticalTextWidget

    var blurredVerticalTextWidget: some View {
        let isKm = bvtUnitFilter == .km
        let dateText = activity.startDate.map { Self.bvtDateFormatter.string(from: $0).uppercased() } ?? activity.date.uppercased()
        let timeText = activity.startDate.map { Self.bvtTimeFormatter.string(from: $0).uppercased() } ?? ""
        let locationText: String = {
            let city = activityDetail?.locationCity ?? ""
            let state = activityDetail?.locationState ?? ""
            if !city.isEmpty && !state.isEmpty { return "\(city), \(state)".uppercased() }
            if !city.isEmpty { return city.uppercased() }
            if !state.isEmpty { return state.uppercased() }
            return ""
        }()
        let distText: String = {
            guard activity.hasDistance else { return "" }
            if isKm { return activity.distance.uppercased() }
            return ActivityFormatting.distanceWithUnitUpper(activity.distanceRaw, unit: .miles)
        }()
        let paceText: String = {
            guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "" }
            return ActivityFormatting.paceSlash(distanceRaw: activity.distanceRaw, movingTimeRaw: activity.movingTimeRaw, unit: bvtUnitFilter)
        }()
        let durationText = ActivityFormatting.durationExpanded(activity.movingTimeRaw)
        let elevText = activity.elevationGain.uppercased()
        let calText: String = {
            guard let cal = activityDetail?.calories, cal > 0 else { return "" }
            return String(format: "%.0f CAL", cal)
        }()
        let bpmText: String = {
            guard let hr = activity.averageHeartrate else { return "" }
            let digits = hr.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            guard let bpm = Int(digits), bpm > 0 else { return "" }
            return "\(bpm) BPM"
        }()

        let lines: [(String, Bool)] = [
            (dateText, bvtShowDate),
            (timeText, bvtShowTime && !timeText.isEmpty),
            (locationText, bvtShowLocation && !locationText.isEmpty),
            (distText, bvtShowDistance && !distText.isEmpty),
            (paceText, bvtShowPace && !paceText.isEmpty),
            (durationText, bvtShowDuration),
            (elevText, bvtShowElevation),
            (calText, bvtShowCalories && !calText.isEmpty),
            (bpmText, bvtShowBPM && !bpmText.isEmpty),
        ]
        let visibleLines = lines.filter { $0.1 }.map { $0.0 }

        let mainFont: Font = .system(size: 22, weight: .black, design: .rounded)

        let textContent = VStack(alignment: .leading, spacing: -2) {
            ForEach(Array(visibleLines.enumerated()), id: \.offset) { _, line in
                bvtStyledLine(line, font: mainFont)
            }
        }
        .fixedSize(horizontal: true, vertical: true)
        .drawingGroup()

        let stretchMultiplier: CGFloat = bvtEffect == .stretch ? 1.6 : 1.0

        let gestureAnchor = textContent
            .hidden()
            .padding(.horizontal, 20)
            .padding(.vertical, 20 * stretchMultiplier)
            .scaleEffect(x: 1.0, y: stretchMultiplier, anchor: .top)

        return ZStack {
            gestureAnchor

            Group {
                switch bvtEffect {
                case .glow:
                    textContent
                        .shadow(color: primaryColor.opacity(0.7), radius: 8, x: 0, y: 0)
                        .shadow(color: primaryColor.opacity(0.35), radius: 16, x: 0, y: 0)
                case .stroke:
                    ZStack {
                        VStack(alignment: .leading, spacing: -2) {
                            ForEach(Array(visibleLines.enumerated()), id: \.offset) { _, line in
                                bvtStrokedLine(line, font: mainFont)
                            }
                        }
                        .fixedSize(horizontal: true, vertical: true)
                        textContent
                    }
                case .gradient:
                    VStack(alignment: .leading, spacing: -2) {
                        ForEach(Array(visibleLines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(mainFont)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [primaryColor, primaryColor.opacity(0.5)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    }
                    .fixedSize(horizontal: true, vertical: true)
                case .glitch:
                    ZStack {
                        VStack(alignment: .leading, spacing: -2) {
                            ForEach(Array(visibleLines.enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(mainFont)
                                    .foregroundStyle(Color.red.opacity(0.7))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        .fixedSize(horizontal: true, vertical: true)
                        .offset(x: -3, y: -1)
                        .blendMode(.screen)
                        VStack(alignment: .leading, spacing: -2) {
                            ForEach(Array(visibleLines.enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(mainFont)
                                    .foregroundStyle(Color.blue.opacity(0.7))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        .fixedSize(horizontal: true, vertical: true)
                        .offset(x: 3, y: 1)
                        .blendMode(.screen)
                        VStack(alignment: .leading, spacing: -2) {
                            ForEach(Array(visibleLines.enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(mainFont)
                                    .foregroundStyle(Color.green.opacity(0.7))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        .fixedSize(horizontal: true, vertical: true)
                        .offset(x: 1, y: -2)
                        .blendMode(.screen)
                        textContent
                            .opacity(0.5)
                    }
                case .wave:
                    VStack(alignment: .leading, spacing: -2) {
                        ForEach(Array(visibleLines.enumerated()), id: \.offset) { idx, line in
                            bvtStyledLine(line, font: mainFont)
                                .offset(x: sin(Double(idx) * 1.2) * 8)
                        }
                    }
                    .fixedSize(horizontal: true, vertical: true)
                case .pixelate:
                    textContent
                        .drawingGroup()
                        .blur(radius: 1.5)
                        .scaleEffect(x: 0.35, y: 0.35, anchor: .topLeading)
                        .scaleEffect(x: 1.0 / 0.35, y: 1.0 / 0.35, anchor: .topLeading)
                case .lineBlur:
                    VStack(alignment: .leading, spacing: -2) {
                        ForEach(Array(visibleLines.enumerated()), id: \.offset) { idx, line in
                            let blurAmount: CGFloat = idx % 3 == 0 ? 0 : (idx % 3 == 1 ? 2.5 : 4.5)
                            bvtStyledLine(line, font: mainFont)
                                .blur(radius: blurAmount)
                        }
                    }
                    .fixedSize(horizontal: true, vertical: true)
                case .noise:
                    textContent
                        .overlay {
                            Canvas { context, size in
                                var rng = SplitMix64(seed: 42)
                                for _ in 0..<120 {
                                    let x = CGFloat(rng.nextDouble()) * size.width
                                    let y = CGFloat(rng.nextDouble()) * size.height
                                    let opacity = 0.1 + rng.nextDouble() * 0.5
                                    let rect = CGRect(x: x, y: y, width: 2, height: 2)
                                    context.fill(Path(rect), with: .color(primaryColor.opacity(opacity)))
                                }
                            }
                            .allowsHitTesting(false)
                            .blendMode(.overlay)
                        }
                case .stretch:
                    textContent
                        .scaleEffect(x: 1.0, y: 1.6, anchor: .top)
                case .skew:
                    textContent
                        .transformEffect(CGAffineTransform(a: 1, b: 0, c: -0.35, d: 1, tx: 0, ty: 0))
                case .tracking:
                    VStack(alignment: .leading, spacing: -2) {
                        ForEach(Array(visibleLines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(mainFont)
                                .tracking(12)
                                .foregroundStyle(primaryColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    }
                    .fixedSize(horizontal: true, vertical: true)
                case .gradientMask:
                    textContent
                        .mask {
                            LinearGradient(
                                stops: [
                                    .init(color: .white, location: 0),
                                    .init(color: .white, location: 0.5),
                                    .init(color: .clear, location: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                case .echo:
                    ZStack(alignment: .topLeading) {
                        textContent.opacity(0.1).offset(x: 8, y: 8)
                        textContent.opacity(0.15).offset(x: 6, y: 6)
                        textContent.opacity(0.25).offset(x: 4, y: 4)
                        textContent.opacity(0.4).offset(x: 2, y: 2)
                        textContent
                    }
                }
            }
        }
    }

    // MARK: - BVT line helpers

    private func bvtStyledLine(_ text: String, font: Font) -> some View {
        Text(text)
            .font(font)
            .foregroundStyle(primaryColor)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }

    private func bvtStrokedLine(_ text: String, font: Font) -> some View {
        let strokeColor: Color = primaryColor.isLightColor ? Color.black : Color.white
        return Text(text)
            .font(font)
            .foregroundStyle(strokeColor.opacity(0.8))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .offset(x: -1, y: -1)
            .overlay(
                Text(text)
                    .font(font)
                    .foregroundStyle(strokeColor.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .offset(x: 1, y: -1)
            )
            .overlay(
                Text(text)
                    .font(font)
                    .foregroundStyle(strokeColor.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .offset(x: -1, y: 1)
            )
            .overlay(
                Text(text)
                    .font(font)
                    .foregroundStyle(strokeColor.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .offset(x: 1, y: 1)
            )
    }
}
