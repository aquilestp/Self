import SwiftUI
import UIKit

nonisolated enum DashboardTab: Hashable {
    case share
    case challenges
}

struct ProviderItem: Identifiable {
    let id = UUID()
    let name: String
}

nonisolated struct ActivityHighlight: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let date: String
    let distance: String
    let pace: String
    let duration: String
    let systemImage: String
    let summarySymbol: String
    let accent: Color
    let backgroundTop: Color
    let backgroundBottom: Color
    let linePoints: [CGPoint]
    let hasRealRoute: Bool
    let hasDistance: Bool
    let startDate: Date?
    let activityName: String
    let activityType: String
    let elapsedTime: String
    let elevationGain: String
    let maxSpeed: String
    let averageHeartrate: String?
    let distanceRaw: Double
    let movingTimeRaw: Int
    let elapsedTimeRaw: Int

    nonisolated var dayTag: String? {
        guard let startDate else { return nil }
        let calendar = Calendar.current
        if calendar.isDateInToday(startDate) { return "Today" }
        if calendar.isDateInYesterday(startDate) { return "Yesterday" }
        return nil
    }

    var primaryStat: String {
        hasDistance ? distance : duration
    }

    var primaryLabel: String {
        hasDistance ? "DISTANCE" : "DURATION"
    }

    var primaryLabelShort: String {
        hasDistance ? "DIST" : "TIME"
    }

    var secondaryStats: String {
        if hasDistance {
            return "\(pace)  ·  \(duration)"
        } else {
            return pace != "--" ? pace : ""
        }
    }
}

struct DashboardRootView: View {
    @Bindable var authViewModel: AuthViewModel
    @State private var selectedTab: DashboardTab = .share
    @State private var pendingActivity: ActivityHighlight?
    @State private var editorActivity: ActivityHighlight?
    @State private var editorPhoto: UIImage?
    @State private var showSettings: Bool = false
    @State private var stravaViewModel = StravaViewModel()
    @State private var healthKitViewModel = HealthKitViewModel()
    @State private var activeSource: ActiveSource = ActiveSource.current
    @State private var detailActivity: ActivityHighlight?
    @State private var showNotificationPrompt: Bool = false
    @State private var isPhotoFirstFlow: Bool = false
    @State private var photoFirstImage: UIImage?
    @State private var showTemplatePicker: Bool = false
    @State private var showUpdateSheet: Bool = false
    @State private var updateService = AppUpdateService.shared

    private var activeHighlights: [ActivityHighlight] {
        switch activeSource {
        case .strava: return stravaViewModel.activityHighlights
        case .appleHealth: return healthKitViewModel.activityHighlights
        }
    }

    private var hasActivitySource: Bool {
        switch activeSource {
        case .strava: return stravaViewModel.isConnected || stravaViewModel.isUsingDemoActivities
        case .appleHealth: return healthKitViewModel.isConnected
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            activeScreen
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if editorActivity == nil && pendingActivity == nil {
                VStack(spacing: 0) {
                    if selectedTab == .share && !activeHighlights.isEmpty && (stravaViewModel.isConnected || healthKitViewModel.isConnected) {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.tap")
                                .font(.system(size: 9, weight: .medium))
                            Text("Hold activity card for details")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(Color.white.opacity(0.45))
                        .padding(.bottom, 4)
                    }
                    DashboardTabBar(selectedTab: $selectedTab)
                }
            }
        }
        .background(Color.black)
        .ignoresSafeArea(edges: .bottom)
        .sheet(item: $detailActivity) { activity in
            ActivityDetailSheet(
                activity: activity,
                detail: activeSource == .strava ? stravaViewModel.currentActivityDetail : nil,
                isLoading: activeSource == .strava ? stravaViewModel.isLoadingDetail : false,
                error: activeSource == .strava ? stravaViewModel.detailError : nil,
                onDelete: { activityId in
                    if activeSource == .strava {
                        return await stravaViewModel.deleteActivity(activityId: activityId)
                    }
                    return false
                }
            )
            .presentationDetents([.fraction(0.70), .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color(white: 0.08))
            .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $showNotificationPrompt) {
            NotificationPermissionView(
                onEnable: {
                    Task {
                        await NotificationService.shared.requestAuthorization()
                        showNotificationPrompt = false
                        await triggerUpdateCheckIfNeeded()
                    }
                },
                onSkip: {
                    NotificationService.shared.hasBeenPrompted = true
                    showNotificationPrompt = false
                    Task { await triggerUpdateCheckIfNeeded() }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(Color(white: 0.06))
            .interactiveDismissDisabled()
        }
        .onChange(of: stravaViewModel.didCompleteFirstLoad) { _, completed in
            if completed {
                Task {
                    await NotificationService.shared.refreshAuthorizationStatus()
                    if NotificationService.shared.shouldShowPermissionPrompt {
                        try? await Task.sleep(for: .seconds(1.2))
                        showNotificationPrompt = true
                    } else {
                        await triggerUpdateCheckIfNeeded()
                    }
                }
            }
            if completed && stravaViewModel.isConnected {
                stravaViewModel.startWebhookPolling()
            }
        }
        .onChange(of: healthKitViewModel.didCompleteFirstLoad) { _, completed in
            if completed && activeSource == .appleHealth {
                Task { await triggerUpdateCheckIfNeeded() }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task { await stravaViewModel.checkWebhookActivities() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            stravaViewModel.stopWebhookPolling()
        }
        .alert("Apple Health", isPresented: Binding(
            get: { healthKitViewModel.errorMessage != nil },
            set: { if !$0 { healthKitViewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { healthKitViewModel.errorMessage = nil }
        } message: {
            Text(healthKitViewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showUpdateSheet) {
            if let config = updateService.config, config.isActive {
                AppUpdateSheet(
                    config: config,
                    onLater: {
                        updateService.dismissForToday()
                        showUpdateSheet = false
                    },
                    onUpdate: {
                        updateService.dismissForToday()
                        showUpdateSheet = false
                        if let url = URL(string: "https://apps.apple.com/co/app/self-share/id6762170645") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationBackground(Color(white: 0.06))
                .interactiveDismissDisabled()
            }
        }
        .sheet(isPresented: $showTemplatePicker) {
            TemplatePickerSheet(
                templates: activeHighlights,
                onPick: { template in
                    showTemplatePicker = false
                    guard let image = photoFirstImage else { return }
                    withAnimation(.snappy(duration: 0.32, extraBounce: 0.02)) {
                        editorPhoto = image
                        editorActivity = template
                        isPhotoFirstFlow = false
                        photoFirstImage = nil
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color(white: 0.06))
            .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(
                userProfile: authViewModel.userProfile,
                isStravaConnected: stravaViewModel.isConnected,
                isAppleHealthConnected: healthKitViewModel.isConnected,
                activeSource: activeSource,
                isConnecting: stravaViewModel.isConnecting,
                onDisconnectStrava: {
                    stravaViewModel.disconnect()
                    activeSource = .strava
                },
                onConnectStrava: {
                    Task { await connectStrava() }
                },
                onDisconnectAppleHealth: {
                    healthKitViewModel.disconnect()
                    activeSource = .strava
                },
                onConnectAppleHealth: {
                    Task { await connectAppleHealth() }
                },
                onSignOut: {
                    Task { await authViewModel.signOut() }
                },
                onDeleteAccount: {
                    await authViewModel.deleteAccount()
                }
            )
        }
    }

    @ViewBuilder
    private var activeScreen: some View {
        switch selectedTab {
        case .share:
            if let editorActivity, let editorPhoto {
                PhotoEditorView(
                    activity: editorActivity,
                    photo: editorPhoto,
                    activities: activeHighlights,
                    onClose: {
                        withAnimation(.snappy(duration: 0.32, extraBounce: 0.02)) {
                            self.editorActivity = nil
                            self.editorPhoto = nil
                        }
                    }
                )
            } else if let pendingActivity {
                PhotoGridPickerView(
                    activity: pendingActivity,
                    stravaViewModel: stravaViewModel,
                    onPhotoPicked: { image in
                        withAnimation(.snappy(duration: 0.32, extraBounce: 0.02)) {
                            editorPhoto = image
                            editorActivity = pendingActivity
                        }
                    },
                    onGoBack: {
                        withAnimation(.snappy(duration: 0.32, extraBounce: 0.02)) {
                            self.pendingActivity = nil
                        }
                    }
                )
            } else if isPhotoFirstFlow {
                PhotoGridPickerView(
                    activity: placeholderActivity,
                    stravaViewModel: stravaViewModel,
                    onPhotoPicked: { image in
                        photoFirstImage = image
                        showTemplatePicker = true
                    },
                    onGoBack: {
                        withAnimation(.snappy(duration: 0.32, extraBounce: 0.02)) {
                            isPhotoFirstFlow = false
                            photoFirstImage = nil
                        }
                    }
                )
            } else {
                NavigationStack {
                    DashboardView(
                        authViewModel: authViewModel,
                        stravaViewModel: stravaViewModel,
                        healthKitViewModel: healthKitViewModel,
                        activeSource: activeSource,
                        onSelectActivity: { activity in
                            withAnimation(.snappy(duration: 0.32, extraBounce: 0.02)) {
                                pendingActivity = activity
                            }
                        },
                        onShowDetail: presentActivityDetail,
                        onOpenSettings: {
                            showSettings = true
                        },
                        onStartTemplates: {
                            HapticService.heavy.impactOccurred()
                            Task { await stravaViewModel.loadDemoActivities() }
                        },
                        onStartFromPhoto: {
                            HapticService.medium.impactOccurred()
                            if activeHighlights.isEmpty && activeSource == .strava {
                                Task { await stravaViewModel.loadDemoActivities() }
                            }
                            withAnimation(.snappy(duration: 0.32, extraBounce: 0.02)) {
                                isPhotoFirstFlow = true
                            }
                        },
                        onGoWithoutActivity: {
                            HapticService.medium.impactOccurred()
                            withAnimation(.snappy(duration: 0.32, extraBounce: 0.02)) {
                                pendingActivity = placeholderActivity
                            }
                        },
                        onGoBack: {
                            HapticService.medium.impactOccurred()
                            if activeSource == .strava {
                                stravaViewModel.resetDemoState()
                            }
                        },
                        onConnectAppleHealth: {
                            Task { await connectAppleHealth() }
                        },
                        onSourceChanged: { newSource in
                            activeSource = newSource
                        }
                    )
                }
            }
        case .challenges:
            NavigationStack {
                DashboardPlaceholderView(
                    eyebrow: "COMING SOON",
                    title: "Challenges",
                    message: "Competitive moments, rewards and shared goals will live here."
                )
            }
        }
    }

    private var placeholderActivity: ActivityHighlight {
        activeHighlights.first ?? ActivityHighlight(
            id: "placeholder",
            title: "New post",
            date: "",
            distance: "",
            pace: "",
            duration: "",
            systemImage: "sparkles",
            summarySymbol: "sparkles",
            accent: Color(red: 0.92, green: 0.86, blue: 0.72),
            backgroundTop: Color(red: 0.15, green: 0.13, blue: 0.11),
            backgroundBottom: Color(red: 0.05, green: 0.04, blue: 0.03),
            linePoints: [],
            hasRealRoute: false,
            hasDistance: false,
            startDate: nil,
            activityName: "New post",
            activityType: "Run",
            elapsedTime: "",
            elevationGain: "",
            maxSpeed: "",
            averageHeartrate: nil,
            distanceRaw: 0,
            movingTimeRaw: 0,
            elapsedTimeRaw: 0
        )
    }

    private func presentActivityDetail(_ activity: ActivityHighlight) {
        switch activeSource {
        case .strava:
            guard !stravaViewModel.isUsingDemoActivities,
                  let stravaId = Int(activity.id) else { return }
            detailActivity = activity
            Task {
                await stravaViewModel.fetchActivityDetail(stravaId: stravaId)
            }
        case .appleHealth:
            detailActivity = activity
        }
    }

    private func connectStrava() async {
        await stravaViewModel.connect()
        if stravaViewModel.isConnected {
            ActiveSource.current = .strava
            activeSource = .strava
        }
    }

    private func connectAppleHealth() async {
        await healthKitViewModel.connect()
        if healthKitViewModel.isConnected {
            activeSource = .appleHealth
        }
    }

    private func triggerUpdateCheckIfNeeded() async {
        await updateService.fetch()
        guard updateService.shouldShowUpdate else { return }
        try? await Task.sleep(for: .seconds(1.5))
        showUpdateSheet = true
    }
}

struct DashboardView: View {
    @Bindable var authViewModel: AuthViewModel
    @Bindable var stravaViewModel: StravaViewModel
    @Bindable var healthKitViewModel: HealthKitViewModel
    let activeSource: ActiveSource
    let onSelectActivity: (ActivityHighlight) -> Void
    let onShowDetail: (ActivityHighlight) -> Void
    let onOpenSettings: () -> Void
    let onStartTemplates: () -> Void
    let onStartFromPhoto: () -> Void
    let onGoWithoutActivity: () -> Void
    let onGoBack: () -> Void
    let onConnectAppleHealth: () -> Void
    let onSourceChanged: (ActiveSource) -> Void

    private var activities: [ActivityHighlight] {
        switch activeSource {
        case .strava: return stravaViewModel.activityHighlights
        case .appleHealth: return healthKitViewModel.activityHighlights
        }
    }

    private var hasActivitySource: Bool {
        switch activeSource {
        case .strava: return stravaViewModel.isConnected || stravaViewModel.isUsingDemoActivities
        case .appleHealth: return healthKitViewModel.isConnected
        }
    }

    private var isDemoOnly: Bool {
        activeSource == .strava && stravaViewModel.isUsingDemoActivities && !stravaViewModel.isConnected
    }

    private var isSourceConnected: Bool {
        switch activeSource {
        case .strava: return stravaViewModel.isConnected
        case .appleHealth: return healthKitViewModel.isConnected
        }
    }

    private var isCurrentlyLoading: Bool {
        switch activeSource {
        case .strava: return stravaViewModel.isLoading
        case .appleHealth: return healthKitViewModel.isLoading
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                topActions
                heroHeader
                activityRail
                if isDemoOnly && !activities.isEmpty {
                    goWithoutActivityButton
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 122)
        }
        .scrollDisabled(true)
        .background(Color.black)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            switch activeSource {
            case .strava:
                if stravaViewModel.isUsingDemoActivities { return }
                if authViewModel.isDemoMode {
                    await stravaViewModel.loadDemoActivities()
                } else {
                    stravaViewModel.checkConnection()
                    if stravaViewModel.isConnected {
                        await stravaViewModel.loadInitial()
                    }
                }
            case .appleHealth:
                healthKitViewModel.checkConnection()
                if healthKitViewModel.isConnected && healthKitViewModel.activityHighlights.isEmpty {
                    await healthKitViewModel.loadInitial()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if activeSource == .strava {
                Task { await stravaViewModel.refreshTokenProactively() }
            }
        }
    }

    private var topActions: some View {
        HStack {
            Button(action: onOpenSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.02), in: Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            if isSourceConnected {
                Button {
                    HapticService.heavy.impactOccurred()
                    triggerRateLimitedRefresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.72))
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.02), in: Circle())
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                        .animation(isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                }
                .buttonStyle(.plain)
                .disabled(isRefreshing)
            }
        }
    }

    private var heroTitle: String {
        if isDemoOnly { return "Choose your demo activity" }
        return "Choose your activity"
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            let greeting = authViewModel.userProfile?.fullName.map { "Hey \($0)," } ?? "Express your Self, and"
            Text(greeting)
                .font(.system(size: 13, weight: .regular, design: .default))
                .tracking(2.8)
                .foregroundStyle(Color.white.opacity(0.48))

            if hasActivitySource {
                Text(heroTitle)
                    .font(.system(size: 28, weight: .regular, design: .serif).italic())
                    .foregroundStyle(Color(red: 0.97, green: 0.96, blue: 0.95))
                    .lineSpacing(-3)
                    .minimumScaleFactor(0.9)

                if isSourceConnected {
                    sourceChip
                }
            }
        }
        .padding(.top, 6)
    }

    private var sourceChip: some View {
        HStack(spacing: 5) {
            Image(systemName: activeSource == .appleHealth ? "heart.fill" : "figure.run")
                .font(.system(size: 9, weight: .medium))
            Text(activeSource == .appleHealth ? "Apple Health" : "Strava")
                .font(.system(size: 10, weight: .medium))
                .tracking(0.5)
        }
        .foregroundStyle(
            activeSource == .appleHealth
            ? Color(red: 1.0, green: 0.30, blue: 0.30).opacity(0.75)
            : Color(red: 0.99, green: 0.32, blue: 0.14).opacity(0.75)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            (activeSource == .appleHealth
             ? Color(red: 1.0, green: 0.30, blue: 0.30)
             : Color(red: 0.99, green: 0.32, blue: 0.14)).opacity(0.08),
            in: Capsule()
        )
        .overlay(
            Capsule().stroke(
                (activeSource == .appleHealth
                 ? Color(red: 1.0, green: 0.30, blue: 0.30)
                 : Color(red: 0.99, green: 0.32, blue: 0.14)).opacity(0.12),
                lineWidth: 0.5
            )
        )
    }

    @State private var visibleActivityID: String?
    @State private var comingSoonProvider: ProviderItem?
    @State private var visibleProviderIndex: Int?
    @State private var showConnectProvidersSheet: Bool = false
    @State private var pullRefreshTriggered: Bool = false
    @State private var showCooldownToast: Bool = false
    @State private var isRefreshing: Bool = false

    private var activityRail: some View {
        ZStack(alignment: .top) {
            Group {
                if isCurrentlyLoading && activities.isEmpty {
                    loadingRail
                } else if !hasActivitySource {
                    connectSourceRail
                } else if activities.isEmpty {
                    emptyActivitiesRail
                } else {
                    realActivityRail
                }
            }

            if showCooldownToast {
                cooldownToast
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var goWithoutActivityButton: some View {
        Button {
            HapticService.medium.impactOccurred()
            onGoBack()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .bold))
                Text("Go back")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(Color.white.opacity(0.92))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white.opacity(0.06), in: .capsule)
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.14), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var cooldownToast: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13, weight: .medium))
            Text("All recent activities imported")
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(Color.white.opacity(0.80))
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.10), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 0.5))
    }

    private var realActivityRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 14) {
                Color.clear
                    .frame(width: 0)
                    .background(
                        GeometryReader { geo in
                            let minX = geo.frame(in: .named("activityRail")).minX
                            Color.clear
                                .onChange(of: minX) { _, newX in
                                    handlePullOffset(newX)
                                }
                        }
                    )

                ForEach(activities) { activity in
                    ActivityHighlightCard(activity: activity, isCompact: isDemoOnly)
                        .onTapGesture {
                            HapticService.medium.impactOccurred()
                            onSelectActivity(activity)
                        }
                        .onLongPressGesture(minimumDuration: 0.4) {
                            HapticService.heavy.impactOccurred()
                            onShowDetail(activity)
                        }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .scrollTargetLayout()
        }
        .coordinateSpace(name: "activityRail")
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $visibleActivityID)
        .contentMargins(.horizontal, 20)
        .padding(.horizontal, -20)
        .overlay(alignment: .leading) {
            if isRefreshing {
                ProgressView()
                    .tint(Color.white.opacity(0.60))
                    .scaleEffect(0.9)
                    .padding(.leading, 6)
                    .transition(.opacity)
            }
        }
        .onChange(of: visibleActivityID) { _, newValue in
            guard newValue != nil else { return }
            HapticService.medium.impactOccurred()

            if newValue == activities.last?.id {
                switch activeSource {
                case .strava:
                    if stravaViewModel.hasMoreActivities && !stravaViewModel.isLoadingMore {
                        Task { await stravaViewModel.loadMore() }
                    }
                case .appleHealth:
                    if healthKitViewModel.hasMoreActivities && !healthKitViewModel.isLoadingMore {
                        Task { await healthKitViewModel.loadMore() }
                    }
                }
            }
        }
    }

    private func handlePullOffset(_ offset: CGFloat) {
        let threshold: CGFloat = 60
        let isAtFirst = visibleActivityID == activities.first?.id || visibleActivityID == nil

        if isAtFirst && offset > threshold && !pullRefreshTriggered && !isRefreshing {
            pullRefreshTriggered = true
            HapticService.heavy.impactOccurred()
            triggerRateLimitedRefresh()
        }

        if offset <= 20 {
            pullRefreshTriggered = false
        }
    }

    private func triggerRateLimitedRefresh() {
        Task {
            switch activeSource {
            case .strava:
                if stravaViewModel.isOnCooldown {
                    withAnimation(.snappy(duration: 0.3)) { showCooldownToast = true }
                    try? await Task.sleep(for: .seconds(2))
                    withAnimation(.snappy(duration: 0.3)) { showCooldownToast = false }
                } else {
                    withAnimation(.snappy(duration: 0.2)) { isRefreshing = true }
                    await stravaViewModel.refresh()
                    withAnimation(.snappy(duration: 0.3)) { isRefreshing = false }
                }
            case .appleHealth:
                withAnimation(.snappy(duration: 0.2)) { isRefreshing = true }
                await healthKitViewModel.refresh()
                withAnimation(.snappy(duration: 0.3)) { isRefreshing = false }
            }
        }
    }

    private func connectStrava() {
        Task {
            await stravaViewModel.connect()
            if stravaViewModel.isConnected {
                ActiveSource.current = .strava
                onSourceChanged(.strava)
            }
        }
    }

    private var connectSourceRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 14) {
                BringActivitiesCard(
                    onTap: { showConnectProvidersSheet = true }
                )
                .id(0)

                CreatePostCard(
                    isLoading: stravaViewModel.isLoading,
                    onStart: onStartTemplates,
                    onNewFromPhoto: onStartFromPhoto
                )
                .id(1)
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $visibleProviderIndex)
        .contentMargins(.horizontal, 20)
        .padding(.horizontal, -20)
        .onChange(of: visibleProviderIndex) { _, _ in
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        .sheet(isPresented: $showConnectProvidersSheet) {
            ConnectProvidersSheet(
                isConnecting: stravaViewModel.isConnecting,
                onConnectStrava: connectStrava,
                onConnectAppleHealth: onConnectAppleHealth
            )
            .presentationDetents([.height(480)])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color(white: 0.08))
        }
    }

    private var loadingRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 14) {
                ForEach(0..<3, id: \.self) { _ in
                    LoadingActivityCard()
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 20)
        .padding(.horizontal, -20)
    }

    private var emptyActivitiesRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 14) {
                EmptyActivitiesCard(
                    sourceName: activeSource == .appleHealth ? "Apple Health" : "Strava",
                    onDisconnect: {
                        switch activeSource {
                        case .strava: stravaViewModel.disconnect()
                        case .appleHealth: healthKitViewModel.disconnect()
                        }
                        onSourceChanged(.strava)
                    }
                )
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 20)
        .padding(.horizontal, -20)
    }
}

#Preview {
    DashboardRootView(authViewModel: AuthViewModel())
        .preferredColorScheme(.dark)
}
