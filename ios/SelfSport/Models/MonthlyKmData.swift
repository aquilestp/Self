import Foundation

struct MonthlyKmData: Sendable, Equatable {
    let dailyKm: [Double]
    let totalKm: Double
    let todayIndex: Int
    let daysInMonth: Int
    let monthLabel: String

    static let empty = MonthlyKmData(dailyKm: Array(repeating: 0.0, count: 31), totalKm: 0, todayIndex: -1, daysInMonth: 31, monthLabel: "")

    func dayLabel(for index: Int) -> String? {
        let day = index + 1
        if day == 1 || day % 5 == 0 || day == daysInMonth {
            return "\(day)"
        }
        return nil
    }
}
