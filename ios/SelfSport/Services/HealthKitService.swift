import HealthKit
import Foundation

final class HealthKitService {
    private let healthStore = HKHealthStore()

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isAvailable else { throw HealthKitError.unavailable }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceCycling),
            HKQuantityType(.distanceSwimming)
        ]

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }

    func fetchWorkouts(limit: Int = 20, offset: Int = 0) async throws -> [HKWorkout] {
        guard isAvailable else { throw HealthKitError.unavailable }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: nil,
                limit: limit + offset,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let workouts = (samples as? [HKWorkout]) ?? []
                let paginated = offset < workouts.count ? Array(workouts.dropFirst(offset)) : []
                continuation.resume(returning: paginated)
            }
            self.healthStore.execute(query)
        }
    }

    func distanceMeters(from workout: HKWorkout) -> Double {
        let identifiers: [HKQuantityTypeIdentifier] = [
            .distanceWalkingRunning, .distanceCycling, .distanceSwimming,
            .distanceDownhillSnowSports, .distanceWheelchair
        ]
        for id in identifiers {
            if let dist = workout.statistics(for: HKQuantityType(id))?.sumQuantity()?.doubleValue(for: .meter()),
               dist > 0 {
                return dist
            }
        }
        return 0
    }

    func calories(from workout: HKWorkout) -> Double {
        return workout.statistics(for: HKQuantityType(.activeEnergyBurned))?
            .sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
    }

    func averageHeartRate(from workout: HKWorkout) -> Double? {
        workout.statistics(for: HKQuantityType(.heartRate))?
            .averageQuantity()?
            .doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
    }

    func elevationGain(from workout: HKWorkout) -> Double? {
        return nil
    }
}

enum HealthKitError: Error, LocalizedError, Sendable {
    case unavailable
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .unavailable: return "Apple Health is not available on this device."
        case .unauthorized: return "Permission to access Apple Health was denied."
        }
    }
}
