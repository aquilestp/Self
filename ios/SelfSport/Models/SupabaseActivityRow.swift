import Foundation

nonisolated struct SupabaseActivityRow: Codable, Sendable {
    let id: String?
    let userId: String
    let stravaActivityId: Int
    let name: String
    let type: String
    let sportType: String?
    let distance: Double
    let movingTime: Int
    let elapsedTime: Int
    let totalElevationGain: Double
    let startDateLocal: String
    let summaryPolyline: String?
    let averageSpeed: Double?
    let maxSpeed: Double?
    let hasHeartrate: Bool?
    let averageHeartrate: Double?
    let syncedByWebhook: Bool?

    nonisolated enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case stravaActivityId = "strava_activity_id"
        case name, type
        case sportType = "sport_type"
        case distance
        case movingTime = "moving_time"
        case elapsedTime = "elapsed_time"
        case totalElevationGain = "total_elevation_gain"
        case startDateLocal = "start_date_local"
        case summaryPolyline = "summary_polyline"
        case averageSpeed = "average_speed"
        case maxSpeed = "max_speed"
        case hasHeartrate = "has_heartrate"
        case averageHeartrate = "average_heartrate"
        case syncedByWebhook = "synced_by_webhook"
    }

    func toStravaActivity() -> StravaActivity {
        let map: StravaMap? = summaryPolyline.map {
            StravaMap(id: "\(stravaActivityId)", summaryPolyline: $0, resourceState: nil)
        }
        return StravaActivity(
            id: stravaActivityId,
            name: name,
            type: type,
            sportType: sportType,
            distance: distance,
            movingTime: movingTime,
            elapsedTime: elapsedTime,
            totalElevationGain: totalElevationGain,
            startDateLocal: startDateLocal,
            map: map,
            averageSpeed: averageSpeed,
            maxSpeed: maxSpeed,
            hasHeartrate: hasHeartrate,
            averageHeartrate: averageHeartrate
        )
    }

    static func from(stravaActivity: StravaActivity, userId: String) -> SupabaseActivityRow {
        SupabaseActivityRow(
            id: nil,
            userId: userId,
            stravaActivityId: stravaActivity.id,
            name: stravaActivity.name,
            type: stravaActivity.type,
            sportType: stravaActivity.sportType,
            distance: stravaActivity.distance,
            movingTime: stravaActivity.movingTime,
            elapsedTime: stravaActivity.elapsedTime,
            totalElevationGain: stravaActivity.totalElevationGain,
            startDateLocal: stravaActivity.startDateLocal,
            summaryPolyline: stravaActivity.map?.summaryPolyline,
            averageSpeed: stravaActivity.averageSpeed,
            maxSpeed: stravaActivity.maxSpeed,
            hasHeartrate: stravaActivity.hasHeartrate,
            averageHeartrate: stravaActivity.averageHeartrate,
            syncedByWebhook: false
        )
    }
}
