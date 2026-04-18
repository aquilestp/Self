import Foundation

nonisolated enum ActiveSource: String, Sendable {
    case strava
    case appleHealth

    private static let key = "active_fitness_source"

    static var current: ActiveSource {
        get {
            let raw = UserDefaults.standard.string(forKey: key) ?? ""
            return ActiveSource(rawValue: raw) ?? .strava
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
