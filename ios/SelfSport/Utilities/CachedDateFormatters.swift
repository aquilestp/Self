import Foundation

nonisolated enum CachedDateFormatters: Sendable {
    private static let utc = TimeZone(secondsFromGMT: 0)!

    static let bvtDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        f.timeZone = utc
        return f
    }()

    static let timeShort: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.timeZone = utc
        return f
    }()

    static let dayOfWeek: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        f.timeZone = utc
        return f
    }()

    static let monthDay: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        f.timeZone = utc
        return f
    }()

    static let notesDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d, yyyy"
        f.timeZone = utc
        return f
    }()

    static let medalDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        f.timeZone = utc
        return f
    }()
}
