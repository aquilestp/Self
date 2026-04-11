import SwiftUI
import UIKit

struct PhotoEditorView: View {
    let activity: ActivityHighlight
    let photo: UIImage
    let onClose: () -> Void

    @State private var filterMode: FilterMode = .none
    @State private var cityFilterIndex: Int = 0
    @State private var raceFilterIndex: Int = 0
    @State private var placedWidgets: [PlacedWidget] = []
    @State private var placedTexts: [PlacedText] = []
    @State private var editingTextId: String? = nil
    @State private var editingTextContent: String = ""
    @State private var editingTextStyle: TextStyleType = .classic
    @State private var editingTextColor: Color = .white
    @State private var keyboardHeight: CGFloat = 0

    @State private var canvasSize: CGSize = .zero
    @State private var canvasGlobalOrigin: CGPoint = .zero
    @State var drawerState: DrawerState = .collapsed
    @State private var showInstagramAlert: Bool = false
    @State private var drawerDragOffset: CGFloat = 0
    @State private var locationService = LocationService()
    @State private var showLocationDeniedAlert: Bool = false
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
    @State var showEditStyleDrawer: Bool = false
    @State var selectedEditStyle: AIEditStyle? = nil
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
    @State var includeStatsOverlay: Bool = true
    @State private var dynamicCityFilters: [CityFilterRow] = []
    @State private var isLoadingCityFilters: Bool = false
    @State private var filterSwipeDirection: Edge = .trailing
    @State var weeklyKmData: WeeklyKmData = .empty
    @State var lastWeekKmData: WeeklyKmData = .empty
    @State var monthlyKmData: MonthlyKmData = .empty
    @State var lastMonthKmData: MonthlyKmData = .empty
    @State private var activityDetail: StravaActivityDetail? = nil
    @State private var isLoadingDetail: Bool = false
    @State private var detailFetchTask: Task<Void, Never>? = nil
    @State private var showWhatsappTextEdit: Bool = false
    @State private var whatsappEditingText: String = ""
    let grokService = GrokImageEditService()
    private let cityFilterService = CityFilterService()
    private let weeklyKmService = WeeklyKmService()
    private let monthlyKmService = MonthlyKmService()
    private let detailService = SupabaseActivityDetailService()
    private let stravaService = StravaService()

    var currentPhoto: UIImage {
        aiEditedPhoto ?? photo
    }

    var photoBeforeAIEdit: UIImage {
        photo
    }

    private let fallbackCityFilters = CityFilter.allCases
    private let raceFilters = RaceFilter.allCases

    private var hasDynamicCityFilters: Bool {
        !dynamicCityFilters.isEmpty
    }

    private var cityFilterCount: Int {
        hasDynamicCityFilters ? dynamicCityFilters.count + 1 : fallbackCityFilters.count
    }

    private var isNoFilterPosition: Bool {
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

                        if drawerState == .collapsed && !isDraggingWidget && !isPhotoGesturing {
                            collapsedDrawer
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                .padding(.bottom, 12)
                                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                                .zIndex(5)
                        }

                        AlignmentGuidesOverlay(
                            canvasSize: geo.size,
                            activeGuides: alignmentGuideState.activeGuides
                        )
                        .allowsHitTesting(false)
                        .zIndex(3.5)
                        .sensoryFeedback(.impact(weight: .medium), trigger: alignmentGuideState.snapHapticTrigger)
                        .sensoryFeedback(.impact(weight: .light), trigger: alignmentGuideState.crossingHapticTrigger)

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



                        if !isDraggingWidget && !isPhotoGesturing && !isTextEditing && paletteTargetWidgetId == nil {
                            addTextButton
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                                .padding(.trailing, 12)
                                .transition(.identity)
                                .zIndex(5.5)
                        }


                        if filterMode != .none || hasDynamicCityFilters {
                            filterDots
                                .frame(maxHeight: .infinity, alignment: .bottom)
                                .padding(.bottom, drawerState == .collapsed ? 140 : drawerState == .open ? 280 : 140)
                        }
                    }
                    .clipShape(.rect(cornerRadius: 55))
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
                    .contentShape(.rect(cornerRadius: 55))
                    .gesture(
                        DragGesture(minimumDistance: 30, coordinateSpace: .local)
                            .onEnded { value in
                                guard !isDraggingWidget, !isPhotoGesturing, !isTextEditing, !photoSessionActive else { return }
                                guard filterMode != .none || hasDynamicCityFilters else { return }
                                let horizontal = value.translation.width
                                let vertical = abs(value.translation.height)
                                guard abs(horizontal) > vertical else { return }
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
            .ignoresSafeArea()

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
                                .padding(.top, 1)
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
            .opacity(isPhotoGesturing || isDraggingWidget || isTextEditing ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: isPhotoGesturing || isDraggingWidget || isTextEditing)

            if showPaletteSelector && !isDraggingWidget && !isPhotoGesturing && !isTextEditing {
                paletteSelectorView
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .padding(.trailing, 12)
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
        .statusBarHidden()
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
            weeklyKmData = await weeklyKmService.fetchWeeklyKm()
            lastWeekKmData = await weeklyKmService.fetchLastWeekKm()
            monthlyKmData = await monthlyKmService.fetchMonthlyKm()
            lastMonthKmData = await monthlyKmService.fetchLastMonthKm()
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
        .alert("Edit Message", isPresented: $showWhatsappTextEdit) {
            TextField("Message", text: $whatsappEditingText)
            Button("Save") {
                guard let id = paletteTargetWidgetId,
                      let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                let trimmed = whatsappEditingText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    placedWidgets[idx].whatsappText = trimmed
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Type your WhatsApp message")
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
        if isBackgroundExposed && !isPhotoGesturing && !isDraggingWidget {
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
        canvasBackgroundColor != .black
    }

    var hasCanvasContent: Bool {
        !placedWidgets.isEmpty || !placedTexts.isEmpty || filterMode != .none
    }

    // MARK: - Add Text Button

    private var addTextButton: some View {
        Button {
            hapticLight.impactOccurred()
            if drawerState != .collapsed {
                withAnimation(.snappy(duration: 0.25)) {
                    drawerState = .collapsed
                }
            }
            startNewTextEditing()
        } label: {
            Image(systemName: "textformat")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Color.black.opacity(0.45), in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 3)
    }

    // MARK: - Palette Selector

    private var paletteSelectorView: some View {
        let targetWidget: PlacedWidget? = {
            guard let id = paletteTargetWidgetId else { return nil }
            return placedWidgets.first(where: { $0.id == id })
        }()
        let targetPalette = targetWidget?.colorStyle.palette ?? .classic
        let targetSupportsGlass = targetWidget?.type.supportsGlass ?? false
        let targetGlassEnabled = targetWidget?.useGlassBackground ?? false
        let targetIsBestEfforts = targetWidget?.type == .bestEfforts
        let targetEffortsFilter = targetWidget?.bestEffortsFilter ?? .km
        let targetIsSplits = targetWidget?.type == .splits || targetWidget?.type == .splitsTable || targetWidget?.type == .splitsFastest || targetWidget?.type == .splitsBars
        let targetSplitsFilter = targetWidget?.splitsFilter ?? .km
        let targetIsDistanceWords = targetWidget?.type.isDistanceWords ?? false
        let targetDistanceWordsFilter = targetWidget?.distanceWordsFilter ?? .km
        let targetSupportsFontStyle = targetWidget?.type.supportsFontStyle ?? false
        let targetFontStyle = targetWidget?.fontStyle ?? .system
        let targetSupportsBasicFieldVisibility = targetWidget?.type.supportsBasicFieldVisibility ?? false
        let targetBasicUnitFilter = targetWidget?.basicUnitFilter ?? .km
        let targetIsBoldOrImpact = targetWidget?.type == .bold || targetWidget?.type == .impact
        let targetIsHeroStat = targetWidget?.type == .heroStat
        let targetIsFullBanner = targetWidget?.type == .fullBanner || targetWidget?.type == .fullBannerBottom
        let targetShowTitle = targetWidget?.showTitle ?? true
        let targetShowActivityName = targetWidget?.showActivityName ?? true
        let targetShowDate = targetWidget?.showDate ?? true
        let targetShowDistance = targetWidget?.showDistance ?? true
        let targetShowPace = targetWidget?.showPace ?? true
        let targetShowTime = targetWidget?.showTime ?? true
        let targetShowElevation = targetWidget?.showElevation ?? true
        let targetFullBannerUnit = targetWidget?.fullBannerUnitFilter ?? .km
        let targetFBShowDistance = targetWidget?.fullBannerShowDistance ?? true
        let targetFBShowPace = targetWidget?.fullBannerShowPace ?? true
        let targetFBShowTime = targetWidget?.fullBannerShowTime ?? true
        let targetFBShowElevation = targetWidget?.fullBannerShowElevation ?? true
        let targetIsBVT = targetWidget?.type == .blurredVerticalText
        let targetBvtShowDate = targetWidget?.bvtShowDate ?? true
        let targetBvtShowTime = targetWidget?.bvtShowTime ?? true
        let targetBvtShowLocation = targetWidget?.bvtShowLocation ?? true
        let targetBvtShowDistance = targetWidget?.bvtShowDistance ?? true
        let targetBvtShowPace = targetWidget?.bvtShowPace ?? true
        let targetBvtShowDuration = targetWidget?.bvtShowDuration ?? true
        let targetBvtShowElevation = targetWidget?.bvtShowElevation ?? true
        let targetBvtShowCalories = targetWidget?.bvtShowCalories ?? true
        let targetBvtShowBPM = targetWidget?.bvtShowBPM ?? true
        let targetBvtUnitFilter = targetWidget?.bvtUnitFilter ?? .km
        let targetBvtEffect = targetWidget?.bvtEffect ?? .blur
        let targetIsWhatsapp = targetWidget?.type == .whatsappMessage
        let fontPreviewText = targetWidget.map { w in
            w.type == .distanceWords ? "five" : (activity.hasDistance ? activity.primaryStat : activity.duration)
        } ?? "5:30"
        let fontPreviewLabel = String(fontPreviewText.prefix(4)).uppercased()

        let paletteCount = WidgetPalette.allCases.count

        return VStack(spacing: 8) {
          if !targetIsWhatsapp {
            ForEach(Array(WidgetPalette.allCases.enumerated()), id: \.element.id) { index, palette in
                let isActive = targetPalette == palette
                Button {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].colorStyle.setPalette(palette)
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                } label: {
                    ZStack {
                        let previewColors = palette.previewColors
                        ForEach(Array(previewColors.enumerated()), id: \.offset) { i, color in
                            Circle()
                                .fill(color)
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(Color.black.opacity(0.25), lineWidth: 0.5))
                                .offset(
                                    x: i == 0 ? -6 : i == 1 ? 6 : 0,
                                    y: i == 0 ? -4 : i == 1 ? -4 : 6
                                )
                        }
                    }
                    .frame(width: 36, height: 36)
                    .background(isActive ? Color.white.opacity(0.25) : Color.black.opacity(0.45), in: Circle())
                    .overlay(
                        Circle().stroke(
                            isActive ? Color.white.opacity(0.6) : Color.white.opacity(0.15),
                            lineWidth: isActive ? 1.5 : 0.5
                        )
                    )
                }
                .buttonStyle(.plain)
                .scaleEffect(showPaletteSelector ? 1 : 0.3)
                .opacity(showPaletteSelector ? 1 : 0)
                .animation(
                    .spring(response: 0.35, dampingFraction: 0.7).delay(Double(index) * 0.04),
                    value: showPaletteSelector
                )
            }
          }

            if targetSupportsGlass && !targetIsWhatsapp {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04),
                        value: showPaletteSelector
                    )

                Button {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].useGlassBackground.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                } label: {
                    Image(systemName: targetGlassEnabled ? "square.fill.on.square.fill" : "square.dashed")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(targetGlassEnabled ? .white.opacity(0.9) : .white.opacity(0.5))
                        .frame(width: 36, height: 36)
                        .background(targetGlassEnabled ? Color.white.opacity(0.25) : Color.black.opacity(0.45), in: Circle())
                        .overlay(
                            Circle().stroke(
                                targetGlassEnabled ? Color.white.opacity(0.6) : Color.white.opacity(0.15),
                                lineWidth: targetGlassEnabled ? 1.5 : 0.5
                            )
                        )
                }
                .buttonStyle(.plain)
                .scaleEffect(showPaletteSelector ? 1 : 0.3)
                .opacity(showPaletteSelector ? 1 : 0)
                .animation(
                    .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.02),
                    value: showPaletteSelector
                )
            }

            if targetIsBestEfforts {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.04),
                        value: showPaletteSelector
                    )

                ForEach(Array(BestEffortsUnitFilter.allCases.enumerated()), id: \.element.id) { filterIdx, filter in
                    let isFilterActive = targetEffortsFilter == filter
                    Button {
                        guard let id = paletteTargetWidgetId,
                              let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            placedWidgets[idx].bestEffortsFilter = filter
                        }
                        hapticLight.impactOccurred()
                        resetPaletteHideTimer()
                    } label: {
                        Text(filter.label)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(isFilterActive ? .white.opacity(0.9) : .white.opacity(0.5))
                            .frame(width: 36, height: 36)
                            .background(isFilterActive ? Color.white.opacity(0.25) : Color.black.opacity(0.45), in: Circle())
                            .overlay(
                                Circle().stroke(
                                    isFilterActive ? Color.white.opacity(0.6) : Color.white.opacity(0.15),
                                    lineWidth: isFilterActive ? 1.5 : 0.5
                                )
                            )
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.06 + Double(filterIdx) * 0.03),
                        value: showPaletteSelector
                    )
                }
            }

            if targetIsSplits {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.04),
                        value: showPaletteSelector
                    )

                unitToggleButton(currentFilter: targetSplitsFilter, delay: Double(paletteCount) * 0.04 + 0.06) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].splitsFilter = placedWidgets[idx].splitsFilter == .km ? .miles : .km
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }
            }

            if targetIsDistanceWords {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.04),
                        value: showPaletteSelector
                    )

                unitToggleButton(currentFilter: targetDistanceWordsFilter, delay: Double(paletteCount) * 0.04 + 0.06) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].distanceWordsFilter = placedWidgets[idx].distanceWordsFilter == .km ? .miles : .km
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }
            }

            if targetSupportsBasicFieldVisibility {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.04),
                        value: showPaletteSelector
                    )

                visibilityToggleButton(icon: "textformat", isOn: targetShowActivityName, delay: Double(paletteCount) * 0.04 + 0.06) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].showActivityName.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "calendar", isOn: targetShowDate, delay: Double(paletteCount) * 0.04 + 0.09) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].showDate.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "ruler", isOn: targetShowDistance, delay: Double(paletteCount) * 0.04 + 0.12) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].showDistance.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "speedometer", isOn: targetShowPace, delay: Double(paletteCount) * 0.04 + 0.15) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].showPace.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "clock", isOn: targetShowTime, delay: Double(paletteCount) * 0.04 + 0.18) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].showTime.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                basicUnitFilterSection(currentFilter: targetBasicUnitFilter, paletteCount: paletteCount)
            }

            if targetIsBoldOrImpact {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.04),
                        value: showPaletteSelector
                    )

                visibilityToggleButton(icon: "textformat", isOn: targetShowTitle, delay: Double(paletteCount) * 0.04 + 0.06) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].showTitle.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "speedometer", isOn: targetShowPace, delay: Double(paletteCount) * 0.04 + 0.09) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].showPace.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "clock", isOn: targetShowTime, delay: Double(paletteCount) * 0.04 + 0.12) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].showTime.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "mountain.2", isOn: targetShowElevation, delay: Double(paletteCount) * 0.04 + 0.15) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].showElevation.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }
            }

            if targetIsHeroStat {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.04),
                        value: showPaletteSelector
                    )

                visibilityToggleButton(icon: "speedometer", isOn: targetShowPace, delay: Double(paletteCount) * 0.04 + 0.06) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].showPace.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "clock", isOn: targetShowTime, delay: Double(paletteCount) * 0.04 + 0.09) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].showTime.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }
            }

            if targetIsFullBanner {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.04),
                        value: showPaletteSelector
                    )

                unitToggleButton(currentFilter: targetFullBannerUnit, delay: Double(paletteCount) * 0.04 + 0.06) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].fullBannerUnitFilter = placedWidgets[idx].fullBannerUnitFilter == .km ? .miles : .km
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.12),
                        value: showPaletteSelector
                    )

                visibilityToggleButton(icon: "clock", isOn: targetFBShowTime, delay: Double(paletteCount) * 0.04 + 0.14) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].fullBannerShowTime.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "ruler", isOn: targetFBShowDistance, delay: Double(paletteCount) * 0.04 + 0.17) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].fullBannerShowDistance.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "speedometer", isOn: targetFBShowPace, delay: Double(paletteCount) * 0.04 + 0.20) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].fullBannerShowPace.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "mountain.2", isOn: targetFBShowElevation, delay: Double(paletteCount) * 0.04 + 0.23) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].fullBannerShowElevation.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }
            }

            if targetIsBVT {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.04),
                        value: showPaletteSelector
                    )

                bvtEffectButton(effect: targetBvtEffect, delay: Double(paletteCount) * 0.04 + 0.06) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].bvtEffect = placedWidgets[idx].bvtEffect.next()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                unitToggleButton(currentFilter: targetBvtUnitFilter, delay: Double(paletteCount) * 0.04 + 0.09) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].bvtUnitFilter = placedWidgets[idx].bvtUnitFilter == .km ? .miles : .km
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "calendar", isOn: targetBvtShowDate, delay: Double(paletteCount) * 0.04 + 0.09) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].bvtShowDate.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "clock", isOn: targetBvtShowTime, delay: Double(paletteCount) * 0.04 + 0.12) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].bvtShowTime.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "location", isOn: targetBvtShowLocation, delay: Double(paletteCount) * 0.04 + 0.15) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].bvtShowLocation.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "ruler", isOn: targetBvtShowDistance, delay: Double(paletteCount) * 0.04 + 0.18) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].bvtShowDistance.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "speedometer", isOn: targetBvtShowPace, delay: Double(paletteCount) * 0.04 + 0.21) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].bvtShowPace.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "timer", isOn: targetBvtShowDuration, delay: Double(paletteCount) * 0.04 + 0.24) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].bvtShowDuration.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "mountain.2", isOn: targetBvtShowElevation, delay: Double(paletteCount) * 0.04 + 0.27) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].bvtShowElevation.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "flame", isOn: targetBvtShowCalories, delay: Double(paletteCount) * 0.04 + 0.30) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].bvtShowCalories.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }

                visibilityToggleButton(icon: "heart.fill", isOn: targetBvtShowBPM, delay: Double(paletteCount) * 0.04 + 0.33) {
                    guard let id = paletteTargetWidgetId,
                          let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        placedWidgets[idx].bvtShowBPM.toggle()
                    }
                    hapticLight.impactOccurred()
                    resetPaletteHideTimer()
                }
            }

            if targetIsWhatsapp {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.04),
                        value: showPaletteSelector
                    )

                Button {
                    guard let id = paletteTargetWidgetId,
                          let widget = placedWidgets.first(where: { $0.id == id }) else { return }
                    whatsappEditingText = widget.whatsappText
                    showWhatsappTextEdit = true
                    resetPaletteHideTimer()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 36, height: 36)
                        .background(Color(red: 0.00, green: 0.37, blue: 0.33), in: Circle())
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        )
                }
                .buttonStyle(.plain)
                .scaleEffect(showPaletteSelector ? 1 : 0.3)
                .opacity(showPaletteSelector ? 1 : 0)
                .animation(
                    .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.06),
                    value: showPaletteSelector
                )
            }

            if targetSupportsFontStyle {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 1)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.08),
                        value: showPaletteSelector
                    )

                ForEach(Array(WidgetFontStyle.allCases.enumerated()), id: \.element.id) { fontIdx, style in
                    let isFontActive = targetFontStyle == style
                    Button {
                        guard let id = paletteTargetWidgetId,
                              let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            placedWidgets[idx].fontStyle = style
                        }
                        hapticLight.impactOccurred()
                        resetPaletteHideTimer()
                    } label: {
                        fontStyleButtonLabel(text: fontPreviewLabel, style: style, isActive: isFontActive)
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(showPaletteSelector ? 1 : 0.3)
                    .opacity(showPaletteSelector ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.10 + Double(fontIdx) * 0.03),
                        value: showPaletteSelector
                    )
                }
            }
        }
        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
    }

    private func statWidgetsLayer(canvasSize: CGSize) -> some View {
        Color.clear
            .allowsHitTesting(false)
            .overlay {
                ForEach($placedWidgets) { $widget in
            let isActive = paletteTargetWidgetId == widget.id && showPaletteSelector
            DraggableStatWidget(
                widget: $widget,
                activity: activity,
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
                isLoadingDetail: isLoadingDetail
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

    @ViewBuilder
    private func basicUnitFilterSection(currentFilter: SplitsUnitFilter, paletteCount: Int) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(width: 20, height: 1)
            .scaleEffect(showPaletteSelector ? 1 : 0.3)
            .opacity(showPaletteSelector ? 1 : 0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.7).delay(Double(paletteCount) * 0.04 + 0.20),
                value: showPaletteSelector
            )

        unitToggleButton(currentFilter: currentFilter, delay: Double(paletteCount) * 0.04 + 0.22) {
            guard let id = paletteTargetWidgetId,
                  let idx = placedWidgets.firstIndex(where: { $0.id == id }) else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                placedWidgets[idx].basicUnitFilter = placedWidgets[idx].basicUnitFilter == .km ? .miles : .km
            }
            hapticLight.impactOccurred()
            resetPaletteHideTimer()
        }
    }

    private func unitToggleButton(currentFilter: SplitsUnitFilter, delay: Double, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(currentFilter.label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))
                .contentTransition(.numericText())
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.25), in: Circle())
                .overlay(
                    Circle().stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(showPaletteSelector ? 1 : 0.3)
        .opacity(showPaletteSelector ? 1 : 0)
        .animation(
            .spring(response: 0.35, dampingFraction: 0.7).delay(delay),
            value: showPaletteSelector
        )
    }

    private func visibilityToggleButton(icon: String, isOn: Bool, delay: Double, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Image(systemName: isOn ? icon : icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isOn ? .white.opacity(0.9) : .white.opacity(0.3))
                if !isOn {
                    Rectangle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 22, height: 1.5)
                        .rotationEffect(.degrees(-45))
                }
            }
            .frame(width: 36, height: 36)
            .background(isOn ? Color.white.opacity(0.25) : Color.black.opacity(0.45), in: Circle())
            .overlay(
                Circle().stroke(
                    isOn ? Color.white.opacity(0.6) : Color.white.opacity(0.15),
                    lineWidth: isOn ? 1.5 : 0.5
                )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(showPaletteSelector ? 1 : 0.3)
        .opacity(showPaletteSelector ? 1 : 0)
        .animation(
            .spring(response: 0.35, dampingFraction: 0.7).delay(delay),
            value: showPaletteSelector
        )
    }

    private func bvtEffectButton(effect: BVTEffect, delay: Double, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: effect.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.25), in: Circle())
                .overlay(
                    Circle().stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(showPaletteSelector ? 1 : 0.3)
        .opacity(showPaletteSelector ? 1 : 0)
        .animation(
            .spring(response: 0.35, dampingFraction: 0.7).delay(delay),
            value: showPaletteSelector
        )
    }

    private func fontStyleButtonLabel(text: String, style: WidgetFontStyle, isActive: Bool) -> some View {
        let foregroundColor: Color = isActive ? .white.opacity(0.95) : .white.opacity(0.5)
        let backgroundColor: Color = isActive ? .white.opacity(0.25) : .black.opacity(0.45)
        let strokeColor: Color = isActive ? .white.opacity(0.6) : .white.opacity(0.15)
        let strokeWidth: CGFloat = isActive ? 1.5 : 0.5

        return Text(text)
            .font(style.font(size: 13))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(foregroundColor)
            .frame(width: 40, height: 48)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            )
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
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .medium))
                            .symbolEffect(.pulse.wholeSymbol, options: .repeating.speed(0.6), value: selfAiGlowPhase)
                        Text("Self ai")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        in: .capsule
                    )
                    .background(.black.opacity(0.7), in: .capsule)

                }
                .buttonStyle(.plain)
                .background(
                    Capsule()
                        .fill(selfAiGlowColors[selfAiGlowColorIndex].opacity(selfAiGlowPhase ? 0.7 : 0.0))
                        .blur(radius: selfAiGlowPhase ? 22 : 12)
                        .scaleEffect(selfAiGlowPhase ? 1.3 : 1.0)
                )
                .background(
                    Capsule()
                        .fill(selfAiGlowColors[(selfAiGlowColorIndex + 1) % selfAiGlowColors.count].opacity(selfAiGlowPhase ? 0.2 : 0.0))
                        .blur(radius: selfAiGlowPhase ? 28 : 14)
                        .scaleEffect(selfAiGlowPhase ? 1.4 : 1.0)
                )
                .shadow(color: selfAiGlowColors[selfAiGlowColorIndex].opacity(selfAiGlowPhase ? 0.6 : 0.05), radius: selfAiGlowPhase ? 20 : 4, x: 0, y: 0)
                .shadow(color: selfAiGlowColors[(selfAiGlowColorIndex + 1) % selfAiGlowColors.count].opacity(selfAiGlowPhase ? 0.15 : 0.0), radius: selfAiGlowPhase ? 24 : 6, x: 0, y: 0)
                .shadow(color: .black.opacity(selfAiGlowPhase ? 0.1 : 0.4), radius: selfAiGlowPhase ? 4 : 10, x: 0, y: selfAiGlowPhase ? 1 : 3)
                .animation(.easeInOut(duration: 1.8), value: selfAiGlowColorIndex)
                .confirmationDialog("Self ai", isPresented: $showAIAnimateOptions, titleVisibility: .visible) {
                    Button("Edit current image") {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                            drawerState = .collapsed
                            showEditStyleDrawer = true
                        }
                    }
                    Button("Generate video") {
                        startVideoGeneration()
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))

                Spacer(minLength: 4)

                Button {
                    if locationService.cityName != nil {
                        return
                    }
                    locationService.requestLocationIfNeeded()
                    if locationService.permissionDenied {
                        showLocationDeniedAlert = true
                    }
                } label: {
                    HStack(spacing: 5) {
                        if locationService.isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.65)
                        } else {
                            Image(systemName: locationService.cityName != nil ? "location.fill" : "mappin.and.ellipse")
                                .font(.system(size: 11, weight: .medium))
                        }
                        Text(locationService.cityName ?? "Location")
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(topBarButtonBackground, in: .capsule)
                    .overlay(Capsule().stroke(topBarStroke, lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 3)
                .frame(maxWidth: locationService.cityName != nil ? 160 : nil)
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

    // MARK: - Filter Toggles

    private var filterToggles: some View {
        HStack(spacing: 8) {
            filterToggleButton(label: locationService.cityName ?? "City", icon: "building.2.fill", mode: .city)
        }
        .padding(.horizontal, 14)
    }

    private func filterToggleButton(label: String, icon: String, mode: FilterMode) -> some View {
        let isActive = filterMode == mode
        return Button {
            withAnimation(.snappy(duration: 0.3)) {
                if filterMode == mode {
                    filterMode = .none
                } else {
                    filterMode = mode
                    if mode == .city { cityFilterIndex = 0 }
                    if mode == .races { raceFilterIndex = 0 }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(isActive ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .frame(height: 36)
            .background(
                isActive
                    ? AnyShapeStyle(Color.white.opacity(0.22))
                    : AnyShapeStyle(Color.white.opacity(0.08)),
                in: .capsule
            )
            .background(.ultraThinMaterial, in: .capsule)
            .overlay(
                Capsule()
                    .stroke(isActive ? Color.white.opacity(0.35) : Color.white.opacity(0.1), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isActive)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)
    }

    // MARK: - Filter Overlay

    @ViewBuilder
    private func activeFilterOverlay(size: CGSize) -> some View {
        switch filterMode {
        case .none:
            EmptyView()
        case .city:
            Group {
                if hasDynamicCityFilters {
                    if cityFilterIndex < dynamicCityFilters.count {
                        DynamicCityOverlay(
                            size: size,
                            overlayURL: dynamicCityFilters[cityFilterIndex].overlayURL
                        )
                    } else {
                        EmptyView()
                    }
                } else {
                    let filter = fallbackCityFilters[cityFilterIndex]
                    switch filter {
                    case .none: EmptyView()
                    case .skyline: CityOverlay_Skyline(size: size)
                    case .postcard: CityOverlay_Postcard(size: size, activity: activity)
                    case .neon: CityOverlay_Neon(size: size, activity: activity)
                    case .stamp: CityOverlay_Stamp(size: size, activity: activity)
                    case .gps: CityOverlay_GPS(size: size, activity: activity)
                    }
                }
            }
        case .races:
            let filter = raceFilters[raceFilterIndex]
            Group {
                switch filter {
                case .none: EmptyView()
                case .bibNumber: RaceOverlay_Bib(size: size)
                case .finisher: RaceOverlay_Finisher(size: size, activity: activity)
                case .medal: RaceOverlay_Medal(size: size, activity: activity)
                case .raceRoute: RaceOverlay_Route(size: size, activity: activity)
                case .racePoster: RaceOverlay_Poster(size: size, activity: activity)
                }
            }
        }
    }

    private var filterOverlayId: String {
        switch filterMode {
        case .none: return "filter_none"
        case .city: return "filter_city_\(cityFilterIndex)"
        case .races: return "filter_race_\(raceFilterIndex)"
        }
    }

    // MARK: - Filter Dots

    private var filterDots: some View {
        let count: Int
        let currentIndex: Int

        switch filterMode {
        case .none:
            if hasDynamicCityFilters {
                count = cityFilterCount
                currentIndex = cityFilterIndex
            } else {
                count = 0
                currentIndex = 0
            }
        case .city:
            count = cityFilterCount
            currentIndex = cityFilterIndex
        case .races:
            count = raceFilters.count
            currentIndex = raceFilterIndex
        }

        return HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.white : Color.white.opacity(0.35))
                    .frame(width: index == currentIndex ? 8 : 6, height: index == currentIndex ? 8 : 6)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.3)) {
                            setFilterIndex(index)
                        }
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.black.opacity(0.3), in: .capsule)
        .background(.ultraThinMaterial.opacity(0.5), in: .capsule)
    }

    private func advanceFilter(by delta: Int) {
        switch filterMode {
        case .none:
            if hasDynamicCityFilters {
                guard !dynamicCityFilters.isEmpty else { return }
                if delta > 0 {
                    cityFilterIndex = 0
                } else {
                    cityFilterIndex = dynamicCityFilters.count - 1
                }
                filterMode = .city
            }
        case .city:
            let total = cityFilterCount
            guard total > 0 else { return }
            cityFilterIndex = ((cityFilterIndex + delta) % total + total) % total
        case .races:
            let newIndex = raceFilterIndex + delta
            if newIndex >= 0 && newIndex < raceFilters.count {
                raceFilterIndex = newIndex
            }
        }
    }

    private func setFilterIndex(_ index: Int) {
        switch filterMode {
        case .none:
            if hasDynamicCityFilters {
                cityFilterIndex = index
                filterMode = .city
            }
        case .city: cityFilterIndex = index
        case .races: raceFilterIndex = index
        }
    }

    private func loadDynamicCityFilters(lat: Double, lng: Double) async {
        isLoadingCityFilters = true
        do {
            let filters = try await cityFilterService.fetchNearbyFilters(latitude: lat, longitude: lng)
            dynamicCityFilters = filters
            if !filters.isEmpty {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    filterSwipeDirection = .trailing
                    filterMode = .city
                    cityFilterIndex = 0
                }
            }
        } catch {
            print("[CityFilters] Error loading filters: \(error)")
            dynamicCityFilters = []
        }
        isLoadingCityFilters = false
    }

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

    private var expandedDrawer: some View {
        GeometryReader { geo in
            let isExpanded = drawerState == .expanded
            let drawerHeight = isExpanded ? geo.size.height * 0.75 : 0

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 0) {
                    Capsule()
                        .fill(.white.opacity(0.35))
                        .frame(width: 36, height: 4)
                        .padding(.top, 10)
                        .padding(.bottom, 6)



                    if isExpanded {
                        expandedGrid
                            .transition(.opacity)
                    } else {
                        compactStatsList
                            .transition(.opacity)
                    }
                }
                .frame(height: isExpanded ? drawerHeight : nil)
                .background(.black.opacity(0.55))
                .background(.ultraThinMaterial)
                .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
                .contentShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
                .onTapGesture {
                    if drawerState == .open {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                            drawerState = .expanded
                        }
                    }
                }
                .offset(y: drawerDragOffset)
                .gesture(drawerDragGesture)
            }
        }
    }

    private var activeWidgetTypes: Set<StatWidgetType> {
        Set(placedWidgets.map(\.type))
    }

    private var gridStatTypes: [StatWidgetType] {
        StatWidgetType.allCases.filter { $0 != .fullBanner && $0 != .fullBannerBottom }
    }

    private var compactStatsList: some View {
        let activeTypes = activeWidgetTypes
        let types = gridStatTypes
        return VStack(spacing: 10) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                spacing: 10
            ) {
                ForEach(Array(types.prefix(6))) { type in
                    widgetThumbnail(type: type, isActive: activeTypes.contains(type), large: true)
                }
            }
            .padding(.horizontal, 14)

            fullWidthThumbnail(type: .fullBanner, isActive: activeTypes.contains(.fullBanner))
                .padding(.horizontal, 14)

            fullWidthThumbnail(type: .fullBannerBottom, isActive: activeTypes.contains(.fullBannerBottom))
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
        }
        .frame(maxHeight: 262, alignment: .top)
        .clipped()
    }

    private var expandedGrid: some View {
        let activeTypes = activeWidgetTypes
        let types = gridStatTypes
        let firstTwo = Array(types.prefix(6))
        let rest = Array(types.dropFirst(6))
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                    spacing: 10
                ) {
                    ForEach(firstTwo) { type in
                        widgetThumbnail(type: type, isActive: activeTypes.contains(type), large: true)
                    }
                }

                fullWidthThumbnail(type: .fullBanner, isActive: activeTypes.contains(.fullBanner))

                fullWidthThumbnail(type: .fullBannerBottom, isActive: activeTypes.contains(.fullBannerBottom))

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                    spacing: 10
                ) {
                    ForEach(rest) { type in
                        widgetThumbnail(type: type, isActive: activeTypes.contains(type), large: true)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 20)
        }
    }

    private var drawerDragGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                let translation = value.translation.height
                if drawerState == .open {
                    drawerDragOffset = translation < 0 ? translation * 0.5 : translation
                } else if drawerState == .expanded {
                    drawerDragOffset = translation > 0 ? translation * 0.5 : 0
                }
            }
            .onEnded { value in
                let translation = value.translation.height
                let velocity = value.predictedEndTranslation.height
                withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                    drawerDragOffset = 0
                    if drawerState == .open {
                        if translation < -50 || velocity < -200 {
                            drawerState = .expanded
                        } else if translation > 60 || velocity > 300 {
                            drawerState = .collapsed
                        }
                    } else if drawerState == .expanded {
                        if translation > 50 || velocity > 200 {
                            drawerState = .open
                        }
                    }
                }
            }
    }

    private func widgetThumbnail(type: StatWidgetType, isActive: Bool, large: Bool = false) -> some View {
        let h: CGFloat = large ? 80 : 72
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                toggleWidget(type)
            }
        } label: {
            VStack(spacing: 6) {
                miniWidgetPreview(type: type)
            }
            .frame(maxWidth: large ? .infinity : nil)
            .frame(width: large ? nil : 119, height: h)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isActive ? Color.white.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 0.5)
            )
            .scaleEffect(isActive ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isActive)
    }

    private func fullWidthThumbnail(type: StatWidgetType, isActive: Bool) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                toggleWidget(type)
            }
        } label: {
            VStack(spacing: 6) {
                miniWidgetPreview(type: type)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 94)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isActive ? Color.white.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 0.5)
            )
            .scaleEffect(isActive ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isActive)
    }

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
                    .frame(width: 56, height: 56)
                    .background(Color.white.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 18))
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
                .frame(height: 56)
                .background(Color.white.opacity(0.12))
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.15), lineWidth: 0.5)
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
                .frame(height: 56)
                .background(Color.white.opacity(0.12))
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.15), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
    }

    // MARK: - Actions



    @State private var isNewTextEditing: Bool = false

    private func startNewTextEditing() {
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

    private func toggleWidget(_ type: StatWidgetType) {
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
        guard let stravaId = Int(activity.id) else { return }
        detailFetchTask?.cancel()
        detailFetchTask = Task {
            isLoadingDetail = true
            do {
                if let cached = try await detailService.fetchCachedDetail(stravaActivityId: stravaId) {
                    activityDetail = cached
                    isLoadingDetail = false
                    return
                }
                let detail = try await stravaService.fetchActivityDetail(id: stravaId)
                activityDetail = detail
                try? await detailService.upsertDetail(detail)
            } catch {
                // keep nil — widgets show empty state
            }
            isLoadingDetail = false
        }
    }

    func captureCanvas() -> UIImage? {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return nil }

        let content = ZStack {
            Rectangle().fill(canvasBackgroundColor)

            Image(uiImage: currentPhoto)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: canvasSize.width, height: canvasSize.height)
                .scaleEffect(photoScale)
                .rotationEffect(photoRotation)
                .offset(photoOffset)
                .allowsHitTesting(false)

            activeFilterOverlay(size: canvasSize)

            ForEach(placedWidgets) { widget in
                StatWidgetContentView(type: widget.type, activity: activity, colorStyle: widget.colorStyle, weeklyKmData: weeklyKmData, lastWeekKmData: lastWeekKmData, monthlyKmData: monthlyKmData, lastMonthKmData: lastMonthKmData, activityDetail: activityDetail, bestEffortsFilter: widget.bestEffortsFilter, splitsFilter: widget.splitsFilter, distanceWordsFilter: widget.distanceWordsFilter, fontStyle: widget.fontStyle, showTitle: widget.showTitle, showActivityName: widget.showActivityName, showDate: widget.showDate, showDistance: widget.showDistance, showPace: widget.showPace, showTime: widget.showTime, showElevation: widget.showElevation, basicUnitFilter: widget.basicUnitFilter, fullBannerUnitFilter: widget.fullBannerUnitFilter, fullBannerShowDistance: widget.fullBannerShowDistance, fullBannerShowPace: widget.fullBannerShowPace, fullBannerShowTime: widget.fullBannerShowTime, fullBannerShowElevation: widget.fullBannerShowElevation, bvtShowDate: widget.bvtShowDate, bvtShowTime: widget.bvtShowTime, bvtShowLocation: widget.bvtShowLocation, bvtShowDistance: widget.bvtShowDistance, bvtShowPace: widget.bvtShowPace, bvtShowDuration: widget.bvtShowDuration, bvtShowElevation: widget.bvtShowElevation, bvtShowCalories: widget.bvtShowCalories, bvtShowBPM: widget.bvtShowBPM, bvtUnitFilter: widget.bvtUnitFilter, bvtEffect: widget.bvtEffect, whatsappText: widget.whatsappText)
                    .scaleEffect(widget.scale)
                    .rotationEffect(widget.rotation)
                    .offset(x: widget.position.width, y: widget.position.height)
            }

            ForEach(placedTexts) { textWidget in
                StyledCanvasText(
                    text: textWidget.text,
                    styleType: textWidget.styleType,
                    styleColor: textWidget.styleColor,
                    maxWidth: canvasSize.width * 0.8
                )
                .scaleEffect(textWidget.scale)
                .rotationEffect(textWidget.rotation)
                .offset(x: textWidget.position.width, y: textWidget.position.height)
            }

        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .clipped()
        .environment(\.isExport, true)

        let renderer = ImageRenderer(content: content)
        renderer.scale = max(1080 / canvasSize.width, 1920 / canvasSize.height)
        return renderer.uiImage
    }

    private func shareToStory() {
        let facebookAppID = "1722813128328059"
        guard let instagramURL = URL(string: "instagram-stories://share?source_application=\(facebookAppID)"),
              UIApplication.shared.canOpenURL(instagramURL) else {
            showInstagramAlert = true
            return
        }

        guard let image = captureCanvas(),
              let imageData = image.pngData() else { return }

        let pasteboardItems: [[String: Any]] = [
            [
                "com.instagram.sharedSticker.backgroundImage": imageData
            ]
        ]
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(300)
        ]
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)

        UIApplication.shared.open(instagramURL)
    }

    private func saveToPhotos() {
        guard let image = captureCanvas() else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        HapticService.notification.notificationOccurred(.success)
        showSavedAlert = true
    }

}

