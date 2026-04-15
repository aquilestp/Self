import SwiftUI

// MARK: - Shapes used by route and elevation widgets

struct MountainRidgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: w * 0.0, y: h * 0.72))
        path.addQuadCurve(to: CGPoint(x: w * 0.08, y: h * 0.55), control: CGPoint(x: w * 0.04, y: h * 0.60))
        path.addQuadCurve(to: CGPoint(x: w * 0.15, y: h * 0.62), control: CGPoint(x: w * 0.12, y: h * 0.52))
        path.addQuadCurve(to: CGPoint(x: w * 0.22, y: h * 0.38), control: CGPoint(x: w * 0.18, y: h * 0.55))
        path.addQuadCurve(to: CGPoint(x: w * 0.30, y: h * 0.48), control: CGPoint(x: w * 0.26, y: h * 0.32))
        path.addQuadCurve(to: CGPoint(x: w * 0.38, y: h * 0.30), control: CGPoint(x: w * 0.34, y: h * 0.42))
        path.addQuadCurve(to: CGPoint(x: w * 0.45, y: h * 0.42), control: CGPoint(x: w * 0.42, y: h * 0.28))
        path.addQuadCurve(to: CGPoint(x: w * 0.52, y: h * 0.18), control: CGPoint(x: w * 0.48, y: h * 0.38))
        path.addQuadCurve(to: CGPoint(x: w * 0.60, y: h * 0.08), control: CGPoint(x: w * 0.55, y: h * 0.12))
        path.addQuadCurve(to: CGPoint(x: w * 0.68, y: h * 0.25), control: CGPoint(x: w * 0.65, y: h * 0.05))
        path.addQuadCurve(to: CGPoint(x: w * 0.75, y: h * 0.35), control: CGPoint(x: w * 0.72, y: h * 0.28))
        path.addQuadCurve(to: CGPoint(x: w * 0.82, y: h * 0.45), control: CGPoint(x: w * 0.78, y: h * 0.32))
        path.addQuadCurve(to: CGPoint(x: w * 0.90, y: h * 0.55), control: CGPoint(x: w * 0.86, y: h * 0.48))
        path.addQuadCurve(to: CGPoint(x: w * 1.0, y: h * 0.68), control: CGPoint(x: w * 0.95, y: h * 0.58))
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        return path
    }
}

struct RouteTraceShape: Shape {
    let normalizedPoints: [CGPoint]

    func path(in rect: CGRect) -> Path {
        let padding: CGFloat = 0.0
        guard normalizedPoints.count >= 2 else { return Path() }
        let xs = normalizedPoints.map(\.x)
        let ys = normalizedPoints.map(\.y)
        guard let minX = xs.min(), let maxX = xs.max(),
              let minY = ys.min(), let maxY = ys.max() else { return Path() }
        let rangeW = maxX - minX
        let rangeH = maxY - minY
        let availW = rect.width * (1 - 2 * padding)
        let availH = rect.height * (1 - 2 * padding)
        let scale: CGFloat
        if rangeW < 0.001 && rangeH < 0.001 {
            scale = 1
        } else if rangeW < 0.001 {
            scale = availH / rangeH
        } else if rangeH < 0.001 {
            scale = availW / rangeW
        } else {
            scale = min(availW / rangeW, availH / rangeH)
        }
        let centerX = (minX + maxX) / 2
        let centerY = (minY + maxY) / 2
        var path = Path()
        let mapped = normalizedPoints.map { pt in
            CGPoint(
                x: (pt.x - centerX) * scale + rect.midX,
                y: (pt.y - centerY) * scale + rect.midY
            )
        }
        guard let first = mapped.first else { return path }
        path.move(to: first)
        for point in mapped.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}

// MARK: - StatWidgetContentView Route & Time Extensions

extension StatWidgetContentView {

    // MARK: - Route helpers

    private func routeTightSize(for points: [CGPoint], maxDimension: CGFloat, strokePadding: CGFloat) -> CGSize {
        guard points.count >= 2 else { return CGSize(width: maxDimension, height: maxDimension) }
        let xs = points.map(\.x)
        let ys = points.map(\.y)
        guard let minX = xs.min(), let maxX = xs.max(),
              let minY = ys.min(), let maxY = ys.max() else {
            return CGSize(width: maxDimension, height: maxDimension)
        }
        let rangeW = maxX - minX
        let rangeH = maxY - minY
        let minSize: CGFloat = 80
        if rangeW < 0.001 && rangeH < 0.001 { return CGSize(width: minSize, height: minSize) }
        let drawArea = maxDimension - strokePadding
        if rangeW < 0.001 { return CGSize(width: minSize, height: maxDimension) }
        if rangeH < 0.001 { return CGSize(width: maxDimension, height: minSize) }
        let aspect = rangeW / rangeH
        let width: CGFloat
        let height: CGFloat
        if aspect >= 1 {
            width = maxDimension
            height = max(minSize, drawArea / aspect + strokePadding)
        } else {
            height = maxDimension
            width = max(minSize, drawArea * aspect + strokePadding)
        }
        return CGSize(width: width, height: height)
    }

    // MARK: - routeCleanWidget

    var routeCleanWidget: some View {
        let rawPoints = activity.linePoints
        let frameSize = routeTightSize(for: rawPoints, maxDimension: 220, strokePadding: 2)
        return ZStack {
            if rawPoints.count >= 2 {
                RouteTraceShape(normalizedPoints: rawPoints)
                    .stroke(primaryColor.opacity(0.9), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            } else {
                Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(primaryColor.opacity(0.3))
            }
        }
        .frame(width: frameSize.width, height: frameSize.height)
    }

    // MARK: - Time helpers

    private var efficiencyRatio: Double {
        guard activity.elapsedTimeRaw > 0 else { return 1.0 }
        return min(1.0, Double(activity.movingTimeRaw) / Double(activity.elapsedTimeRaw))
    }

    private func formatDurationCompact(_ seconds: Int) -> String {
        ActivityFormatting.durationCompact(seconds)
    }

    // MARK: - movingTimeCleanWidget

    var movingTimeCleanWidget: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(primaryColor.opacity(0.12), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: 48, height: 48)
                Circle()
                    .trim(from: 0, to: efficiencyRatio * 0.75)
                    .stroke(primaryColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: 48, height: 48)
                    .shadow(color: primaryColor.opacity(0.4), radius: 6, x: 0, y: 2)
                Image(systemName: "timer")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(primaryColor.opacity(0.70))
            }
            Text(String(format: "%.0f%% active", efficiencyRatio * 100))
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(primaryColor.opacity(0.60))
            Text(activity.duration)
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(primaryColor)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text("MOVING")
                .font(.system(size: 8, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(primaryColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    // MARK: - elapsedTimeCleanWidget

    var elapsedTimeCleanWidget: some View {
        let pausedSeconds = activity.elapsedTimeRaw - activity.movingTimeRaw
        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(primaryColor.opacity(0.12), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: 48, height: 48)
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(primaryColor.opacity(0.50), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: 48, height: 48)
                    .shadow(color: primaryColor.opacity(0.3), radius: 6, x: 0, y: 2)
                Image(systemName: "clock")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(primaryColor.opacity(0.55))
            }
            if pausedSeconds > 0 {
                Text(formatDurationCompact(pausedSeconds) + " paused")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(primaryColor.opacity(0.50))
            }
            Text(activity.elapsedTime)
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(primaryColor)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text("ELAPSED")
                .font(.system(size: 8, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(primaryColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    // MARK: - Heart Rate helpers

    var heartRateBPM: Int {
        guard let hrString = activity.averageHeartrate else { return 0 }
        let digits = hrString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(digits) ?? 0
    }

    var heartRateZone: (index: Int, label: String, progress: Double, glowOpacity: Double) {
        let bpm = heartRateBPM
        guard bpm > 0 else { return (0, "--", 0.2, 0.0) }
        let normalized = min(1.0, max(0.0, Double(bpm - 60) / 140.0))
        switch bpm {
        case ..<100:
            return (1, "Zone 1 · Light", max(0.15, normalized), 0.0)
        case 100..<120:
            return (2, "Zone 2 · Easy", normalized, 0.1)
        case 120..<140:
            return (3, "Zone 3 · Moderate", normalized, 0.25)
        case 140..<160:
            return (4, "Zone 4 · Hard", normalized, 0.45)
        default:
            return (5, "Zone 5 · Max", min(1.0, normalized), 0.65)
        }
    }

    // MARK: - hrPulseDotsWidget

    var hrPulseDotsWidget: some View {
        let bpm = heartRateBPM
        let zone = heartRateZone
        let bpmText = bpm > 0 ? "\(bpm)" : "--"
        let zoneLabels = ["Light", "Easy", "Moderate", "Hard", "Max"]
        let dotSizes: [CGFloat] = [6, 7, 8, 9, 10]

        return HStack(spacing: 14) {
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { i in
                        let isActive = (i + 1) == zone.index
                        let isPast = (i + 1) < zone.index
                        let dotOpacity = isActive ? 1.0 : (isPast ? 0.45 : 0.15)
                        Circle()
                            .fill(primaryColor.opacity(dotOpacity))
                            .frame(width: dotSizes[i], height: dotSizes[i])
                            .shadow(color: isActive ? primaryColor.opacity(0.6) : .clear, radius: isActive ? 8 : 0)
                            .scaleEffect(isActive ? 1.3 : 1.0)
                    }
                }
                Text(bpm > 0 ? "Zone \(zone.index) · \(zoneLabels[max(0, zone.index - 1)])" : "--")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(primaryColor.opacity(0.50))
            }
            VStack(spacing: 1) {
                Text(bpmText)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryColor)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text("BPM")
                    .font(.system(size: 7, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(primaryColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    // MARK: - avgHeartRateWidget

    var avgHeartRateWidget: some View {
        let zone = heartRateZone
        let bpm = heartRateBPM
        let bpmText = bpm > 0 ? "\(bpm)" : "--"
        let arcOpacity = bpm > 0 ? (zone.index >= 4 ? 1.0 : zone.index >= 3 ? 0.8 : 0.6) : 0.2

        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(primaryColor.opacity(0.10), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: 48, height: 48)
                Circle()
                    .trim(from: 0, to: zone.progress * 0.75)
                    .stroke(primaryColor.opacity(arcOpacity), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: 48, height: 48)
                    .shadow(color: primaryColor.opacity(zone.glowOpacity), radius: zone.index >= 4 ? 10 : 6, x: 0, y: 2)
                Image(systemName: "heart.fill")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(primaryColor.opacity(0.70))
            }
            Text(zone.label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(primaryColor.opacity(0.55))
            Text(bpmText)
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(primaryColor)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text("AVG HR")
                .font(.system(size: 8, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(primaryColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    // MARK: - Elevation helpers

    private var elevationNumeric: String {
        let digits = activity.elevationGain.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return digits.isEmpty ? "--" : digits
    }

    // MARK: - elevationGainWidget

    var elevationGainWidget: some View {
        let elev = elevationNumeric
        let widgetWidth: CGFloat = 180
        let widgetHeight: CGFloat = 130
        let mountainHeight: CGFloat = 58

        return VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(primaryColor.opacity(0.50))
                Text(elev)
                    .font(.system(size: 30, weight: .black).width(.expanded).italic())
                    .tracking(-1)
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("m")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(primaryColor.opacity(0.50))
                    .offset(y: -2)
            }
            .padding(.bottom, 2)

            ZStack(alignment: .bottom) {
                MountainRidgeShape()
                    .fill(
                        LinearGradient(
                            colors: [primaryColor.opacity(0.55), primaryColor.opacity(0.08)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: widgetWidth - 16, height: mountainHeight)

                MountainRidgeShape()
                    .stroke(primaryColor.opacity(0.35), lineWidth: 1.2)
                    .frame(width: widgetWidth - 16, height: mountainHeight)

                ForEach(0..<3, id: \.self) { i in
                    let yRatio = 0.30 + Double(i) * 0.22
                    let opacity = 0.18 - Double(i) * 0.05
                    Rectangle()
                        .fill(primaryColor.opacity(opacity))
                        .frame(height: 0.5)
                        .offset(y: -mountainHeight * yRatio)
                }
            }
            .frame(height: mountainHeight)
            .clipped()

            HStack(spacing: 4) {
                Image(systemName: "triangle.fill")
                    .font(.system(size: 5, weight: .bold))
                    .foregroundStyle(primaryColor.opacity(0.40))
                Text("ELEVATION GAIN")
                    .font(.system(size: 7, weight: .bold))
                    .tracking(2.2)
                    .foregroundStyle(primaryColor)
            }
            .padding(.top, 6)
        }
        .frame(width: widgetWidth, height: widgetHeight)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }
}
