import SwiftUI

struct SplitMix64: Sendable {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
    mutating func nextDouble() -> Double {
        Double(next() >> 11) / Double(1 << 53)
    }
}

enum ExportEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isExport: Bool {
        get { self[ExportEnvironmentKey.self] }
        set { self[ExportEnvironmentKey.self] = newValue }
    }
}

struct StatDisplayItem: Identifiable, Sendable {
    let id: String
    let label: String
    let value: String
}

struct StatWidgetContentView: View, Equatable {
    static func == (lhs: StatWidgetContentView, rhs: StatWidgetContentView) -> Bool {
        lhs.type == rhs.type &&
        lhs.activity == rhs.activity &&
        lhs.colorStyle == rhs.colorStyle &&
        lhs.useGlassBackground == rhs.useGlassBackground &&
        lhs.weeklyKmData == rhs.weeklyKmData &&
        lhs.lastWeekKmData == rhs.lastWeekKmData &&
        lhs.monthlyKmData == rhs.monthlyKmData &&
        lhs.lastMonthKmData == rhs.lastMonthKmData &&
        lhs.activityDetail == rhs.activityDetail &&
        lhs.isLoadingDetail == rhs.isLoadingDetail &&
        lhs.bestEffortsFilter == rhs.bestEffortsFilter &&
        lhs.splitsFilter == rhs.splitsFilter &&
        lhs.distanceWordsFilter == rhs.distanceWordsFilter &&
        lhs.distanceWordsFontStyle == rhs.distanceWordsFontStyle &&
        lhs.fontStyle == rhs.fontStyle &&
        lhs.showTitle == rhs.showTitle &&
        lhs.showActivityName == rhs.showActivityName &&
        lhs.showDate == rhs.showDate &&
        lhs.showDistance == rhs.showDistance &&
        lhs.showPace == rhs.showPace &&
        lhs.showTime == rhs.showTime &&
        lhs.showElevation == rhs.showElevation &&
        lhs.basicUnitFilter == rhs.basicUnitFilter &&
        lhs.fullBannerUnitFilter == rhs.fullBannerUnitFilter &&
        lhs.fullBannerShowDistance == rhs.fullBannerShowDistance &&
        lhs.fullBannerShowPace == rhs.fullBannerShowPace &&
        lhs.fullBannerShowTime == rhs.fullBannerShowTime &&
        lhs.fullBannerShowElevation == rhs.fullBannerShowElevation &&
        lhs.bvtShowDate == rhs.bvtShowDate &&
        lhs.bvtShowTime == rhs.bvtShowTime &&
        lhs.bvtShowLocation == rhs.bvtShowLocation &&
        lhs.bvtShowDistance == rhs.bvtShowDistance &&
        lhs.bvtShowPace == rhs.bvtShowPace &&
        lhs.bvtShowDuration == rhs.bvtShowDuration &&
        lhs.bvtShowElevation == rhs.bvtShowElevation &&
        lhs.bvtShowCalories == rhs.bvtShowCalories &&
        lhs.bvtShowBPM == rhs.bvtShowBPM &&
        lhs.bvtUnitFilter == rhs.bvtUnitFilter &&
        lhs.bvtEffect == rhs.bvtEffect &&
        lhs.whatsappText == rhs.whatsappText &&
        lhs.notesUnitFilter == rhs.notesUnitFilter &&
        lhs.ancestralUnitFilter == rhs.ancestralUnitFilter &&
        lhs.ancestralShowPace == rhs.ancestralShowPace &&
        lhs.ancestralShowTime == rhs.ancestralShowTime &&
        lhs.splitBannerUnitFilter == rhs.splitBannerUnitFilter &&
        lhs.splitBannerFontStyle == rhs.splitBannerFontStyle &&
        lhs.cityActivityUnitFilter == rhs.cityActivityUnitFilter &&
        lhs.geocodedActivityCity == rhs.geocodedActivityCity &&
        lhs.routeDistanceUnitFilter == rhs.routeDistanceUnitFilter &&
        lhs.routeDistanceShowElevation == rhs.routeDistanceShowElevation &&
        lhs.routeDistanceShowTime == rhs.routeDistanceShowTime &&
        lhs.routeDistanceShowSpeed == rhs.routeDistanceShowSpeed &&
        lhs.nameStatsUnitFilter == rhs.nameStatsUnitFilter &&
        lhs.nameStatsShowDistance == rhs.nameStatsShowDistance &&
        lhs.nameStatsShowPace == rhs.nameStatsShowPace &&
        lhs.nameStatsShowTime == rhs.nameStatsShowTime &&
        lhs.nameStatsShowElevation == rhs.nameStatsShowElevation
    }

    let type: StatWidgetType
    let activity: ActivityHighlight
    var colorStyle: WidgetColorStyle = .initial
    var useGlassBackground: Bool = false
    var weeklyKmData: WeeklyKmData = .empty
    var lastWeekKmData: WeeklyKmData = .empty
    var monthlyKmData: MonthlyKmData = .empty
    var lastMonthKmData: MonthlyKmData = .empty
    var activityDetail: StravaActivityDetail? = nil
    var isLoadingDetail: Bool = false
    var bestEffortsFilter: BestEffortsUnitFilter = .km
    var splitsFilter: SplitsUnitFilter = .km
    var distanceWordsFilter: SplitsUnitFilter = .km
    var distanceWordsFontStyle: SplitBannerFontStyle = .system
    var fontStyle: WidgetFontStyle = .system
    var showTitle: Bool = true
    var showActivityName: Bool = true
    var showDate: Bool = true
    var showDistance: Bool = true
    var showPace: Bool = true
    var showTime: Bool = true
    var showElevation: Bool = true
    var basicUnitFilter: SplitsUnitFilter = .km
    var fullBannerUnitFilter: SplitsUnitFilter = .km
    var fullBannerShowDistance: Bool = true
    var fullBannerShowPace: Bool = true
    var fullBannerShowTime: Bool = true
    var fullBannerShowElevation: Bool = true
    var bvtShowDate: Bool = true
    var bvtShowTime: Bool = true
    var bvtShowLocation: Bool = true
    var bvtShowDistance: Bool = true
    var bvtShowPace: Bool = true
    var bvtShowDuration: Bool = true
    var bvtShowElevation: Bool = true
    var bvtShowCalories: Bool = true
    var bvtShowBPM: Bool = true
    var bvtUnitFilter: SplitsUnitFilter = .km
    var bvtEffect: BVTEffect = .glow
    var whatsappText: String = "My coach would be proud"
    var notesUnitFilter: SplitsUnitFilter = .km
    var ancestralUnitFilter: SplitsUnitFilter = .km
    var ancestralShowPace: Bool = true
    var ancestralShowTime: Bool = true
    var splitBannerUnitFilter: SplitsUnitFilter = .km
    var splitBannerFontStyle: SplitBannerFontStyle = .system
    var cityActivityUnitFilter: SplitsUnitFilter = .km
    var geocodedActivityCity: String? = nil
    var routeDistanceUnitFilter: SplitsUnitFilter = .km
    var routeDistanceShowElevation: Bool = true
    var routeDistanceShowTime: Bool = true
    var routeDistanceShowSpeed: Bool = true
    var nameStatsUnitFilter: SplitsUnitFilter = .km
    var nameStatsShowDistance: Bool = true
    var nameStatsShowPace: Bool = true
    var nameStatsShowTime: Bool = true
    var nameStatsShowElevation: Bool = false

    // MARK: - Color palette (internal so extension files can access)

    var primaryColor: Color { colorStyle.currentColor }
    var secondaryColor: Color { primaryColor.opacity(0.55) }
    var tertiaryColor: Color { primaryColor.opacity(0.6) }
    var dimColor: Color { primaryColor.opacity(0.45) }
    var boldColor: Color { primaryColor }
    var dividerColor: Color { primaryColor.opacity(0.2) }

    // MARK: - Body

    var body: some View {
        switch type {
        case .distance: distanceWidget
        case .distPace: distPaceWidget
        case .threeStats: threeStatsWidget
        case .titleCard: titleCardWidget
        case .stack: stackWidget
        case .bold: boldWidget
        case .impact: impactWidget
        case .poster: posterWidget
        case .routeClean: routeCleanWidget
        case .heroStat: heroStatWidget
        case .wide: wideWidget
        case .tower: towerWidget
        case .timeCombined: timeCombinedWidget
        case .avgHeartRate: avgHeartRateWidget
        case .hrPulseDots: hrPulseDotsWidget
        case .weeklyKm: weeklyKmWidget
        case .lastWeekKm: lastWeekKmWidget
        case .monthlyKm: monthlyKmWidget
        case .lastMonthKm: lastMonthKmWidget
        case .elevationGain: elevationGainWidget
        case .splits: splitsWidget(filter: splitsFilter)
        case .splitsTable: splitsTableWidget(filter: splitsFilter)
        case .splitsFastest: splitsFastestWidget(filter: splitsFilter)
        case .splitsBars: splitsBarsWidget(filter: splitsFilter)
        case .bestEfforts: bestEffortsWidget(filter: bestEffortsFilter)
        case .distanceWords: distanceWordsWidget(filter: distanceWordsFilter)
        case .fullBanner: fullBannerWidget
        case .fullBannerBottom: fullBannerBottomWidget
        case .blurredVerticalText: blurredVerticalTextWidget
        case .whatsappMessage: whatsappMessageWidget
        case .notesScreenshot: notesScreenshotWidget
        case .ancestralMedal: ancestralMedalWidget
        case .splitBanner: splitBannerWidget
        case .cityActivity: cityActivityWidget
        case .routeDistance: routeDistanceWidget
        case .nameStats: nameStatsWidget
        }
    }
}

// MARK: - DraggableStatWidget

struct DraggableStatWidget: View {
    @Binding var widget: PlacedWidget
    let activity: ActivityHighlight
    let canvasSize: CGSize
    var canvasGlobalOrigin: CGPoint = .zero
    var guideState: AlignmentGuideState? = nil
    var activeWidgetId: String? = nil
    var onDragStarted: ((String) -> Void)? = nil
    var onDragChanged: ((String, CGPoint) -> Void)? = nil
    var onDragEnded: ((String, CGPoint) -> Bool)? = nil
    var onWidgetTapped: ((String) -> Void)? = nil
    var isPaletteActive: Bool = false
    var weeklyKmData: WeeklyKmData = .empty
    var lastWeekKmData: WeeklyKmData = .empty
    var monthlyKmData: MonthlyKmData = .empty
    var lastMonthKmData: MonthlyKmData = .empty
    var activityDetail: StravaActivityDetail? = nil
    var isLoadingDetail: Bool = false
    var geocodedActivityCity: String? = nil

    @State private var dragOffset: CGSize = .zero
    @State private var snapAdjustment: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var isBeingDeleted: Bool = false
    @State private var measuredSize: CGSize = CGSize(width: 120, height: 60)
    @State private var liveScale: CGFloat = 1.0
    @State private var liveRotation: Angle = .zero
    @State private var isRotating: Bool = false
    @State private var cachedBoundingSize: CGSize = .zero

    var body: some View {
        widgetContent
            .equatable()
            .onGeometryChange(for: CGSize.self, of: \.size) { newSize in
                if newSize.width > 0, newSize.height > 0 {
                    measuredSize = newSize
                }
            }
            .allowsHitTesting(false)
            .overlay {
                StatGestureOverlay(
                    widgetVisualCenter: widgetVisualCenter,
                    widgetVisualSize: widgetVisualBoundingSize,
                    widgetRotationRadians: CGFloat((widget.rotation + liveRotation).radians),
                    isLocked: activeWidgetId != nil && activeWidgetId != widget.id,
                    onTranslationChanged: { translation in
                        if !isDragging {
                            isDragging = true
                            guideState?.beginDrag()
                            if measuredSize.width > 0, measuredSize.height > 0 {
                                let scaledSize = CGSize(width: measuredSize.width * widget.scale, height: measuredSize.height * widget.scale)
                                cachedBoundingSize = rotatedBoundingBox(size: scaledSize, rotation: widget.rotation)
                            }
                            onDragStarted?(widget.id)
                        }
                        dragOffset = translation

                        if let guideState, cachedBoundingSize.width > 0 {
                            let widgetCenter = CGPoint(
                                x: canvasSize.width * 0.5 + widget.position.width + translation.width,
                                y: canvasSize.height * 0.5 + widget.position.height + translation.height
                            )
                            let result = guideState.computeSnap(widgetCenter: widgetCenter, widgetSize: cachedBoundingSize, canvasSize: canvasSize)
                            snapAdjustment = result.adjustedOffset
                        }
                    },
                    onTranslationEnded: { translation, globalLocation in
                        isDragging = false
                        isRotating = false
                        guideState?.clearGuides()
                        guideState?.clearRotation()
                        let finalSnap = snapAdjustment
                        let wasDeleted = onDragEnded?(widget.id, globalLocation) ?? false
                        if wasDeleted {
                            widget.position.width += translation.width + finalSnap.width
                            widget.position.height += translation.height + finalSnap.height
                            dragOffset = .zero
                            snapAdjustment = .zero
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                isBeingDeleted = true
                            }
                        } else {
                            widget.position.width += translation.width + finalSnap.width
                            widget.position.height += translation.height + finalSnap.height
                            dragOffset = .zero
                            snapAdjustment = .zero
                        }
                    },
                    onScaleChanged: { scale in
                        liveScale = scale
                    },
                    onScaleEnded: { scale in
                        widget.scale *= scale
                        widget.scale = min(max(widget.scale, 0.3), 4.0)
                        liveScale = 1.0
                    },
                    onRotationChanged: { angle in
                        if !isRotating {
                            isRotating = true
                            guideState?.beginRotation()
                        }
                        if let guideState {
                            let totalDeg = widget.rotation.degrees + angle.degrees
                            let result = guideState.computeRotationSnap(currentDegrees: totalDeg)
                            liveRotation = result.snappedAngle - widget.rotation
                        } else {
                            liveRotation = angle
                        }
                    },
                    onRotationEnded: { _ in
                        widget.rotation += liveRotation
                        liveRotation = .zero
                        isRotating = false
                        guideState?.clearRotation()
                    },
                    onDragStarted: {},
                    onGlobalLocationChanged: { location in
                        onDragChanged?(widget.id, location)
                    },
                    onTapped: {
                        HapticService.light.impactOccurred()
                        if isPaletteActive {
                            widget.colorStyle.cycleNext()
                        }
                        onWidgetTapped?(widget.id)
                    }
                )
            }
        .scaleEffect(isBeingDeleted ? 0.01 : widget.scale * liveScale)
        .rotationEffect(widget.rotation + liveRotation)
        .opacity(isBeingDeleted ? 0 : 1)
        .offset(
            x: widget.position.width + dragOffset.width + snapAdjustment.width,
            y: widget.position.height + dragOffset.height + snapAdjustment.height
        )
        .transition(.scale.combined(with: .opacity))
    }
}

extension Color {
    var isLightColor: Bool {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.5
    }
}

extension DraggableStatWidget {
    private var widgetVisualCenter: CGPoint {
        CGPoint(
            x: canvasGlobalOrigin.x + canvasSize.width * 0.5 + widget.position.width + dragOffset.width + snapAdjustment.width,
            y: canvasGlobalOrigin.y + canvasSize.height * 0.5 + widget.position.height + dragOffset.height + snapAdjustment.height
        )
    }

    private var widgetVisualBoundingSize: CGSize {
        if isDragging, cachedBoundingSize.width > 0 {
            return cachedBoundingSize
        }
        let currentScale = widget.scale * liveScale
        let scaledSize = CGSize(width: measuredSize.width * currentScale, height: measuredSize.height * currentScale)
        return rotatedBoundingBox(size: scaledSize, rotation: widget.rotation + liveRotation)
    }

    private var widgetContent: StatWidgetContentView {
        StatWidgetContentView(type: widget.type, activity: activity, colorStyle: widget.colorStyle, useGlassBackground: widget.useGlassBackground, weeklyKmData: weeklyKmData, lastWeekKmData: lastWeekKmData, monthlyKmData: monthlyKmData, lastMonthKmData: lastMonthKmData, activityDetail: activityDetail, isLoadingDetail: isLoadingDetail, bestEffortsFilter: widget.bestEffortsFilter, splitsFilter: widget.splitsFilter, distanceWordsFilter: widget.distanceWordsFilter, distanceWordsFontStyle: widget.distanceWordsFontStyle, fontStyle: widget.fontStyle, showTitle: widget.showTitle, showActivityName: widget.showActivityName, showDate: widget.showDate, showDistance: widget.showDistance, showPace: widget.showPace, showTime: widget.showTime, showElevation: widget.showElevation, basicUnitFilter: widget.basicUnitFilter, fullBannerUnitFilter: widget.fullBannerUnitFilter, fullBannerShowDistance: widget.fullBannerShowDistance, fullBannerShowPace: widget.fullBannerShowPace, fullBannerShowTime: widget.fullBannerShowTime, fullBannerShowElevation: widget.fullBannerShowElevation, bvtShowDate: widget.bvtShowDate, bvtShowTime: widget.bvtShowTime, bvtShowLocation: widget.bvtShowLocation, bvtShowDistance: widget.bvtShowDistance, bvtShowPace: widget.bvtShowPace, bvtShowDuration: widget.bvtShowDuration, bvtShowElevation: widget.bvtShowElevation, bvtShowCalories: widget.bvtShowCalories, bvtShowBPM: widget.bvtShowBPM, bvtUnitFilter: widget.bvtUnitFilter, bvtEffect: widget.bvtEffect, whatsappText: widget.whatsappText, notesUnitFilter: widget.notesUnitFilter, ancestralUnitFilter: widget.ancestralUnitFilter, ancestralShowPace: widget.ancestralShowPace, ancestralShowTime: widget.ancestralShowTime, splitBannerUnitFilter: widget.splitBannerUnitFilter, splitBannerFontStyle: widget.splitBannerFontStyle, cityActivityUnitFilter: widget.cityActivityUnitFilter, geocodedActivityCity: geocodedActivityCity, routeDistanceUnitFilter: widget.routeDistanceUnitFilter, routeDistanceShowElevation: widget.routeDistanceShowElevation, routeDistanceShowTime: widget.routeDistanceShowTime, routeDistanceShowSpeed: widget.routeDistanceShowSpeed, nameStatsUnitFilter: widget.nameStatsUnitFilter, nameStatsShowDistance: widget.nameStatsShowDistance, nameStatsShowPace: widget.nameStatsShowPace, nameStatsShowTime: widget.nameStatsShowTime, nameStatsShowElevation: widget.nameStatsShowElevation)
    }
}

// MARK: - Glass effect modifier

private struct GlassCardModifier: ViewModifier {
    @Environment(\.isExport) private var isExport
    let colorStyle: WidgetColorStyle

    private var accentColor: Color { colorStyle.currentColor }
    private var isNeon: Bool { colorStyle.palette == .neon }
    private var isAesthetic: Bool { colorStyle.palette == .aesthetic }

    func body(content: Content) -> some View {
        if isExport {
            content
                .background(glassExportBackground)
                .clipShape(.rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(accentColor.opacity(isNeon ? 0.35 : 0.18), lineWidth: 0.5)
                )
        } else {
            content
                .background(.ultraThinMaterial.opacity(isAesthetic ? 0.5 : 0.7))
                .background(Color.white.opacity(isNeon ? 0.04 : 0.14))
                .background(accentColor.opacity(isNeon ? 0.12 : 0.06))
                .clipShape(.rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(accentColor.opacity(isNeon ? 0.35 : 0.18), lineWidth: 0.5)
                )
                .shadow(color: isNeon ? accentColor.opacity(0.35) : .black.opacity(0.3), radius: isNeon ? 16 : 12, x: 0, y: isNeon ? 0 : 6)
        }
    }

    @ViewBuilder
    private var glassExportBackground: some View {
        if isNeon {
            Color(red: 0.05, green: 0.05, blue: 0.12).opacity(0.75)
        } else if isAesthetic {
            Color.white.opacity(0.20)
        } else {
            Color.white.opacity(0.30)
        }
    }
}

// MARK: - Horizontal stretch modifier

private struct HorizontalStretchModifier: ViewModifier {
    let scale: CGFloat
    @State private var contentWidth: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: scale, y: 1.0, anchor: .leading)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { contentWidth = geo.size.width }
                        .onChange(of: geo.size.width) { _, new in contentWidth = new }
                }
            )
            .frame(width: contentWidth > 0 ? contentWidth * scale : nil, alignment: .leading)
    }
}

// MARK: - View extensions

extension View {
    func glassCard(colorStyle: WidgetColorStyle = .initial) -> some View {
        modifier(GlassCardModifier(colorStyle: colorStyle))
    }

    @ViewBuilder
    func conditionalGlass(enabled: Bool, colorStyle: WidgetColorStyle) -> some View {
        if enabled {
            modifier(GlassCardModifier(colorStyle: colorStyle))
        } else {
            self
        }
    }

    func horizontalStretch(_ scale: CGFloat) -> some View {
        modifier(HorizontalStretchModifier(scale: scale))
    }
}
