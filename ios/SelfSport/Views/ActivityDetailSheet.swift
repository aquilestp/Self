import SwiftUI

struct ActivityDetailSheet: View {
    let activity: ActivityHighlight
    let detail: StravaActivityDetail?
    let isLoading: Bool
    let error: String?
    var onDelete: ((String) async -> Bool)?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDetent: PresentationDetent = .fraction(0.70)
    @State private var showDeleteConfirmation: Bool = false
    @State private var isDeleting: Bool = false

    private static let dateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d · h:mm a"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    private var formattedDateTime: String {
        guard let date = activity.startDate else { return activity.date }
        return Self.dateTimeFormatter.string(from: date)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                header
                routeSection
                statsGrid
                    .padding(.top, 20)

                if isLoading {
                    detailLoadingSection
                        .padding(.top, 24)
                } else if let detail {
                    detailSections(detail)
                        .padding(.top, 24)
                }

                if onDelete != nil {
                    deleteSection
                        .padding(.top, 32)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 40)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(duration: 0.35)) {
                selectedDetent = .large
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.height < -30 {
                        withAnimation(.spring(duration: 0.35)) {
                            selectedDetent = .large
                        }
                    }
                }
        )
        .alert("Delete Activity", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    isDeleting = true
                    let success = await onDelete?(activity.id) ?? false
                    isDeleting = false
                    if success {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("This activity will be removed from your feed. This action cannot be undone.")
        }
        .sensoryFeedback(.success, trigger: isDeleting)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(activity.accent.opacity(0.14))
                        .frame(width: 44, height: 44)

                    Image(systemName: activity.systemImage)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(activity.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(activity.activityName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.95))
                        .lineLimit(2)

                    Text(formattedDateTime)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.40))
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 6) {
                Text(activity.activityType.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression))
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(activity.accent.opacity(0.90))
                    .textCase(.uppercase)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(activity.accent.opacity(0.10))
                    )
                    .overlay(
                        Capsule().stroke(activity.accent.opacity(0.12), lineWidth: 0.5)
                    )

                if let tag = activity.dayTag {
                    Text(tag)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.70))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                }

                if let detail, let device = detail.deviceName, !device.isEmpty {
                    Text(device)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.36))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white.opacity(0.05)))
                }
            }

            if let detail, let desc = detail.description, !desc.isEmpty {
                Text(desc)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.56))
                    .lineLimit(3)
                    .padding(.top, 4)
            }
        }
    }

    private var routeSection: some View {
        Group {
            if activity.hasRealRoute {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [activity.backgroundTop.opacity(0.6), activity.backgroundBottom.opacity(0.4)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                        }

                    GeometryReader { proxy in
                        Path { path in
                            guard let first = activity.linePoints.first else { return }
                            let inset: CGFloat = 20
                            let w = proxy.size.width - inset * 2
                            let h = proxy.size.height - inset * 2
                            path.move(to: CGPoint(x: inset + first.x * w, y: inset + first.y * h))
                            for point in activity.linePoints.dropFirst() {
                                path.addLine(to: CGPoint(x: inset + point.x * w, y: inset + point.y * h))
                            }
                        }
                        .stroke(activity.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                        .shadow(color: activity.accent.opacity(0.30), radius: 8, x: 0, y: 4)
                    }
                }
                .frame(height: 160)
                .padding(.top, 16)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [activity.backgroundTop.opacity(0.4), activity.backgroundBottom.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                        }

                    VStack(spacing: 8) {
                        Image(systemName: activity.systemImage)
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(activity.accent.opacity(0.50))

                        Text(activity.activityType.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.30))
                    }
                }
                .frame(height: 120)
                .padding(.top, 16)
            }
        }
    }

    private var statsGrid: some View {
        let items = buildStatItems()
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return VStack(spacing: 12) {
            timeArcRow

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items) { item in
                    StatCell(item: item, accent: activity.accent)
                }
            }
        }
    }

    private var efficiencyRatio: Double {
        guard activity.elapsedTimeRaw > 0 else { return 1.0 }
        return min(1.0, Double(activity.movingTimeRaw) / Double(activity.elapsedTimeRaw))
    }

    private var timeArcRow: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        return LazyVGrid(columns: columns, spacing: 12) {
            TimeArcStatCell(
                value: activity.duration,
                label: "MOVING",
                icon: "timer",
                arcProgress: efficiencyRatio,
                accent: activity.accent,
                subtitle: String(format: "%.0f%% active", efficiencyRatio * 100)
            )

            TimeArcStatCell(
                value: activity.elapsedTime,
                label: "ELAPSED",
                icon: "clock",
                arcProgress: 1.0,
                accent: activity.accent.opacity(0.45),
                subtitle: efficiencyRatio < 1.0 ? formatDuration(activity.elapsedTimeRaw - activity.movingTimeRaw) + " paused" : nil
            )
        }
    }

    private func buildStatItems() -> [DetailStatItem] {
        var items: [DetailStatItem] = []

        if activity.hasDistance && !activity.distance.isEmpty {
            items.append(DetailStatItem(label: "Distance", value: activity.distance, icon: "point.bottomleft.forward.to.point.topright.scurvepath"))
        }



        if activity.hasDistance && activity.pace != "--" {
            let paceLabel = activity.activityType.lowercased().contains("ride") || activity.activityType.lowercased().contains("cycle") ? "Avg Speed" : "Avg Pace"
            items.append(DetailStatItem(label: paceLabel, value: activity.pace, icon: "speedometer"))
        }

        if activity.maxSpeed != "--" {
            items.append(DetailStatItem(label: "Max Speed", value: activity.maxSpeed, icon: "gauge.with.dots.needle.67percent"))
        }

        if activity.elevationGain != "--" {
            items.append(DetailStatItem(label: "Elevation", value: activity.elevationGain, icon: "mountain.2"))
        }

        if let hr = activity.averageHeartrate {
            items.append(DetailStatItem(label: "Avg Heart Rate", value: hr, icon: "heart"))
        }

        if let detail {
            if let maxHr = detail.maxHeartrate, maxHr > 0 {
                items.append(DetailStatItem(label: "Max Heart Rate", value: String(format: "%.0f bpm", maxHr), icon: "heart.fill"))
            }
            if let cal = detail.calories, cal > 0 {
                items.append(DetailStatItem(label: "Calories", value: String(format: "%.0f kcal", cal), icon: "flame"))
            }
            if let cadence = detail.averageCadence, cadence > 0 {
                items.append(DetailStatItem(label: "Avg Cadence", value: String(format: "%.0f rpm", cadence), icon: "metronome"))
            }
            if let watts = detail.averageWatts, watts > 0 {
                items.append(DetailStatItem(label: "Avg Power", value: String(format: "%.0f W", watts), icon: "bolt"))
            }
            if let temp = detail.averageTemp, temp != 0 {
                items.append(DetailStatItem(label: "Avg Temp", value: String(format: "%.0f°C", temp), icon: "thermometer.medium"))
            }
        }

        return items
    }

    private var deleteSection: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            HStack(spacing: 8) {
                if isDeleting {
                    ProgressView()
                        .tint(Color.red.opacity(0.70))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                }
                Text("Delete Activity")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(Color.red.opacity(0.70))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.red.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.red.opacity(0.10), lineWidth: 0.5)
            )
        }
        .disabled(isDeleting)
    }

    private var detailLoadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(activity.accent.opacity(0.60))
                .scaleEffect(0.9)
            Text("Loading details...")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.30))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    @ViewBuilder
    private func detailSections(_ detail: StravaActivityDetail) -> some View {
        VStack(spacing: 20) {
            if let efforts = detail.bestEfforts, !efforts.isEmpty {
                bestEffortsSection(efforts)
            }

            if let segments = detail.segmentEfforts, !segments.isEmpty {
                segmentEffortsSection(segments)
            }

            if let splits = detail.splitsMetric, splits.count > 1 {
                splitsSection(splits)
            }

            if let laps = detail.laps, laps.count > 1 {
                lapsSection(laps)
            }
        }
    }

    private func bestEffortsSection(_ efforts: [StravaBestEffort]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Personal Records", icon: "trophy")

            VStack(spacing: 8) {
                ForEach(efforts) { effort in
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(effort.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.88))

                            Text(formatDuration(effort.elapsedTime))
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.white.opacity(0.44))
                        }

                        Spacer(minLength: 8)

                        if let rank = effort.prRank, rank > 0 {
                            prBadge(rank: rank)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.03))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                    )
                }
            }
        }
    }

    private func segmentEffortsSection(_ segments: [StravaSegmentEffort]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Segments", icon: "point.topleft.down.to.point.bottomright.curvepath")

            VStack(spacing: 8) {
                ForEach(segments) { segment in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 0) {
                            Text(segment.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.88))
                                .lineLimit(1)

                            Spacer(minLength: 8)

                            if let rank = segment.prRank, rank > 0 {
                                prBadge(rank: rank)
                            }
                        }

                        HStack(spacing: 12) {
                            segmentStat(label: "Time", value: formatDuration(segment.elapsedTime))

                            if segment.distance > 0 {
                                segmentStat(label: "Dist", value: String(format: "%.1f km", segment.distance / 1000.0))
                            }

                            if let grade = segment.segment?.averageGrade, grade != 0 {
                                segmentStat(label: "Grade", value: String(format: "%.1f%%", grade))
                            }

                            if let hr = segment.averageHeartrate, hr > 0 {
                                segmentStat(label: "HR", value: String(format: "%.0f", hr))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.03))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                    )
                }
            }
        }
    }

    private func splitsSection(_ splits: [StravaSplit]) -> some View {
        let speeds = splits.map { $0.averageSpeed }
        let maxSpeed = speeds.max() ?? 1.0
        let minSpeed = speeds.filter { $0 > 0 }.min() ?? 0
        let avgSpeed: Double = {
            let valid = speeds.filter { $0 > 0 }
            guard !valid.isEmpty else { return 0 }
            return valid.reduce(0, +) / Double(valid.count)
        }()
        let avgPaceStr: String = {
            guard avgSpeed > 0 else { return "--" }
            let sec = 1000.0 / avgSpeed
            let m = Int(sec) / 60
            let s = Int(sec) % 60
            return String(format: "%d'%02d\"", m, s)
        }()
        let count = splits.count
        let barW: CGFloat = count <= 8 ? 20 : count <= 15 ? 14 : count <= 22 ? 9 : 6
        let fastBarW: CGFloat = count <= 8 ? 28 : count <= 15 ? 20 : count <= 22 ? 14 : 10
        let barSpacing: CGFloat = count <= 8 ? 8 : count <= 15 ? 5 : 3
        let paceFontSize: CGFloat = count <= 8 ? 13 : count <= 15 ? 10 : 8
        let fastPaceFontSize: CGFloat = count <= 8 ? 20 : count <= 15 ? 15 : 12
        let labelSize: CGFloat = count <= 8 ? 10 : count <= 15 ? 8 : 6
        let maxBarH: CGFloat = 80
        let showAllPaces = count <= 10
        let showSomePaces = count <= 18

        return VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Splits", icon: "chart.bar")

            VStack(spacing: 10) {
                HStack(alignment: .bottom, spacing: barSpacing) {
                    ForEach(Array(splits.enumerated()), id: \.offset) { idx, split in
                        let speed = split.averageSpeed
                        let range = maxSpeed - minSpeed
                        let normalized = range > 0 ? (speed - minSpeed) / range : 0.5
                        let ratio = 0.20 + 0.80 * normalized
                        let isFastest = speed == maxSpeed && speed > 0
                        let barH = max(10, CGFloat(ratio) * maxBarH)
                        let paceStr = formatPace(speed: speed)
                        let shouldShowPace = showAllPaces || (showSomePaces && (isFastest || idx % 2 == 0)) || isFastest

                        VStack(spacing: 2) {
                            if shouldShowPace {
                                Text(paceStr)
                                    .font(.system(size: isFastest ? fastPaceFontSize : paceFontSize, weight: .black, design: .default).width(.compressed))
                                    .foregroundStyle(Color.white.opacity(isFastest ? 1.0 : 0.65))
                                    .shadow(color: isFastest ? activity.accent.opacity(0.7) : .clear, radius: 8, x: 0, y: 0)
                                    .lineLimit(1)
                                    .fixedSize()
                            }

                            RoundedRectangle(cornerRadius: isFastest ? 4 : 3, style: .continuous)
                                .fill(activity.accent.opacity(isFastest ? 0.90 : 0.15 + 0.50 * normalized))
                                .frame(width: isFastest ? fastBarW : barW, height: barH)
                                .shadow(color: isFastest ? activity.accent.opacity(0.5) : .clear, radius: 8, x: 0, y: 3)

                            Text("\(split.split)")
                                .font(.system(size: labelSize, weight: isFastest ? .heavy : .medium))
                                .foregroundStyle(Color.white.opacity(isFastest ? 0.8 : 0.30))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: maxBarH + fastPaceFontSize + 20, alignment: .bottom)

                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Text("\(count)")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.85))
                        Text("KM")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.0)
                            .foregroundStyle(Color.white.opacity(0.36))
                    }
                    Rectangle()
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 1, height: 20)
                    HStack(spacing: 6) {
                        Text(avgPaceStr)
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundStyle(Color.white.opacity(0.85))
                        Text("AVG")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.0)
                            .foregroundStyle(Color.white.opacity(0.36))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
            )
        }
    }

    private func lapsSection(_ laps: [StravaLap]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Laps", icon: "repeat")

            VStack(spacing: 6) {
                ForEach(laps) { lap in
                    HStack(spacing: 0) {
                        Text("Lap \(lap.lapIndex)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.70))

                        Spacer()

                        if lap.distance > 0 {
                            Text(String(format: "%.2f km", lap.distance / 1000.0))
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(Color.white.opacity(0.44))
                                .frame(width: 68, alignment: .trailing)
                        }

                        Text(formatDuration(lap.movingTime))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.white.opacity(0.60))
                            .frame(width: 68, alignment: .trailing)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
            )
        }
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(activity.accent.opacity(0.70))

            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(Color.white.opacity(0.44))
        }
    }

    private func segmentStat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.28))
            Text(value)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.56))
        }
    }

    private func prBadge(rank: Int) -> some View {
        let colors: (bg: Color, fg: Color) = {
            switch rank {
            case 1: return (Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.16), Color(red: 1.0, green: 0.84, blue: 0.0))
            case 2: return (Color.white.opacity(0.08), Color.white.opacity(0.60))
            case 3: return (Color(red: 0.80, green: 0.50, blue: 0.20).opacity(0.12), Color(red: 0.80, green: 0.50, blue: 0.20))
            default: return (activity.accent.opacity(0.10), activity.accent.opacity(0.70))
            }
        }()

        return Text("PR \(rank)")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(colors.fg)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(colors.bg))
    }

    private func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    private func formatPace(speed: Double) -> String {
        guard speed > 0 else { return "--" }
        let isRide = activity.activityType.lowercased().contains("ride") || activity.activityType.lowercased().contains("cycle")
        if isRide {
            return String(format: "%.1f km/h", speed * 3.6)
        }
        let paceSeconds = 1000.0 / speed
        let m = Int(paceSeconds) / 60
        let s = Int(paceSeconds) % 60
        return String(format: "%d'%02d\"", m, s)
    }
}

private struct DetailStatItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String
}

private struct StatCell: View {
    let item: DetailStatItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: item.icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(accent.opacity(0.60))

                Text(item.label.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.0)
                    .foregroundStyle(Color.white.opacity(0.36))
            }

            Text(item.value)
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(Color.white.opacity(0.92))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
        )
    }
}
