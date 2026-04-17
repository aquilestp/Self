import SwiftUI

extension PhotoEditorView {

    @ViewBuilder
    func miniWidgetPreview(type: StatWidgetType) -> some View {
        switch type {
        case .distance:
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.primaryLabel)
                    .font(.system(size: 8, weight: .regular, design: .serif))
                    .tracking(1)
                    .foregroundStyle(.white)
                Text(activity.primaryStat)
                    .font(.system(size: 16, weight: .regular, design: .serif).italic())
                    .foregroundStyle(.white)
            }
        case .distPace:
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(activity.primaryLabelShort)
                        .font(.system(size: 7, weight: .regular, design: .serif))
                        .tracking(0.8)
                        .foregroundStyle(.white)
                    Text(activity.primaryStat)
                        .font(.system(size: 12, weight: .regular, design: .serif).italic())
                        .foregroundStyle(.white)
                }
                Rectangle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 0.5, height: 18)
                VStack(alignment: .leading, spacing: 1) {
                    Text(activity.hasDistance ? "PACE" : "TIME")
                        .font(.system(size: 7, weight: .regular, design: .serif))
                        .tracking(0.8)
                        .foregroundStyle(.white)
                    Text(activity.hasDistance ? activity.pace : activity.duration)
                        .font(.system(size: 12, weight: .regular, design: .serif).italic())
                        .foregroundStyle(.white)
                }
            }
        case .threeStats:
            HStack(spacing: 6) {
                if activity.hasDistance {
                    miniStat(label: "DIST", value: activity.distance)
                    miniStat(label: "PACE", value: activity.pace)
                    miniStat(label: "TIME", value: activity.duration)
                } else {
                    miniStat(label: "TIME", value: activity.duration)
                    miniStat(label: "TYPE", value: activity.title)
                }
            }
        case .titleCard:
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.system(size: 8, weight: .black, design: .default).width(.expanded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text("\(activity.primaryStat) · \(activity.date)")
                    .font(.system(size: 5, weight: .bold, design: .default).width(.expanded))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.leading, 5)
            .scaleEffect(x: 1.5, y: 1.0, anchor: .leading)
        case .stack:
            VStack(spacing: 2) {
                ForEach(
                    activity.hasDistance
                        ? [("Dist", activity.distance), ("Pace", activity.pace), ("Time", activity.duration)]
                        : [("Duration", activity.duration), ("Activity", activity.title)],
                    id: \.0
                ) { label, value in
                    HStack {
                        Text(label)
                            .font(.system(size: 6, weight: .semibold).italic().width(.expanded))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(value)
                            .font(.system(size: 8, weight: .heavy).italic().width(.expanded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
            .padding(.horizontal, 6)
        case .bold:
            VStack(alignment: .leading, spacing: 0) {
                Text(activity.title.uppercased())
                    .font(.system(size: 4, weight: .heavy, design: .default).width(.expanded))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(activity.primaryStat.uppercased())
                    .font(.system(size: 15, weight: .black, design: .default).width(.expanded))
                    .tracking(-1)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                HStack(spacing: 4) {
                    if activity.hasDistance {
                        Text(activity.pace)
                            .font(.system(size: 5.5, weight: .heavy, design: .default).width(.expanded))
                            .foregroundStyle(.white)
                        Text(activity.duration.uppercased())
                            .font(.system(size: 5.5, weight: .heavy, design: .default).width(.expanded))
                            .foregroundStyle(.white)
                    } else {
                        Text(activity.title.uppercased())
                            .font(.system(size: 5.5, weight: .heavy, design: .default).width(.expanded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
            .padding(.leading, 5)
            .scaleEffect(x: 1.5, y: 1.0, anchor: .leading)
        case .impact:
            VStack(alignment: .leading, spacing: -2) {
                Text(activity.title.uppercased())
                    .font(.system(size: 4, weight: .heavy, design: .default).width(.expanded))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(activity.primaryStat.uppercased())
                    .font(.system(size: 16, weight: .black, design: .default).width(.expanded))
                    .tracking(-1.5)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .shadow(color: Color.white.opacity(0.5), radius: 6, x: 0, y: 0)
                HStack(spacing: 3) {
                    if activity.hasDistance {
                        Text(activity.pace)
                            .font(.system(size: 5, weight: .black, design: .default).width(.expanded))
                            .foregroundStyle(.white.opacity(0.8))
                        Rectangle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 1, height: 6)
                        Text(activity.duration.uppercased())
                            .font(.system(size: 5, weight: .black, design: .default).width(.expanded))
                            .foregroundStyle(.white.opacity(0.8))
                    } else {
                        Text(activity.title.uppercased())
                            .font(.system(size: 5, weight: .black, design: .default).width(.expanded))
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
            .padding(.leading, 5)
            .scaleEffect(x: 1.5, y: 1.0, anchor: .leading)
        case .poster:
            VStack(alignment: .leading, spacing: 0) {
                Text(activity.title.uppercased())
                    .font(.system(size: 4, weight: .heavy, design: .default).width(.expanded))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(activity.primaryStat.uppercased())
                    .font(.system(size: 16, weight: .black, design: .default).width(.expanded))
                    .tracking(-1.2)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .shadow(color: .white.opacity(0.28), radius: 4, x: 0, y: 0)
                HStack(spacing: 4) {
                    if activity.hasDistance {
                        Text(activity.pace)
                            .font(.system(size: 5.5, weight: .heavy, design: .default).width(.expanded))
                            .foregroundStyle(.white.opacity(0.88))
                        Rectangle()
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 1, height: 6)
                        Text(activity.duration.uppercased())
                            .font(.system(size: 5.5, weight: .heavy, design: .default).width(.expanded))
                            .foregroundStyle(.white.opacity(0.88))
                    } else {
                        Text(activity.date.uppercased())
                            .font(.system(size: 5.5, weight: .heavy, design: .default).width(.expanded))
                            .foregroundStyle(.white.opacity(0.88))
                    }
                }
            }
            .padding(.leading, 5)
            .scaleEffect(x: 1.5, y: 1.0, anchor: .leading)
        case .routeClean:
            ZStack {
                if activity.linePoints.count >= 2 {
                    RouteTraceShape(normalizedPoints: activity.linePoints)
                        .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                } else {
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .frame(width: 65, height: 65)
        case .heroStat:
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.primaryStat.uppercased())
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .scaleEffect(x: 1.0, y: 2.5, anchor: .top)
                    .padding(.bottom, 20)
                HStack(spacing: 8) {
                    if activity.hasDistance {
                        Text("PACE \(activity.pace)")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundStyle(.white)
                        Text("TIME \(activity.duration)")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text(activity.date.uppercased())
                            .font(.system(size: 6, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
        case .wide:
            VStack(alignment: .leading, spacing: 1) {
                Text(activity.primaryLabel)
                    .font(.system(size: 5, weight: .bold, design: .default).width(.expanded))
                    .tracking(2)
                    .foregroundStyle(.white)
                Text(activity.primaryStat.uppercased())
                    .font(.system(size: 14, weight: .black, design: .default).width(.expanded))
                    .tracking(-0.5)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
        case .tower:
            VStack(alignment: .leading, spacing: 1) {
                Text(activity.primaryLabel)
                    .font(.system(size: 5, weight: .bold, design: .default).width(.condensed))
                    .tracking(1)
                    .foregroundStyle(.white)
                Text(activity.primaryStat.uppercased())
                    .font(.system(size: 14, weight: .black, design: .default).width(.compressed))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .scaleEffect(x: 1.0, y: 2.5, anchor: .top)
                    .padding(.bottom, 20)
            }
        case .movingTimeClean:
            miniTimeArcClean(
                value: activity.duration,
                label: "MOVING",
                subLabel: String(format: "%.0f%%", miniEfficiencyRatio * 100),
                icon: "timer",
                progress: miniEfficiencyRatio
            )
        case .elapsedTimeClean:
            let paused = activity.elapsedTimeRaw - activity.movingTimeRaw
            miniTimeArcClean(
                value: activity.elapsedTime,
                label: "ELAPSED",
                subLabel: paused > 0 ? miniFormatDuration(paused) + " p" : "",
                icon: "clock",
                progress: 1.0
            )
        case .avgHeartRate:
            let bpm = miniHeartRateBPM
            let progress = bpm > 0 ? min(1.0, max(0.15, Double(bpm - 60) / 140.0)) : 0.2
            miniTimeArcClean(
                value: bpm > 0 ? "\(bpm)" : "--",
                label: "AVG HR",
                subLabel: bpm > 0 ? miniHeartRateZoneShort : "",
                icon: "heart.fill",
                progress: progress
            )
        case .hrPulseDots:
            miniHRPulseDots
        case .weeklyKm:
            miniWeeklyKm
        case .lastWeekKm:
            miniLastWeekKm
        case .monthlyKm:
            miniMonthlyKm
        case .lastMonthKm:
            miniLastMonthKm
        case .elevationGain:
            miniElevationGain
        case .splits:
            miniSplits
        case .splitsTable:
            miniSplitsTable
        case .splitsFastest:
            miniSplitsFastest
        case .splitsBars:
            miniSplitsBars
        case .bestEfforts:
            miniBestEfforts
        case .distanceWords:
            miniDistanceWords
        case .fullBanner:
            miniFullBanner
        case .fullBannerBottom:
            miniFullBannerBottom
        case .blurredVerticalText:
            miniBlurredVerticalText
        case .whatsappMessage:
            miniWhatsappMessage
        case .notesScreenshot:
            miniNotesScreenshot
        case .ancestralMedal:
            miniAncestralMedal
        case .splitBanner:
            miniSplitBanner
        case .cityActivity:
            miniCityActivity
        case .routeDistance:
            miniRouteDistance
        }
    }

    func miniStat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 7, weight: .regular, design: .serif))
                .tracking(0.8)
                .foregroundStyle(.white)
            Text(value)
                .font(.system(size: 9, weight: .regular, design: .serif).italic())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    var miniEfficiencyRatio: Double {
        guard activity.elapsedTimeRaw > 0 else { return 1.0 }
        return min(1.0, Double(activity.movingTimeRaw) / Double(activity.elapsedTimeRaw))
    }

    func miniFormatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }

    var miniHeartRateBPM: Int {
        guard let hrString = activity.averageHeartrate else { return 0 }
        let digits = hrString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(digits) ?? 0
    }

    var miniHeartRateZoneShort: String {
        let bpm = miniHeartRateBPM
        switch bpm {
        case ..<100: return "Z1"
        case 100..<120: return "Z2"
        case 120..<140: return "Z3"
        case 140..<160: return "Z4"
        default: return "Z5"
        }
    }

    var miniWeeklyKm: some View {
        let data = weeklyKmData
        let maxDaily = max(data.dailyKm.max() ?? 1.0, 0.1)
        return VStack(spacing: 3) {
            Text(String(format: "%.1f", data.totalKm))
                .font(.system(size: 12, weight: .black).width(.expanded).italic())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            HStack(alignment: .bottom, spacing: 2.5) {
                ForEach(0..<7, id: \.self) { i in
                    let km = data.dailyKm[i]
                    let ratio = km / maxDaily
                    let isToday = i == data.todayIndex
                    let barH = max(2, CGFloat(ratio) * 18)
                    VStack(spacing: 1.5) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.white.opacity(isToday ? 0.9 : (km > 0 ? 0.45 : 0.1)))
                            .frame(width: 6, height: barH)
                        Text(WeeklyKmData.dayLabels[i])
                            .font(.system(size: 4.5, weight: isToday ? .bold : .medium))
                            .foregroundStyle(.white.opacity(isToday ? 0.8 : 0.35))
                    }
                }
            }
            Text("THIS WEEK")
                .font(.system(size: 5, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(.white)
        }
    }

    var miniLastWeekKm: some View {
        let data = lastWeekKmData
        let maxDaily = max(data.dailyKm.max() ?? 1.0, 0.1)
        return VStack(spacing: 3) {
            Text(String(format: "%.1f", data.totalKm))
                .font(.system(size: 12, weight: .black).width(.expanded).italic())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            HStack(alignment: .bottom, spacing: 2.5) {
                ForEach(0..<7, id: \.self) { i in
                    let km = data.dailyKm[i]
                    let ratio = km / maxDaily
                    let barH = max(2, CGFloat(ratio) * 18)
                    VStack(spacing: 1.5) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.white.opacity(km > 0 ? 0.55 : 0.1))
                            .frame(width: 6, height: barH)
                        Text(WeeklyKmData.dayLabels[i])
                            .font(.system(size: 4.5, weight: .medium))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                }
            }
            Text("LAST WEEK")
                .font(.system(size: 5, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(.white)
        }
    }

    var miniMonthlyKm: some View {
        let data = monthlyKmData
        let maxDaily = max(data.dailyKm.prefix(data.daysInMonth).max() ?? 1.0, 0.1)
        return VStack(spacing: 3) {
            Text(String(format: "%.1f", data.totalKm))
                .font(.system(size: 12, weight: .black).width(.expanded).italic())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            HStack(alignment: .bottom, spacing: 1) {
                ForEach(0..<data.daysInMonth, id: \.self) { i in
                    let km = data.dailyKm[i]
                    let ratio = km / maxDaily
                    let isToday = i == data.todayIndex
                    let barH = max(1.5, CGFloat(ratio) * 18)
                    RoundedRectangle(cornerRadius: 0.5)
                        .fill(Color.white.opacity(isToday ? 0.9 : (km > 0 ? 0.45 : 0.1)))
                        .frame(width: 2, height: barH)
                }
            }
            Text(data.monthLabel.isEmpty ? "THIS MONTH" : data.monthLabel)
                .font(.system(size: 5, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(.white)
        }
    }

    var miniLastMonthKm: some View {
        let data = lastMonthKmData
        let maxDaily = max(data.dailyKm.prefix(data.daysInMonth).max() ?? 1.0, 0.1)
        return VStack(spacing: 3) {
            Text(String(format: "%.1f", data.totalKm))
                .font(.system(size: 12, weight: .black).width(.expanded).italic())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            HStack(alignment: .bottom, spacing: 1) {
                ForEach(0..<data.daysInMonth, id: \.self) { i in
                    let km = data.dailyKm[i]
                    let ratio = km / maxDaily
                    let barH = max(1.5, CGFloat(ratio) * 18)
                    RoundedRectangle(cornerRadius: 0.5)
                        .fill(Color.white.opacity(km > 0 ? 0.55 : 0.1))
                        .frame(width: 2, height: barH)
                }
            }
            Text(data.monthLabel.isEmpty ? "LAST MONTH" : data.monthLabel)
                .font(.system(size: 5, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(.white)
        }
    }

    var miniElevationGain: some View {
        let digits = activity.elevationGain.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let elev = digits.isEmpty ? "--" : digits
        return VStack(spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(elev)
                    .font(.system(size: 12, weight: .black).width(.expanded).italic())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("m")
                    .font(.system(size: 7, weight: .semibold))
                    .foregroundStyle(.white)
            }
            MountainRidgeShape()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.45), Color.white.opacity(0.05)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 70, height: 28)
            Text("ELEVATION")
                .font(.system(size: 5, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(.white)
        }
    }

    var miniSplits: some View {
        VStack(spacing: 3) {
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<6, id: \.self) { i in
                    let heights: [CGFloat] = [12, 18, 10, 16, 14, 8]
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(i == 1 ? 0.9 : 0.4))
                        .frame(width: 5, height: heights[i])
                }
            }
            .frame(height: 22, alignment: .bottom)
            Text("SPLITS")
                .font(.system(size: 5, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(.white)
        }
    }

    var miniSplitsFastest: some View {
        VStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                let widths: [CGFloat] = [48, 55, 32, 44, 38]
                let isFastest = i == 1
                HStack(spacing: 2) {
                    if isFastest {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 4, weight: .black))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Text("\(i + 1)")
                        .font(.system(size: 4.5, weight: isFastest ? .black : .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(isFastest ? 0.9 : 0.25))
                        .frame(width: isFastest ? 6 : 8, alignment: .trailing)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(isFastest ? 0.95 : 0.12))
                        .frame(width: widths[i], height: isFastest ? 6 : 3)
                        .shadow(color: isFastest ? .white.opacity(0.5) : .clear, radius: 3, x: 0, y: 0)
                    Spacer()
                    if isFastest {
                        Text("4'12\"")
                            .font(.system(size: 7, weight: .black, design: .default).width(.compressed))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
            Text("FASTEST")
                .font(.system(size: 4.5, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 6)
    }

    var miniSplitsBars: some View {
        VStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                let widths: [CGFloat] = [42, 55, 28, 48, 35]
                let opacities: [Double] = [0.35, 0.9, 0.15, 0.5, 0.25]
                let isFastest = i == 1
                HStack(spacing: 2) {
                    Text("\(i + 1)")
                        .font(.system(size: 4.5, weight: isFastest ? .black : .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(isFastest ? 0.9 : 0.3))
                        .frame(width: 8, alignment: .trailing)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(opacities[i]))
                        .frame(width: widths[i], height: isFastest ? 5.5 : 3)
                        .shadow(color: isFastest ? .white.opacity(0.4) : .clear, radius: 2, x: 0, y: 0)
                    Spacer()
                    Text(isFastest ? "4'12\"" : "\(4 + i)'\(10 + i * 7)\"")
                        .font(.system(size: isFastest ? 6.5 : 5, weight: .black, design: .default).width(.compressed))
                        .foregroundStyle(.white.opacity(isFastest ? 0.9 : 0.4))
                }
            }
            Text("SPLITS")
                .font(.system(size: 4.5, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 6)
    }

    var miniSplitsTable: some View {
        VStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { i in
                let widths: [CGFloat] = [50, 38, 45, 30]
                let isFastest = i == 0
                HStack(spacing: 3) {
                    Text("\(i + 1)")
                        .font(.system(size: 5, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.35))
                        .frame(width: 8, alignment: .trailing)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(isFastest ? 0.85 : 0.3))
                        .frame(width: widths[i], height: isFastest ? 5 : 3.5)
                    Spacer()
                    Text(isFastest ? "4'12\"" : "--")
                        .font(.system(size: isFastest ? 7 : 5, weight: .black, design: .default).width(.compressed))
                        .foregroundStyle(.white.opacity(isFastest ? 0.9 : 0.4))
                }
            }
            Text("ALL SPLITS")
                .font(.system(size: 4.5, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
    }

    var miniDistanceWords: some View {
        let result = DistanceToWords.convert(distanceMeters: activity.distanceRaw, unit: .km)
        let words = result.numberText.lowercased()
        return VStack(alignment: .leading, spacing: 1) {
            Text(words)
                .font(.system(size: 10, weight: .light, design: .monospaced))
                .foregroundStyle(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.5)
            Text(result.unitText.uppercased())
                .font(.system(size: 5, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(.white)
        }
    }

    var miniBestEfforts: some View {
        VStack(spacing: 3) {
            Image(systemName: "medal.fill")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(.white.opacity(0.7))
            VStack(spacing: 1.5) {
                ForEach(["1K", "5K"], id: \.self) { label in
                    HStack(spacing: 4) {
                        Text(label)
                            .font(.system(size: 6, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                        Text("--:--")
                            .font(.system(size: 6, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                }
            }
            Text("BEST EFFORTS")
                .font(.system(size: 4.5, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(.white)
        }
    }

    var miniHRPulseDots: some View {
        let bpm = miniHeartRateBPM
        let zoneIndex: Int = {
            switch bpm {
            case ..<100: return 1
            case 100..<120: return 2
            case 120..<140: return 3
            case 140..<160: return 4
            default: return bpm > 0 ? 5 : 0
            }
        }()
        return HStack(spacing: 6) {
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { i in
                    let isActive = (i + 1) == zoneIndex
                    let isPast = (i + 1) < zoneIndex
                    Circle()
                        .fill(Color.white.opacity(isActive ? 0.9 : (isPast ? 0.35 : 0.12)))
                        .frame(width: isActive ? 5 : 3.5, height: isActive ? 5 : 3.5)
                }
            }
            VStack(spacing: 0) {
                Text(bpm > 0 ? "\(bpm)" : "--")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("BPM")
                    .font(.system(size: 4, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white)
            }
        }
    }

    func miniTimeArcClean(value: String, label: String, subLabel: String, icon: String, progress: Double) -> some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.white.opacity(0.08), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: 28, height: 28)
                Circle()
                    .trim(from: 0, to: progress * 0.75)
                    .stroke(Color.white.opacity(0.85), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: 28, height: 28)
                Image(systemName: icon)
                    .font(.system(size: 8, weight: .light))
                    .foregroundStyle(.white.opacity(0.6))
            }
            if !subLabel.isEmpty {
                Text(subLabel)
                    .font(.system(size: 6, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Text(value)
                .font(.system(size: 10, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 5, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(.white)
        }
    }

    var miniFullBanner: some View {
        HStack(spacing: 0) {
            VStack(spacing: 3) {
                Text("TIME")
                    .font(.system(size: 8, weight: .regular, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(.white)
                Text(activity.duration)
                    .font(.system(size: 18, weight: .regular, design: .serif).italic())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            VStack(spacing: 3) {
                Text("DIST")
                    .font(.system(size: 8, weight: .regular, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(.white)
                Text(activity.distance)
                    .font(.system(size: 18, weight: .regular, design: .serif).italic())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            VStack(spacing: 3) {
                Text("PACE")
                    .font(.system(size: 8, weight: .regular, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(.white)
                Text(activity.pace)
                    .font(.system(size: 18, weight: .regular, design: .serif).italic())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            VStack(spacing: 3) {
                Text("ELEV")
                    .font(.system(size: 8, weight: .regular, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(.white)
                Text(activity.elevationGain)
                    .font(.system(size: 18, weight: .regular, design: .serif).italic())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 12)
    }

    var miniFullBannerBottom: some View {
        HStack(spacing: 0) {
            VStack(spacing: 3) {
                Text(activity.duration)
                    .font(.system(size: 18, weight: .regular, design: .serif).italic())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("TIME")
                    .font(.system(size: 8, weight: .regular, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            VStack(spacing: 3) {
                Text(activity.distance)
                    .font(.system(size: 18, weight: .regular, design: .serif).italic())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("DIST")
                    .font(.system(size: 8, weight: .regular, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            VStack(spacing: 3) {
                Text(activity.pace)
                    .font(.system(size: 18, weight: .regular, design: .serif).italic())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("PACE")
                    .font(.system(size: 8, weight: .regular, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            VStack(spacing: 3) {
                Text(activity.elevationGain)
                    .font(.system(size: 18, weight: .regular, design: .serif).italic())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("ELEV")
                    .font(.system(size: 8, weight: .regular, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 12)
    }

    var miniWhatsappMessage: some View {
        HStack(alignment: .bottom, spacing: 3) {
            Text("My coach would be proud")
                .font(.system(size: 5))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text("9:54")
                .font(.system(size: 3.5))
                .foregroundStyle(.white.opacity(0.5))
            Image(systemName: "checkmark")
                .font(.system(size: 3, weight: .bold))
                .foregroundStyle(Color(red: 0.33, green: 0.75, blue: 0.98))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(red: 0.00, green: 0.37, blue: 0.33))
        )
    }

    var miniAncestralMedal: some View {
        let bronzeDark = Color(red: 0.54, green: 0.40, blue: 0.14)
        let goldDeep = Color(red: 0.83, green: 0.68, blue: 0.21)
        let goldBright = Color(red: 0.93, green: 0.79, blue: 0.28)
        let goldShine = Color(red: 0.98, green: 0.91, blue: 0.55)
        let rimGrad = AngularGradient(
            colors: [bronzeDark, goldDeep, goldShine, goldBright, bronzeDark, goldDeep, goldShine, goldDeep, bronzeDark],
            center: .center
        )
        let bodyGrad = RadialGradient(
            colors: [goldShine, goldBright, goldDeep, bronzeDark.opacity(0.8)],
            center: .init(x: 0.38, y: 0.32),
            startRadius: 2,
            endRadius: 26
        )
        let sz: CGFloat = 50
        return ZStack {
            Circle()
                .fill(rimGrad)
                .frame(width: sz, height: sz)
                .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1)
            Circle()
                .fill(bodyGrad)
                .frame(width: sz - 5, height: sz - 5)
            Circle()
                .strokeBorder(bronzeDark.opacity(0.35), lineWidth: 0.7)
                .frame(width: sz - 9, height: sz - 9)
            ForEach(0..<6, id: \.self) { i in
                let side: CGFloat = i < 3 ? -1 : 1
                let idx = i < 3 ? i : i - 3
                let t = Double(idx) / 2.0
                let baseAngle = side < 0 ? (-60.0 + t * 120.0) : (180.0 + 60.0 - t * 120.0)
                let rad = baseAngle * .pi / 180
                let r: CGFloat = sz * 0.32
                Ellipse()
                    .fill(bronzeDark.opacity(0.18))
                    .frame(width: 2.5, height: 5)
                    .rotationEffect(.degrees(baseAngle + (side < 0 ? 90 : -90)))
                    .offset(x: cos(rad) * r, y: sin(rad) * r)
            }
            VStack(spacing: 0) {
                Text("MY FIRST")
                    .font(.system(size: 3, weight: .heavy, design: .serif))
                    .tracking(0.3)
                    .foregroundStyle(Color.black.opacity(0.6))
                Text(activity.hasDistance ? ActivityFormatting.distanceValue(activity.distanceRaw, unit: .km) : "--")
                    .font(.system(size: 14, weight: .black, design: .serif))
                    .foregroundStyle(Color.black.opacity(0.8))
                Text("KM")
                    .font(.system(size: 3, weight: .heavy, design: .serif))
                    .tracking(1)
                    .foregroundStyle(Color.black.opacity(0.4))
            }
        }
    }

    var miniNotesScreenshot: some View {
        let notesOrange = Color(red: 1.0, green: 0.65, blue: 0.0)
        return VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 2) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 4, weight: .semibold))
                    .foregroundStyle(notesOrange)
                Text("notes")
                    .font(.system(size: 5, weight: .regular))
                    .foregroundStyle(notesOrange)
                Spacer()
                Text(activity.hasDistance ? activity.distance : "")
                    .font(.system(size: 5, weight: .semibold))
                    .foregroundStyle(notesOrange)
                Image(systemName: "figure.run")
                    .font(.system(size: 4.5, weight: .semibold))
                    .foregroundStyle(notesOrange)
            }
            Text(activity.title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.black)
                .lineLimit(1)
            Text(activity.hasDistance ? activity.pace : activity.duration)
                .font(.system(size: 6, weight: .regular))
                .foregroundStyle(.gray)
                .lineLimit(1)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(.white)
        )
        .padding(.horizontal, 8)
    }

    var miniSplitBanner: some View {
        let font: Font = .system(size: 7, weight: .heavy, design: .default).italic().width(.expanded)
        return HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 1) {
                Text("SUNDAY")
                    .font(font)
                    .foregroundStyle(.white)
                Text(activity.date.uppercased())
                    .font(font)
                    .foregroundStyle(.white)
                Text("7:18 AM")
                    .font(font)
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 1) {
                Text(activity.distance.uppercased())
                    .font(font)
                    .foregroundStyle(.white)
                Text(activity.pace.uppercased())
                    .font(font)
                    .foregroundStyle(.white)
                Text(activity.duration.uppercased())
                    .font(font)
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 6)
    }

    var miniBlurredVerticalText: some View {
        VStack(alignment: .leading, spacing: -1) {
            Text(activity.date.uppercased())
                .font(.system(size: 5, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            if activity.hasDistance {
                Text(activity.distance.uppercased())
                    .font(.system(size: 5, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(activity.pace.uppercased())
                    .font(.system(size: 5, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            Text(activity.duration.uppercased())
                .font(.system(size: 5, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(activity.elevationGain.uppercased())
                .font(.system(size: 5, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            if activity.averageHeartrate != nil {
                Text("BPM")
                    .font(.system(size: 5, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    func miniTimeArc(value: String, label: String, icon: String, progress: Double) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.white.opacity(0.08), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: 30, height: 30)
                Circle()
                    .trim(from: 0, to: progress * 0.75)
                    .stroke(Color.white.opacity(0.85), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .light))
                    .foregroundStyle(.white.opacity(0.6))
            }
            Text(value)
                .font(.system(size: 10, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 5, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(.white)
        }
    }

    var miniRouteDistance: some View {
        VStack(spacing: 3) {
            ZStack {
                if activity.linePoints.count >= 2 {
                    RouteTraceShape(normalizedPoints: activity.linePoints)
                        .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                } else {
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                        .font(.system(size: 24, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.25))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(activity.hasDistance ? activity.distance.components(separatedBy: " ").first ?? activity.distance : "--")
                    .font(.system(size: 16, weight: .black, design: .default).width(.compressed))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("KM")
                    .font(.system(size: 7, weight: .heavy, design: .default).width(.compressed))
                    .foregroundStyle(.white.opacity(0.7))
                    .offset(y: -2)
            }
            HStack(spacing: 6) {
                Text(activity.elevationGain)
                    .font(.system(size: 6, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(1)
                Text(activity.duration)
                    .font(.system(size: 6, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 4)
    }

    var miniCityActivity: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Today at 6:32 AM")
                .font(.system(size: 6, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)
            Text(activity.activityType.lowercased().contains("ride") ? "City Ride" : "City Run")
                .font(.system(size: 13, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            HStack(spacing: 5) {
                if activity.hasDistance {
                    miniStat(label: "Dist", value: activity.distance)
                    miniStat(label: "Pace", value: activity.pace)
                }
                miniStat(label: "Time", value: activity.duration)
            }
        }
    }
}
