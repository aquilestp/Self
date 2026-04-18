import HealthKit
import SwiftUI

nonisolated enum HealthKitActivityType {
    static func systemImage(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "figure.run"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .hiking: return "figure.hiking"
        case .walking: return "figure.walk"
        case .yoga: return "figure.yoga"
        case .crossTraining, .highIntensityIntervalTraining,
             .functionalStrengthTraining, .traditionalStrengthTraining:
            return "dumbbell"
        case .rowing: return "oar.2.crossed"
        case .downhillSkiing, .crossCountrySkiing, .snowboarding:
            return "figure.skiing.downhill"
        case .climbing: return "figure.climbing"
        case .surfingSports: return "figure.surfing"
        case .golf: return "figure.golf"
        case .tennis, .tableTennis, .squash, .racquetball:
            return "figure.tennis"
        case .soccer: return "soccerball"
        case .basketball: return "basketball"
        case .volleyball: return "volleyball"
        case .baseball, .softball: return "baseball"
        case .americanFootball: return "football"
        case .rugby: return "figure.rugby"
        case .boxing, .kickboxing, .martialArts: return "figure.boxing"
        case .dance, .barre: return "figure.dance"
        case .pilates: return "figure.pilates"
        case .elliptical: return "figure.elliptical"
        case .stairClimbing: return "figure.stair.stepper"
        case .paddleSports: return "figure.rower"
        case .waterFitness: return "figure.water.fitness"
        case .wheelchairWalkPace, .wheelchairRunPace: return "wheelchair"
        default: return "figure.mixed.cardio"
        }
    }

    static func displayName(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "Run"
        case .cycling: return "Ride"
        case .swimming: return "Swim"
        case .hiking: return "Hike"
        case .walking: return "Walk"
        case .yoga: return "Yoga"
        case .crossTraining: return "Cross Training"
        case .highIntensityIntervalTraining: return "HIIT"
        case .functionalStrengthTraining: return "Functional Training"
        case .traditionalStrengthTraining: return "Strength Training"
        case .rowing: return "Rowing"
        case .downhillSkiing: return "Skiing"
        case .crossCountrySkiing: return "Cross-Country Ski"
        case .snowboarding: return "Snowboarding"
        case .climbing: return "Climbing"
        case .surfingSports: return "Surfing"
        case .golf: return "Golf"
        case .tennis: return "Tennis"
        case .tableTennis: return "Table Tennis"
        case .squash: return "Squash"
        case .racquetball: return "Racquetball"
        case .soccer: return "Soccer"
        case .basketball: return "Basketball"
        case .volleyball: return "Volleyball"
        case .baseball: return "Baseball"
        case .softball: return "Softball"
        case .americanFootball: return "Football"
        case .rugby: return "Rugby"
        case .boxing: return "Boxing"
        case .kickboxing: return "Kickboxing"
        case .martialArts: return "Martial Arts"
        case .dance: return "Dance"
        case .barre: return "Barre"
        case .pilates: return "Pilates"
        case .elliptical: return "Elliptical"
        case .stairClimbing: return "Stair Climbing"
        case .paddleSports: return "Paddle Sports"
        case .waterFitness: return "Water Fitness"
        case .wheelchairWalkPace, .wheelchairRunPace: return "Wheelchair"
        default: return "Workout"
        }
    }

    static func accent(for type: HKWorkoutActivityType) -> Color {
        switch type {
        case .running:
            return Color(red: 0.70, green: 0.64, blue: 0.57)
        case .cycling:
            return Color(red: 0.30, green: 0.55, blue: 0.85)
        case .swimming:
            return Color(red: 0.20, green: 0.72, blue: 0.68)
        case .hiking:
            return Color(red: 0.45, green: 0.62, blue: 0.32)
        case .walking:
            return Color(red: 0.58, green: 0.52, blue: 0.70)
        case .yoga:
            return Color(red: 0.72, green: 0.50, blue: 0.60)
        case .crossTraining, .highIntensityIntervalTraining,
             .functionalStrengthTraining, .traditionalStrengthTraining:
            return Color(red: 0.88, green: 0.46, blue: 0.28)
        case .rowing, .paddleSports:
            return Color(red: 0.24, green: 0.62, blue: 0.78)
        case .downhillSkiing, .crossCountrySkiing, .snowboarding:
            return Color(red: 0.62, green: 0.78, blue: 0.90)
        case .tennis, .tableTennis, .squash, .racquetball:
            return Color(red: 0.72, green: 0.78, blue: 0.32)
        default:
            return Color(red: 0.60, green: 0.55, blue: 0.50)
        }
    }

    static func gradientColors(for type: HKWorkoutActivityType) -> (top: Color, bottom: Color) {
        switch type {
        case .running:
            return (Color(red: 0.14, green: 0.14, blue: 0.16), Color(red: 0.03, green: 0.03, blue: 0.05))
        case .cycling:
            return (Color(red: 0.10, green: 0.16, blue: 0.24), Color(red: 0.03, green: 0.04, blue: 0.08))
        case .swimming:
            return (Color(red: 0.08, green: 0.18, blue: 0.20), Color(red: 0.02, green: 0.05, blue: 0.07))
        case .hiking:
            return (Color(red: 0.12, green: 0.16, blue: 0.10), Color(red: 0.04, green: 0.05, blue: 0.03))
        case .walking:
            return (Color(red: 0.14, green: 0.12, blue: 0.18), Color(red: 0.04, green: 0.03, blue: 0.06))
        case .yoga:
            return (Color(red: 0.18, green: 0.12, blue: 0.16), Color(red: 0.06, green: 0.03, blue: 0.05))
        case .crossTraining, .highIntensityIntervalTraining,
             .functionalStrengthTraining, .traditionalStrengthTraining:
            return (Color(red: 0.22, green: 0.12, blue: 0.08), Color(red: 0.06, green: 0.03, blue: 0.02))
        default:
            return (Color(red: 0.14, green: 0.14, blue: 0.14), Color(red: 0.04, green: 0.04, blue: 0.04))
        }
    }
}
