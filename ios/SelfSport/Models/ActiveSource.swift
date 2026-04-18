import Foundation

enum ActiveSource: String, Sendable {
    case strava

    private static let key = "active_fitness_source"

    static var current: ActiveSource {
        get { .strava }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: key) }
    }
}
