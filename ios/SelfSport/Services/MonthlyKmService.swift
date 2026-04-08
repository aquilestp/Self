import Foundation
import Supabase

final class MonthlyKmService {
    private let table = "strava_activities"
    private let runningTypes = ["run", "virtualrun", "trailrun"]

    private func currentUserId() async -> String? {
        try? await supabase.auth.session.user.id.uuidString
    }

    private func monthLabel(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }

    func fetchMonthlyKm() async -> MonthlyKmData {
        guard let userId = await currentUserId() else { return .empty }

        let calendar = Calendar.current
        let today = Date()
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else {
            return .empty
        }

        let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count ?? 31
        let todayDay = calendar.component(.day, from: today) - 1

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

        let startStr = isoFormatter.string(from: monthStart)

        do {
            let rows: [SupabaseActivityRow] = try await supabase
                .from(table)
                .select()
                .eq("user_id", value: userId)
                .gte("start_date_local", value: startStr)
                .execute()
                .value

            var dailyKm: [Double] = Array(repeating: 0.0, count: daysInMonth)

            for row in rows {
                let typeLower = (row.sportType ?? row.type).lowercased()
                guard runningTypes.contains(typeLower) else { continue }

                if let date = isoFormatter.date(from: row.startDateLocal) {
                    let dayIndex = calendar.component(.day, from: date) - 1
                    if dayIndex >= 0, dayIndex < daysInMonth {
                        dailyKm[dayIndex] += row.distance / 1000.0
                    }
                }
            }

            let totalKm = dailyKm.reduce(0, +)
            return MonthlyKmData(dailyKm: dailyKm, totalKm: totalKm, todayIndex: todayDay, daysInMonth: daysInMonth, monthLabel: monthLabel(from: today))
        } catch {
            return .empty
        }
    }

    func fetchLastMonthKm() async -> MonthlyKmData {
        guard let userId = await currentUserId() else { return .empty }

        let calendar = Calendar.current
        let today = Date()
        guard let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)),
              let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: thisMonthStart),
              let lastMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: lastMonthDate)) else {
            return .empty
        }

        let daysInMonth = calendar.range(of: .day, in: .month, for: lastMonthDate)?.count ?? 31

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

        let startStr = isoFormatter.string(from: lastMonthStart)
        let endStr = isoFormatter.string(from: thisMonthStart)

        do {
            let rows: [SupabaseActivityRow] = try await supabase
                .from(table)
                .select()
                .eq("user_id", value: userId)
                .gte("start_date_local", value: startStr)
                .lt("start_date_local", value: endStr)
                .execute()
                .value

            var dailyKm: [Double] = Array(repeating: 0.0, count: daysInMonth)

            for row in rows {
                let typeLower = (row.sportType ?? row.type).lowercased()
                guard runningTypes.contains(typeLower) else { continue }

                if let date = isoFormatter.date(from: row.startDateLocal) {
                    let dayIndex = calendar.component(.day, from: date) - 1
                    if dayIndex >= 0, dayIndex < daysInMonth {
                        dailyKm[dayIndex] += row.distance / 1000.0
                    }
                }
            }

            let totalKm = dailyKm.reduce(0, +)
            return MonthlyKmData(dailyKm: dailyKm, totalKm: totalKm, todayIndex: -1, daysInMonth: daysInMonth, monthLabel: monthLabel(from: lastMonthDate))
        } catch {
            return .empty
        }
    }
}
