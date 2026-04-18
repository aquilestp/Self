import SwiftUI
import UIKit
import CoreLocation

struct PhotoEditorView: View {
    static let waPresetTexts: [String] = [
        "My coach would be proud",
        "New PR 🔥",
        "Easy run day",
        "That was tough 😮‍💨",
        "Sunday long run ✅",
        "Recovery mode",
        "Let's gooo 🏃‍♂️",
        "Pain is temporary, PRs are forever",
        "Just getting started",
        "Who's coming tomorrow?"
    ]

    let activity: ActivityHighlight
    let photo: UIImage
    let activities: [ActivityHighlight]
    let onClose: () -> Void

    @State var filterMode: FilterMode = .none
    @State var cityFilterIndex: Int = 0
    @State var raceFilterIndex: Int = 0
    @State var placedWidgets: [PlacedWidget] = []
    @State var placedTexts: [PlacedText] = []
    @State private var editingTextId: String? = nil
    @State private var editingTextContent: String = ""
    @State private var editingTextStyle: TextStyleType = .classic
    @State private var editingTextColor: Color = .white
    @State private var keyboardHeight: CGFloat = 0

    @State private var canvasSize: CGSize = .zero
    @State private var canvasGlobalOrigin: CGPoint = .zero
    @State var drawerState: DrawerState = .collapsed
    @State private var showInstagramAlert: Bool = false
    @State var drawerDragOffset: CGFloat = 0
    @State var locationService = LocationService()
    @State private var showLocationDeniedAlert: Bool = false
    @State private var showCityInfoAlert: Bool = false
    @State private var isDraggingWidget: Bool = false
    @State private var draggingWidgetId: String? = nil
    @State private var isOverDeleteZone: Bool = false
    @State private var didDeleteWidget: Bool = false
    @State private var widgetsPendingRemoval: Set<String> = []
    @State private var deleteZoneFrame: CGRect = .zero
    @State private var drawerStateBeforeDrag: DrawerState = .collapsed
    @State private var isPhotoGesturing: Bool = false
    @State private var paletteTargetWidgetId: String? = nil
    @State private var showPaletteSelector: Bool = false
    @State private var paletteHideTask: Task<Void, Never>? = nil
    @State private var showStatTapHint: Bool = false
    @State private var statTapHintTask: Task<Void, Never>? = nil

    @State private var photoOffset: CGSize = .zero
    @State private var photoScale: CGFloat = 1.0
    @State private var photoRotation: Angle = .zero
    @State private var livePhotoOffset: CGSize = .zero
    @State private var livePhotoScale: CGFloat = 1.0
    @State private var livePhotoRotation: Angle = .zero
    @State private var photoSessionActive: Bool = false
    @State private var rotationStarted: Bool = false

    @State private var canvasBackgroundColor: Color = .black
    @State private var showColorPicker: Bool = false
    @State private var isBackgroundExposed: Bool = false
    @State private var showSavedAlert: Bool = false
    @State private var showAIAnimateOptions: Bool = false
    @State private var showVideoComingSoon: Bool = false
    @State var showEditStyleDrawer: Bool = false
    @State var selectedEditStyle: AIEditStyle? = nil
    @State private var showActivitySwitcher: Bool = false
    @State private var _overrideActivity: ActivityHighlight? = nil
    @State private var alignmentGuideState = AlignmentGuideState()
    @State private var photoSnapAdjustment: CGSize = .zero
    @State private var cachedPhotoDisplaySize: CGSize = .zero

    @State var isGeneratingAI: Bool = false
    @State var aiGenerationStyle: String = ""
    @State var aiEditedPhoto: UIImage? = nil
    @State var aiGenerationTask: Task<Void, Never>? = nil
    @State var showAIErrorAlert: Bool = false
    @State var aiErrorMessage: String = ""
    @State var aiPulseAnimation: Bool = false
    @State var showAIReview: Bool = false
    @State var aiReviewImage: UIImage? = nil
    @State var aiReviewShowingOriginal: Bool = false
    @State var aiReviewAppeared: Bool = false
    @State private var selfAiGlowPhase: Bool = false
    @State private var selfAiGlowColorIndex: Int = 0
    private let selfAiGlowColors: [Color] = [
        Color(red: 0.8, green: 0.65, blue: 0.2),
        Color(red: 0.2, green: 0.75, blue: 0.4),
        Color(red: 0.9, green: 0.25, blue: 0.25),
        Color(red: 0.25, green: 0.5, blue: 0.95),
        Color.white
    ]
    @State private var glowColorTask: Task<Void, Never>? = nil
    @State private var showDiscardAlert: Bool = false
    @State var showVideoGeneration: Bool = false
    @State var videoPreviewImage: UIImage? = nil
    @State var quotaService = AIQuotaService.shared
    @State var showQuotaPaywall: Bool = false
    @State var showQuotaInfo: Bool = false
    @State var quotaPaywallKind: AIGenerationKind = .image
    @State var includeStatsOverlay: Bool = true
    @State var dynamicCityFilters: [CityFilterRow] = []
    @State var isLoadingCityFilters: Bool = false
    @State var filterSwipeDirection: Edge = .trailing
    @State var weeklyKmData: WeeklyKmData = .empty
    @State var lastWeekKmData: WeeklyKmData = .empty
    @State var monthlyKmData: MonthlyKmData = .empty
    @State var lastMonthKmData: MonthlyKmData = .empty
    @State private var activityDetail: StravaActivityDetail? = nil
    @State private var isLoadingDetail: Bool = false
    @State private var detailFetchTask: Task<Void, Never>? = nil
    @State private var geocodedActivityCity: String? = nil
    @State var activePhotoFilter: PhotoFilterType = .original
    @State private var filteredPhotoCache: [PhotoFilterType: UIImage] = [:]
    @State private var showFilterLabel: Bool = false
    @State var filterLabelText: String = ""
    @State private var filterLabelHideTask: Task<Void, Never>? = nil
    @State private var showFilterDotsIndicator: Bool = false
    @State private var filterDotsHideTask: Task<Void, Never>? = nil
    @State private var isCapturingCanvas: Bool = false
    @State var drawerTab: DrawerTab = .popular
    @State var widgetPopularityMap: [String: Int] = [:]
    @State var userRecentsMap: [String: Date] = [:]
    private let photoFilterService = PhotoFilterService()
    let grokService = GrokImageEditService()
    let cityFilterService = CityFilterService()
    private let weeklyKmService = WeeklyKmService()
    private let monthlyKmService = MonthlyKmService()
    private let detailService = SupabaseActivityDetailService()
    private let stravaService = StravaService()
    private let widgetPopularityService = WidgetPopularityService()

    var currentActivity: ActivityHighlight {
        _overrideActivity ?? activity
    }

    var currentPhoto: UIImage {
        let base = aiEditedPhoto ?? photo
        guard activePhotoFilter != .original else { return base }
        if let cached = filteredPhotoCache[activePhotoFilter] { return cached }
        return base
    }

    private func applyCurrentFilter() {
        let base = aiEditedPhoto ?? photo
        guard activePhotoFilter != .original else { return }
        if filteredPhotoCache[activePhotoFilter] != nil { return }
        photoFilterService.setSource(base)
        let result = photoFilterService.apply(activePhotoFilter, to: base)
        filteredPhotoCache[activePhotoFilter] = result
    }

    private func cyclePhotoFilter(by delta: Int) {
        let allFilters = PhotoFilterType.allCases
        guard let idx = allFilters.firstIndex(of: activePhotoFilter) else { return }
        let newIdx = ((idx + delta) % allFilters.count + allFilters.count) % allFilters.count
        let newFilter = allFilters[newIdx]
        activePhotoFilter = newFilter
        applyCurrentFilter()
        filterLabelText = newFilter.rawValue
        withAnimation(.easeInOut(duration: 0.25)) {
            showFilterLabel = true
        }
        filterLabelHideTask?.cancel()
        filterLabelHideTask = Task {
            try? await Task.sleep(for: .seconds(1.0))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                showFilterLabel = false
            }
        }
        HapticService.selection.selectionChanged()
    }

    private func showFilterDotsTemporarily() {
        filterDotsHideTask?.cancel()
        withAnimation(.easeInOut(duration: 0.25)) {
            showFilterDotsIndicator = true
        }
        filterDotsHideTask = Task {
            try? await Task.sleep(for: .seconds(3.0))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                showFilterDotsIndicator = false
            }
        }
    }

    var photoBeforeAIEdit: UIImage {
        photo
    }

    let fallbackCityFilters = CityFilter.allCases
    let raceFilters = RaceFilter.allCases

    var hasDynamicCityFilters: Bool {
        !dynamicCityFilters.isEmpty
    }

    var cityFilterCount: Int {
        hasDynamicCityFilters ? dynamicCityFilters.count + 1 : fallbackCityFilters.count
    }

    var isNoFilterPosition: Bool {
        hasDynamicCityFilters && cityFilterIndex == dynamicCityFilters.count
    }

    let hapticMedium = HapticService.medium
    let hapticLight = HapticService.light

    private var effectivePhotoScale: CGFloat {
        photoScale * livePhotoScale
    }

    private var effectivePhotoOffset: CGSize {
        CGSize(
            width: photoOffset.width + livePhotoOffset.width + photoSnapAdjustment.width,
            height: photoOffset.height + livePhotoOffset.height + photoSnapAdjustment.height
        )
    }

    private var effectivePhotoRotation: Angle {
        Angle(degrees: photoRotation.degrees + livePhotoRotation.degrees)
    }

    private var isHorizontalPhoto: Bool {
        photo.size.width > photo.size.height
    }

    private func computeInitialFillScale(canvasSize: CGSize) -> CGFloat {
        let imageSize = photo.size
        guard imageSize.width > 0, imageSize.height > 0,
              canvasSize.width > 0, canvasSize.height > 0 else { return 1.0 }
        let scaleW = canvasSize.width / imageSize.width
        let scaleH = canvasSize.height / imageSize.height
        return max(scaleW, scaleH)
    }

    private func defaultPhotoScale(canvasSize: CGSize) -> CGFloat {
        guard isHorizontalPhoto else { return 1.0 }
        let imageSize = photo.size
        guard imageSize.width > 0, imageSize.height > 0,
              canvasSize.width > 0, canvasSize.height > 0 else { return 1.0 }
        let scaleW = canvasSize.width / imageSize.width
        let scaleH = canvasSize.height / imageSize.height
        let fillScale = max(scaleW, scaleH)
        return scaleW / fillScale
    }

    private func checkBackgroundExposure(canvasSize: CGSize) {
        let imageSize = photo.size
        guard imageSize.width > 0, imageSize.height > 0,
              canvasSize.width > 0, canvasSize.height > 0 else { return }

        let fillScale = computeInitialFillScale(canvasSize: canvasSize)
        let totalScale = effectivePhotoScale * fillScale
        let displayW = imageSize.width * totalScale
        let displayH = imageSize.height * totalScale

        let imgLeft = (canvasSize.width - displayW) / 2 + effectivePhotoOffset.width
        let imgTop = (canvasSize.height - displayH) / 2 + effectivePhotoOffset.height
        let imgRight = imgLeft + displayW
        let imgBottom = imgTop + displayH

        let exposed = imgLeft > 0.5 || imgTop > 0.5 ||
                      imgRight < canvasSize.width - 0.5 ||
                      imgBottom < canvasSize.height - 0.5

        if exposed != isBackgroundExposed {
            withAnimation(.easeInOut(duration: 0.25)) {
                isBackgroundExposed = exposed
            }
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { outerGeo in
                let canvasHeight = outerGeo.size.height * 0.90
                let canvasWidth = outerGeo.size.width

                GeometryReader { geo in
                    ZStack {
                        canvasBackgroundColor
                            .zIndex(0)

                        colorPickerInCanvas
                            .zIndex(1)

                        Image(uiImage: currentPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: geo.size.width,
                                height: geo.size.height
                            )
                            .scaleEffect(effectivePhotoScale)
                            .rotationEffect(effectivePhotoRotation)
                            .offset(effectivePhotoOffset)
                            .allowsHitTesting(false)
                            .zIndex(2)

                        activeFilterOverlay(size: geo.size)
                            .id(filterOverlayId)
                            .transition(.asymmetric(
                                insertion: .move(edge: filterSwipeDirection).combined(with: .opacity),
                                removal: .move(edge: filterSwipeDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                            ))
                            .allowsHitTesting(false)
                            .zIndex(3)

                        if drawerState == .collapsed && !isDraggingWidget && !isPhotoGesturing && !isCapturingCanvas {
                            collapsedDrawer
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                .padding(.bottom, 12)
                                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                                .zIndex(5)
                        }

                        if !isCapturingCanvas {
                            AlignmentGuidesOverlay(
                                canvasSize: geo.size,
                                activeGuides: alignmentGuideState.activeGuides
                            )
                            .allowsHitTesting(false)
                            .zIndex(3.5)
                            .sensoryFeedback(.impact(weight: .medium), trigger: alignmentGuideState.snapHapticTrigger)
                            .sensoryFeedback(.impact(weight: .light), trigger: alignmentGuideState.crossingHapticTrigger)
                        }

                        PhotoGestureOverlay(
                            photoCenter: CGPoint(
                                x: canvasSize.width * 0.5 + effectivePhotoOffset.width,
                                y: canvasSize.height * 0.5 + effectivePhotoOffset.height
                            ),
                            photoDisplaySize: photoDisplaySize(),
                            photoRotationRadians: CGFloat(effectivePhotoRotation.radians),
                            boundsCheckEnabled: isBackgroundExposed,
                            isDisabled: isTextEditing,
                            onPanChanged: { translation in
                                if !isPhotoGesturing {
                                    isPhotoGesturing = true
                                    hidePaletteSelector()
                                    alignmentGuideState.beginDrag()
                                    cachedPhotoDisplaySize = photoDisplaySize()
                                }
                                livePhotoOffset = translation
                                let photoCenter = CGPoint(
                                    x: canvasSize.width * 0.5 + photoOffset.width + translation.width,
                                    y: canvasSize.height * 0.5 + photoOffset.height + translation.height
                                )
                                let result = alignmentGuideState.computeSnap(
                                    widgetCenter: photoCenter,
                                    widgetSize: cachedPhotoDisplaySize,
                                    canvasSize: canvasSize
                                )
                                photoSnapAdjustment = result.adjustedOffset
                            },
                            onPanEnded: { translation in
                                photoOffset.width += translation.width + photoSnapAdjustment.width
                                photoOffset.height += translation.height + photoSnapAdjustment.height
                                livePhotoOffset = .zero
                                photoSnapAdjustment = .zero
                                alignmentGuideState.clearGuides()
                            },
                            onPinchChanged: { scale in
                                if !isPhotoGesturing { isPhotoGesturing = true }
                                livePhotoScale = scale
                            },
                            onPinchEnded: { scale in
                                photoScale *= scale
                                let minZoom: CGFloat = isHorizontalPhoto ? 0.08 : 0.3
                                photoScale = min(max(photoScale, minZoom), 5.0)
                                livePhotoScale = 1.0
                            },
                            onRotationChanged: { angle in
                                if !isPhotoGesturing { isPhotoGesturing = true }
                                if !rotationStarted {
                                    rotationStarted = true
                                    alignmentGuideState.beginRotation()
                                }
                                let totalDeg = photoRotation.degrees + angle.degrees
                                let result = alignmentGuideState.computeRotationSnap(currentDegrees: totalDeg)
                                livePhotoRotation = result.snappedAngle - photoRotation
                            },
                            onRotationEnded: { angle in
                                if rotationStarted {
                                    let totalDeg = photoRotation.degrees + angle.degrees
                                    let result = alignmentGuideState.computeRotationSnap(currentDegrees: totalDeg)
                                    photoRotation = result.snappedAngle
                                    livePhotoRotation = .zero
                                    rotationStarted = false
                                    alignmentGuideState.clearRotation()
                                }
                            },
                            onSessionStarted: {
                                photoSessionActive = true
                            },
                            onSessionEnded: {
                                isPhotoGesturing = false
                                photoSessionActive = false
                                rotationStarted = false
                            }
                        )
                        .zIndex(0.5)

                        ForEach($placedTexts) { $textWidget in
                            if editingTextId == textWidget.id {
                                CanvasLiveTextView(
                                    text: $editingTextContent,
                                    maxWidth: geo.size.width * 0.8,
                                    selectAllOnAppear: isNewTextEditing,
                                    styleType: editingTextStyle,
                                    styleColor: editingTextColor,
                                    onCommit: { commitTextEditing() }
                                )
                                .frame(maxWidth: geo.size.width * 0.8)
                                .scaleEffect(textWidget.scale)
                                .rotationEffect(textWidget.rotation)
                                .offset(x: textWidget.position.width, y: textWidget.position.height)
                                .zIndex(4.5)
                            } else {
                                DraggableTextWidget(
                                    textWidget: $textWidget,
                                    canvasSize: geo.size,
                                    canvasGlobalOrigin: canvasGlobalOrigin,
                                    guideState: alignmentGuideState,
                                    activeWidgetId: draggingWidgetId,
                                    isEditing: isTextEditing,
                                    onDragStarted: { widgetId in
                                        draggingWidgetId = widgetId
                                        drawerStateBeforeDrag = drawerState
                                        withAnimation(.snappy(duration: 0.25)) {
                                            isDraggingWidget = true
                                            drawerState = .collapsed
                                        }
                                    },
                                    onDragChanged: { _, position in
                                        let over = deleteZoneFrame.contains(position)
                                        if over && !isOverDeleteZone {
                                            isOverDeleteZone = true
                                            hapticMedium.impactOccurred()
                                        } else if !over && isOverDeleteZone {
                                            isOverDeleteZone = false
                                        }
                                    },
                                    onDragEnded: { widgetId, position in
                                        let shouldDelete = deleteZoneFrame.contains(position)
                                        if shouldDelete {
                                            didDeleteWidget.toggle()
                                            scheduleTextDeletion(widgetId)
                                        }
                                        withAnimation(.snappy(duration: 0.25)) {
                                            isDraggingWidget = false
                                            isOverDeleteZone = false
                                            draggingWidgetId = nil
                                        }
                                        return shouldDelete
                                    },
                                    onTapped: { widgetId in
                                        startEditingExistingText(widgetId)
                                    }
                                )
                                .zIndex(4)
                            }
                        }

                        statWidgetsLayer(canvasSize: geo.size)
                            .zIndex(4)



                        if !isCapturingCanvas {
                            if showFilterDotsIndicator && (filterMode != .none || hasDynamicCityFilters) {
                                filterDots
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .padding(.bottom, drawerState == .collapsed ? 140 : drawerState == .open ? 280 : 140)
                                    .transition(.opacity)
                            }

                            if showFilterDotsIndicator {
                                photoFilterDotsView
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                    .padding(.bottom, drawerState == .collapsed ? 110 : drawerState == .open ? 250 : 110)
                                    .allowsHitTesting(false)
                                    .zIndex(5.8)
                                    .transition(.opacity)
                            }

                            if showFilterLabel {
                                photoFilterLabelView
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .allowsHitTesting(false)
                                    .transition(.opacity)
                                    .zIndex(5.9)
                            }
                        }
                    }
                    .clipShape(.rect(cornerRadius: isCapturingCanvas ? 0 : 28))
                    .onAppear {
                        canvasSize = geo.size
                        if isHorizontalPhoto {
                            photoScale = defaultPhotoScale(canvasSize: geo.size)
                            isBackgroundExposed = true
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onChange(of: proxy.frame(in: .global)) { _, newFrame in
                                    canvasGlobalOrigin = newFrame.origin
                                }
                                .onAppear {
                                    canvasGlobalOrigin = proxy.frame(in: .global).origin
                                }
                        }
                    )
                    .contentShape(.rect(cornerRadius: 28))
                    .gesture(
                        DragGesture(minimumDistance: 30, coordinateSpace: .local)
                            .onEnded { value in
                                guard !isDraggingWidget, !isPhotoGesturing, !isTextEditing, !photoSessionActive else { return }
                                let horizontal = value.translation.width
                                let vertical = abs(value.translation.height)
                                guard abs(horizontal) > vertical else { return }
                                showFilterDotsTemporarily()
                                if filterMode != .none || hasDynamicCityFilters {
                                    if horizontal < 0 {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                            filterSwipeDirection = .trailing
                                            advanceFilter(by: 1)
                                        }
                                    } else {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                            filterSwipeDirection = .leading
                                            advanceFilter(by: -1)
                                        }
                                    }
                                } else {
                                    if horizontal < 0 {
                                        cyclePhotoFilter(by: 1)
                                    } else {
                                        cyclePhotoFilter(by: -1)
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            photoOffset = .zero
                            photoScale = defaultPhotoScale(canvasSize: canvasSize)
                            photoRotation = .zero
                            photoSnapAdjustment = .zero
                        }
                        checkBackgroundExposure(canvasSize: geo.size)
                    }
                    .onTapGesture {
                        if isTextEditing {
                            commitTextEditing()
                        } else if showEditStyleDrawer {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                showEditStyleDrawer = false
                                selectedEditStyle = nil
                            }
                        } else if drawerState != .collapsed {
                            withAnimation(.snappy(duration: 0.3)) {
                                drawerState = .collapsed
                            }
                        }
                    }
                    .onChange(of: isPhotoGesturing) { _, newValue in
                        if !newValue {
                            checkBackgroundExposure(canvasSize: canvasSize)
                        }
                    }
                }
                .frame(width: canvasWidth, height: canvasHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea(.container, edges: .bottom)

            GeometryReader { overlayGeo in
                let canvasH = overlayGeo.size.height * 0.90

                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            topBar
                                .padding(.top, 8)
                                .padding(.horizontal, 14)

                            Spacer()

                            if drawerState == .open || drawerState == .expanded {
                                expandedDrawer
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                    .animation(.snappy(duration: 0.32), value: drawerState)
                            }

                            if showEditStyleDrawer {
                                editStyleDrawer
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                    .animation(.spring(response: 0.38, dampingFraction: 0.82), value: showEditStyleDrawer)
                            }
                        }
                        .frame(height: canvasH)

                        if drawerState == .collapsed && !showEditStyleDrawer {
                            bottomShareBar
                                .padding(.top, 14)
                                .padding(.bottom, 10)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                                .animation(.snappy(duration: 0.32), value: drawerState)
                        } else if drawerState == .open || drawerState == .expanded {
                            Rectangle()
                                .fill(.black.opacity(0.55))
                                .background(.ultraThinMaterial)
                                .transition(.opacity)
                                .animation(.snappy(duration: 0.32), value: drawerState)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)

                    if showStatTapHint {
                        StatTapHintView()
                            .padding(.top, 14)
                            .padding(.horizontal, 12)
                            .allowsHitTesting(false)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                    }
                }
            }
            .opacity(isCapturingCanvas ? 0 : (isPhotoGesturing || isDraggingWidget || isTextEditing ? 0 : 1))
            .animation(isCapturingCanvas ? nil : .easeInOut(duration: 0.2), value: isPhotoGesturing || isDraggingWidget || isTextEditing)

            if showPaletteSelector && !isDraggingWidget && !isPhotoGesturing && !isTextEditing && !isCapturingCanvas {
                PaletteSelectorView(
                    targetWidget: placedWidgets.first(where: { $0.id == paletteTargetWidgetId }),
                    showPaletteSelector: showPaletteSelector,
                    waPresetTexts: Self.waPresetTexts,
                    updateWidget: { widgetId, transform in
                        guard let idx = placedWidgets.firstIndex(where: { $0.id == widgetId }) else { return }
                        transform(&placedWidgets[idx])
                    },
                    resetHideTimer: { resetPaletteHideTimer() }
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .offset(y: -60)
                    .allowsHitTesting(true)
                    .transition(.opacity)
            }

            if isDraggingWidget {
                VStack {
                    Spacer()
                    deleteDropZone
                        .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.snappy(duration: 0.25), value: isDraggingWidget)
            }

            if isTextEditing {
                VStack {
                    Spacer()
                    TextStyleCarousel(
                        selectedStyle: $editingTextStyle
                    )
                }
                .padding(.bottom, keyboardHeight)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: isTextEditing)
                .ignoresSafeArea(.keyboard)
            }

            if isGeneratingAI {
                aiGenerationOverlay
                    .transition(.opacity)
                    .zIndex(100)
            }

            if showAIReview, let reviewImage = aiReviewImage {
                aiReviewOverlay(editedImage: reviewImage)
                    .transition(.opacity)
                    .zIndex(101)
            }

            if showVideoGeneration, let preview = videoPreviewImage {
                VideoGenerationView(
                    previewImage: preview,
                    onDiscard: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showVideoGeneration = false
                        }
                        videoPreviewImage = nil
                    },
                    onKeep: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showVideoGeneration = false
                        }
                        videoPreviewImage = nil
                    }
                )
                .transition(.opacity)
                .zIndex(102)
            }
        }

        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    keyboardHeight = frame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                keyboardHeight = 0
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.7))
            guard drawerState == .collapsed else { return }
            withAnimation(.snappy(duration: 0.18)) {
                drawerState = .open
            }
            hapticMedium.impactOccurred()
        }
        .task {
            await grokService.loadPrompts()
        }
        .task {
            await quotaService.refresh()
        }
        .fullScreenCover(isPresented: $showQuotaPaywall) {
            AIQuotaPaywallView(
                kind: quotaPaywallKind,
                daysUntilNextSlot: quotaService.daysUntilNextSlot(for: quotaPaywallKind),
                onDismiss: { showQuotaPaywall = false }
            )
        }
        .alert("Videos are hitting the gym 🏋️", isPresented: $showVideoComingSoon) {
            Button("Got it, I'll wait", role: .cancel) {}
        } message: {
            Text("Our AI is training hard to generate epic videos of your runs. In the meantime, enjoy creating stunning images. Check back soon!")
        }
        .task {
            weeklyKmData = await weeklyKmService.fetchWeeklyKm()
            lastWeekKmData = await weeklyKmService.fetchLastWeekKm()
            monthlyKmData = await monthlyKmService.fetchMonthlyKm()
            lastMonthKmData = await monthlyKmService.fetchLastMonthKm()
        }
        .task {
            async let pop = widgetPopularityService.fetchPopularity()
            async let rec = widgetPopularityService.fetchUserRecents()
            widgetPopularityMap = await pop
            userRecentsMap = await rec
        }
        .onChange(of: aiEditedPhoto) { _, _ in
            filteredPhotoCache.removeAll()
            photoFilterService.invalidateCache()
            if activePhotoFilter != .original {
                applyCurrentFilter()
            }
        }
        .onChange(of: locationService.latitude) { _, newLat in
            guard let lat = newLat, let lng = locationService.longitude else { return }
            Task {
                await loadDynamicCityFilters(lat: lat, lng: lng)
            }
        }
        .alert("Instagram not installed", isPresented: $showInstagramAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Install Instagram to share your photo directly to Stories.")
        }
        .alert("You are in \(locationService.cityName ?? "") 📍", isPresented: $showCityInfoAlert) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text("Soon you'll be able to filter activities and discover events happening in your city.")
        }
        .alert("Location Access Denied", isPresented: $showLocationDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enable location access in Settings to show your city.")
        }
        .alert("AI Edit Error", isPresented: $showAIErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(aiErrorMessage)
        }
        .alert("Leave editor?", isPresented: $showDiscardAlert) {
            Button("Leave", role: .destructive) {
                onClose()
            }
            Button("Continue editing", role: .cancel) { }
        } message: {
            Text("Your editing progress will be lost.")
        }
        .alert("Photo Saved!", isPresented: $showSavedAlert) {
            Button("View in Photos") {
                if let url = URL(string: "photos-redirect://") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Continue Editing", role: .cancel) { }
        } message: {
            Text("Your image has been saved to the photo library.")
        }
        .sheet(isPresented: $showActivitySwitcher) {
            ActivitySwitcherSheet(
                activities: activities,
                currentActivityId: currentActivity.id,
                onPick: { picked in
                    withAnimation(.snappy(duration: 0.2)) {
                        _overrideActivity = picked
                        activityDetail = nil
                        geocodedActivityCity = nil
                        showActivitySwitcher = false
                        drawerState = .open
                    }
                    if placedWidgets.contains(where: { $0.type.requiresDetail }) {
                        fetchActivityDetailOnDemand()
                    }
                }
            )
            .presentationDetents([.fraction(0.58), .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color(white: 0.06))
            .presentationContentInteraction(.scrolls)
        }
        .onDisappear {
            statTapHintTask?.cancel()
            statTapHintTask = nil
        }
    }

    // MARK: - Photo Gesture

    private func photoDisplaySize() -> CGSize {
        let fillScale = computeInitialFillScale(canvasSize: canvasSize)
        let totalScale = photoScale * fillScale
        return CGSize(
            width: photo.size.width * totalScale,
            height: photo.size.height * totalScale
        )
    }

    // MARK: - Color Picker Button

    private var colorPickerButton: some View {
        ColorPicker("", selection: $canvasBackgroundColor, supportsOpacity: false)
            .labelsHidden()
            .frame(width: 36, height: 36)
    }

    @ViewBuilder
    private var colorPickerInCanvas: some View {
        if isBackgroundExposed && !isPhotoGesturing && !isDraggingWidget && !isCapturingCanvas {
            colorPickerButton
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.leading, 16)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                .animation(.easeInOut(duration: 0.25), value: isBackgroundExposed)
        }
    }

    private var isTextEditing: Bool {
        editingTextId != nil
    }

    private var hasUnsavedChanges: Bool {
        !placedWidgets.isEmpty ||
        !placedTexts.isEmpty ||
        aiEditedPhoto != nil ||
        photoOffset != .zero ||
        photoScale != defaultPhotoScale(canvasSize: canvasSize) ||
        photoRotation != .zero ||
        filterMode != .none ||
        canvasBackgroundColor != .black ||
        activePhotoFilter != .original
    }

    var hasCanvasContent: Bool {
        !placedWidgets.isEmpty || !placedTexts.isEmpty || filterMode != .none
    }

    // MARK: - Palette Selector

    private func statWidgetsLayer(canvasSize: CGSize) -> some View {
        Color.clear
            .allowsHitTesting(false)
            .overlay {
                ForEach($placedWidgets) { $widget in
            let isActive = paletteTargetWidgetId == widget.id && showPaletteSelector
            DraggableStatWidget(
                widget: $widget,
                activity: currentActivity,
                canvasSize: canvasSize,
                canvasGlobalOrigin: canvasGlobalOrigin,
                guideState: alignmentGuideState,
                activeWidgetId: isTextEditing ? "__locked__" : draggingWidgetId,
                onDragStarted: { widgetId in
                    hidePaletteSelector()
                    draggingWidgetId = widgetId
                    drawerStateBeforeDrag = drawerState
                    withAnimation(.snappy(duration: 0.25)) {
                        isDraggingWidget = true
                        drawerState = .collapsed
                    }
                },
                onDragChanged: { _, position in
                    let over = deleteZoneFrame.contains(position)
                    if over && !isOverDeleteZone {
                        isOverDeleteZone = true
                        hapticMedium.impactOccurred()
                    } else if !over && isOverDeleteZone {
                        isOverDeleteZone = false
                    }
                },
                onDragEnded: { widgetId, position in
                    let shouldDelete = deleteZoneFrame.contains(position)
                    if shouldDelete {
                        didDeleteWidget.toggle()
                        scheduleWidgetDeletion(widgetId)
                    }
                    withAnimation(.snappy(duration: 0.25)) {
                        isDraggingWidget = false
                        isOverDeleteZone = false
                        draggingWidgetId = nil
                    }
                    if !shouldDelete {
                        paletteTargetWidgetId = widgetId
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            showPaletteSelector = true
                        }
                        resetPaletteHideTimer()
                    }
                    return shouldDelete
                },
                onWidgetTapped: { widgetId in
                    dismissStatTapHint()
                    showPaletteSelectorFor(widgetId: widgetId)
                    if drawerState != .collapsed {
                        withAnimation(.snappy(duration: 0.32)) {
                            drawerState = .collapsed
                        }
                    }
                },
                isPaletteActive: isActive,
                weeklyKmData: weeklyKmData,
                lastWeekKmData: lastWeekKmData,
                monthlyKmData: monthlyKmData,
                lastMonthKmData: lastMonthKmData,
                activityDetail: activityDetail,
                isLoadingDetail: isLoadingDetail,
                geocodedActivityCity: geocodedActivityCity
            )
        }
            }
    }

    private func showPaletteSelectorFor(widgetId: String) {
        paletteTargetWidgetId = widgetId
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            showPaletteSelector = true
        }
        resetPaletteHideTimer()
    }

    private func hidePaletteSelector() {
        paletteHideTask?.cancel()
        paletteHideTask = nil
        guard showPaletteSelector else { return }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            showPaletteSelector = false
        }
        paletteTargetWidgetId = nil
    }

    private func presentStatTapHint() {
        statTapHintTask?.cancel()
        statTapHintTask = nil

        if !showStatTapHint {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.84)) {
                showStatTapHint = true
            }
        }

        statTapHintTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.22)) {
                showStatTapHint = false
            }
            statTapHintTask = nil
        }
    }

    private func dismissStatTapHint() {
        statTapHintTask?.cancel()
        statTapHintTask = nil
        guard showStatTapHint else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            showStatTapHint = false
        }
    }

    private func resetPaletteHideTimer() {
        paletteHideTask?.cancel()
        paletteHideTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                showPaletteSelector = false
            }
            paletteTargetWidgetId = nil
        }
    }

    // MARK: - Top Bar

    private let topBarButtonBackground: some ShapeStyle = Color.black.opacity(0.45)
    private let topBarStroke: some ShapeStyle = Color.white.opacity(0.2)

    private var topBar: some View {
        HStack(spacing: 8) {
            if paletteTargetWidgetId == nil {
                Button { showAIAnimateOptions = true } label: {
                    Text("Self ai")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(
                            LinearGradient(
                                colors: [
                                    selfAiGlowColors[selfAiGlowColorIndex].opacity(0.85),
                                    selfAiGlowColors[(selfAiGlowColorIndex + 1) % selfAiGlowColors.count].opacity(0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: .capsule
                        )
                        .background(.black.opacity(0.5), in: .capsule)
                }
                .buttonStyle(.plain)
                .shadow(color: selfAiGlowColors[selfAiGlowColorIndex].opacity(0.45), radius: 10, x: 0, y: 0)
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 2)
                .animation(.easeInOut(duration: 1.8), value: selfAiGlowColorIndex)
                .confirmationDialog("Self ai", isPresented: $showAIAnimateOptions, titleVisibility: .visible) {
                    Button("Edit current image") {
                        if quotaService.hasImageQuota {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                                drawerState = .collapsed
                                showEditStyleDrawer = true
                            }
                        } else {
                            quotaPaywallKind = .image
                            showQuotaPaywall = true
                        }
                    }
                    Button("Generate video") {
                        showVideoComingSoon = true
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))

                Spacer(minLength: 4)

                if !activities.isEmpty {
                    Button {
                        hapticLight.impactOccurred()
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                            drawerState = .collapsed
                            showEditStyleDrawer = false
                            showActivitySwitcher = true
                        }
                    } label: {
                        Image(systemName: "arrow.2.circlepath")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(topBarButtonBackground, in: .capsule)
                            .overlay(Capsule().stroke(topBarStroke, lineWidth: 0.5))
                    }
                    .buttonStyle(.plain)
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 3)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }

                Button {
                    if locationService.cityName != nil {
                        showCityInfoAlert = true
                        return
                    }
                    locationService.requestLocationIfNeeded()
                    if locationService.permissionDenied {
                        showLocationDeniedAlert = true
                    }
                } label: {
                    ZStack {
                        if locationService.isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.65)
                        } else {
                            Image(systemName: locationService.cityName != nil ? "location.fill" : "location")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(locationService.cityName != nil ? .white : .white.opacity(0.7))
                        }
                    }
                    .frame(width: 36, height: 36)
                    .background(topBarButtonBackground, in: .capsule)
                    .overlay(Capsule().stroke(topBarStroke, lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 3)
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                selfAiGlowPhase = true
            }
            glowColorTask?.cancel()
            glowColorTask = Task { @MainActor in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(2))
                    guard !Task.isCancelled else { break }
                    withAnimation(.easeInOut(duration: 1.8)) {
                        selfAiGlowColorIndex = (selfAiGlowColorIndex + 1) % selfAiGlowColors.count
                    }
                }
            }
        }
        .onDisappear {
            glowColorTask?.cancel()
            glowColorTask = nil
        }
    }

    // MARK: - Filters (see EditorFiltersOverlay.swift)

    // MARK: - Bottom Section



    private var deleteDropZone: some View {
        deleteDropZoneContent
            .background(deleteZoneMeasurementView)
    }

    private var deleteDropZoneContent: some View {
        Image(systemName: "trash.fill")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(
                isOverDeleteZone
                    ? Color.red.opacity(0.85)
                    : Color.red.opacity(0.45),
                in: .capsule
            )
            .background(.ultraThinMaterial, in: .capsule)
            .overlay(
                Capsule().stroke(
                    isOverDeleteZone ? Color.red.opacity(0.9) : Color.red.opacity(0.3),
                    lineWidth: 1
                )
            )
            .scaleEffect(isOverDeleteZone ? 1.15 : 1.0)
            .shadow(color: isOverDeleteZone ? .red.opacity(0.5) : .black.opacity(0.3), radius: isOverDeleteZone ? 16 : 10, x: 0, y: 4)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: isOverDeleteZone)
            .sensoryFeedback(.success, trigger: didDeleteWidget)
            .padding(.bottom, 60)
    }

    private var deleteZoneMeasurementView: some View {
        GeometryReader { geo in
            let frame = geo.frame(in: .global)
            Color.clear
                .onAppear {
                    deleteZoneFrame = frame
                }
                .onChange(of: frame) { _, newValue in
                    deleteZoneFrame = newValue
                }
        }
    }

    private var collapsedDrawer: some View {
        Button {
            hapticMedium.impactOccurred()
            withAnimation(.snappy(duration: 0.18)) {
                drawerState = .open
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                Text("Add stats")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 22)
            .padding(.vertical, 11)
            .background(Color.white.opacity(0.12), in: .capsule)
            .background(.ultraThinMaterial, in: .capsule)
            .overlay(
                Capsule().stroke(.white.opacity(0.15), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
    }

    // MARK: - Drawer (see EditorDrawerView.swift)

    // MARK: - Share Bar

    private var bottomShareBar: some View {
        HStack(spacing: 8) {
            Button {
                hapticLight.impactOccurred()
                if hasUnsavedChanges {
                    showDiscardAlert = true
                } else {
                    onClose()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 53, height: 53)
                    .background(Color.white.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 17))
            }
            .buttonStyle(.plain)

            Button(action: shareToStory) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 17, weight: .semibold))
                    Text("IG Story")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundStyle(.white.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 53)
                .background(Color.white.opacity(0.12))
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 17))
                .overlay(
                    RoundedRectangle(cornerRadius: 17).stroke(.white.opacity(0.15), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)

            Button(action: saveToPhotos) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.to.line")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Save")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundStyle(.white.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 53)
                .background(Color.white.opacity(0.12))
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 17))
                .overlay(
                    RoundedRectangle(cornerRadius: 17).stroke(.white.opacity(0.15), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
    }

    // MARK: - Actions



    @State private var isNewTextEditing: Bool = false

    func startNewTextEditing() {
        let newText = PlacedText(text: "text", position: .zero)
        placedTexts.append(newText)
        editingTextId = newText.id
        editingTextContent = "text"
        editingTextStyle = .classic
        editingTextColor = .white
        isNewTextEditing = true
        withAnimation(.snappy(duration: 0.25)) {
            drawerState = .collapsed
        }
    }

    private func startEditingExistingText(_ textId: String) {
        guard let textWidget = placedTexts.first(where: { $0.id == textId }) else { return }
        editingTextId = textId
        editingTextContent = textWidget.text
        editingTextStyle = textWidget.styleType
        editingTextColor = textWidget.styleColor
        isNewTextEditing = false
        withAnimation(.snappy(duration: 0.25)) {
            drawerState = .collapsed
        }
    }

    private func commitTextEditing() {
        guard let editId = editingTextId else { return }
        let trimmed = editingTextContent.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                placedTexts.removeAll { $0.id == editId }
            }
        } else {
            if let index = placedTexts.firstIndex(where: { $0.id == editId }) {
                placedTexts[index].text = trimmed
                placedTexts[index].styleType = editingTextStyle
                placedTexts[index].styleColor = editingTextColor
            }
        }
        editingTextId = nil
        editingTextContent = ""
        isNewTextEditing = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func scheduleTextDeletion(_ textId: String) {
        guard !widgetsPendingRemoval.contains(textId) else { return }
        widgetsPendingRemoval.insert(textId)
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                placedTexts.removeAll { $0.id == textId }
            }
            widgetsPendingRemoval.remove(textId)
        }
    }

    private func scheduleWidgetDeletion(_ widgetId: String) {
        guard !widgetsPendingRemoval.contains(widgetId) else { return }

        widgetsPendingRemoval.insert(widgetId)

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                placedWidgets.removeAll { $0.id == widgetId }
            }
            widgetsPendingRemoval.remove(widgetId)
        }
    }

    func toggleWidget(_ type: StatWidgetType) {
        if let index = placedWidgets.firstIndex(where: { $0.type == type }) {
            placedWidgets.remove(at: index)
        } else {
            let offset = CGFloat(placedWidgets.count) * 20
            let initialScale: CGFloat = (type == .bold || type == .impact || type == .titleCard) ? 0.55 : 1.0
            var newWidget = PlacedWidget(type: type, position: CGSize(width: offset, height: offset))
            newWidget.scale = initialScale
            placedWidgets.append(newWidget)
            presentStatTapHint()
            if drawerState == .expanded {
                drawerState = .open
            }
            if type.requiresDetail && activityDetail == nil && !isLoadingDetail {
                fetchActivityDetailOnDemand()
            }
        }
    }

    private func fetchActivityDetailOnDemand() {
        guard let stravaId = Int(currentActivity.id) else { return }
        detailFetchTask?.cancel()
        detailFetchTask = Task {
            isLoadingDetail = true
            do {
                if let cached = try await detailService.fetchCachedDetail(stravaActivityId: stravaId) {
                    activityDetail = cached
                    isLoadingDetail = false
                    await geocodeCityIfNeeded(from: cached)
                    return
                }
                let detail = try await stravaService.fetchActivityDetail(id: stravaId)
                activityDetail = detail
                try? await detailService.upsertDetail(detail)
                await geocodeCityIfNeeded(from: detail)
            } catch {
                // keep nil — widgets show empty state
            }
            isLoadingDetail = false
        }
    }

    private func geocodeCityIfNeeded(from detail: StravaActivityDetail) async {
        if let city = detail.locationCity, !city.isEmpty {
            geocodedActivityCity = city
            return
        }
        guard let coords = detail.startLatlng, coords.count >= 2 else { return }
        let location = CLLocation(latitude: coords[0], longitude: coords[1])
        let geocoder = CLGeocoder()
        guard let placemarks = try? await geocoder.reverseGeocodeLocation(location),
              let city = placemarks.first?.locality ?? placemarks.first?.subAdministrativeArea else { return }
        geocodedActivityCity = city
    }

    func captureCanvas() async -> UIImage? {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return nil }

        UIView.setAnimationsEnabled(false)
        isCapturingCanvas = true
        try? await Task.sleep(for: .milliseconds(50))

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            isCapturingCanvas = false
            UIView.setAnimationsEnabled(true)
            return nil
        }

        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let fullImage = renderer.image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }

        isCapturingCanvas = false
        UIView.setAnimationsEnabled(true)

        let imageScale = fullImage.scale
        let cropRect = CGRect(
            x: canvasGlobalOrigin.x * imageScale,
            y: canvasGlobalOrigin.y * imageScale,
            width: canvasSize.width * imageScale,
            height: canvasSize.height * imageScale
        )

        guard let cgCropped = fullImage.cgImage?.cropping(to: cropRect) else { return nil }
        let cropped = UIImage(cgImage: cgCropped, scale: imageScale, orientation: .up)

        let targetScale = max(1080 / canvasSize.width, 1920 / canvasSize.height)
        let targetSize = CGSize(width: canvasSize.width * targetScale, height: canvasSize.height * targetScale)

        let upscaleRenderer = UIGraphicsImageRenderer(size: targetSize)
        return upscaleRenderer.image { _ in
            cropped.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    private func trackWidgetUsage() {
        let types = placedWidgets.map(\.type.rawValue)
        guard !types.isEmpty else { return }
        Task {
            await widgetPopularityService.trackWidgetUsage(widgetTypes: types)
            widgetPopularityMap = await widgetPopularityService.fetchPopularity()
            userRecentsMap = await widgetPopularityService.fetchUserRecents()
        }
    }

    private func shareToStory() {
        Task {
            let facebookAppID = "1722813128328059"
            guard let instagramURL = URL(string: "instagram-stories://share?source_application=\(facebookAppID)"),
                  UIApplication.shared.canOpenURL(instagramURL) else {
                showInstagramAlert = true
                return
            }

            guard let image = await captureCanvas(),
                  let imageData = image.pngData() else { return }

            trackWidgetUsage()

            let pasteboardItems: [[String: Any]] = [
                [
                    "com.instagram.sharedSticker.backgroundImage": imageData
                ]
            ]
            let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
                .expirationDate: Date().addingTimeInterval(300)
            ]
            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)

            await UIApplication.shared.open(instagramURL)
        }
    }

    private func saveToPhotos() {
        Task {
            guard let image = await captureCanvas() else { return }
            trackWidgetUsage()
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            HapticService.notification.notificationOccurred(.success)
            showSavedAlert = true
        }
    }

}

