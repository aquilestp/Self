import Foundation

nonisolated struct WeeklyKmData: Sendable, Equatable {
    let dailyKm: [Double]
    let totalKm: Double
    let todayIndex: Int

    static let empty = WeeklyKmData(dailyKm: [0, 0, 0, 0, 0, 0, 0], totalKm: 0, todayIndex: 0)

    static let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
}
