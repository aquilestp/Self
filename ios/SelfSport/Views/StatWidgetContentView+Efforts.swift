import SwiftUI

extension StatWidgetContentView {

    // MARK: - bestEffortsWidget

    func bestEffortsWidget(filter: BestEffortsUnitFilter) -> some View {
        Group {
            if isLoadingDetail {
                detailShimmer(width: 150, height: 120, label: "BEST EFFORTS")
            } else if let efforts = activityDetail?.bestEfforts?.filter({ filter.shouldInclude(effortName: $0.name) }), !efforts.isEmpty {
                bestEffortsContent(efforts: efforts)
            } else {
                detailEmptyState(icon: "medal.fill", label: "BEST EFFORTS", sublabel: "No effort data")
            }
        }
    }

    private func bestEffortsContent(efforts: [StravaBestEffort]) -> some View {
        let fontSize: CGFloat = efforts.count > 6 ? 16 : 20
        let timeFontSize: CGFloat = efforts.count > 6 ? 18 : 24
        let iconSize: CGFloat = efforts.count > 6 ? 12 : 16
        let rowSpacing: CGFloat = efforts.count > 6 ? 3 : 5
        return VStack(spacing: 8) {
            Text("BEST EFFORTS")
                .font(.system(size: 14, weight: .bold))
                .tracking(2.0)
                .foregroundStyle(primaryColor)

            VStack(spacing: rowSpacing) {
                ForEach(Array(efforts.enumerated()), id: \.element.id) { idx, effort in
                    let hasPR = effort.prRank == 1
                    HStack(spacing: 0) {
                        Text(effortDistanceLabel(effort.name))
                            .font(.system(size: fontSize, weight: .bold))
                            .foregroundStyle(primaryColor)
                            .frame(width: 70, alignment: .leading)

                        Spacer()

                        Text(formatEffortTime(effort.elapsedTime))
                            .font(.system(size: timeFontSize, weight: .semibold, design: .monospaced))
                            .foregroundStyle(primaryColor.opacity(hasPR ? 1.0 : 0.75))

                        if hasPR {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: iconSize, weight: .bold))
                                .foregroundStyle(primaryColor)
                                .padding(.leading, 4)
                        }
                    }
                    if idx < efforts.count - 1 {
                        Rectangle()
                            .fill(dividerColor)
                            .frame(height: 0.5)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .fixedSize()
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
    }

    private func effortDistanceLabel(_ name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("400m") { return "400m" }
        if lower.contains("1/2 mile") || lower.contains("half mile") { return "800m" }
        if lower.contains("1k") { return "1K" }
        if lower.contains("2 mile") { return "2 MI" }
        if lower.contains("1 mile") || lower == "mile" { return "1 MI" }
        if lower.contains("30k") { return "30K" }
        if lower.contains("20k") { return "20K" }
        if lower.contains("15k") { return "15K" }
        if lower.contains("10k") { return "10K" }
        if lower.contains("5k") { return "5K" }
        if lower.contains("half") { return "21K" }
        if lower.contains("marathon") { return "42K" }
        return String(name.prefix(5))
    }

    private func formatEffortTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d hrs", h, m, s) }
        return String(format: "%d:%02d mins", m, s)
    }

    // MARK: - distanceWordsWidget

    func distanceWordsWidget(filter: SplitsUnitFilter) -> some View {
        let result = DistanceToWords.convert(distanceMeters: activity.distanceRaw, unit: filter)
        let words = result.numberText.lowercased()
        let unit = result.unitText.uppercased()
        let wordsFont: Font = distanceWordsFontStyle == .system
            ? .system(size: 32, weight: .light, design: .monospaced)
            : distanceWordsFontStyle.font(size: 32)
        let unitFont: Font = distanceWordsFontStyle == .system
            ? .system(size: 11, weight: .bold, design: .monospaced)
            : distanceWordsFontStyle.font(size: 11)

        return VStack(alignment: .leading, spacing: 2) {
            Text(words)
                .font(wordsFont)
                .foregroundStyle(primaryColor)
                .lineSpacing(-2)
                .fixedSize(horizontal: false, vertical: true)
            Text(unit)
                .font(unitFont)
                .tracking(4)
                .foregroundStyle(primaryColor)
                .padding(.top, 2)
        }
        .frame(width: 200, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .conditionalGlass(enabled: useGlassBackground, colorStyle: colorStyle)
    }
}
