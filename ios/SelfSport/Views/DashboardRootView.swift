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
    @State private var detailActivity: ActivityHighlight?
    @State private var showNotificationPrompt: Bool = false

    private var hasActivitySource: Bool {
        stravaViewModel.isConnected || stravaViewModel.isUsingDemoActivities
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            activeScreen
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if editorActivity == nil && pendingActivity == nil {
                VStack(spacing: 0) {
                    if selectedTab == .share && !stravaViewModel.activityHighlights.isEmpty && stravaViewModel.isConnected {
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
                detail: stravaViewModel.currentActivityDetail,
                isLoading: stravaViewModel.isLoadingDetail,
                error: stravaViewModel.detailError,
                onDelete: { activityId in
                    await stravaViewModel.deleteActivity(activityId: activityId)
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
                    }
                },
                onSkip: {
                    NotificationService.shared.hasBeenPrompted = true
                    showNotificationPrompt = false
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
                    }
                }
            }
            if completed && stravaViewModel.isConnected {
                stravaViewModel.startWebhookPolling()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task { await stravaViewModel.checkWebhookActivities() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            stravaViewModel.stopWebhookPolling()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(
                userProfile: authViewModel.userProfile,
                isStravaConnected: stravaViewModel.isConnected,
                onDisconnectStrava: {
                    stravaViewModel.disconnect()
                },
                onSignOut: {
                    Task { await authViewModel.signOut() }
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
            } else {
                NavigationStack {
                    DashboardView(
                        authViewModel: authViewModel,
                        stravaViewModel: stravaViewModel,
                        onSelectActivity: { activity in
                            withAnimation(.snappy(duration: 0.32, extraBounce: 0.02)) {
                                pendingActivity = activity
                            }
                        },
                        onShowDetail: presentActivityDetail,
                        onOpenSettings: {
                            showSettings = true
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

    private func presentActivityDetail(_ activity: ActivityHighlight) {
        guard !stravaViewModel.isUsingDemoActivities,
              let stravaId = Int(activity.id) else { return }
        detailActivity = activity
        Task {
            await stravaViewModel.fetchActivityDetail(stravaId: stravaId)
        }
    }
}

struct DashboardView: View {
    @Bindable var authViewModel: AuthViewModel
    @Bindable var stravaViewModel: StravaViewModel
    let onSelectActivity: (ActivityHighlight) -> Void
    let onShowDetail: (ActivityHighlight) -> Void
    let onOpenSettings: () -> Void

    private var activities: [ActivityHighlight] {
        stravaViewModel.activityHighlights
    }

    private var hasActivitySource: Bool {
        stravaViewModel.isConnected || stravaViewModel.isUsingDemoActivities
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                topActions
                heroHeader
                activityRail
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 122)
        }
        .background(Color.black)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if stravaViewModel.isUsingDemoActivities {
                return
            }
            if authViewModel.isDemoMode {
                await stravaViewModel.loadDemoActivities()
            } else {
                stravaViewModel.checkConnection()
                if stravaViewModel.isConnected {
                    await stravaViewModel.loadInitial()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task { await stravaViewModel.refreshTokenProactively() }
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

            if stravaViewModel.isConnected {
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
        hasActivitySource ? "Choose your activity" : "Import your activities"
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            let greeting = authViewModel.userProfile?.fullName.map { "Hey \($0)," } ?? "Express your Self, and"
            Text(greeting)
                .font(.system(size: 13, weight: .regular, design: .default))
                .tracking(2.8)
                .foregroundStyle(Color.white.opacity(0.48))

            Text(heroTitle)
                .font(.system(size: 34, weight: .regular, design: .serif).italic())
                .foregroundStyle(Color(red: 0.97, green: 0.96, blue: 0.95))
                .lineSpacing(-3)
                .minimumScaleFactor(0.9)
        }
        .padding(.top, 6)
    }

    @State private var visibleActivityID: String?
    @State private var comingSoonProvider: ProviderItem?
    @State private var visibleProviderIndex: Int?
    @State private var pullRefreshTriggered: Bool = false
    @State private var showCooldownToast: Bool = false
    @State private var isRefreshing: Bool = false

    private var activityRail: some View {
        ZStack(alignment: .top) {
            Group {
                if stravaViewModel.isLoading && activities.isEmpty {
                    loadingRail
                } else if !hasActivitySource {
                    connectStravaRail
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
                    ActivityHighlightCard(activity: activity)
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

            if newValue == activities.last?.id,
               stravaViewModel.hasMoreActivities,
               !stravaViewModel.isLoadingMore {
                Task { await stravaViewModel.loadMore() }
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
            if stravaViewModel.isOnCooldown {
                withAnimation(.snappy(duration: 0.3)) { showCooldownToast = true }
                try? await Task.sleep(for: .seconds(2))
                withAnimation(.snappy(duration: 0.3)) { showCooldownToast = false }
            } else {
                withAnimation(.snappy(duration: 0.2)) { isRefreshing = true }
                await stravaViewModel.refresh()
                withAnimation(.snappy(duration: 0.3)) { isRefreshing = false }
            }
        }
    }

    private func openDemoActivities() {
        HapticService.heavy.impactOccurred()
        Task {
            await stravaViewModel.loadDemoActivities()
        }
    }

    private func connectStrava() {
        Task {
            await stravaViewModel.connect()
        }
    }

    private var connectStravaRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 14) {
                DemoActivitiesCard(
                    isLoading: stravaViewModel.isLoading,
                    onOpenDemo: openDemoActivities
                )
                .id(0)

                ConnectStravaCard(
                    isConnecting: stravaViewModel.isConnecting,
                    onConnect: connectStrava
                )
                .id(1)

                ConnectProviderCard(
                    providerName: "COROS",
                    subtitle: "Sync workouts from your COROS watch",
                    systemImage: "applewatch.side.right",
                    accentColor: Color(red: 0.85, green: 0.12, blue: 0.15),
                    gradientTop: Color(red: 0.16, green: 0.04, blue: 0.04),
                    gradientBottom: Color(red: 0.07, green: 0.02, blue: 0.02),
                    onConnect: { comingSoonProvider = ProviderItem(name: "COROS") }
                )
                .id(2)

                ConnectProviderCard(
                    providerName: "Garmin",
                    subtitle: "Import activities from Garmin Connect",
                    systemImage: "location.north.circle",
                    accentColor: Color(red: 0.0, green: 0.47, blue: 0.78),
                    gradientTop: Color(red: 0.02, green: 0.08, blue: 0.14),
                    gradientBottom: Color(red: 0.01, green: 0.03, blue: 0.07),
                    onConnect: { comingSoonProvider = ProviderItem(name: "Garmin") }
                )
                .id(3)
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
        .sheet(item: $comingSoonProvider) { provider in
            ComingSoonSheet(providerName: provider.name)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(white: 0.10))
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
                    onDisconnect: {
                        stravaViewModel.disconnect()
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
