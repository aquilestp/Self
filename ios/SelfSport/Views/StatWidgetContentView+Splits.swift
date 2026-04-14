import SwiftUI

// MARK: - ShimmerRect (used by detail loading state)

struct ShimmerRect: View {
    let color: Color
    let width: CGFloat
    let height: CGFloat
    @State private var phase: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color.opacity(0.08))
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.0), color.opacity(0.15), color.opacity(0.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: phase ? width : -width)
            )
            .clipShape(.rect(cornerRadius: 3))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = true
                }
            }
    }
}

// MARK: - StatWidgetContentView Splits Extensions

extension StatWidgetContentView {

    // MARK: - Shared loading helpers (internal so Efforts can access)

    func detailShimmer(width: CGFloat, height: CGFloat, label: String) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 7, weight: .bold))
                .tracking(2.0)
                .foregroundStyle(secondaryColor)

            VStack(spacing: 6) {
                ShimmerRect(color: primaryColor, width: width * 0.8, height: 10)
                ShimmerRect(color: primaryColor, width: width * 0.6, height: 8)
                ShimmerRect(color: primaryColor, width: width * 0.7, height: 8)
            }
        }
        .frame(width: width, height: height)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    func detailEmptyState(icon: String, label: String, sublabel: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(primaryColor.opacity(0.3))
            Text(label)
                .font(.system(size: 7, weight: .bold))
                .tracking(2.0)
                .foregroundStyle(secondaryColor)
            Text(sublabel)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(primaryColor.opacity(0.35))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    // MARK: - Pace formatter helper

    private func splitPaceString(speed: Double, unitDistance: Double) -> String {
        ActivityFormatting.splitPace(speed: speed, unitDistance: unitDistance)
    }

    // MARK: - splitsWidget

    func splitsWidget(filter: SplitsUnitFilter) -> some View {
        Group {
            if isLoadingDetail {
                detailShimmer(width: 180, height: 110, label: "SPLITS")
            } else {
                let splits: [StravaSplit]? = filter == .miles ? activityDetail?.splitsStandard : activityDetail?.splitsMetric
                if let splits, splits.count > 1 {
                    splitsContent(splits: splits, filter: filter)
                } else {
                    detailEmptyState(icon: "chart.bar.xaxis", label: "SPLITS", sublabel: "No split data")
                }
            }
        }
    }

    private func splitsContent(splits: [StravaSplit], filter: SplitsUnitFilter) -> some View {
        let paces = splits.map { $0.movingTime > 0 && $0.distance > 0 ? $0.distance / Double($0.movingTime) : 0 }
        let maxPace = paces.max() ?? 1.0
        let minPace: Double = paces.filter { $0 > 0 }.min() ?? 0
        let avgPace: Double = {
            let validPaces = paces.filter { $0 > 0 }
            guard !validPaces.isEmpty else { return 0 }
            return validPaces.reduce(0, +) / Double(validPaces.count)
        }()
        let unitDistance: Double = filter == .miles ? 1609.34 : 1000.0
        let avgPaceFormatted: String = {
            guard avgPace > 0 else { return "--" }
            let secPerUnit = unitDistance / avgPace
            let m = Int(secPerUnit) / 60
            let s = Int(secPerUnit) % 60
            return String(format: "%d:%02d", m, s)
        }()
        let count = splits.count
        let showAllPaces = count <= 8
        let showSomePaces = count <= 15
        let barW: CGFloat = count <= 8 ? 14 : count <= 15 ? 9 : count <= 22 ? 6 : 4
        let fastBarW: CGFloat = count <= 8 ? 20 : count <= 15 ? 14 : count <= 22 ? 10 : 7
        let barSpacing: CGFloat = count <= 8 ? 5 : count <= 15 ? 3 : 2
        let paceFontSize: CGFloat = count <= 8 ? 11 : count <= 15 ? 8 : 7
        let fastPaceFontSize: CGFloat = count <= 8 ? 16 : count <= 15 ? 12 : 10
        let labelSize: CGFloat = count <= 8 ? 7 : count <= 15 ? 5.5 : count <= 22 ? 4 : 3
        let maxBarH: CGFloat = 52

        return VStack(spacing: 4) {
            Text("SPLITS")
                .font(.system(size: 9, weight: .heavy))
                .tracking(3.0)
                .foregroundStyle(secondaryColor)

            HStack(alignment: .bottom, spacing: barSpacing) {
                ForEach(Array(splits.enumerated()), id: \.offset) { idx, split in
                    let pace = paces[idx]
                    let range = maxPace - minPace
                    let normalized = range > 0 ? (pace - minPace) / range : 0.5
                    let ratio = 0.25 + 0.75 * normalized
                    let isFastest = pace == maxPace && pace > 0
                    let barH = max(8, CGFloat(ratio) * maxBarH)
                    let paceStr = splitPaceString(speed: pace, unitDistance: unitDistance)
                    let shouldShowPace = isFastest || (showAllPaces && count <= 6) || (showSomePaces && !showAllPaces && idx % 3 == 0)

                    VStack(spacing: 1) {
                        if shouldShowPace {
                            Text(paceStr)
                                .font(.system(size: isFastest ? fastPaceFontSize : paceFontSize, weight: .black, design: .default).width(.compressed))
                                .foregroundStyle(primaryColor.opacity(isFastest ? 1.0 : 0.7))
                                .shadow(color: isFastest ? primaryColor.opacity(0.6) : .clear, radius: 6, x: 0, y: 0)
                                .lineLimit(1)
                                .fixedSize()
                        }

                        RoundedRectangle(cornerRadius: isFastest ? 3 : 2)
                            .fill(primaryColor.opacity(isFastest ? 1.0 : (pace > 0 ? 0.25 + 0.45 * normalized : 0.10)))
                            .frame(width: isFastest ? fastBarW : barW, height: barH)
                            .shadow(color: isFastest ? primaryColor.opacity(0.5) : .clear, radius: 6, x: 0, y: 2)

                        Text("\(idx + 1)")
                            .font(.system(size: labelSize, weight: isFastest ? .heavy : .medium))
                            .foregroundStyle(primaryColor.opacity(isFastest ? 0.9 : 0.35))
                    }
                }
            }
            .frame(height: maxBarH + fastPaceFontSize + 8, alignment: .bottom)

            HStack(spacing: 12) {
                VStack(spacing: 1) {
                    Text("\(count)")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(primaryColor)
                    Text(filter.unitLabel)
                        .font(.system(size: 6, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(dimColor)
                }
                Rectangle()
                    .fill(dividerColor)
                    .frame(width: 1, height: 18)
                VStack(spacing: 1) {
                    Text(avgPaceFormatted)
                        .font(.system(size: 15, weight: .black, design: .monospaced))
                        .foregroundStyle(primaryColor)
                    Text(filter.paceLabel)
                        .font(.system(size: 6, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(dimColor)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    // MARK: - splitsTableWidget

    func splitsTableWidget(filter: SplitsUnitFilter) -> some View {
        Group {
            if isLoadingDetail {
                detailShimmer(width: 200, height: 160, label: "ALL SPLITS")
            } else {
                let splits: [StravaSplit]? = filter == .miles ? activityDetail?.splitsStandard : activityDetail?.splitsMetric
                if let splits, splits.count > 1 {
                    splitsTableContent(splits: splits, filter: filter)
                } else {
                    detailEmptyState(icon: "list.number", label: "ALL SPLITS", sublabel: "No split data")
                }
            }
        }
    }

    private func splitsTableContent(splits: [StravaSplit], filter: SplitsUnitFilter) -> some View {
        let unitDistance: Double = filter == .miles ? 1609.34 : 1000.0
        let paces = splits.map { $0.movingTime > 0 && $0.distance > 0 ? $0.distance / Double($0.movingTime) : 0 }
        let maxPace = paces.max() ?? 1.0
        let minPace = paces.filter { $0 > 0 }.min() ?? 0
        let count = splits.count
        let isCompact = count > 10
        let rowH: CGFloat = isCompact ? 16 : 20
        let numFont: CGFloat = isCompact ? 9 : 11
        let paceFont: CGFloat = isCompact ? 13 : 16
        let barMaxW: CGFloat = 80

        return VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "list.number")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(secondaryColor)
                Text("ALL SPLITS")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(3.0)
                    .foregroundStyle(secondaryColor)
                Spacer()
                Text(filter == .miles ? "MI" : "KM")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(dimColor)
            }

            VStack(spacing: isCompact ? 2 : 4) {
                ForEach(Array(splits.enumerated()), id: \.offset) { idx, split in
                    let pace = paces[idx]
                    let isFastest = pace == maxPace && pace > 0
                    let range = maxPace - minPace
                    let normalized = range > 0 ? (pace - minPace) / range : 0.5
                    let barRatio = 0.15 + 0.85 * normalized
                    let paceStr = splitPaceString(speed: pace, unitDistance: unitDistance)

                    HStack(spacing: 4) {
                        Text("\(idx + 1)")
                            .font(.system(size: numFont, weight: isFastest ? .black : .medium, design: .monospaced))
                            .foregroundStyle(primaryColor.opacity(isFastest ? 1.0 : 0.4))
                            .frame(width: 18, alignment: .trailing)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(primaryColor.opacity(0.08))
                                .frame(width: barMaxW, height: isFastest ? rowH : rowH - 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(primaryColor.opacity(isFastest ? 0.9 : 0.15 + 0.45 * normalized))
                                .frame(width: max(4, barMaxW * CGFloat(barRatio)), height: isFastest ? rowH : rowH - 4)
                                .shadow(color: isFastest ? primaryColor.opacity(0.5) : .clear, radius: 6, x: 0, y: 0)
                        }

                        Text(paceStr)
                            .font(.system(size: isFastest ? paceFont + 4 : paceFont, weight: .black, design: .default).width(.compressed))
                            .foregroundStyle(primaryColor.opacity(isFastest ? 1.0 : 0.7))
                            .shadow(color: isFastest ? primaryColor.opacity(0.6) : .clear, radius: 8, x: 0, y: 0)
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .frame(height: rowH)
                }
            }

            Rectangle()
                .fill(dividerColor)
                .frame(height: 0.5)

            HStack(spacing: 12) {
                VStack(spacing: 1) {
                    Text("\(count)")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(primaryColor)
                    Text(filter.unitLabel)
                        .font(.system(size: 6, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(dimColor)
                }
                Rectangle()
                    .fill(dividerColor)
                    .frame(width: 1, height: 18)
                VStack(spacing: 1) {
                    let avgPace: String = {
                        let valid = paces.filter { $0 > 0 }
                        guard !valid.isEmpty else { return "--" }
                        let avg = valid.reduce(0, +) / Double(valid.count)
                        let sec = unitDistance / avg
                        let m = Int(sec) / 60
                        let s = Int(sec) % 60
                        return String(format: "%d:%02d", m, s)
                    }()
                    Text(avgPace)
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundStyle(primaryColor)
                    Text(filter.paceLabel)
                        .font(.system(size: 6, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(dimColor)
                }
                Rectangle()
                    .fill(dividerColor)
                    .frame(width: 1, height: 18)
                VStack(spacing: 1) {
                    let fastestPace: String = {
                        guard maxPace > 0 else { return "--" }
                        let sec = unitDistance / maxPace
                        let m = Int(sec) / 60
                        let s = Int(sec) % 60
                        return String(format: "%d:%02d", m, s)
                    }()
                    Text(fastestPace)
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundStyle(primaryColor)
                    Text("FASTEST")
                        .font(.system(size: 6, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(dimColor)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .fixedSize()
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    // MARK: - splitsFastestWidget

    func splitsFastestWidget(filter: SplitsUnitFilter) -> some View {
        Group {
            if isLoadingDetail {
                detailShimmer(width: 200, height: 140, label: "FASTEST SPLIT")
            } else {
                let splits: [StravaSplit]? = filter == .miles ? activityDetail?.splitsStandard : activityDetail?.splitsMetric
                if let splits, splits.count > 1 {
                    splitsFastestContent(splits: splits, filter: filter)
                } else {
                    detailEmptyState(icon: "bolt.horizontal.fill", label: "FASTEST SPLIT", sublabel: "No split data")
                }
            }
        }
    }

    private func splitsFastestContent(splits: [StravaSplit], filter: SplitsUnitFilter) -> some View {
        let unitDistance: Double = filter == .miles ? 1609.34 : 1000.0
        let paces = splits.map { $0.movingTime > 0 && $0.distance > 0 ? $0.distance / Double($0.movingTime) : 0 }
        let maxPace = paces.max() ?? 1.0
        let minPace = paces.filter { $0 > 0 }.min() ?? 0
        let count = splits.count
        let isCompact = count > 10
        let rowH: CGFloat = isCompact ? 14 : 18
        let fastRowH: CGFloat = isCompact ? 22 : 28
        let numFont: CGFloat = isCompact ? 8 : 10
        let barMaxW: CGFloat = 100
        let avgPaceFormatted: String = {
            let valid = paces.filter { $0 > 0 }
            guard !valid.isEmpty else { return "--" }
            let avg = valid.reduce(0, +) / Double(valid.count)
            let sec = unitDistance / avg
            let m = Int(sec) / 60
            let s = Int(sec) % 60
            return String(format: "%d:%02d", m, s)
        }()
        let fastestPaceFormatted: String = {
            guard maxPace > 0 else { return "--" }
            let sec = unitDistance / maxPace
            let m = Int(sec) / 60
            let s = Int(sec) % 60
            return String(format: "%d:%02d", m, s)
        }()

        return VStack(spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(secondaryColor)
                Text("FASTEST SPLIT")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(3.0)
                    .foregroundStyle(secondaryColor)
                Spacer()
                Text(filter == .miles ? "MI" : "KM")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(dimColor)
            }

            VStack(spacing: isCompact ? 1 : 3) {
                ForEach(Array(splits.enumerated()), id: \.offset) { idx, split in
                    let pace = paces[idx]
                    let isFastest = pace == maxPace && pace > 0
                    let range = maxPace - minPace
                    let normalized = range > 0 ? (pace - minPace) / range : 0.5
                    let barRatio = 0.08 + 0.92 * normalized
                    let paceStr = splitPaceString(speed: pace, unitDistance: unitDistance)
                    let currentRowH = isFastest ? fastRowH : rowH

                    HStack(spacing: 5) {
                        HStack(spacing: 2) {
                            if isFastest {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: isCompact ? 7 : 9, weight: .black))
                                    .foregroundStyle(primaryColor)
                                    .shadow(color: primaryColor.opacity(0.8), radius: 4, x: 0, y: 0)
                            }
                            Text("\(idx + 1)")
                                .font(.system(size: isFastest ? numFont + 3 : numFont, weight: isFastest ? .black : .medium, design: .monospaced))
                                .foregroundStyle(primaryColor.opacity(isFastest ? 1.0 : 0.3))
                        }
                        .frame(width: isFastest ? 30 : 18, alignment: .trailing)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: isFastest ? 4 : 2)
                                .fill(primaryColor.opacity(0.05))
                                .frame(width: barMaxW, height: isFastest ? fastRowH - 4 : currentRowH - 6)

                            RoundedRectangle(cornerRadius: isFastest ? 4 : 2)
                                .fill(primaryColor.opacity(isFastest ? 1.0 : 0.06 + 0.20 * normalized))
                                .frame(width: max(4, barMaxW * CGFloat(barRatio)), height: isFastest ? fastRowH - 4 : currentRowH - 6)
                                .shadow(color: isFastest ? primaryColor.opacity(0.7) : .clear, radius: 10, x: 4, y: 0)
                                .shadow(color: isFastest ? primaryColor.opacity(0.4) : .clear, radius: 20, x: 0, y: 0)
                        }

                        Spacer()

                        if isFastest {
                            Text(paceStr)
                                .font(.system(size: isCompact ? 18 : 22, weight: .black, design: .default).width(.compressed))
                                .foregroundStyle(primaryColor)
                                .shadow(color: primaryColor.opacity(0.6), radius: 10, x: 0, y: 0)
                                .lineLimit(1)
                                .fixedSize()
                        }
                    }
                    .frame(height: currentRowH)
                }
            }

            Rectangle()
                .fill(dividerColor)
                .frame(height: 0.5)

            HStack(spacing: 12) {
                VStack(spacing: 1) {
                    Text("\(count)")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(primaryColor)
                    Text(filter.unitLabel)
                        .font(.system(size: 6, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(dimColor)
                }
                Rectangle()
                    .fill(dividerColor)
                    .frame(width: 1, height: 18)
                VStack(spacing: 1) {
                    Text(avgPaceFormatted)
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundStyle(primaryColor)
                    Text(filter.paceLabel)
                        .font(.system(size: 6, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(dimColor)
                }
                Rectangle()
                    .fill(dividerColor)
                    .frame(width: 1, height: 18)
                VStack(spacing: 1) {
                    Text(fastestPaceFormatted)
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundStyle(primaryColor)
                    Text("FASTEST")
                        .font(.system(size: 6, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(dimColor)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .fixedSize()
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    // MARK: - splitsBarsWidget

    func splitsBarsWidget(filter: SplitsUnitFilter) -> some View {
        Group {
            if isLoadingDetail {
                detailShimmer(width: 200, height: 140, label: "SPLITS")
            } else {
                let splits: [StravaSplit]? = filter == .miles ? activityDetail?.splitsStandard : activityDetail?.splitsMetric
                if let splits, splits.count > 1 {
                    splitsBarsContent(splits: splits, filter: filter)
                } else {
                    detailEmptyState(icon: "chart.bar.doc.horizontal", label: "SPLITS", sublabel: "No split data")
                }
            }
        }
    }

    private func splitsBarsContent(splits: [StravaSplit], filter: SplitsUnitFilter) -> some View {
        let unitDistance: Double = filter == .miles ? 1609.34 : 1000.0
        let paces = splits.map { $0.movingTime > 0 && $0.distance > 0 ? $0.distance / Double($0.movingTime) : 0 }
        let maxPace = paces.max() ?? 1.0
        let minPace = paces.filter { $0 > 0 }.min() ?? 0
        let count = splits.count
        let isCompact = count > 10
        let rowH: CGFloat = isCompact ? 14 : 18
        let fastRowH: CGFloat = isCompact ? 20 : 24
        let numFont: CGFloat = isCompact ? 8 : 10
        let paceFont: CGFloat = isCompact ? 11 : 14
        let barMaxW: CGFloat = 90
        let avgPaceFormatted: String = {
            let valid = paces.filter { $0 > 0 }
            guard !valid.isEmpty else { return "--" }
            let avg = valid.reduce(0, +) / Double(valid.count)
            let sec = unitDistance / avg
            let m = Int(sec) / 60
            let s = Int(sec) % 60
            return String(format: "%d:%02d", m, s)
        }()

        return VStack(spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(secondaryColor)
                Text("SPLITS")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(3.0)
                    .foregroundStyle(secondaryColor)
                Spacer()
                Text(filter == .miles ? "MI" : "KM")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(dimColor)
            }

            VStack(spacing: isCompact ? 1 : 3) {
                ForEach(Array(splits.enumerated()), id: \.offset) { idx, split in
                    let pace = paces[idx]
                    let isFastest = pace == maxPace && pace > 0
                    let range = maxPace - minPace
                    let normalized = range > 0 ? (pace - minPace) / range : 0.5
                    let barRatio = 0.08 + 0.92 * normalized
                    let paceStr = splitPaceString(speed: pace, unitDistance: unitDistance)
                    let currentRowH = isFastest ? fastRowH : rowH
                    let barThickness: CGFloat = isFastest ? (isCompact ? 16 : 20) : (isCompact ? 8 : 12)

                    HStack(spacing: 4) {
                        Text("\(idx + 1)")
                            .font(.system(size: isFastest ? numFont + 2 : numFont, weight: isFastest ? .black : .medium, design: .monospaced))
                            .foregroundStyle(primaryColor.opacity(isFastest ? 1.0 : 0.35))
                            .frame(width: 18, alignment: .trailing)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: isFastest ? 4 : 2)
                                .fill(primaryColor.opacity(0.05))
                                .frame(width: barMaxW, height: barThickness)

                            RoundedRectangle(cornerRadius: isFastest ? 4 : 2)
                                .fill(primaryColor.opacity(isFastest ? 0.95 : 0.08 + 0.50 * normalized))
                                .frame(width: max(4, barMaxW * CGFloat(barRatio)), height: barThickness)
                                .shadow(color: isFastest ? primaryColor.opacity(0.6) : .clear, radius: 8, x: 3, y: 0)
                                .shadow(color: isFastest ? primaryColor.opacity(0.3) : .clear, radius: 16, x: 0, y: 0)
                        }

                        Text(paceStr)
                            .font(.system(size: isFastest ? paceFont + 6 : paceFont, weight: .black, design: .default).width(.compressed))
                            .foregroundStyle(primaryColor.opacity(isFastest ? 1.0 : 0.55))
                            .shadow(color: isFastest ? primaryColor.opacity(0.5) : .clear, radius: 8, x: 0, y: 0)
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .frame(height: currentRowH)
                }
            }

            Rectangle()
                .fill(dividerColor)
                .frame(height: 0.5)

            HStack(spacing: 12) {
                VStack(spacing: 1) {
                    Text("\(count)")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(primaryColor)
                    Text(filter.unitLabel)
                        .font(.system(size: 6, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(dimColor)
                }
                Rectangle()
                    .fill(dividerColor)
                    .frame(width: 1, height: 18)
                VStack(spacing: 1) {
                    Text(avgPaceFormatted)
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundStyle(primaryColor)
                    Text(filter.paceLabel)
                        .font(.system(size: 6, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(dimColor)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .fixedSize()
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }
}
