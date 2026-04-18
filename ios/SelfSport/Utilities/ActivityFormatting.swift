import Foundation

enum ActivityFormatting: Sendable {
    static let metersPerMile: Double = 1609.34
    static let metersPerKm: Double = 1000.0

    static func distanceInKm(_ meters: Double) -> Double {
        meters / metersPerKm
    }

    static func distanceInMiles(_ meters: Double) -> Double {
        meters / metersPerMile
    }

    static func unitDistance(for unit: SplitsUnitFilter) -> Double {
        unit == .miles ? metersPerMile : metersPerKm
    }

    static func unitLabel(for unit: SplitsUnitFilter) -> String {
        unit == .miles ? "MI" : "KM"
    }

    static func paceLabel(for unit: SplitsUnitFilter) -> String {
        unit == .miles ? "MIN/MI" : "MIN/KM"
    }

    static func distanceWithUnit(_ meters: Double, unit: SplitsUnitFilter, kmFormat: String = "%.1f km", miFormat: String = "%.2f mi") -> String {
        if unit == .miles {
            let mi = meters / metersPerMile
            return String(format: miFormat, mi)
        }
        let km = meters / metersPerKm
        return String(format: kmFormat, km)
    }

    static func distanceValue(_ meters: Double, unit: SplitsUnitFilter, kmFormat: String = "%.1f", miFormat: String = "%.1f") -> String {
        if unit == .miles {
            return String(format: miFormat, meters / metersPerMile)
        }
        return String(format: kmFormat, meters / metersPerKm)
    }

    static func distanceWithUnitUpper(_ meters: Double, unit: SplitsUnitFilter) -> String {
        if unit == .miles {
            return String(format: "%.1f MI", meters / metersPerMile)
        }
        return String(format: "%.1f KM", meters / metersPerKm)
    }

    static func bannerDistance(_ meters: Double, unit: SplitsUnitFilter, fallbackKm: String) -> String {
        if unit == .km { return fallbackKm }
        let mi = meters / metersPerMile
        return mi >= 100 ? String(format: "%.0f mi", mi) : String(format: "%.2f mi", mi)
    }

    static func paceSpaced(distanceRaw: Double, movingTimeRaw: Int, unit: SplitsUnitFilter) -> String {
        guard distanceRaw > 0, movingTimeRaw > 0 else { return "--" }
        let speed = distanceRaw / Double(movingTimeRaw)
        let secPerUnit = unitDistance(for: unit) / speed
        let m = Int(secPerUnit) / 60
        let s = Int(secPerUnit) % 60
        return unit == .miles
            ? String(format: "%d:%02d /mi", m, s)
            : String(format: "%d:%02d /km", m, s)
    }

    static func pacePrime(distanceRaw: Double, movingTimeRaw: Int, unit: SplitsUnitFilter) -> String {
        guard distanceRaw > 0, movingTimeRaw > 0 else { return "--" }
        let speed = distanceRaw / Double(movingTimeRaw)
        let secPerUnit = unitDistance(for: unit) / speed
        let m = Int(secPerUnit) / 60
        let s = Int(secPerUnit) % 60
        return String(format: "%d'%02d\"", m, s)
    }

    static func paceSlash(distanceRaw: Double, movingTimeRaw: Int, unit: SplitsUnitFilter) -> String {
        guard distanceRaw > 0, movingTimeRaw > 0 else { return "" }
        let speed = distanceRaw / Double(movingTimeRaw)
        let secPerUnit = unitDistance(for: unit) / speed
        let m = Int(secPerUnit) / 60
        let s = Int(secPerUnit) % 60
        return unit == .miles
            ? String(format: "%d:%02d/MI", m, s)
            : String(format: "%d:%02d/KM", m, s)
    }

    static func paceSlashMixed(distanceRaw: Double, movingTimeRaw: Int, unit: SplitsUnitFilter) -> String {
        guard distanceRaw > 0, movingTimeRaw > 0 else { return "--" }
        let speed = distanceRaw / Double(movingTimeRaw)
        let secPerUnit = unitDistance(for: unit) / speed
        let m = Int(secPerUnit) / 60
        let s = Int(secPerUnit) % 60
        return String(format: "%d:%02d/%@", m, s, unitLabel(for: unit))
    }

    static func splitPace(speed: Double, unitDistance: Double) -> String {
        guard speed > 0 else { return "--" }
        let secPerUnit = unitDistance / speed
        let m = Int(secPerUnit) / 60
        let s = Int(secPerUnit) % 60
        return String(format: "%d'%02d\"", m, s)
    }

    static func durationCompact(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }

    static func durationExpanded(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%dH %dM %dS", h, m, s) }
        return String(format: "%dM %dS", m, s)
    }

    static func durationShort(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 { return String(format: "%dH %02dM", h, m) }
        return String(format: "%dM", m)
    }
}
