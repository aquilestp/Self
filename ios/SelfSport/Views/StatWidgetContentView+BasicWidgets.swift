import SwiftUI

extension StatWidgetContentView {

    // MARK: - Metadata Helpers

    private var basicMetadataValues: [String] {
        var values: [String] = []
        if showActivityName { values.append(activity.title) }
        if showDate { values.append(activity.date) }
        return values
    }

    var basicMetadataText: String { basicMetadataValues.joined(separator: " · ") }

    private var isBasicMiles: Bool { basicUnitFilter == .miles }

    private var basicDistanceText: String {
        if isBasicMiles {
            return ActivityFormatting.distanceWithUnit(activity.distanceRaw, unit: .miles, kmFormat: "%.1f km", miFormat: "%.2f mi")
        }
        return activity.distance
    }

    private var basicPaceText: String {
        guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
        return ActivityFormatting.paceSpaced(distanceRaw: activity.distanceRaw, movingTimeRaw: activity.movingTimeRaw, unit: isBasicMiles ? .miles : .km)
    }

    var basicMetricItems: [StatDisplayItem] {
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

    private var basicPrimaryMetric: StatDisplayItem? { basicMetricItems.first }

    private var titleCardPrimaryText: String? {
        if let primaryMetric = basicPrimaryMetric { return primaryMetric.value }
        if showDate { return activity.date }
        if showActivityName { return activity.title }
        return nil
    }

    private var titleCardSecondaryText: String {
        var parts: [String] = []
        if showDate, titleCardPrimaryText != activity.date { parts.append(activity.date) }
        for metric in basicMetricItems.dropFirst() { parts.append(metric.value) }
        return parts.joined(separator: " · ")
    }

    // MARK: - distanceWidget

    var distanceWidget: some View {
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
                    .foregroundStyle(primaryColor)
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

    // MARK: - distPaceWidget

    var distPaceWidget: some View {
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
                            .foregroundStyle(primaryColor)
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
                                .foregroundStyle(primaryColor)
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

    // MARK: - threeStatsWidget

    var threeStatsWidget: some View {
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

    // MARK: - titleCardWidget

    var titleCardWidget: some View {
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

    // MARK: - stackWidget

    var stackWidget: some View {
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
                        .font(.system(size: 10, weight: .semibold).italic().width(.expanded))
                        .foregroundStyle(primaryColor)
                    Spacer()
                    Text(row.value)
                        .font(.system(size: 14, weight: .heavy).italic().width(.expanded))
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

    // MARK: - boldWidget

    var boldWidget: some View {
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

    // MARK: - impactWidget

    var impactWidget: some View {
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

    // MARK: - posterWidget

    var posterWidget: some View {
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

    // MARK: - heroStatWidget

    var heroStatWidget: some View {
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
                            .foregroundStyle(primaryColor)
                    }
                    if showTime {
                        Text("TIME \(activity.duration)")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(primaryColor)
                    }
                }
            } else if !activity.hasDistance {
                Text(activity.date.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(primaryColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }

    // MARK: - wideWidget

    var wideWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(activity.primaryLabel)
                .font(.system(size: 10, weight: .bold, design: .default).width(.expanded))
                .tracking(4)
                .foregroundStyle(primaryColor)
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

    // MARK: - towerWidget

    var towerWidget: some View {
        Text(activity.primaryStat.uppercased())
            .font(.system(size: 110, weight: .black, design: .default))
            .tracking(-4)
            .foregroundStyle(primaryColor)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .scaleEffect(x: 1.0, y: 2.5, anchor: .top)
            .padding(.bottom, 160)
    }

    // MARK: - Shared Helpers

    func topRowStatColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .regular, design: .serif))
                .tracking(1.2)
                .foregroundStyle(primaryColor)
            Text(value)
                .font(.system(size: 22, weight: .regular, design: .serif).italic())
                .foregroundStyle(primaryColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    func statColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .regular, design: .serif))
                .tracking(1)
                .foregroundStyle(primaryColor)
            Text(value)
                .font(.system(size: 16, weight: .regular, design: .serif).italic())
                .foregroundStyle(primaryColor)
                .minimumScaleFactor(0.8)
        }
    }
}
