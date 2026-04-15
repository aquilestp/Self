import SwiftUI

extension StatWidgetContentView {

    // MARK: - weeklyKmWidget

    var weeklyKmWidget: some View {
        let maxDaily = weeklyKmData.dailyKm.max() ?? 1.0
        let barMax = max(maxDaily, 0.1)
        return VStack(spacing: 6) {
            VStack(spacing: 1) {
                Text(String(format: "%.1f", weeklyKmData.totalKm))
                    .font(.system(size: 24, weight: .black).width(.expanded).italic())
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("KMs THIS WEEK")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(primaryColor)
            }
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(0..<7, id: \.self) { i in
                    let km = weeklyKmData.dailyKm[i]
                    let ratio = km / barMax
                    let isToday = i == weeklyKmData.todayIndex
                    let barHeight = max(3, CGFloat(ratio) * 32)
                    VStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(primaryColor.opacity(isToday ? 0.95 : (km > 0 ? 0.55 : 0.12)))
                            .frame(width: 10, height: barHeight)
                            .shadow(color: isToday && km > 0 ? primaryColor.opacity(0.4) : .clear, radius: 4, x: 0, y: 2)
                        Text(WeeklyKmData.dayLabels[i])
                            .font(.system(size: 7, weight: isToday ? .bold : .medium))
                            .foregroundStyle(primaryColor.opacity(isToday ? 0.9 : 0.4))
                    }
                }
            }
            .frame(height: 50, alignment: .bottom)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    // MARK: - lastWeekKmWidget

    var lastWeekKmWidget: some View {
        let maxDaily = lastWeekKmData.dailyKm.max() ?? 1.0
        let barMax = max(maxDaily, 0.1)
        return VStack(spacing: 6) {
            VStack(spacing: 1) {
                Text(String(format: "%.1f", lastWeekKmData.totalKm))
                    .font(.system(size: 24, weight: .black).width(.expanded).italic())
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("KMs LAST WEEK")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(primaryColor)
            }
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(0..<7, id: \.self) { i in
                    let km = lastWeekKmData.dailyKm[i]
                    let ratio = km / barMax
                    let barHeight = max(3, CGFloat(ratio) * 32)
                    VStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(primaryColor.opacity(km > 0 ? 0.65 : 0.12))
                            .frame(width: 10, height: barHeight)
                        Text(WeeklyKmData.dayLabels[i])
                            .font(.system(size: 7, weight: .medium))
                            .foregroundStyle(primaryColor.opacity(0.5))
                    }
                }
            }
            .frame(height: 50, alignment: .bottom)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    // MARK: - monthlyKmWidget

    var monthlyKmWidget: some View {
        let data = monthlyKmData
        let maxDaily = data.dailyKm.prefix(data.daysInMonth).max() ?? 1.0
        let barMax = max(maxDaily, 0.1)
        return VStack(spacing: 6) {
            VStack(spacing: 1) {
                Text(String(format: "%.1f", data.totalKm))
                    .font(.system(size: 24, weight: .black).width(.expanded).italic())
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("KMs \(data.monthLabel.isEmpty ? "THIS MONTH" : data.monthLabel)")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(primaryColor)
            }
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<data.daysInMonth, id: \.self) { i in
                    let km = data.dailyKm[i]
                    let ratio = km / barMax
                    let isToday = i == data.todayIndex
                    let barHeight = max(2, CGFloat(ratio) * 32)
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(primaryColor.opacity(isToday ? 0.95 : (km > 0 ? 0.55 : 0.12)))
                            .frame(width: 4, height: barHeight)
                            .shadow(color: isToday && km > 0 ? primaryColor.opacity(0.4) : .clear, radius: 3, x: 0, y: 2)
                        if let label = data.dayLabel(for: i) {
                            Text(label)
                                .font(.system(size: 5, weight: isToday ? .bold : .medium))
                                .foregroundStyle(primaryColor.opacity(isToday ? 0.9 : 0.4))
                        } else {
                            Text("")
                                .font(.system(size: 5))
                        }
                    }
                }
            }
            .frame(height: 50, alignment: .bottom)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    // MARK: - lastMonthKmWidget

    var lastMonthKmWidget: some View {
        let data = lastMonthKmData
        let maxDaily = data.dailyKm.prefix(data.daysInMonth).max() ?? 1.0
        let barMax = max(maxDaily, 0.1)
        return VStack(spacing: 6) {
            VStack(spacing: 1) {
                Text(String(format: "%.1f", data.totalKm))
                    .font(.system(size: 24, weight: .black).width(.expanded).italic())
                    .foregroundStyle(primaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("KMs \(data.monthLabel.isEmpty ? "LAST MONTH" : data.monthLabel)")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(primaryColor)
            }
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<data.daysInMonth, id: \.self) { i in
                    let km = data.dailyKm[i]
                    let ratio = km / barMax
                    let barHeight = max(2, CGFloat(ratio) * 32)
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(primaryColor.opacity(km > 0 ? 0.65 : 0.12))
                            .frame(width: 4, height: barHeight)
                        if let label = data.dayLabel(for: i) {
                            Text(label)
                                .font(.system(size: 5, weight: .medium))
                                .foregroundStyle(primaryColor.opacity(0.5))
                        } else {
                            Text("")
                                .font(.system(size: 5))
                        }
                    }
                }
            }
            .frame(height: 50, alignment: .bottom)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }
}
