import SwiftUI

extension StatWidgetContentView {

    private var nameStatsIsMiles: Bool { nameStatsUnitFilter == .miles }

    private static let nameStatsTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    private static let nameStatsDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    private var nameStatsDateTime: String {
        guard let date = activity.startDate else { return activity.date }
        var utcCalendar = Calendar.current
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let timeStr = Self.nameStatsTimeFormatter.string(from: date)
        if utcCalendar.isDateInToday(date) { return "Today at \(timeStr)" }
        if utcCalendar.isDateInYesterday(date) { return "Yesterday at \(timeStr)" }
        return "\(Self.nameStatsDayFormatter.string(from: date)) at \(timeStr)"
    }

    private var nameStatsHeroTitle: String {
        let name = activity.activityName
        if !name.isEmpty { return name }
        return activity.title
    }

    private var nameStatsDistanceText: String {
        ActivityFormatting.distanceWithUnit(
            activity.distanceRaw,
            unit: nameStatsIsMiles ? .miles : .km,
            kmFormat: "%.1f km",
            miFormat: "%.2f mi"
        )
    }

    private var nameStatsPaceText: String {
        guard activity.hasDistance, activity.distanceRaw > 0, activity.movingTimeRaw > 0 else { return "--" }
        let typeLower = activity.activityType.lowercased()
        let isRide = typeLower.contains("ride") || typeLower.contains("cycle") || typeLower.contains("ebike")
        if isRide {
            let speedKmh = (activity.distanceRaw / Double(activity.movingTimeRaw)) * 3.6
            let speedMph = (activity.distanceRaw / Double(activity.movingTimeRaw)) * 2.23694
            return nameStatsIsMiles
                ? String(format: "%.1f mph", speedMph)
                : String(format: "%.1f km/h", speedKmh)
        }
        return ActivityFormatting.paceSpaced(
            distanceRaw: activity.distanceRaw,
            movingTimeRaw: activity.movingTimeRaw,
            unit: nameStatsIsMiles ? .miles : .km
        )
    }

    private var nameStatsElevationText: String {
        let digits = activity.elevationGain.components(separatedBy: CharacterSet.decimalDigits.inverted.union(CharacterSet(charactersIn: "."))).joined()
        guard let meters = Double(digits), meters > 0 else { return "--" }
        if nameStatsIsMiles {
            return String(format: "%.0f ft", meters * 3.28084)
        }
        return String(format: "%.0f m", meters)
    }

    var nameStatsWidget: some View {
        let statColumns: [(label: String, value: String, visible: Bool)] = [
            ("Distance", nameStatsDistanceText, nameStatsShowDistance && activity.hasDistance),
            ("Pace", nameStatsPaceText, nameStatsShowPace && activity.hasDistance),
            ("Time", activity.duration, nameStatsShowTime),
            ("Elevation", nameStatsElevationText, nameStatsShowElevation),
        ]
        let visibleColumns = statColumns.filter { $0.visible }

        return VStack(alignment: .center, spacing: 0) {
            Text(nameStatsDateTime)
                .font(.system(size: 11, weight: .light, design: .serif))
                .foregroundStyle(primaryColor.opacity(0.65))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer().frame(height: 10)

            Text(nameStatsHeroTitle)
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(primaryColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.45)
                .fixedSize(horizontal: false, vertical: true)

            if !visibleColumns.isEmpty {
                Spacer().frame(height: 18)

                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(visibleColumns.enumerated()), id: \.offset) { idx, col in
                        VStack(alignment: .center, spacing: 4) {
                            Text(col.label)
                                .font(.system(size: 9, weight: .regular, design: .serif))
                                .tracking(0.3)
                                .foregroundStyle(primaryColor.opacity(0.55))
                                .lineLimit(1)
                            Text(col.value)
                                .font(.system(size: 16, weight: .regular, design: .serif).italic())
                                .foregroundStyle(primaryColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        .frame(maxWidth: .infinity)

                        if idx < visibleColumns.count - 1 {
                            Rectangle()
                                .fill(primaryColor.opacity(0.18))
                                .frame(width: 0.5, height: 28)
                                .padding(.top, 4)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }
}
