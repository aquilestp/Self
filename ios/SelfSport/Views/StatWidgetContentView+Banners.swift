import SwiftUI

extension StatWidgetContentView {

    // MARK: - fullBannerWidget

    var fullBannerWidget: some View {
        let isKm = fullBannerUnitFilter == .km
        let distValue: String = {
            if !activity.hasDistance { return "--" }
            return ActivityFormatting.bannerDistance(activity.distanceRaw, unit: fullBannerUnitFilter, fallbackKm: activity.distance)
        }()
        let paceValue: String = {
            guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
            return ActivityFormatting.pacePrime(distanceRaw: activity.distanceRaw, movingTimeRaw: activity.movingTimeRaw, unit: fullBannerUnitFilter)
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
                        .foregroundStyle(primaryColor)
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

    // MARK: - fullBannerBottomWidget

    var fullBannerBottomWidget: some View {
        let isKm = fullBannerUnitFilter == .km
        let distValue: String = {
            if !activity.hasDistance { return "--" }
            return ActivityFormatting.bannerDistance(activity.distanceRaw, unit: fullBannerUnitFilter, fallbackKm: activity.distance)
        }()
        let paceValue: String = {
            guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
            return ActivityFormatting.pacePrime(distanceRaw: activity.distanceRaw, movingTimeRaw: activity.movingTimeRaw, unit: fullBannerUnitFilter)
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
                        .foregroundStyle(primaryColor)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 300)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }

    // MARK: - splitBannerWidget

    private static let splitBannerDayFormatter = CachedDateFormatters.dayOfWeek
    private static let splitBannerDateFormatter = CachedDateFormatters.monthDay
    private static let splitBannerTimeFormatter = CachedDateFormatters.timeShort

    var splitBannerWidget: some View {
        let isKm = splitBannerUnitFilter == .km
        let dayText = activity.startDate.map { Self.splitBannerDayFormatter.string(from: $0).uppercased() } ?? "SUNDAY"
        let dateText = activity.startDate.map { Self.splitBannerDateFormatter.string(from: $0).uppercased() } ?? activity.date.uppercased()
        let timeText = activity.startDate.map { Self.splitBannerTimeFormatter.string(from: $0).uppercased() } ?? ""

        let distValue: String = {
            if !activity.hasDistance { return "--" }
            return ActivityFormatting.distanceWithUnitUpper(activity.distanceRaw, unit: splitBannerUnitFilter)
        }()
        let paceValue: String = {
            guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
            return ActivityFormatting.paceSlashMixed(distanceRaw: activity.distanceRaw, movingTimeRaw: activity.movingTimeRaw, unit: splitBannerUnitFilter)
        }()
        let durationValue = ActivityFormatting.durationShort(activity.movingTimeRaw)

        let font: Font = splitBannerFontStyle.font(size: 19)

        return HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(dayText)
                    .font(font)
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(dateText)
                    .font(font)
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if !timeText.isEmpty {
                    Text(timeText)
                        .font(font)
                        .foregroundStyle(primaryColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }

            Spacer(minLength: 20)

            VStack(alignment: .trailing, spacing: 2) {
                Text(distValue)
                    .font(font)
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(paceValue)
                    .font(font)
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(durationValue)
                    .font(font)
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(width: 300)
    }
}
