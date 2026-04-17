import AuthenticationServices
import Foundation
import SwiftUI

@Observable
final class StravaViewModel {
    private var activities: [StravaActivity] = []
    var activityHighlights: [ActivityHighlight] = []
    private var highlightCache: [Int: ActivityHighlight] = [:]
    var isLoading: Bool = false
    var isConnecting: Bool = false
    var isConnected: Bool = false
    var isLoadingMore: Bool = false
    var hasMoreActivities: Bool = true
    var isUsingDemoActivities: Bool = false
    var errorMessage: String?
    var isLoadingDetail: Bool = false
    var currentActivityDetail: StravaActivityDetail?
    var detailError: String?
    var lastRefreshDate: Date?
    var refreshCooldownActive: Bool = false
    var didCompleteFirstLoad: Bool = false

    private let refreshCooldown: TimeInterval = 60

    private let service = StravaService()
    private let cache = SupabaseActivityService()
    private let detailCache = SupabaseActivityDetailService()
    let pollingService = ActivityPollingService()
    private let pageSize: Int = 20
    private var cachedOffset: Int = 0
    private var stravaPage: Int = 1
    private var cachedTotalKnown: Bool = false

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    private static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    private func rebuildHighlights() {
        activityHighlights = activities.map { activity in
            if let cached = highlightCache[activity.id] { return cached }
            let highlight = toActivityHighlight(activity)
            highlightCache[activity.id] = highlight
            return highlight
        }
    }

    private func setActivities(_ newActivities: [StravaActivity]) {
        activities = newActivities
        rebuildHighlights()
    }

    private func appendActivities(_ newActivities: [StravaActivity]) {
        let existingIds = Set(activities.map(\.id))
        let unique = newActivities.filter { !existingIds.contains($0.id) }
        guard !unique.isEmpty else { return }
        activities.append(contentsOf: unique)
        let newHighlights = unique.map { activity -> ActivityHighlight in
            if let cached = highlightCache[activity.id] { return cached }
            let highlight = toActivityHighlight(activity)
            highlightCache[activity.id] = highlight
            return highlight
        }
        activityHighlights.append(contentsOf: newHighlights)
    }

    private func prependActivities(_ newActivities: [StravaActivity]) {
        let existingIds = Set(activities.map(\.id))
        let unique = newActivities.filter { !existingIds.contains($0.id) }
        guard !unique.isEmpty else { return }
        let sorted = unique.sorted { $0.startDateLocal > $1.startDateLocal }
        activities.insert(contentsOf: sorted, at: 0)
        let newHighlights = sorted.map { activity -> ActivityHighlight in
            if let cached = highlightCache[activity.id] { return cached }
            let highlight = toActivityHighlight(activity)
            highlightCache[activity.id] = highlight
            return highlight
        }
        activityHighlights.insert(contentsOf: newHighlights, at: 0)
    }

    func checkConnection() {
        isUsingDemoActivities = false
        isConnected = service.isConnected
    }

    func refreshTokenProactively() async {
        guard isConnected else { return }
        do {
            try await service.refreshTokenIfNeeded()
        } catch {
            // Silent — will retry on next API call
        }
    }

    func connect() async {
        isUsingDemoActivities = false
        isConnecting = true
        errorMessage = nil
        do {
            try await service.authenticate()
            isConnected = true
            await firstTimeLoad()
        } catch {
            if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
            } else {
                errorMessage = "Could not connect to Strava"
            }
        }
        isConnecting = false
    }

    func disconnect() {
        service.disconnect()
        pollingService.stopPolling()
        isConnected = false
        isUsingDemoActivities = false
        activities = []
        activityHighlights = []
        highlightCache = [:]
        resetPagination()
    }

    func startWebhookPolling() {
        guard isConnected else { return }
        pollingService.configure { [weak self] newActivities in
            guard let self else { return }
            prependActivities(newActivities)
            cachedOffset += newActivities.count
        }
        pollingService.startPolling()
    }

    func stopWebhookPolling() {
        pollingService.stopPolling()
    }

    func checkWebhookActivities() async {
        guard isConnected else { return }
        await pollingService.checkForNewActivities()
    }

    func resetDemoState() {
        isUsingDemoActivities = false
        activityHighlights = []
        activities = []
        highlightCache = [:]
        didCompleteFirstLoad = false
        resetPagination()
    }

    func loadDemoActivities() async {
        pollingService.stopPolling()
        isLoading = true
        errorMessage = nil
        currentActivityDetail = nil
        detailError = nil
        activities = []
        activityHighlights = []
        highlightCache = [:]
        isConnected = false
        isUsingDemoActivities = true
        didCompleteFirstLoad = false
        resetPagination()
        hasMoreActivities = false
        let calendar = Calendar.current
        let now = Date()
        func daysAgo(_ n: Int) -> Date { calendar.date(byAdding: .day, value: -n, to: now) ?? now }
        func dateStr(_ d: Date) -> String {
            let f = DateFormatter()
            f.dateFormat = "MMM d"
            return f.string(from: d)
        }

        let runs: [ActivityHighlight] = [
            ActivityHighlight(
                id: "demo-1",
                title: "Morning Run",
                date: dateStr(daysAgo(1)),
                distance: "10.2 km",
                pace: "5'12\"/km",
                duration: "52:58",
                systemImage: "figure.run",
                summarySymbol: "figure.run",
                accent: Color(red: 0.70, green: 0.64, blue: 0.57),
                backgroundTop: Color(red: 0.14, green: 0.14, blue: 0.16),
                backgroundBottom: Color(red: 0.03, green: 0.03, blue: 0.05),
                linePoints: [
                    CGPoint(x: 0.05, y: 0.68), CGPoint(x: 0.15, y: 0.58), CGPoint(x: 0.25, y: 0.62),
                    CGPoint(x: 0.35, y: 0.48), CGPoint(x: 0.45, y: 0.52), CGPoint(x: 0.55, y: 0.38),
                    CGPoint(x: 0.65, y: 0.42), CGPoint(x: 0.75, y: 0.30), CGPoint(x: 0.88, y: 0.28)
                ],
                hasRealRoute: true,
                hasDistance: true,
                startDate: daysAgo(1),
                activityName: "Morning Run",
                activityType: "Run",
                elapsedTime: "54:10",
                elevationGain: "112 m",
                maxSpeed: "4'30\"/km",
                averageHeartrate: "158 bpm",
                distanceRaw: 10200,
                movingTimeRaw: 3178,
                elapsedTimeRaw: 3250
            ),
            ActivityHighlight(
                id: "demo-2",
                title: "Easy Recovery",
                date: dateStr(daysAgo(3)),
                distance: "5.8 km",
                pace: "6'02\"/km",
                duration: "34:59",
                systemImage: "figure.run",
                summarySymbol: "figure.run",
                accent: Color(red: 0.70, green: 0.64, blue: 0.57),
                backgroundTop: Color(red: 0.14, green: 0.14, blue: 0.16),
                backgroundBottom: Color(red: 0.03, green: 0.03, blue: 0.05),
                linePoints: [
                    CGPoint(x: 0.05, y: 0.55), CGPoint(x: 0.18, y: 0.60), CGPoint(x: 0.30, y: 0.52),
                    CGPoint(x: 0.42, y: 0.58), CGPoint(x: 0.55, y: 0.50), CGPoint(x: 0.68, y: 0.54),
                    CGPoint(x: 0.80, y: 0.46), CGPoint(x: 0.92, y: 0.42)
                ],
                hasRealRoute: true,
                hasDistance: true,
                startDate: daysAgo(3),
                activityName: "Easy Recovery",
                activityType: "Run",
                elapsedTime: "35:40",
                elevationGain: "48 m",
                maxSpeed: "5'10\"/km",
                averageHeartrate: "138 bpm",
                distanceRaw: 5800,
                movingTimeRaw: 2099,
                elapsedTimeRaw: 2140
            ),
            ActivityHighlight(
                id: "demo-3",
                title: "Tempo Intervals",
                date: dateStr(daysAgo(5)),
                distance: "12.0 km",
                pace: "4'45\"/km",
                duration: "57:00",
                systemImage: "figure.run",
                summarySymbol: "figure.run",
                accent: Color(red: 0.70, green: 0.64, blue: 0.57),
                backgroundTop: Color(red: 0.14, green: 0.14, blue: 0.16),
                backgroundBottom: Color(red: 0.03, green: 0.03, blue: 0.05),
                linePoints: [
                    CGPoint(x: 0.05, y: 0.70), CGPoint(x: 0.12, y: 0.45), CGPoint(x: 0.20, y: 0.65),
                    CGPoint(x: 0.28, y: 0.40), CGPoint(x: 0.38, y: 0.62), CGPoint(x: 0.48, y: 0.38),
                    CGPoint(x: 0.58, y: 0.55), CGPoint(x: 0.70, y: 0.32), CGPoint(x: 0.82, y: 0.48),
                    CGPoint(x: 0.92, y: 0.28)
                ],
                hasRealRoute: true,
                hasDistance: true,
                startDate: daysAgo(5),
                activityName: "Tempo Intervals",
                activityType: "Run",
                elapsedTime: "58:20",
                elevationGain: "85 m",
                maxSpeed: "3'55\"/km",
                averageHeartrate: "172 bpm",
                distanceRaw: 12000,
                movingTimeRaw: 3420,
                elapsedTimeRaw: 3500
            ),
            ActivityHighlight(
                id: "demo-4",
                title: "Long Run",
                date: dateStr(daysAgo(8)),
                distance: "21.5 km",
                pace: "5'28\"/km",
                duration: "1:57:42",
                systemImage: "figure.run",
                summarySymbol: "figure.run",
                accent: Color(red: 0.70, green: 0.64, blue: 0.57),
                backgroundTop: Color(red: 0.14, green: 0.14, blue: 0.16),
                backgroundBottom: Color(red: 0.03, green: 0.03, blue: 0.05),
                linePoints: [
                    CGPoint(x: 0.04, y: 0.60), CGPoint(x: 0.14, y: 0.52), CGPoint(x: 0.24, y: 0.56),
                    CGPoint(x: 0.34, y: 0.44), CGPoint(x: 0.44, y: 0.50), CGPoint(x: 0.54, y: 0.36),
                    CGPoint(x: 0.64, y: 0.42), CGPoint(x: 0.74, y: 0.30), CGPoint(x: 0.84, y: 0.35),
                    CGPoint(x: 0.93, y: 0.26)
                ],
                hasRealRoute: true,
                hasDistance: true,
                startDate: daysAgo(8),
                activityName: "Long Run",
                activityType: "Run",
                elapsedTime: "2:00:05",
                elevationGain: "210 m",
                maxSpeed: "4'22\"/km",
                averageHeartrate: "155 bpm",
                distanceRaw: 21500,
                movingTimeRaw: 7062,
                elapsedTimeRaw: 7205
            ),
            ActivityHighlight(
                id: "demo-5",
                title: "Evening Jog",
                date: dateStr(daysAgo(10)),
                distance: "7.1 km",
                pace: "5'44\"/km",
                duration: "40:44",
                systemImage: "figure.run",
                summarySymbol: "figure.run",
                accent: Color(red: 0.70, green: 0.64, blue: 0.57),
                backgroundTop: Color(red: 0.14, green: 0.14, blue: 0.16),
                backgroundBottom: Color(red: 0.03, green: 0.03, blue: 0.05),
                linePoints: [
                    CGPoint(x: 0.06, y: 0.62), CGPoint(x: 0.20, y: 0.55), CGPoint(x: 0.33, y: 0.60),
                    CGPoint(x: 0.46, y: 0.48), CGPoint(x: 0.60, y: 0.53), CGPoint(x: 0.74, y: 0.44),
                    CGPoint(x: 0.88, y: 0.40)
                ],
                hasRealRoute: true,
                hasDistance: true,
                startDate: daysAgo(10),
                activityName: "Evening Jog",
                activityType: "Run",
                elapsedTime: "41:30",
                elevationGain: "62 m",
                maxSpeed: "4'50\"/km",
                averageHeartrate: "144 bpm",
                distanceRaw: 7100,
                movingTimeRaw: 2444,
                elapsedTimeRaw: 2490
            ),
            ActivityHighlight(
                id: "demo-6",
                title: "5K Workout",
                date: dateStr(daysAgo(13)),
                distance: "5.0 km",
                pace: "4'30\"/km",
                duration: "22:30",
                systemImage: "figure.run",
                summarySymbol: "figure.run",
                accent: Color(red: 0.70, green: 0.64, blue: 0.57),
                backgroundTop: Color(red: 0.14, green: 0.14, blue: 0.16),
                backgroundBottom: Color(red: 0.03, green: 0.03, blue: 0.05),
                linePoints: [
                    CGPoint(x: 0.05, y: 0.72), CGPoint(x: 0.18, y: 0.50), CGPoint(x: 0.32, y: 0.56),
                    CGPoint(x: 0.46, y: 0.36), CGPoint(x: 0.60, y: 0.42), CGPoint(x: 0.75, y: 0.28),
                    CGPoint(x: 0.90, y: 0.32)
                ],
                hasRealRoute: true,
                hasDistance: true,
                startDate: daysAgo(13),
                activityName: "5K Workout",
                activityType: "Run",
                elapsedTime: "23:05",
                elevationGain: "30 m",
                maxSpeed: "3'42\"/km",
                averageHeartrate: "178 bpm",
                distanceRaw: 5000,
                movingTimeRaw: 1350,
                elapsedTimeRaw: 1385
            ),
            ActivityHighlight(
                id: "demo-7",
                title: "Sunday Long Run",
                date: dateStr(daysAgo(15)),
                distance: "18.3 km",
                pace: "5'35\"/km",
                duration: "1:42:14",
                systemImage: "figure.run",
                summarySymbol: "figure.run",
                accent: Color(red: 0.70, green: 0.64, blue: 0.57),
                backgroundTop: Color(red: 0.14, green: 0.14, blue: 0.16),
                backgroundBottom: Color(red: 0.03, green: 0.03, blue: 0.05),
                linePoints: [
                    CGPoint(x: 0.04, y: 0.65), CGPoint(x: 0.13, y: 0.55), CGPoint(x: 0.23, y: 0.60),
                    CGPoint(x: 0.33, y: 0.46), CGPoint(x: 0.43, y: 0.52), CGPoint(x: 0.53, y: 0.38),
                    CGPoint(x: 0.63, y: 0.44), CGPoint(x: 0.73, y: 0.32), CGPoint(x: 0.83, y: 0.36),
                    CGPoint(x: 0.93, y: 0.28)
                ],
                hasRealRoute: true,
                hasDistance: true,
                startDate: daysAgo(15),
                activityName: "Sunday Long Run",
                activityType: "Run",
                elapsedTime: "1:44:00",
                elevationGain: "175 m",
                maxSpeed: "4'18\"/km",
                averageHeartrate: "152 bpm",
                distanceRaw: 18300,
                movingTimeRaw: 6134,
                elapsedTimeRaw: 6240
            )
        ]

        activityHighlights = runs
        isLoading = false
    }

    func loadFromCacheOnly() async {
        isUsingDemoActivities = false
        isLoading = true
        errorMessage = nil
        resetPagination()

        do {
            let cached = try await cache.fetchCachedActivities(limit: pageSize, offset: 0)
            if !cached.isEmpty {
                setActivities(cached)
                cachedOffset = cached.count
                hasMoreActivities = cached.count >= pageSize
                isConnected = true
                didCompleteFirstLoad = true
            }
        } catch {
            // Silent
        }
        isLoading = false
    }

    func loadInitial() async {
        guard isConnected else { return }
        isUsingDemoActivities = false
        isLoading = true
        errorMessage = nil
        resetPagination()

        do {
            let cached = try await cache.fetchCachedActivities(limit: pageSize, offset: 0)
            if !cached.isEmpty {
                setActivities(cached)
                cachedOffset = cached.count
                hasMoreActivities = cached.count >= pageSize
            } else {
                errorMessage = "Pull refresh to load activities"
            }
        } catch {
            if activities.isEmpty {
                errorMessage = "Could not load activities"
            }
        }
        isLoading = false
    }

    func firstTimeLoad() async {
        guard isConnected else { return }
        isUsingDemoActivities = false
        isLoading = true
        errorMessage = nil
        resetPagination()

        do {
            let fetched = try await service.fetchActivities(page: 1, perPage: pageSize)
            if !fetched.isEmpty {
                try await cache.upsertActivities(fetched)
                setActivities(fetched)
                cachedOffset = fetched.count
                stravaPage = 2
            }
            hasMoreActivities = fetched.count >= pageSize
            if !fetched.isEmpty { didCompleteFirstLoad = true }
        } catch StravaError.tokenExpired, StravaError.refreshFailed {
            isConnected = false
            setActivities([])
            errorMessage = "Session expired. Please reconnect."
        } catch StravaError.notConnected {
            isConnected = false
            setActivities([])
        } catch {
            errorMessage = "Could not load activities"
        }
        isLoading = false
    }

    var isOnCooldown: Bool {
        guard let last = lastRefreshDate else { return false }
        return Date().timeIntervalSince(last) < refreshCooldown
    }

    func refreshWithRateLimit() async {
        guard isConnected else { return }

        if isOnCooldown {
            refreshCooldownActive = true
            try? await Task.sleep(for: .seconds(2))
            refreshCooldownActive = false
            return
        }

        await refresh()
    }

    func refresh() async {
        guard isConnected else { return }
        isLoading = true
        errorMessage = nil

        await syncNewActivities()

        do {
            resetPagination()
            let cached = try await cache.fetchCachedActivities(limit: pageSize, offset: 0)
            setActivities(cached)
            cachedOffset = cached.count
            hasMoreActivities = cached.count >= pageSize
        } catch {
            // Keep existing activities visible
        }

        lastRefreshDate = Date()
        isLoading = false
    }

    func loadMore() async {
        guard isConnected, !isLoadingMore, hasMoreActivities else { return }
        isLoadingMore = true

        do {
            let moreCached = try await cache.fetchCachedActivities(limit: pageSize, offset: cachedOffset)
            if !moreCached.isEmpty {
                appendActivities(moreCached)
                cachedOffset += moreCached.count
                hasMoreActivities = moreCached.count >= pageSize
            } else {
                let oldestDate = parseStravaDate(try await cache.oldestActivityDate())
                let fetched = try await service.fetchActivities(
                    page: stravaPage,
                    perPage: pageSize,
                    before: oldestDate
                )

                if !fetched.isEmpty {
                    try await cache.upsertActivities(fetched)
                    appendActivities(fetched)
                    stravaPage += 1
                    cachedOffset += fetched.count
                }
                hasMoreActivities = fetched.count >= pageSize
            }
        } catch {
            // Silently fail, user can retry by scrolling again
        }

        isLoadingMore = false
    }

    func handleCallback(_ url: URL) async {
        do {
            try await service.handleCallbackURL(url)
            isUsingDemoActivities = false
            isConnected = service.isConnected
            if isConnected {
                await firstTimeLoad()
            }
        } catch {
            errorMessage = "Authentication failed"
        }
    }

    private func syncNewActivities() async {
        do {
            let latestDateStr = try await cache.latestActivityDate()
            let afterDate = parseStravaDate(latestDateStr)

            var page = 1
            var allNew: [StravaActivity] = []

            while true {
                let fetched = try await service.fetchActivities(
                    page: page,
                    perPage: pageSize,
                    after: afterDate
                )
                guard !fetched.isEmpty else { break }
                allNew.append(contentsOf: fetched)
                if fetched.count < pageSize { break }
                page += 1
            }

            if !allNew.isEmpty {
                try await cache.upsertActivities(allNew)
                let countBefore = activities.count
                prependActivities(allNew)
                cachedOffset += activities.count - countBefore
            }
        } catch {
            // Sync silently fails — cached data still available
        }
    }

    private func resetPagination() {
        cachedOffset = 0
        stravaPage = 1
        hasMoreActivities = true
        cachedTotalKnown = false
    }

    private func parseStravaDate(_ dateString: String?) -> Date? {
        guard let dateString else { return nil }
        return Self.isoFormatter.date(from: dateString)
    }

    func toActivityHighlight(_ activity: StravaActivity) -> ActivityHighlight {
        let type = activity.sportType ?? activity.type
        let typeLower = type.lowercased()
        let accent = StravaActivityType.accent(for: type)
        let gradient = StravaActivityType.gradientColors(for: type)

        let distanceKm = activity.distance / 1000.0
        let hasDistance = distanceKm >= 0.1
        let distanceStr = hasDistance ? String(format: "%.1f km", distanceKm) : ""

        let isRideOrCycle = typeLower.contains("ride") || typeLower.contains("cycle")

        let paceStr: String = {
            if isRideOrCycle {
                let speedKmh = (activity.averageSpeed ?? 0) * 3.6
                return speedKmh > 0 ? String(format: "%.1f km/h", speedKmh) : "--"
            } else {
                guard distanceKm > 0 else { return "--" }
                let paceSeconds = Double(activity.movingTime) / distanceKm
                let paceMin = Int(paceSeconds) / 60
                let paceSec = Int(paceSeconds) % 60
                return String(format: "%d'%02d\"", paceMin, paceSec)
            }
        }()

        let durationStr: String = {
            let hours = activity.movingTime / 3600
            let minutes = (activity.movingTime % 3600) / 60
            let seconds = activity.movingTime % 60
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            }
            return String(format: "%d:%02d", minutes, seconds)
        }()

        let parsedDate = Self.isoFormatter.date(from: activity.startDateLocal)

        let dateStr: String = {
            if let date = parsedDate {
                return Self.displayDateFormatter.string(from: date)
            }
            return ""
        }()

        var hasRealRoute = false
        let linePoints: [CGPoint] = {
            if let polyline = activity.map?.summaryPolyline, !polyline.isEmpty {
                let points = PolylineDecoder.normalizedPoints(from: polyline)
                if points.count >= 2 { return points }
            }
            return []
        }()
        hasRealRoute = !linePoints.isEmpty

        let elapsedStr: String = {
            let hours = activity.elapsedTime / 3600
            let minutes = (activity.elapsedTime % 3600) / 60
            let seconds = activity.elapsedTime % 60
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            }
            return String(format: "%d:%02d", minutes, seconds)
        }()

        let elevStr: String = {
            let gain = activity.totalElevationGain
            return gain > 0 ? String(format: "%.0f m", gain) : "--"
        }()

        let maxSpeedStr: String = {
            guard let ms = activity.maxSpeed, ms > 0 else { return "--" }
            if isRideOrCycle {
                return String(format: "%.1f km/h", ms * 3.6)
            } else {
                let paceSeconds = 1000.0 / ms
                let paceMin = Int(paceSeconds) / 60
                let paceSec = Int(paceSeconds) % 60
                return String(format: "%d'%02d\"/km", paceMin, paceSec)
            }
        }()

        let avgHR: String? = {
            guard activity.hasHeartrate == true, let hr = activity.averageHeartrate, hr > 0 else { return nil }
            return String(format: "%.0f bpm", hr)
        }()

        return ActivityHighlight(
            id: "\(activity.id)",
            title: activity.name,
            date: dateStr,
            distance: distanceStr,
            pace: paceStr,
            duration: durationStr,
            systemImage: StravaActivityType.systemImage(for: type),
            summarySymbol: StravaActivityType.systemImage(for: type),
            accent: accent,
            backgroundTop: gradient.top,
            backgroundBottom: gradient.bottom,
            linePoints: linePoints,
            hasRealRoute: hasRealRoute,
            hasDistance: hasDistance,
            startDate: parsedDate,
            activityName: activity.name,
            activityType: type,
            elapsedTime: elapsedStr,
            elevationGain: elevStr,
            maxSpeed: maxSpeedStr,
            averageHeartrate: avgHR,
            distanceRaw: activity.distance,
            movingTimeRaw: activity.movingTime,
            elapsedTimeRaw: activity.elapsedTime
        )
    }

    func deleteActivity(activityId: String) async -> Bool {
        guard let stravaId = Int(activityId) else { return false }
        do {
            try await cache.deleteActivity(stravaActivityId: stravaId)
            try? await detailCache.deleteDetail(stravaActivityId: stravaId)
            activities.removeAll { $0.id == stravaId }
            activityHighlights.removeAll { $0.id == activityId }
            highlightCache.removeValue(forKey: stravaId)
            if cachedOffset > 0 { cachedOffset -= 1 }
            return true
        } catch {
            return false
        }
    }

    func fetchActivityDetail(stravaId: Int) async {
        isLoadingDetail = true
        currentActivityDetail = nil
        detailError = nil

        do {
            if let cached = try await detailCache.fetchCachedDetail(stravaActivityId: stravaId) {
                currentActivityDetail = cached
                isLoadingDetail = false
                return
            }

            let detail = try await service.fetchActivityDetail(id: stravaId)
            currentActivityDetail = detail

            try? await detailCache.upsertDetail(detail)
        } catch {
            detailError = "Could not load activity details"
        }

        isLoadingDetail = false
    }

    private func defaultLinePoints(for type: String) -> [CGPoint] {
        [
            CGPoint(x: 0.12, y: 0.60), CGPoint(x: 0.25, y: 0.52),
            CGPoint(x: 0.38, y: 0.55), CGPoint(x: 0.50, y: 0.42),
            CGPoint(x: 0.62, y: 0.46), CGPoint(x: 0.75, y: 0.35),
            CGPoint(x: 0.88, y: 0.30)
        ]
    }
}
