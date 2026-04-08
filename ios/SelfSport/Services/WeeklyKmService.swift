import Foundation
import Supabase

final class WeeklyKmService {
    private let table = "strava_activities"
    private let runningTypes = ["run", "virtualrun", "trailrun"]

    private func currentUserId() async -> String? {
        try? await supabase.auth.session.user.id.uuidString
    }

    func fetchLastWeekKm() async -> WeeklyKmData {
        guard let userId = await currentUserId() else { return .empty }

        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let today = Date()
        guard let thisMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let lastMonday = calendar.date(byAdding: .weekOfYear, value: -1, to: thisMonday) else {
            return .empty
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

        let startStr = isoFormatter.string(from: lastMonday)
        let endStr = isoFormatter.string(from: thisMonday)

        do {
            let rows: [SupabaseActivityRow] = try await supabase
                .from(table)
                .select()
                .eq("user_id", value: userId)
                .gte("start_date_local", value: startStr)
                .lt("start_date_local", value: endStr)
                .execute()
                .value

            var dailyKm: [Double] = [0, 0, 0, 0, 0, 0, 0]

            for row in rows {
                let typeLower = (row.sportType ?? row.type).lowercased()
                guard runningTypes.contains(typeLower) else { continue }

                if let date = isoFormatter.date(from: row.startDateLocal) {
                    let dayIndex = (calendar.component(.weekday, from: date) + 5) % 7
                    dailyKm[dayIndex] += row.distance / 1000.0
                }
            }

            let totalKm = dailyKm.reduce(0, +)
            return WeeklyKmData(dailyKm: dailyKm, totalKm: totalKm, todayIndex: -1)
        } catch {
            return .empty
        }
    }

    func fetchWeeklyKm() async -> WeeklyKmData {
        guard let userId = await currentUserId() else { return .empty }

        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let today = Date()
        guard let mondayStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return .empty
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

        let startStr = isoFormatter.string(from: mondayStart)

        do {
            let rows: [SupabaseActivityRow] = try await supabase
                .from(table)
                .select()
                .eq("user_id", value: userId)
                .gte("start_date_local", value: startStr)
                .execute()
                .value

            var dailyKm: [Double] = [0, 0, 0, 0, 0, 0, 0]

            for row in rows {
                let typeLower = (row.sportType ?? row.type).lowercased()
                guard runningTypes.contains(typeLower) else { continue }

                if let date = isoFormatter.date(from: row.startDateLocal) {
                    let dayIndex = (calendar.component(.weekday, from: date) + 5) % 7
                    dailyKm[dayIndex] += row.distance / 1000.0
                }
            }

            let totalKm = dailyKm.reduce(0, +)
            let todayIndex = (calendar.component(.weekday, from: today) + 5) % 7

            return WeeklyKmData(dailyKm: dailyKm, totalKm: totalKm, todayIndex: todayIndex)
        } catch {
            return .empty
        }
    }
}
