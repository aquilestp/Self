import HealthKit
import SwiftUI

@Observable
final class HealthKitViewModel {
    var activityHighlights: [ActivityHighlight] = []
    var isLoading: Bool = false
    var isConnected: Bool = false
    var hasMoreActivities: Bool = true
    var isLoadingMore: Bool = false
    var errorMessage: String?
    var didCompleteFirstLoad: Bool = false

    private let service = HealthKitService()
    private let pageSize: Int = 20
    private var loadedOffset: Int = 0

    private static let connectedKey = "healthkit_connected"

    private static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    func checkConnection() {
        isConnected = service.isAvailable
            && UserDefaults.standard.bool(forKey: Self.connectedKey)
    }

    func connect() async {
        guard service.isAvailable else {
            errorMessage = "Apple Health is not available on this device."
            return
        }
        do {
            try await service.requestAuthorization()
            UserDefaults.standard.set(true, forKey: Self.connectedKey)
            isConnected = true
            ActiveSource.current = .appleHealth
            await loadInitial()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func disconnect() {
        isConnected = false
        UserDefaults.standard.set(false, forKey: Self.connectedKey)
        if ActiveSource.current == .appleHealth {
            ActiveSource.current = .strava
        }
        activityHighlights = []
        loadedOffset = 0
        hasMoreActivities = true
        didCompleteFirstLoad = false
    }

    func loadInitial() async {
        guard isConnected else { return }
        isLoading = true
        loadedOffset = 0
        do {
            let workouts = try await service.fetchWorkouts(limit: pageSize, offset: 0)
            activityHighlights = workouts.map { toActivityHighlight($0) }
            loadedOffset = workouts.count
            hasMoreActivities = workouts.count >= pageSize
        } catch {
            errorMessage = "Could not load workouts from Apple Health."
        }
        isLoading = false
        didCompleteFirstLoad = true
    }

    func loadMore() async {
        guard isConnected, hasMoreActivities, !isLoadingMore else { return }
        isLoadingMore = true
        do {
            let workouts = try await service.fetchWorkouts(limit: pageSize, offset: loadedOffset)
            let newHighlights = workouts.map { toActivityHighlight($0) }
            let existingIds = Set(activityHighlights.map(\.id))
            let unique = newHighlights.filter { !existingIds.contains($0.id) }
            activityHighlights.append(contentsOf: unique)
            loadedOffset += workouts.count
            hasMoreActivities = workouts.count >= pageSize
        } catch {
        }
        isLoadingMore = false
    }

    func refresh() async {
        await loadInitial()
    }

    private func toActivityHighlight(_ workout: HKWorkout) -> ActivityHighlight {
        let type = workout.workoutActivityType
        let systemImage = HealthKitActivityType.systemImage(for: type)
        let accent = HealthKitActivityType.accent(for: type)
        let gradient = HealthKitActivityType.gradientColors(for: type)
        let typeName = HealthKitActivityType.displayName(for: type)

        let distanceMeters = service.distanceMeters(from: workout)
        let distanceKm = distanceMeters / 1000.0
        let hasDistance = distanceKm > 0.05

        let durationSeconds = Int(workout.duration)
        let durationStr = formatDuration(durationSeconds)
        let dateStr = Self.displayDateFormatter.string(from: workout.startDate)

        let paceStr: String
        if hasDistance && distanceKm > 0 {
            let paceSecPerKm = workout.duration / distanceKm
            paceStr = formatPace(Int(paceSecPerKm))
        } else {
            paceStr = "--"
        }

        let distanceStr = hasDistance ? String(format: "%.2f km", distanceKm) : "--"

        let avgHR = service.averageHeartRate(from: workout)
        let hrStr = avgHR.map { String(format: "%.0f bpm", $0) }

        let elevation = service.elevationGain(from: workout)
        let elevationStr = elevation.map { String(format: "%.0f m", $0) } ?? "--"

        let workoutName = workout.metadata?[HKMetadataKeyWorkoutBrandName] as? String ?? typeName

        return ActivityHighlight(
            id: workout.uuid.uuidString,
            title: workoutName,
            date: dateStr,
            distance: distanceStr,
            pace: paceStr,
            duration: durationStr,
            systemImage: systemImage,
            summarySymbol: systemImage,
            accent: accent,
            backgroundTop: gradient.top,
            backgroundBottom: gradient.bottom,
            linePoints: [],
            hasRealRoute: false,
            hasDistance: hasDistance,
            startDate: workout.startDate,
            activityName: workoutName,
            activityType: typeName,
            elapsedTime: durationStr,
            elevationGain: elevationStr,
            maxSpeed: "--",
            averageHeartrate: hrStr,
            distanceRaw: distanceMeters,
            movingTimeRaw: durationSeconds,
            elapsedTimeRaw: durationSeconds
        )
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

    private func formatPace(_ secondsPerKm: Int) -> String {
        guard secondsPerKm > 0 else { return "--" }
        let m = secondsPerKm / 60
        let s = secondsPerKm % 60
        return String(format: "%d:%02d /km", m, s)
    }
}
