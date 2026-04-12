import SwiftUI

nonisolated struct SplitMix64: Sendable {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
    mutating func nextDouble() -> Double {
        Double(next() >> 11) / Double(1 << 53)
    }
}

nonisolated enum ExportEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isExport: Bool {
        get { self[ExportEnvironmentKey.self] }
        set { self[ExportEnvironmentKey.self] = newValue }
    }
}

nonisolated private struct StatDisplayItem: Identifiable, Sendable {
    let id: String
    let label: String
    let value: String
}

struct StatWidgetContentView: View, Equatable {
    static func == (lhs: StatWidgetContentView, rhs: StatWidgetContentView) -> Bool {
        lhs.type == rhs.type &&
        lhs.activity == rhs.activity &&
        lhs.colorStyle == rhs.colorStyle &&
        lhs.useGlassBackground == rhs.useGlassBackground &&
        lhs.weeklyKmData == rhs.weeklyKmData &&
        lhs.lastWeekKmData == rhs.lastWeekKmData &&
        lhs.monthlyKmData == rhs.monthlyKmData &&
        lhs.lastMonthKmData == rhs.lastMonthKmData &&
        lhs.activityDetail == rhs.activityDetail &&
        lhs.isLoadingDetail == rhs.isLoadingDetail &&
        lhs.bestEffortsFilter == rhs.bestEffortsFilter &&
        lhs.splitsFilter == rhs.splitsFilter &&
        lhs.distanceWordsFilter == rhs.distanceWordsFilter &&
        lhs.fontStyle == rhs.fontStyle &&
        lhs.showTitle == rhs.showTitle &&
        lhs.showActivityName == rhs.showActivityName &&
        lhs.showDate == rhs.showDate &&
        lhs.showDistance == rhs.showDistance &&
        lhs.showPace == rhs.showPace &&
        lhs.showTime == rhs.showTime &&
        lhs.showElevation == rhs.showElevation &&
        lhs.basicUnitFilter == rhs.basicUnitFilter &&
        lhs.fullBannerUnitFilter == rhs.fullBannerUnitFilter &&
        lhs.fullBannerShowDistance == rhs.fullBannerShowDistance &&
        lhs.fullBannerShowPace == rhs.fullBannerShowPace &&
        lhs.fullBannerShowTime == rhs.fullBannerShowTime &&
        lhs.fullBannerShowElevation == rhs.fullBannerShowElevation &&
        lhs.bvtShowDate == rhs.bvtShowDate &&
        lhs.bvtShowTime == rhs.bvtShowTime &&
        lhs.bvtShowLocation == rhs.bvtShowLocation &&
        lhs.bvtShowDistance == rhs.bvtShowDistance &&
        lhs.bvtShowPace == rhs.bvtShowPace &&
        lhs.bvtShowDuration == rhs.bvtShowDuration &&
        lhs.bvtShowElevation == rhs.bvtShowElevation &&
        lhs.bvtShowCalories == rhs.bvtShowCalories &&
        lhs.bvtShowBPM == rhs.bvtShowBPM &&
        lhs.bvtUnitFilter == rhs.bvtUnitFilter &&
        lhs.bvtEffect == rhs.bvtEffect &&
        lhs.whatsappText == rhs.whatsappText &&
        lhs.goldenArchUnitFilter == rhs.goldenArchUnitFilter &&
        lhs.goldenArchShowPace == rhs.goldenArchShowPace &&
        lhs.goldenArchShowTime == rhs.goldenArchShowTime
    }

    let type: StatWidgetType
    let activity: ActivityHighlight
    var colorStyle: WidgetColorStyle = .initial
    var useGlassBackground: Bool = false
    var weeklyKmData: WeeklyKmData = .empty
    var lastWeekKmData: WeeklyKmData = .empty
    var monthlyKmData: MonthlyKmData = .empty
    var lastMonthKmData: MonthlyKmData = .empty
    var activityDetail: StravaActivityDetail? = nil
    var isLoadingDetail: Bool = false
    var bestEffortsFilter: BestEffortsUnitFilter = .km
    var splitsFilter: SplitsUnitFilter = .km
    var distanceWordsFilter: SplitsUnitFilter = .km
    var fontStyle: WidgetFontStyle = .system
    var showTitle: Bool = true
    var showActivityName: Bool = true
    var showDate: Bool = true
    var showDistance: Bool = true
    var showPace: Bool = true
    var showTime: Bool = true
    var showElevation: Bool = true
    var basicUnitFilter: SplitsUnitFilter = .km
    var fullBannerUnitFilter: SplitsUnitFilter = .km
    var fullBannerShowDistance: Bool = true
    var fullBannerShowPace: Bool = true
    var fullBannerShowTime: Bool = true
    var fullBannerShowElevation: Bool = true
    var bvtShowDate: Bool = true
    var bvtShowTime: Bool = true
    var bvtShowLocation: Bool = true
    var bvtShowDistance: Bool = true
    var bvtShowPace: Bool = true
    var bvtShowDuration: Bool = true
    var bvtShowElevation: Bool = true
    var bvtShowCalories: Bool = true
    var bvtShowBPM: Bool = true
    var bvtUnitFilter: SplitsUnitFilter = .km
    var bvtEffect: BVTEffect = .glow
    var whatsappText: String = "My coach would be proud"
    var goldenArchUnitFilter: SplitsUnitFilter = .km
    var goldenArchShowPace: Bool = true
    var goldenArchShowTime: Bool = true

    private var primaryColor: Color {
        colorStyle.currentColor
    }
    private var secondaryColor: Color {
        primaryColor.opacity(0.55)
    }
    private var tertiaryColor: Color {
        primaryColor.opacity(0.6)
    }
    private var dimColor: Color {
        primaryColor.opacity(0.45)
    }
    private var boldColor: Color {
        primaryColor
    }
    private var dividerColor: Color {
        primaryColor.opacity(0.2)
    }

    var body: some View {
        switch type {
        case .distance: distanceWidget
        case .distPace: distPaceWidget
        case .threeStats: threeStatsWidget
        case .titleCard: titleCardWidget
        case .stack: stackWidget
        case .bold: boldWidget
        case .impact: impactWidget
        case .poster: posterWidget
        case .routeClean: routeCleanWidget
        case .heroStat: heroStatWidget
        case .wide: wideWidget
        case .tower: towerWidget
        case .movingTimeClean: movingTimeCleanWidget
        case .elapsedTimeClean: elapsedTimeCleanWidget
        case .avgHeartRate: avgHeartRateWidget
        case .hrPulseDots: hrPulseDotsWidget
        case .weeklyKm: weeklyKmWidget
        case .lastWeekKm: lastWeekKmWidget
        case .monthlyKm: monthlyKmWidget
        case .lastMonthKm: lastMonthKmWidget
        case .elevationGain: elevationGainWidget
        case .splits: splitsWidget(filter: splitsFilter)
        case .splitsTable: splitsTableWidget(filter: splitsFilter)
        case .splitsFastest: splitsFastestWidget(filter: splitsFilter)
        case .splitsBars: splitsBarsWidget(filter: splitsFilter)
        case .bestEfforts: bestEffortsWidget(filter: bestEffortsFilter)
        case .distanceWords: distanceWordsWidget(filter: distanceWordsFilter)
        case .fullBanner: fullBannerWidget
        case .fullBannerBottom: fullBannerBottomWidget
        case .blurredVerticalText: blurredVerticalTextWidget
        case .whatsappMessage: whatsappMessageWidget
        case .goldenArch: goldenArchWidget
        }
    }

    private var basicMetadataValues: [String] {
        var values: [String] = []
        if showActivityName {
            values.append(activity.title)
        }
        if showDate {
            values.append(activity.date)
        }
        return values
    }

    private var basicMetadataText: String {
        basicMetadataValues.joined(separator: " · ")
    }

    private var isBasicMiles: Bool { basicUnitFilter == .miles }

    private var basicDistanceText: String {
        if isBasicMiles {
            let mi = activity.distanceRaw / 1609.34
            return String(format: "%.2f mi", mi)
        }
        return activity.distance
    }

    private var basicPaceText: String {
        guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
        let speed = activity.distanceRaw / Double(activity.movingTimeRaw)
        if isBasicMiles {
            let secPerMile = 1609.34 / speed
            let m = Int(secPerMile) / 60
            let s = Int(secPerMile) % 60
            return String(format: "%d:%02d /mi", m, s)
        } else {
            let secPerKm = 1000.0 / speed
            let m = Int(secPerKm) / 60
            let s = Int(secPerKm) % 60
            return String(format: "%d:%02d /km", m, s)
        }
    }

    private var basicMetricItems: [StatDisplayItem] {
        var items: [StatDisplayItem] = []
        if activity.hasDistance, showDistance {
            items.append(StatDisplayItem(id: "distance", label: "DIST", value: basicDistanceText))
        }
        if showPace, activity.pace != "--" {
            items.append(StatDisplayItem(id: "pace", label: "PACE", value: basicPaceText))
        }
        if showTime {
            items.append(StatDisplayItem(id: "time", label: "TIME", value: activity.duration))
        }
        return items
    }

    private var basicPrimaryMetric: StatDisplayItem? {
        basicMetricItems.first
    }

    private var titleCardPrimaryText: String? {
        if let primaryMetric = basicPrimaryMetric {
            return primaryMetric.value
        }
        if showDate {
            return activity.date
        }
        if showActivityName {
            return activity.title
        }
        return nil
    }

    private var titleCardSecondaryText: String {
        var parts: [String] = []
        if showDate, titleCardPrimaryText != activity.date {
            parts.append(activity.date)
        }
        for metric in basicMetricItems.dropFirst() {
            parts.append(metric.value)
        }
        return parts.joined(separator: " · ")
    }

    private var distanceWidget: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !basicMetadataText.isEmpty {
                Text(basicMetadataText)
                    .font(.system(size: 9, weight: .regular, design: .serif))
                    .foregroundStyle(secondaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            if let primaryMetric = basicPrimaryMetric {
                Text(primaryMetric.label)
                    .font(.system(size: 10, weight: .regular, design: .serif))
                    .tracking(1.5)
                    .foregroundStyle(tertiaryColor)
                Text(primaryMetric.value)
                    .font(.system(size: 28, weight: .regular, design: .serif).italic())
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }

    private var distPaceWidget: some View {
        let metrics = Array(basicMetricItems.prefix(2))
        return VStack(alignment: .leading, spacing: 8) {
            if !basicMetadataText.isEmpty {
                Text(basicMetadataText)
                    .font(.system(size: 9, weight: .regular, design: .serif))
                    .foregroundStyle(secondaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            if let firstMetric = metrics.first {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(firstMetric.label)
                            .font(.system(size: 9, weight: .regular, design: .serif))
                            .tracking(1.2)
                            .foregroundStyle(secondaryColor)
                        Text(firstMetric.value)
                            .font(.system(size: 22, weight: .regular, design: .serif).italic())
                            .foregroundStyle(primaryColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    if metrics.count > 1 {
                        Rectangle()
                            .fill(dividerColor)
                            .frame(width: 1, height: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(metrics[1].label)
                                .font(.system(size: 9, weight: .regular, design: .serif))
                                .tracking(1.2)
                                .foregroundStyle(secondaryColor)
                            Text(metrics[1].value)
                                .font(.system(size: 22, weight: .regular, design: .serif).italic())
                                .foregroundStyle(primaryColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }

    private var threeStatsWidget: some View {
        let metrics = Array(basicMetricItems.prefix(3))
        return VStack(alignment: .leading, spacing: 8) {
            if !basicMetadataText.isEmpty {
                Text(basicMetadataText)
                    .font(.system(size: 9, weight: .regular, design: .serif))
                    .foregroundStyle(secondaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            HStack(spacing: 14) {
                ForEach(metrics) { metric in
                    topRowStatColumn(label: metric.label, value: metric.value)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }


    private var titleCardWidget: some View {
        return VStack(alignment: .leading, spacing: 4) {
            if showActivityName {
                Text(activity.title)
                    .font(.system(size: 20, weight: .black, design: .default).width(.expanded))
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            if let primaryText = titleCardPrimaryText {
                Text(primaryText)
                    .font(.system(size: 12, weight: .bold, design: .default).width(.expanded))
                    .foregroundStyle(tertiaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            if !titleCardSecondaryText.isEmpty {
                Text(titleCardSecondaryText)
                    .font(.system(size: 12, weight: .bold, design: .default).width(.expanded))
                    .foregroundStyle(tertiaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .horizontalStretch(1.5)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }

    private var stackWidget: some View {
        let rows: [StatDisplayItem] = {
            var items: [StatDisplayItem] = []
            if showActivityName {
                items.append(StatDisplayItem(id: "activityName", label: "Activity", value: activity.title))
            }
            if showDate {
                items.append(StatDisplayItem(id: "date", label: "Date", value: activity.date))
            }
            items.append(contentsOf: basicMetricItems)
            return items
        }()
        return VStack(spacing: 6) {
            ForEach(rows) { row in
                HStack {
                    Text(row.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(secondaryColor)
                    Spacer()
                    Text(row.value)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryColor)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .frame(width: 140)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }

    private var boldWidget: some View {
        let mainFont: Font = .system(size: 80, weight: .black, design: .default).width(.expanded)
        let subFont: Font = .system(size: 24, weight: .bold, design: .default).width(.expanded)
        let hasSubItems = activity.hasDistance
            ? (showPace || showTime || showElevation)
            : true
        return VStack(alignment: .leading, spacing: -2) {
            if showTitle {
                Text(activity.title.uppercased())
                    .font(.system(size: 13, weight: .heavy, design: .default).width(.expanded))
                    .tracking(4)
                    .foregroundStyle(boldColor.opacity(0.55))
            }
            Text(activity.hasDistance ? activity.distance.uppercased() : activity.duration.uppercased())
                .font(mainFont)
                .tracking(-1)
                .foregroundStyle(boldColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            if hasSubItems {
                HStack(spacing: 14) {
                    if activity.hasDistance {
                        if showPace {
                            Text(activity.pace)
                                .font(subFont)
                                .foregroundStyle(boldColor)
                        }
                        if showTime {
                            Text(activity.duration.uppercased())
                                .font(subFont)
                                .foregroundStyle(boldColor)
                        }
                        if showElevation {
                            Text(activity.elevationGain)
                                .font(subFont)
                                .foregroundStyle(boldColor)
                        }
                    } else {
                        Text(activity.title.uppercased())
                            .font(subFont)
                            .foregroundStyle(boldColor)
                        Text(activity.date.uppercased())
                            .font(subFont)
                            .foregroundStyle(boldColor)
                    }
                }
                .tracking(-0.3)
            }
        }
        .horizontalStretch(1.5)
    }


    private var impactWidget: some View {
        let impactColor = primaryColor
        let mainFont: Font = .system(size: 96, weight: .black, design: .default).width(.expanded)
        let subFont: Font = .system(size: 26, weight: .bold, design: .default).width(.expanded)
        let subItems: [(String, Bool)] = activity.hasDistance
            ? [(activity.pace, showPace), (activity.duration.uppercased(), showTime), (activity.elevationGain, showElevation)].filter { $0.1 }
            : [(activity.title.uppercased(), true), (activity.date.uppercased(), true)]
        return VStack(alignment: .leading, spacing: -6) {
            if showTitle {
                Text(activity.title.uppercased())
                    .font(.system(size: 14, weight: .heavy, design: .default).width(.expanded))
                    .tracking(5)
                    .foregroundStyle(impactColor.opacity(0.5))
                    .shadow(color: impactColor.opacity(0.3), radius: 8, x: 0, y: 0)
            }
            Text(activity.hasDistance ? activity.distance.uppercased() : activity.duration.uppercased())
                .font(mainFont)
                .tracking(-3)
                .foregroundStyle(impactColor)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .shadow(color: impactColor.opacity(0.6), radius: 20, x: 0, y: 0)
            if !subItems.isEmpty {
                HStack(spacing: 10) {
                    ForEach(Array(subItems.enumerated()), id: \.offset) { idx, item in
                        if idx > 0 {
                            Rectangle()
                                .fill(impactColor.opacity(0.4))
                                .frame(width: 2, height: 18)
                        }
                        Text(item.0)
                            .font(subFont)
                            .foregroundStyle(impactColor.opacity(0.85))
                    }
                }
                .tracking(-0.5)
            }
        }
        .horizontalStretch(1.5)
    }

    private var posterWidget: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(activity.title.uppercased())
                .font(.system(size: 13, weight: .heavy, design: .default).width(.expanded))
                .tracking(4)
                .foregroundStyle(secondaryColor)
                .lineLimit(1)
            Text(activity.hasDistance ? activity.distance.uppercased() : activity.duration.uppercased())
                .font(.system(size: 52, weight: .black, design: .default).width(.expanded))
                .tracking(-1.2)
                .foregroundStyle(primaryColor)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .shadow(color: primaryColor.opacity(0.28), radius: 12, x: 0, y: 0)
            HStack(spacing: 12) {
                if activity.hasDistance {
                    Text(activity.pace)
                        .font(.system(size: 18, weight: .heavy, design: .default).width(.expanded))
                        .foregroundStyle(primaryColor.opacity(0.88))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Rectangle()
                        .fill(primaryColor.opacity(0.35))
                        .frame(width: 1, height: 18)
                    Text(activity.duration.uppercased())
                        .font(.system(size: 18, weight: .heavy, design: .default).width(.expanded))
                        .foregroundStyle(primaryColor.opacity(0.88))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    Text(activity.date.uppercased())
                        .font(.system(size: 18, weight: .heavy, design: .default).width(.expanded))
                        .foregroundStyle(primaryColor.opacity(0.88))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .horizontalStretch(1.5)
    }

    private var heroStatWidget: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(activity.primaryStat.uppercased())
                .font(.system(size: 48, weight: .black))
                .foregroundStyle(primaryColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .scaleEffect(x: 1.0, y: 2.5, anchor: .top)
                .padding(.bottom, 70)
            if activity.hasDistance, (showPace || showTime) {
                HStack(spacing: 16) {
                    if showPace {
                        Text("PACE \(activity.pace)")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(secondaryColor)
                    }
                    if showTime {
                        Text("TIME \(activity.duration)")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(secondaryColor)
                    }
                }
            } else if !activity.hasDistance {
                Text(activity.date.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(secondaryColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }

    private var wideWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(activity.primaryLabel)
                .font(.system(size: 10, weight: .bold, design: .default).width(.expanded))
                .tracking(4)
                .foregroundStyle(tertiaryColor)
            Text(activity.primaryStat.uppercased())
                .font(.system(size: 36, weight: .black, design: .default).width(.expanded))
                .tracking(-1)
                .foregroundStyle(primaryColor)
                .fixedSize()
                .horizontalStretch(1.15)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var towerWidget: some View {
        Text(activity.primaryStat.uppercased())
            .font(.system(size: 110, weight: .black, design: .default))
            .tracking(-4)
            .foregroundStyle(primaryColor)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .scaleEffect(x: 1.0, y: 2.5, anchor: .top)
            .padding(.bottom, 160)
    }

    private var routeCleanWidget: some View {
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
        if rangeW < 0.001 && rangeH < 0.001 {
            return CGSize(width: minSize, height: minSize)
        }
        let drawArea = maxDimension - strokePadding
        if rangeW < 0.001 {
            return CGSize(width: minSize, height: maxDimension)
        }
        if rangeH < 0.001 {
            return CGSize(width: maxDimension, height: minSize)
        }
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

    private var efficiencyRatio: Double {
        guard activity.elapsedTimeRaw > 0 else { return 1.0 }
        return min(1.0, Double(activity.movingTimeRaw) / Double(activity.elapsedTimeRaw))
    }

    private func formatDurationCompact(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }

    private var movingTimeCleanWidget: some View {
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
                .foregroundStyle(secondaryColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    private var elapsedTimeCleanWidget: some View {
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
                .foregroundStyle(secondaryColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    private var hrPulseDotsWidget: some View {
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
                    .foregroundStyle(secondaryColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    private var heartRateBPM: Int {
        guard let hrString = activity.averageHeartrate else { return 0 }
        let digits = hrString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(digits) ?? 0
    }

    private var heartRateZone: (index: Int, label: String, progress: Double, glowOpacity: Double) {
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

    private var avgHeartRateWidget: some View {
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
                .foregroundStyle(secondaryColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    private var weeklyKmWidget: some View {
        let maxDaily = weeklyKmData.dailyKm.max() ?? 1.0
        let barMax = max(maxDaily, 0.1)
        return VStack(spacing: 6) {
            VStack(spacing: 1) {
                Text(String(format: "%.1f", weeklyKmData.totalKm))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("KMs THIS WEEK")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(secondaryColor)
            }
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(0..<7, id: \.self) { i in
                    let km = weeklyKmData.dailyKm[i]
                    let ratio = km / barMax
                    let isToday = i == weeklyKmData.todayIndex
                    let barHeight = max(3, CGFloat(ratio) * 32)
                    VStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(primaryColor.opacity(isToday ? 0.95 : (km > 0 ? 0.55 : 0.12)))
                            .frame(width: 10, height: barHeight)
                            .shadow(color: isToday && km > 0 ? primaryColor.opacity(0.4) : .clear, radius: 4, x: 0, y: 2)
                        Text(WeeklyKmData.dayLabels[i])
                            .font(.system(size: 7, weight: isToday ? .bold : .medium))
                            .foregroundStyle(primaryColor.opacity(isToday ? 0.9 : 0.4))
                    }
                }
            }
            .frame(height: 50, alignment: .bottom)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    private var lastWeekKmWidget: some View {
        let maxDaily = lastWeekKmData.dailyKm.max() ?? 1.0
        let barMax = max(maxDaily, 0.1)
        return VStack(spacing: 6) {
            VStack(spacing: 1) {
                Text(String(format: "%.1f", lastWeekKmData.totalKm))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("KMs LAST WEEK")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(secondaryColor)
            }
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(0..<7, id: \.self) { i in
                    let km = lastWeekKmData.dailyKm[i]
                    let ratio = km / barMax
                    let barHeight = max(3, CGFloat(ratio) * 32)
                    VStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(primaryColor.opacity(km > 0 ? 0.65 : 0.12))
                            .frame(width: 10, height: barHeight)
                        Text(WeeklyKmData.dayLabels[i])
                            .font(.system(size: 7, weight: .medium))
                            .foregroundStyle(primaryColor.opacity(0.5))
                    }
                }
            }
            .frame(height: 50, alignment: .bottom)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    private var monthlyKmWidget: some View {
        let data = monthlyKmData
        let maxDaily = data.dailyKm.prefix(data.daysInMonth).max() ?? 1.0
        let barMax = max(maxDaily, 0.1)
        return VStack(spacing: 6) {
            VStack(spacing: 1) {
                Text(String(format: "%.1f", data.totalKm))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("KMs \(data.monthLabel.isEmpty ? "THIS MONTH" : data.monthLabel)")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(secondaryColor)
            }
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<data.daysInMonth, id: \.self) { i in
                    let km = data.dailyKm[i]
                    let ratio = km / barMax
                    let isToday = i == data.todayIndex
                    let barHeight = max(2, CGFloat(ratio) * 32)
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(primaryColor.opacity(isToday ? 0.95 : (km > 0 ? 0.55 : 0.12)))
                            .frame(width: 4, height: barHeight)
                            .shadow(color: isToday && km > 0 ? primaryColor.opacity(0.4) : .clear, radius: 3, x: 0, y: 2)
                        if let label = data.dayLabel(for: i) {
                            Text(label)
                                .font(.system(size: 5, weight: isToday ? .bold : .medium))
                                .foregroundStyle(primaryColor.opacity(isToday ? 0.9 : 0.4))
                        } else {
                            Text("")
                                .font(.system(size: 5))
                        }
                    }
                }
            }
            .frame(height: 50, alignment: .bottom)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    private var lastMonthKmWidget: some View {
        let data = lastMonthKmData
        let maxDaily = data.dailyKm.prefix(data.daysInMonth).max() ?? 1.0
        let barMax = max(maxDaily, 0.1)
        return VStack(spacing: 6) {
            VStack(spacing: 1) {
                Text(String(format: "%.1f", data.totalKm))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("KMs \(data.monthLabel.isEmpty ? "LAST MONTH" : data.monthLabel)")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(secondaryColor)
            }
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<data.daysInMonth, id: \.self) { i in
                    let km = data.dailyKm[i]
                    let ratio = km / barMax
                    let barHeight = max(2, CGFloat(ratio) * 32)
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(primaryColor.opacity(km > 0 ? 0.65 : 0.12))
                            .frame(width: 4, height: barHeight)
                        if let label = data.dayLabel(for: i) {
                            Text(label)
                                .font(.system(size: 5, weight: .medium))
                                .foregroundStyle(primaryColor.opacity(0.5))
                        } else {
                            Text("")
                                .font(.system(size: 5))
                        }
                    }
                }
            }
            .frame(height: 50, alignment: .bottom)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    private var elevationNumeric: String {
        let digits = activity.elevationGain.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return digits.isEmpty ? "--" : digits
    }


    private var elevationGainWidget: some View {
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
                    .font(.system(size: 36, weight: .black, design: .default).width(.expanded))
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
                    .foregroundStyle(secondaryColor)
            }
            .padding(.top, 6)
        }
        .frame(width: widgetWidth, height: widgetHeight)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    private func splitsWidget(filter: SplitsUnitFilter) -> some View {
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

    private func splitsTableWidget(filter: SplitsUnitFilter) -> some View {
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

    private func splitPaceString(speed: Double, unitDistance: Double) -> String {
        guard speed > 0 else { return "--" }
        let secPerUnit = unitDistance / speed
        let m = Int(secPerUnit) / 60
        let s = Int(secPerUnit) % 60
        return String(format: "%d'%02d\"", m, s)
    }

    private func splitsFastestWidget(filter: SplitsUnitFilter) -> some View {
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

    private func splitsBarsWidget(filter: SplitsUnitFilter) -> some View {
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

    private func bestEffortsWidget(filter: BestEffortsUnitFilter) -> some View {
        Group {
            if isLoadingDetail {
                detailShimmer(width: 150, height: 120, label: "BEST EFFORTS")
            } else if let efforts = activityDetail?.bestEfforts?.filter({ filter.shouldInclude(effortName: $0.name) }), !efforts.isEmpty {
                bestEffortsContent(efforts: efforts)
            } else {
                detailEmptyState(icon: "medal.fill", label: "BEST EFFORTS", sublabel: "No effort data")
            }
        }
    }

    private func bestEffortsContent(efforts: [StravaBestEffort]) -> some View {
        let fontSize: CGFloat = efforts.count > 6 ? 16 : 20
        let timeFontSize: CGFloat = efforts.count > 6 ? 18 : 24
        let iconSize: CGFloat = efforts.count > 6 ? 12 : 16
        let rowSpacing: CGFloat = efforts.count > 6 ? 3 : 5
        return VStack(spacing: 8) {
            Text("BEST EFFORTS")
                .font(.system(size: 14, weight: .bold))
                .tracking(2.0)
                .foregroundStyle(secondaryColor)

            VStack(spacing: rowSpacing) {
                ForEach(Array(efforts.enumerated()), id: \.element.id) { idx, effort in
                    let hasPR = effort.prRank == 1
                    HStack(spacing: 0) {
                        Text(effortDistanceLabel(effort.name))
                            .font(.system(size: fontSize, weight: .bold))
                            .foregroundStyle(primaryColor)
                            .frame(width: 70, alignment: .leading)

                        Spacer()

                        Text(formatEffortTime(effort.elapsedTime))
                            .font(.system(size: timeFontSize, weight: .semibold, design: .monospaced))
                            .foregroundStyle(primaryColor.opacity(hasPR ? 1.0 : 0.75))

                        if hasPR {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: iconSize, weight: .bold))
                                .foregroundStyle(primaryColor)
                                .padding(.leading, 4)
                        }
                    }
                    if idx < efforts.count - 1 {
                        Rectangle()
                            .fill(dividerColor)
                            .frame(height: 0.5)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .fixedSize()
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    private func effortDistanceLabel(_ name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("400m") { return "400m" }
        if lower.contains("1/2 mile") || lower.contains("half mile") { return "800m" }
        if lower.contains("1k") { return "1K" }
        if lower.contains("2 mile") { return "2 MI" }
        if lower.contains("1 mile") || lower == "mile" { return "1 MI" }
        if lower.contains("30k") { return "30K" }
        if lower.contains("20k") { return "20K" }
        if lower.contains("15k") { return "15K" }
        if lower.contains("10k") { return "10K" }
        if lower.contains("5k") { return "5K" }
        if lower.contains("half") { return "21K" }
        if lower.contains("marathon") { return "42K" }
        return String(name.prefix(5))
    }

    private func formatEffortTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d hrs", h, m, s) }
        return String(format: "%d:%02d mins", m, s)
    }

    private func detailShimmer(width: CGFloat, height: CGFloat, label: String) -> some View {
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

    private func detailEmptyState(icon: String, label: String, sublabel: String) -> some View {
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

    private func distanceWordsWidget(filter: SplitsUnitFilter) -> some View {
        let result = DistanceToWords.convert(distanceMeters: activity.distanceRaw, unit: filter)
        let words = result.numberText.lowercased()
        let unit = result.unitText.uppercased()
        let wordsFont: Font = fontStyle == .system
            ? .system(size: 32, weight: .light, design: .monospaced)
            : fontStyle.font(size: 32)
        let unitFont: Font = fontStyle == .system
            ? .system(size: 11, weight: .bold, design: .monospaced)
            : fontStyle.secondaryFont(size: 11)

        return VStack(alignment: .leading, spacing: 2) {
            Text(words)
                .font(wordsFont)
                .foregroundStyle(primaryColor)
                .lineSpacing(-2)
                .fixedSize(horizontal: false, vertical: true)
            Text(unit)
                .font(unitFont)
                .tracking(4)
                .foregroundStyle(secondaryColor)
                .padding(.top, 2)
        }
        .frame(width: 200, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }

    private var fullBannerWidget: some View {
        let isKm = fullBannerUnitFilter == .km
        let distValue: String = {
            if !activity.hasDistance { return "--" }
            if isKm { return activity.distance }
            let mi = activity.distanceRaw / 1609.34
            return mi >= 100 ? String(format: "%.0f mi", mi) : String(format: "%.2f mi", mi)
        }()
        let paceValue: String = {
            guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
            let speed = activity.distanceRaw / Double(activity.movingTimeRaw)
            let unitDist: Double = isKm ? 1000.0 : 1609.34
            let secPerUnit = unitDist / speed
            let m = Int(secPerUnit) / 60
            let s = Int(secPerUnit) % 60
            return String(format: "%d'%02d\"", m, s)
        }()
        let items: [(String, String, Bool)] = [
            ("TIME", activity.duration, fullBannerShowTime),
            ("DIST", distValue, fullBannerShowDistance),
            (isKm ? "MIN/KM" : "MIN/MI", paceValue, fullBannerShowPace),
            ("ELEV", activity.elevationGain, fullBannerShowElevation),
        ]
        let visible = items.filter { $0.2 }
        return HStack(spacing: 0) {
            ForEach(Array(visible.enumerated()), id: \.offset) { idx, item in
                VStack(spacing: 2) {
                    Text(item.0)
                        .font(.system(size: 8, weight: .regular, design: .serif))
                        .tracking(1.5)
                        .foregroundStyle(secondaryColor)
                    Text(item.1)
                        .font(.system(size: 18, weight: .regular, design: .serif).italic())
                        .foregroundStyle(primaryColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 300)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }

    private var fullBannerBottomWidget: some View {
        let isKm = fullBannerUnitFilter == .km
        let distValue: String = {
            if !activity.hasDistance { return "--" }
            if isKm { return activity.distance }
            let mi = activity.distanceRaw / 1609.34
            return mi >= 100 ? String(format: "%.0f mi", mi) : String(format: "%.2f mi", mi)
        }()
        let paceValue: String = {
            guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
            let speed = activity.distanceRaw / Double(activity.movingTimeRaw)
            let unitDist: Double = isKm ? 1000.0 : 1609.34
            let secPerUnit = unitDist / speed
            let m = Int(secPerUnit) / 60
            let s = Int(secPerUnit) % 60
            return String(format: "%d'%02d\"", m, s)
        }()
        let items: [(String, String, Bool)] = [
            ("TIME", activity.duration, fullBannerShowTime),
            ("DIST", distValue, fullBannerShowDistance),
            (isKm ? "MIN/KM" : "MIN/MI", paceValue, fullBannerShowPace),
            ("ELEV", activity.elevationGain, fullBannerShowElevation),
        ]
        let visible = items.filter { $0.2 }
        return HStack(spacing: 0) {
            ForEach(Array(visible.enumerated()), id: \.offset) { idx, item in
                VStack(spacing: 2) {
                    Text(item.1)
                        .font(.system(size: 18, weight: .regular, design: .serif).italic())
                        .foregroundStyle(primaryColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(item.0)
                        .font(.system(size: 8, weight: .regular, design: .serif))
                        .tracking(1.5)
                        .foregroundStyle(secondaryColor)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 300)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }

    private static let bvtDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f
    }()
    private static let bvtTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    private var blurredVerticalTextWidget: some View {
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
            let mi = activity.distanceRaw / 1609.34
            return String(format: "%.1f MI", mi)
        }()
        let paceText: String = {
            guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "" }
            let speed = activity.distanceRaw / Double(activity.movingTimeRaw)
            let unitDist: Double = isKm ? 1000.0 : 1609.34
            let secPerUnit = unitDist / speed
            let m = Int(secPerUnit) / 60
            let s = Int(secPerUnit) % 60
            return isKm ? String(format: "%d:%02d/KM", m, s) : String(format: "%d:%02d/MI", m, s)
        }()
        let durationText: String = {
            let totalSec = activity.movingTimeRaw
            let h = totalSec / 3600
            let m = (totalSec % 3600) / 60
            let s = totalSec % 60
            if h > 0 { return String(format: "%dH %dM %dS", h, m, s) }
            return String(format: "%dM %dS", m, s)
        }()
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
            (dateText, true),
            (timeText, !timeText.isEmpty),
            (locationText, !locationText.isEmpty),
            (distText, !distText.isEmpty),
            (paceText, !paceText.isEmpty),
            (durationText, true),
            (elevText, true),
            (calText, !calText.isEmpty),
            (bpmText, !bpmText.isEmpty),
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

    private static let waTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    private var whatsappMessageWidget: some View {
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

    private var goldenArchIsMiles: Bool { goldenArchUnitFilter == .miles }

    private var goldenArchDistanceText: String {
        if goldenArchIsMiles {
            let mi = activity.distanceRaw / 1609.34
            return String(format: "%.2f", mi)
        }
        let km = activity.distanceRaw / 1000.0
        return String(format: "%.1f", km)
    }

    private var goldenArchUnitLabel: String {
        goldenArchIsMiles ? "MI" : "KM"
    }

    private var goldenArchPaceText: String {
        guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
        let speed = activity.distanceRaw / Double(activity.movingTimeRaw)
        if goldenArchIsMiles {
            let secPerMile = 1609.34 / speed
            let m = Int(secPerMile) / 60
            let s = Int(secPerMile) % 60
            return String(format: "%d:%02d /mi", m, s)
        } else {
            let secPerKm = 1000.0 / speed
            let m = Int(secPerKm) / 60
            let s = Int(secPerKm) % 60
            return String(format: "%d:%02d /km", m, s)
        }
    }

    private var goldenArchDateText: String {
        if let d = activity.startDate {
            let f = DateFormatter()
            f.dateFormat = "dd MMM yyyy"
            return f.string(from: d).uppercased()
        }
        return activity.date.uppercased()
    }

    private var goldenArchWidget: some View {
        let goldDark = Color(red: 0.50, green: 0.36, blue: 0.04)
        let goldMid = Color(red: 0.68, green: 0.50, blue: 0.04)
        let goldBright = Color(red: 0.82, green: 0.65, blue: 0.0)
        let goldLight = Color(red: 0.92, green: 0.80, blue: 0.35)
        let goldShine = Color(red: 1.0, green: 0.94, blue: 0.70)
        let textColor = Color(red: 0.15, green: 0.10, blue: 0.02)

        let medalSize: CGFloat = 170
        let halfSize = medalSize / 2

        let bodyGradient = RadialGradient(
            colors: [goldShine, goldLight, goldBright, goldMid],
            center: .init(x: 0.4, y: 0.35),
            startRadius: 5,
            endRadius: medalSize * 0.55
        )
        let rimGradient = AngularGradient(
            colors: [goldDark, goldBright, goldShine, goldBright, goldDark, goldMid, goldShine, goldMid, goldDark],
            center: .center
        )

        let hasSubMetrics = (goldenArchShowPace && activity.hasDistance) || goldenArchShowTime

        return ZStack {
            Circle()
                .fill(rimGradient)
                .frame(width: medalSize, height: medalSize)
                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                .shadow(color: goldDark.opacity(0.8), radius: 2, x: 0, y: 1)

            Circle()
                .fill(bodyGradient)
                .frame(width: medalSize - 14, height: medalSize - 14)

            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [goldDark.opacity(0.6), goldBright.opacity(0.3), goldDark.opacity(0.6), goldBright.opacity(0.3), goldDark.opacity(0.6)],
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .frame(width: medalSize - 14, height: medalSize - 14)

            Circle()
                .strokeBorder(goldDark.opacity(0.25), lineWidth: 0.5)
                .frame(width: medalSize - 22, height: medalSize - 22)

            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [goldDark.opacity(0.5), goldBright.opacity(0.2), goldDark.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
                .frame(width: medalSize - 28, height: medalSize - 28)

            MedalCurvedText(
                text: "✦  MY FIRST  ✦",
                radius: halfSize - 24,
                fontSize: 11,
                fontWeight: .heavy,
                kerning: 1.2,
                clockwise: true,
                arcSpan: 140,
                color: textColor.opacity(0.9)
            )

            MedalCurvedText(
                text: "FINISHER",
                radius: halfSize - 22,
                fontSize: 8,
                fontWeight: .bold,
                kerning: 2.5,
                clockwise: false,
                arcSpan: 80,
                color: textColor.opacity(0.55)
            )

            VStack(spacing: 0) {
                Image(systemName: "figure.run")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(textColor.opacity(0.3))

                Spacer().frame(height: 1)

                Text(goldenArchDistanceText)
                    .font(.system(size: 40, weight: .black, design: .default).width(.compressed))
                    .foregroundStyle(textColor.opacity(0.92))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .shadow(color: goldShine.opacity(0.4), radius: 1, x: 0, y: 1)

                Text(goldenArchUnitLabel)
                    .font(.system(size: 10, weight: .heavy, design: .default).width(.expanded))
                    .tracking(5)
                    .foregroundStyle(textColor.opacity(0.5))

                Spacer().frame(height: 2)

                MedalBannerView(
                    text: goldenArchDateText,
                    goldDark: goldDark,
                    goldBright: goldBright,
                    goldShine: goldShine,
                    textColor: textColor
                )

                if hasSubMetrics {
                    Spacer().frame(height: 2)

                    HStack(spacing: 0) {
                        if goldenArchShowPace, activity.hasDistance {
                            Text(goldenArchPaceText)
                                .font(.system(size: 8, weight: .semibold, design: .default))
                                .foregroundStyle(textColor.opacity(0.45))
                        }
                        if goldenArchShowPace && activity.hasDistance && goldenArchShowTime {
                            Text(" · ")
                                .font(.system(size: 6, weight: .black))
                                .foregroundStyle(textColor.opacity(0.25))
                        }
                        if goldenArchShowTime {
                            Text(activity.duration)
                                .font(.system(size: 8, weight: .semibold, design: .default))
                                .foregroundStyle(textColor.opacity(0.45))
                        }
                    }
                }
            }
            .frame(width: medalSize - 44)
            .offset(y: 2)
        }
        .frame(width: medalSize + 8, height: medalSize + 8)
    }

    private func topRowStatColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .regular, design: .serif))
                .tracking(1.2)
                .foregroundStyle(secondaryColor)
            Text(value)
                .font(.system(size: 22, weight: .regular, design: .serif).italic())
                .foregroundStyle(primaryColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func statColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .regular, design: .serif))
                .tracking(1)
                .foregroundStyle(secondaryColor)
            Text(value)
                .font(.system(size: 16, weight: .regular, design: .serif).italic())
                .foregroundStyle(primaryColor)
                .minimumScaleFactor(0.8)
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

nonisolated struct MedalBannerShape: InsettableShape {
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

nonisolated struct WhatsAppBubbleShape: Shape {
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

struct DraggableStatWidget: View {
    @Binding var widget: PlacedWidget
    let activity: ActivityHighlight
    let canvasSize: CGSize
    var canvasGlobalOrigin: CGPoint = .zero
    var guideState: AlignmentGuideState? = nil
    var activeWidgetId: String? = nil
    var onDragStarted: ((String) -> Void)? = nil
    var onDragChanged: ((String, CGPoint) -> Void)? = nil
    var onDragEnded: ((String, CGPoint) -> Bool)? = nil
    var onWidgetTapped: ((String) -> Void)? = nil
    var isPaletteActive: Bool = false
    var weeklyKmData: WeeklyKmData = .empty
    var lastWeekKmData: WeeklyKmData = .empty
    var monthlyKmData: MonthlyKmData = .empty
    var lastMonthKmData: MonthlyKmData = .empty
    var activityDetail: StravaActivityDetail? = nil
    var isLoadingDetail: Bool = false

    @State private var dragOffset: CGSize = .zero
    @State private var snapAdjustment: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var isBeingDeleted: Bool = false
    @State private var measuredSize: CGSize = CGSize(width: 120, height: 60)
    @State private var liveScale: CGFloat = 1.0
    @State private var liveRotation: Angle = .zero
    @State private var isRotating: Bool = false
    @State private var cachedBoundingSize: CGSize = .zero


    var body: some View {
        widgetContent
            .equatable()
            .onGeometryChange(for: CGSize.self, of: \.size) { newSize in
                if newSize.width > 0, newSize.height > 0 {
                    measuredSize = newSize
                }
            }
            .allowsHitTesting(false)
            .overlay {
                StatGestureOverlay(
                    widgetVisualCenter: widgetVisualCenter,
                    widgetVisualSize: widgetVisualBoundingSize,
                    widgetRotationRadians: CGFloat((widget.rotation + liveRotation).radians),
                    isLocked: activeWidgetId != nil && activeWidgetId != widget.id,
                    onTranslationChanged: { translation in
                        if !isDragging {
                            isDragging = true
                            guideState?.beginDrag()
                            if measuredSize.width > 0, measuredSize.height > 0 {
                                let scaledSize = CGSize(width: measuredSize.width * widget.scale, height: measuredSize.height * widget.scale)
                                cachedBoundingSize = rotatedBoundingBox(size: scaledSize, rotation: widget.rotation)
                            }
                            onDragStarted?(widget.id)
                        }
                        dragOffset = translation

                        if let guideState, cachedBoundingSize.width > 0 {
                            let widgetCenter = CGPoint(
                                x: canvasSize.width * 0.5 + widget.position.width + translation.width,
                                y: canvasSize.height * 0.5 + widget.position.height + translation.height
                            )
                            let result = guideState.computeSnap(widgetCenter: widgetCenter, widgetSize: cachedBoundingSize, canvasSize: canvasSize)
                            snapAdjustment = result.adjustedOffset
                        }
                    },
                    onTranslationEnded: { translation, globalLocation in
                        isDragging = false
                        isRotating = false
                        guideState?.clearGuides()
                        guideState?.clearRotation()
                        let finalSnap = snapAdjustment
                        let wasDeleted = onDragEnded?(widget.id, globalLocation) ?? false
                        if wasDeleted {
                            widget.position.width += translation.width + finalSnap.width
                            widget.position.height += translation.height + finalSnap.height
                            dragOffset = .zero
                            snapAdjustment = .zero
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                isBeingDeleted = true
                            }
                        } else {
                            widget.position.width += translation.width + finalSnap.width
                            widget.position.height += translation.height + finalSnap.height
                            dragOffset = .zero
                            snapAdjustment = .zero
                        }
                    },
                    onScaleChanged: { scale in
                        liveScale = scale
                    },
                    onScaleEnded: { scale in
                        widget.scale *= scale
                        widget.scale = min(max(widget.scale, 0.3), 4.0)
                        liveScale = 1.0
                    },
                    onRotationChanged: { angle in
                        if !isRotating {
                            isRotating = true
                            guideState?.beginRotation()
                        }
                        if let guideState {
                            let totalDeg = widget.rotation.degrees + angle.degrees
                            let result = guideState.computeRotationSnap(currentDegrees: totalDeg)
                            liveRotation = result.snappedAngle - widget.rotation
                        } else {
                            liveRotation = angle
                        }
                    },
                    onRotationEnded: { _ in
                        widget.rotation += liveRotation
                        liveRotation = .zero
                        isRotating = false
                        guideState?.clearRotation()
                    },
                    onDragStarted: {},
                    onGlobalLocationChanged: { location in
                        onDragChanged?(widget.id, location)
                    },
                    onTapped: {
                        HapticService.light.impactOccurred()
                        if isPaletteActive {
                            widget.colorStyle.cycleNext()
                        }
                        onWidgetTapped?(widget.id)
                    }
                )

            }
        .scaleEffect(isBeingDeleted ? 0.01 : widget.scale * liveScale)
        .rotationEffect(widget.rotation + liveRotation)
        .opacity(isBeingDeleted ? 0 : 1)
        .offset(
            x: widget.position.width + dragOffset.width + snapAdjustment.width,
            y: widget.position.height + dragOffset.height + snapAdjustment.height
        )
        .transition(.scale.combined(with: .opacity))
    }

}

extension Color {
    var isLightColor: Bool {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.5
    }
}

extension DraggableStatWidget {
    private var widgetVisualCenter: CGPoint {
        CGPoint(
            x: canvasGlobalOrigin.x + canvasSize.width * 0.5 + widget.position.width + dragOffset.width + snapAdjustment.width,
            y: canvasGlobalOrigin.y + canvasSize.height * 0.5 + widget.position.height + dragOffset.height + snapAdjustment.height
        )
    }

    private var widgetVisualBoundingSize: CGSize {
        if isDragging, cachedBoundingSize.width > 0 {
            return cachedBoundingSize
        }
        let currentScale = widget.scale * liveScale
        let scaledSize = CGSize(width: measuredSize.width * currentScale, height: measuredSize.height * currentScale)
        return rotatedBoundingBox(size: scaledSize, rotation: widget.rotation + liveRotation)
    }

    private var widgetContent: StatWidgetContentView {
        StatWidgetContentView(type: widget.type, activity: activity, colorStyle: widget.colorStyle, useGlassBackground: widget.useGlassBackground, weeklyKmData: weeklyKmData, lastWeekKmData: lastWeekKmData, monthlyKmData: monthlyKmData, lastMonthKmData: lastMonthKmData, activityDetail: activityDetail, isLoadingDetail: isLoadingDetail, bestEffortsFilter: widget.bestEffortsFilter, splitsFilter: widget.splitsFilter, distanceWordsFilter: widget.distanceWordsFilter, fontStyle: widget.fontStyle, showTitle: widget.showTitle, showActivityName: widget.showActivityName, showDate: widget.showDate, showDistance: widget.showDistance, showPace: widget.showPace, showTime: widget.showTime, showElevation: widget.showElevation, basicUnitFilter: widget.basicUnitFilter, fullBannerUnitFilter: widget.fullBannerUnitFilter, fullBannerShowDistance: widget.fullBannerShowDistance, fullBannerShowPace: widget.fullBannerShowPace, fullBannerShowTime: widget.fullBannerShowTime, fullBannerShowElevation: widget.fullBannerShowElevation, bvtShowDate: widget.bvtShowDate, bvtShowTime: widget.bvtShowTime, bvtShowLocation: widget.bvtShowLocation, bvtShowDistance: widget.bvtShowDistance, bvtShowPace: widget.bvtShowPace, bvtShowDuration: widget.bvtShowDuration, bvtShowElevation: widget.bvtShowElevation, bvtShowCalories: widget.bvtShowCalories, bvtShowBPM: widget.bvtShowBPM, bvtUnitFilter: widget.bvtUnitFilter, bvtEffect: widget.bvtEffect, whatsappText: widget.whatsappText, goldenArchUnitFilter: widget.goldenArchUnitFilter, goldenArchShowPace: widget.goldenArchShowPace, goldenArchShowTime: widget.goldenArchShowTime)
    }
}

private struct GlassCardModifier: ViewModifier {
    @Environment(\.isExport) private var isExport
    let colorStyle: WidgetColorStyle

    private var accentColor: Color { colorStyle.currentColor }
    private var isNeon: Bool { colorStyle.palette == .neon }
    private var isAesthetic: Bool { colorStyle.palette == .aesthetic }

    func body(content: Content) -> some View {
        if isExport {
            content
                .background(glassExportBackground)
                .clipShape(.rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(accentColor.opacity(isNeon ? 0.35 : 0.18), lineWidth: 0.5)
                )
        } else {
            content
                .background(.ultraThinMaterial.opacity(isAesthetic ? 0.5 : 0.7))
                .background(accentColor.opacity(isNeon ? 0.12 : 0.06))
                .clipShape(.rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(accentColor.opacity(isNeon ? 0.35 : 0.18), lineWidth: 0.5)
                )
                .shadow(color: isNeon ? accentColor.opacity(0.35) : .black.opacity(0.3), radius: isNeon ? 16 : 12, x: 0, y: isNeon ? 0 : 6)
        }
    }

    @ViewBuilder
    private var glassExportBackground: some View {
        if isNeon {
            Color(red: 0.05, green: 0.05, blue: 0.12).opacity(0.75)
        } else if isAesthetic {
            Color.black.opacity(0.3)
        } else {
            Color.black.opacity(0.45)
        }
    }
}

private struct HorizontalStretchModifier: ViewModifier {
    let scale: CGFloat
    @State private var contentWidth: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: scale, y: 1.0, anchor: .leading)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { contentWidth = geo.size.width }
                        .onChange(of: geo.size.width) { _, new in contentWidth = new }
                }
            )
            .frame(width: contentWidth > 0 ? contentWidth * scale : nil, alignment: .leading)
    }
}

extension View {
    func glassCard(colorStyle: WidgetColorStyle = .initial) -> some View {
        modifier(GlassCardModifier(colorStyle: colorStyle))
    }

    @ViewBuilder
    func conditionalGlass(enabled: Bool, colorStyle: WidgetColorStyle) -> some View {
        if enabled {
            modifier(GlassCardModifier(colorStyle: colorStyle))
        } else {
            self
        }
    }

    func horizontalStretch(_ scale: CGFloat) -> some View {
        modifier(HorizontalStretchModifier(scale: scale))
    }
}


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
