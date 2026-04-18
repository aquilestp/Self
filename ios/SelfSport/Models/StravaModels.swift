import Foundation
import SwiftUI

struct StravaTokenResponse: Codable, Sendable {
    let tokenType: String
    let expiresAt: Int
    let expiresIn: Int
    let refreshToken: String
    let accessToken: String
    let athlete: StravaAthlete?

    enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case expiresAt = "expires_at"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
        case athlete
    }
}

struct StravaAthlete: Codable, Sendable {
    let id: Int
    let firstname: String?
    let lastname: String?
    let profile: String?
}

struct StravaActivity: Codable, Sendable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let sportType: String?
    let distance: Double
    let movingTime: Int
    let elapsedTime: Int
    let totalElevationGain: Double
    let startDateLocal: String
    let map: StravaMap?
    let averageSpeed: Double?
    let maxSpeed: Double?
    let hasHeartrate: Bool?
    let averageHeartrate: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, type, distance, map
        case sportType = "sport_type"
        case movingTime = "moving_time"
        case elapsedTime = "elapsed_time"
        case totalElevationGain = "total_elevation_gain"
        case startDateLocal = "start_date_local"
        case averageSpeed = "average_speed"
        case maxSpeed = "max_speed"
        case hasHeartrate = "has_heartrate"
        case averageHeartrate = "average_heartrate"
    }
}

struct StravaMap: Codable, Sendable {
    let id: String
    let summaryPolyline: String?
    let resourceState: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case summaryPolyline = "summary_polyline"
        case resourceState = "resource_state"
    }
}

enum StravaActivityType {
    static func systemImage(for type: String) -> String {
        switch type.lowercased() {
        case "run", "virtualrun": return "figure.run"
        case "trailrun": return "mountain.2"
        case "ride", "virtualride", "ebikeride": return "figure.outdoor.cycle"
        case "swim": return "figure.pool.swim"
        case "hike": return "figure.hiking"
        case "walk": return "figure.walk"
        case "workout", "weighttraining": return "dumbbell"
        case "yoga": return "figure.yoga"
        case "crossfit": return "figure.cross.training"
        case "rowing", "canoeing", "kayaking": return "oar.2.crossed"
        case "skiing", "alpineski", "nordicski", "backcountryski": return "figure.skiing.downhill"
        case "snowboard": return "figure.snowboarding"
        case "rockclimbing": return "figure.climbing"
        case "surfing": return "figure.surfing"
        case "golf": return "figure.golf"
        case "tennis", "pickleball": return "figure.tennis"
        case "soccer": return "soccerball"
        case "basketball": return "basketball"
        default: return "figure.mixed.cardio"
        }
    }

    static func accent(for type: String) -> Color {
        switch type.lowercased() {
        case "run", "virtualrun":
            return Color(red: 0.70, green: 0.64, blue: 0.57)
        case "trailrun":
            return Color(red: 0.82, green: 0.67, blue: 0.20)
        case "ride", "virtualride", "ebikeride":
            return Color(red: 0.30, green: 0.55, blue: 0.85)
        case "swim":
            return Color(red: 0.20, green: 0.72, blue: 0.68)
        case "hike":
            return Color(red: 0.45, green: 0.62, blue: 0.32)
        case "walk":
            return Color(red: 0.58, green: 0.52, blue: 0.70)
        case "yoga":
            return Color(red: 0.72, green: 0.50, blue: 0.60)
        default:
            return Color(red: 0.60, green: 0.55, blue: 0.50)
        }
    }

    static func gradientColors(for type: String) -> (top: Color, bottom: Color) {
        switch type.lowercased() {
        case "run", "virtualrun":
            return (Color(red: 0.14, green: 0.14, blue: 0.16), Color(red: 0.03, green: 0.03, blue: 0.05))
        case "trailrun":
            return (Color(red: 0.30, green: 0.20, blue: 0.17), Color(red: 0.05, green: 0.05, blue: 0.06))
        case "ride", "virtualride", "ebikeride":
            return (Color(red: 0.10, green: 0.16, blue: 0.24), Color(red: 0.03, green: 0.04, blue: 0.08))
        case "swim":
            return (Color(red: 0.08, green: 0.18, blue: 0.20), Color(red: 0.02, green: 0.05, blue: 0.07))
        case "hike":
            return (Color(red: 0.12, green: 0.16, blue: 0.10), Color(red: 0.04, green: 0.05, blue: 0.03))
        case "walk":
            return (Color(red: 0.14, green: 0.12, blue: 0.18), Color(red: 0.04, green: 0.03, blue: 0.06))
        default:
            return (Color(red: 0.14, green: 0.14, blue: 0.14), Color(red: 0.04, green: 0.04, blue: 0.04))
        }
    }
}
