import SwiftUI

extension StatWidgetContentView {

    private var cityActivityIsMiles: Bool { cityActivityUnitFilter == .miles }

    private var cityActivityTitle: String {
        let typeLabel = cityActivityTypeLabel
        let city = geocodedActivityCity ?? activityDetail?.locationCity
        if let city, !city.isEmpty {
            return "\(city) \(typeLabel)"
        }
        return activity.activityName.isEmpty ? typeLabel : activity.activityName
    }

    private var cityActivityTypeLabel: String {
        let t = activity.activityType.lowercased()
        if t.contains("run") { return "Run" }
        if t.contains("ride") || t.contains("cycle") || t.contains("ebike") { return "Ride" }
        if t.contains("weight") || t.contains("workout") || t.contains("crossfit") || t.contains("strength") { return "Strength" }
        if t.contains("walk") || t.contains("hike") { return "Walk" }
        if t.contains("swim") { return "Swim" }
        if t.contains("yoga") { return "Yoga" }
        if t.contains("ski") { return "Ski" }
        let spaced = activity.activityType
            .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
        return spaced
    }

    private static let cityActivityTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    private static let cityActivityDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    private var cityActivityDateTime: String {
        guard let date = activity.startDate else { return activity.date }
        var utcCalendar = Calendar.current
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let timeStr = Self.cityActivityTimeFormatter.string(from: date)
        if utcCalendar.isDateInToday(date) { return "Today at \(timeStr)" }
        if utcCalendar.isDateInYesterday(date) { return "Yesterday at \(timeStr)" }
        return "\(Self.cityActivityDayFormatter.string(from: date)) at \(timeStr)"
    }

    private var cityActivityDistanceText: String {
        ActivityFormatting.distanceWithUnit(
            activity.distanceRaw,
            unit: cityActivityIsMiles ? .miles : .km,
            kmFormat: "%.1f km",
            miFormat: "%.2f mi"
        )
    }

    private var cityActivityPaceText: String {
        guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
        let typeLower = activity.activityType.lowercased()
        let isRide = typeLower.contains("ride") || typeLower.contains("cycle") || typeLower.contains("ebike")
        if isRide {
            let speedKmh = (activity.distanceRaw / Double(activity.movingTimeRaw)) * 3.6
            let speedMph = (activity.distanceRaw / Double(activity.movingTimeRaw)) * 2.23694
            return cityActivityIsMiles
                ? String(format: "%.1f mph", speedMph)
                : String(format: "%.1f km/h", speedKmh)
        }
        return ActivityFormatting.paceSpaced(
            distanceRaw: activity.distanceRaw,
            movingTimeRaw: activity.movingTimeRaw,
            unit: cityActivityIsMiles ? .miles : .km
        )
    }

    private var cityActivityIsLoading: Bool {
        isLoadingDetail && activityDetail == nil
    }

    var cityActivityWidget: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(cityActivityDateTime)
                .font(.system(size: 11, weight: .regular, design: .serif))
                .foregroundStyle(secondaryColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer().frame(height: 8)

            if cityActivityIsLoading {
                Text("Loading...")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(primaryColor.opacity(0.4))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            } else {
                Text(cityActivityTitle)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(primaryColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.55)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer().frame(height: 16)

            let showAnyIndicator = (activity.hasDistance && showDistance) || (activity.hasDistance && showPace) || showTime
            if showAnyIndicator {
                HStack(alignment: .top, spacing: 20) {
                    if activity.hasDistance && showDistance {
                        cityActivityStatColumn(label: "Distance", value: cityActivityDistanceText)
                    }
                    if activity.hasDistance && showPace {
                        cityActivityStatColumn(label: "Pace", value: cityActivityPaceText)
                    }
                    if showTime {
                        cityActivityStatColumn(label: "Time", value: activity.duration)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }

    private func cityActivityStatColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 10, weight: .regular, design: .serif))
                .tracking(0.5)
                .foregroundStyle(primaryColor)
                .lineLimit(1)
            Text(value)
                .font(.system(size: 20, weight: .regular, design: .serif).italic())
                .foregroundStyle(primaryColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }
}
