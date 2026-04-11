import Foundation

nonisolated struct StravaActivityDetail: Codable, Sendable, Equatable {
    let id: Int
    let name: String
    let description: String?
    let type: String
    let sportType: String?
    let distance: Double
    let movingTime: Int
    let elapsedTime: Int
    let totalElevationGain: Double
    let startDateLocal: String
    let calories: Double?
    let deviceName: String?
    let averageSpeed: Double?
    let maxSpeed: Double?
    let averageHeartrate: Double?
    let maxHeartrate: Double?
    let hasHeartrate: Bool?
    let averageCadence: Double?
    let averageWatts: Double?
    let maxWatts: Int?
    let weightedAverageWatts: Int?
    let kilojoules: Double?
    let deviceWatts: Bool?
    let averageTemp: Double?
    let locationCity: String?
    let locationState: String?
    let locationCountry: String?
    let segmentEfforts: [StravaSegmentEffort]?
    let bestEfforts: [StravaBestEffort]?
    let splitsMetric: [StravaSplit]?
    let splitsStandard: [StravaSplit]?
    let laps: [StravaLap]?

    nonisolated enum CodingKeys: String, CodingKey {
        case id, name, description, type, distance, calories, laps
        case sportType = "sport_type"
        case movingTime = "moving_time"
        case elapsedTime = "elapsed_time"
        case totalElevationGain = "total_elevation_gain"
        case startDateLocal = "start_date_local"
        case deviceName = "device_name"
        case averageSpeed = "average_speed"
        case maxSpeed = "max_speed"
        case averageHeartrate = "average_heartrate"
        case maxHeartrate = "max_heartrate"
        case hasHeartrate = "has_heartrate"
        case averageCadence = "average_cadence"
        case averageWatts = "average_watts"
        case maxWatts = "max_watts"
        case weightedAverageWatts = "weighted_average_watts"
        case kilojoules
        case deviceWatts = "device_watts"
        case averageTemp = "average_temp"
        case locationCity = "location_city"
        case locationState = "location_state"
        case locationCountry = "location_country"
        case segmentEfforts = "segment_efforts"
        case bestEfforts = "best_efforts"
        case splitsMetric = "splits_metric"
        case splitsStandard = "splits_standard"
    }
}

nonisolated struct StravaSegmentEffort: Codable, Sendable, Identifiable, Equatable {
    let id: Int
    let name: String
    let elapsedTime: Int
    let movingTime: Int
    let distance: Double
    let averageHeartrate: Double?
    let maxHeartrate: Double?
    let averageCadence: Double?
    let averageWatts: Double?
    let prRank: Int?
    let achievements: [StravaAchievement]?
    let segment: StravaSegmentSummary?

    nonisolated enum CodingKeys: String, CodingKey {
        case id, name, distance, achievements, segment
        case elapsedTime = "elapsed_time"
        case movingTime = "moving_time"
        case averageHeartrate = "average_heartrate"
        case maxHeartrate = "max_heartrate"
        case averageCadence = "average_cadence"
        case averageWatts = "average_watts"
        case prRank = "pr_rank"
    }
}

nonisolated struct StravaSegmentSummary: Codable, Sendable, Equatable {
    let id: Int
    let name: String
    let distance: Double
    let averageGrade: Double?
    let maximumGrade: Double?
    let elevationHigh: Double?
    let elevationLow: Double?
    let climbCategory: Int?

    nonisolated enum CodingKeys: String, CodingKey {
        case id, name, distance
        case averageGrade = "average_grade"
        case maximumGrade = "maximum_grade"
        case elevationHigh = "elevation_high"
        case elevationLow = "elevation_low"
        case climbCategory = "climb_category"
    }
}

nonisolated struct StravaAchievement: Codable, Sendable, Equatable {
    let typeId: Int
    let type: String
    let rank: Int

    nonisolated enum CodingKeys: String, CodingKey {
        case typeId = "type_id"
        case type, rank
    }
}

nonisolated struct StravaBestEffort: Codable, Sendable, Identifiable, Equatable {
    let id: Int
    let name: String
    let elapsedTime: Int
    let movingTime: Int
    let distance: Double
    let prRank: Int?
    let achievements: [StravaAchievement]?

    nonisolated enum CodingKeys: String, CodingKey {
        case id, name, distance, achievements
        case elapsedTime = "elapsed_time"
        case movingTime = "moving_time"
        case prRank = "pr_rank"
    }
}

nonisolated struct StravaSplit: Codable, Sendable, Equatable {
    let distance: Double
    let elapsedTime: Int
    let movingTime: Int
    let elevationDifference: Double?
    let averageSpeed: Double
    let averageHeartrate: Double?
    let paceZone: Int?
    let split: Int

    nonisolated enum CodingKeys: String, CodingKey {
        case distance, split
        case elapsedTime = "elapsed_time"
        case movingTime = "moving_time"
        case elevationDifference = "elevation_difference"
        case averageSpeed = "average_speed"
        case averageHeartrate = "average_heartrate"
        case paceZone = "pace_zone"
    }
}

nonisolated struct StravaLap: Codable, Sendable, Identifiable, Equatable {
    let id: Int
    let name: String
    let elapsedTime: Int
    let movingTime: Int
    let distance: Double
    let averageSpeed: Double
    let maxSpeed: Double
    let totalElevationGain: Double?
    let averageHeartrate: Double?
    let maxHeartrate: Double?
    let lapIndex: Int

    nonisolated enum CodingKeys: String, CodingKey {
        case id, name, distance
        case elapsedTime = "elapsed_time"
        case movingTime = "moving_time"
        case averageSpeed = "average_speed"
        case maxSpeed = "max_speed"
        case totalElevationGain = "total_elevation_gain"
        case averageHeartrate = "average_heartrate"
        case maxHeartrate = "max_heartrate"
        case lapIndex = "lap_index"
    }
}
