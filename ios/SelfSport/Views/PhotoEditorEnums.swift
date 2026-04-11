import SwiftUI

nonisolated enum FilterMode: String {
    case none
    case city
    case races
}

nonisolated enum StatWidgetType: String, CaseIterable, Identifiable {
    case distance = "Distance"
    case distPace = "Dist+Pace"
    case threeStats = "3 Stats"
    case titleCard = "Title Card"
    case stack = "Stack"
    case bold = "Bold"
    case impact = "Impact"
    case poster = "Poster"
    case heroStat = "Hero Stat"
    case wide = "Wide"
    case tower = "Tower"
    case routeClean = "Route Clean"
    case movingTimeClean = "Moving Clean"
    case elapsedTimeClean = "Elapsed Clean"
    case avgHeartRate = "Avg HR"
    case hrPulseDots = "HR Pulse"
    case weeklyKm = "Weekly KM"
    case lastWeekKm = "Last Week KM"
    case monthlyKm = "Monthly KM"
    case lastMonthKm = "Last Month KM"
    case elevationGain = "Elevation"
    case splits = "Splits"
    case splitsTable = "Splits Table"
    case splitsFastest = "Splits Fastest"
    case splitsBars = "Splits Bars"
    case bestEfforts = "Best Efforts"
    case distanceWords = "Distance Words"
    case fullBanner = "Full Banner"
    case fullBannerBottom = "Full Banner Bottom"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .distance: return "ruler"
        case .distPace: return "speedometer"
        case .threeStats: return "chart.bar"
        case .titleCard: return "textformat"
        case .stack: return "square.stack"
        case .bold: return "flame.fill"
        case .impact: return "bolt.fill"
        case .poster: return "trophy.fill"
        case .heroStat: return "number"
        case .wide: return "arrow.left.and.right"
        case .tower: return "arrow.up.and.down"
        case .routeClean: return "point.topleft.down.to.point.bottomright.curvepath.fill"
        case .movingTimeClean: return "timer"
        case .elapsedTimeClean: return "clock"
        case .avgHeartRate: return "heart.fill"
        case .hrPulseDots: return "waveform.path.ecg"
        case .weeklyKm: return "figure.run"
        case .lastWeekKm: return "calendar.badge.clock"
        case .monthlyKm: return "calendar"
        case .lastMonthKm: return "calendar.badge.minus"
        case .elevationGain: return "mountain.2.fill"
        case .splits: return "chart.bar.xaxis"
        case .splitsTable: return "list.number"
        case .splitsFastest: return "bolt.horizontal.fill"
        case .splitsBars: return "chart.bar.doc.horizontal"
        case .bestEfforts: return "medal.fill"
        case .distanceWords: return "textformat.abc"
        case .fullBanner: return "rectangle.fill"
        case .fullBannerBottom: return "rectangle.bottomhalf.filled"
        }
    }

    var supportsGlass: Bool {
        switch self {
        case .routeClean, .bold, .impact, .titleCard:
            return false
        default:
            return true
        }
    }

    var isWeeklyAggregate: Bool {
        switch self {
        case .weeklyKm, .lastWeekKm, .monthlyKm, .lastMonthKm: return true
        default: return false
        }
    }

    var requiresHeartRate: Bool {
        switch self {
        case .avgHeartRate, .hrPulseDots: return true
        case .weeklyKm, .lastWeekKm, .monthlyKm, .lastMonthKm, .elevationGain, .splits, .splitsTable, .splitsFastest, .splitsBars, .bestEfforts, .distanceWords, .fullBanner, .fullBannerBottom: return false
        default: return false
        }
    }

    var requiresDetail: Bool {
        switch self {
        case .splits, .splitsTable, .splitsFastest, .splitsBars, .bestEfforts: return true
        default: return false
        }
    }

    var isDistanceWords: Bool {
        self == .distanceWords
    }

    var supportsFontStyle: Bool {
        switch self {
        case .distanceWords: return true
        default: return false
        }
    }

    var supportsBasicFieldVisibility: Bool {
        switch self {
        case .distance, .distPace, .threeStats, .titleCard, .stack:
            return true
        default:
            return false
        }
    }
}

nonisolated enum CityFilter: Int, CaseIterable, Identifiable {
    case none = 0
    case skyline
    case postcard
    case neon
    case stamp
    case gps

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .none: return "None"
        case .skyline: return "Skyline"
        case .postcard: return "Postcard"
        case .neon: return "Neon"
        case .stamp: return "Stamp"
        case .gps: return "GPS"
        }
    }
}

nonisolated enum RaceFilter: Int, CaseIterable, Identifiable {
    case none = 0
    case bibNumber
    case finisher
    case medal
    case raceRoute
    case racePoster

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .none: return "None"
        case .bibNumber: return "Bib Number"
        case .finisher: return "Finisher"
        case .medal: return "Medal"
        case .raceRoute: return "Route"
        case .racePoster: return "Poster"
        }
    }
}

nonisolated enum WidgetPalette: Int, CaseIterable, Identifiable {
    case classic = 0
    case neon
    case aesthetic

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .classic: return "Classic"
        case .neon: return "Neon"
        case .aesthetic: return "Aesthetic"
        }
    }

    var colors: [Color] {
        switch self {
        case .classic:
            return [
                .white,
                Color(red: 0.25, green: 0.52, blue: 1.0),
                Color(red: 1.0, green: 0.09, blue: 0.27),
                Color(red: 0.08, green: 0.08, blue: 0.08),
                Color(red: 0.75, green: 0.75, blue: 0.78),
                Color(red: 0.85, green: 0.70, blue: 0.35),
                Color(red: 0.13, green: 0.55, blue: 0.33),
            ]
        case .neon:
            return [
                Color(red: 0.0, green: 1.0, blue: 1.0),
                Color(red: 1.0, green: 0.0, blue: 0.8),
                Color(red: 0.0, green: 1.0, blue: 0.4),
                Color(red: 1.0, green: 1.0, blue: 0.0),
                Color(red: 1.0, green: 0.2, blue: 0.6),
                Color(red: 1.0, green: 0.5, blue: 0.0),
                Color(red: 0.55, green: 0.0, blue: 1.0),
            ]
        case .aesthetic:
            return [
                Color(red: 1.0, green: 0.75, blue: 0.8),
                Color(red: 0.73, green: 0.65, blue: 0.88),
                Color(red: 0.6, green: 0.88, blue: 0.78),
                Color(red: 1.0, green: 0.82, blue: 0.7),
                Color(red: 0.68, green: 0.82, blue: 1.0),
                Color(red: 0.78, green: 0.65, blue: 0.85),
                Color(red: 1.0, green: 0.95, blue: 0.85),
            ]
        }
    }

    var previewColors: [Color] {
        Array(colors.prefix(3))
    }
}

struct WidgetColorStyle: Equatable {
    var palette: WidgetPalette
    var colorIndex: Int

    static let initial = WidgetColorStyle(palette: .classic, colorIndex: 0)

    var currentColor: Color {
        let cols = palette.colors
        return cols[colorIndex % cols.count]
    }

    mutating func cycleNext() {
        let count = palette.colors.count
        colorIndex = (colorIndex + 1) % count
    }

    mutating func setPalette(_ newPalette: WidgetPalette) {
        palette = newPalette
        colorIndex = 0
    }
}

struct PlacedWidget: Identifiable {
    let id: String = UUID().uuidString
    let type: StatWidgetType
    var position: CGSize
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    var colorStyle: WidgetColorStyle = .initial
    var useGlassBackground: Bool = false
    var bestEffortsFilter: BestEffortsUnitFilter = .km
    var splitsFilter: SplitsUnitFilter = .km
    var distanceWordsFilter: SplitsUnitFilter = .km
    var fontStyle: WidgetFontStyle = .system
    var showTitle: Bool = true
    var showActivityName: Bool = true
    var showDate: Bool = true
    var showDistance: Bool = true
    var showPace: Bool = true
    var showTime: Bool = true
    var showElevation: Bool = true
    var basicUnitFilter: SplitsUnitFilter = .km
    var fullBannerUnitFilter: SplitsUnitFilter = .km
    var fullBannerShowDistance: Bool = true
    var fullBannerShowPace: Bool = true
    var fullBannerShowTime: Bool = true
    var fullBannerShowElevation: Bool = true
}

nonisolated enum SplitsUnitFilter: String, CaseIterable, Identifiable {
    case km = "KM"
    case miles = "MI"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .km: return "KM"
        case .miles: return "MI"
        }
    }

    var unitLabel: String {
        switch self {
        case .km: return "KMs"
        case .miles: return "MIs"
        }
    }

    var paceLabel: String {
        switch self {
        case .km: return "MIN/KM"
        case .miles: return "MIN/MI"
        }
    }
}

nonisolated enum BestEffortsUnitFilter: String, CaseIterable, Identifiable {
    case km = "KM"
    case miles = "MI"
    case both = "Both"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .km: return "KM"
        case .miles: return "MI"
        case .both: return "∞"
        }
    }

    func shouldInclude(effortName: String) -> Bool {
        let lower = effortName.lowercased()
        let isMile = lower.contains("mile") || lower == "mile"
        switch self {
        case .both: return true
        case .miles: return isMile
        case .km: return !isMile
        }
    }
}

nonisolated enum WidgetFontStyle: Int, CaseIterable, Identifiable {
    case system = 0
    case righteous
    case bangers
    case pressStart
    case bungee
    case jetbrainsMono

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .system: return "SF"
        case .righteous: return "Groovy"
        case .bangers: return "Comic"
        case .pressStart: return "Pixel"
        case .bungee: return "Urban"
        case .jetbrainsMono: return "Mono"
        }
    }

    func font(size: CGFloat, weight: Font.Weight = .black) -> Font {
        switch self {
        case .system:
            return .system(size: size, weight: weight, design: .default).width(.compressed)
        case .righteous:
            return .custom("Righteous-Regular", size: size)
        case .bangers:
            return .custom("Bangers-Regular", size: size)
        case .pressStart:
            return .custom("PressStart2P-Regular", size: size * 0.55)
        case .bungee:
            return .custom("Bungee-Regular", size: size)
        case .jetbrainsMono:
            return .custom("JetBrainsMono-Bold", size: size)
        }
    }

    func secondaryFont(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        switch self {
        case .system:
            return .system(size: size, weight: weight, design: .default).width(.compressed)
        case .righteous:
            return .custom("Righteous-Regular", size: size)
        case .bangers:
            return .custom("Bangers-Regular", size: size)
        case .pressStart:
            return .custom("PressStart2P-Regular", size: size * 0.55)
        case .bungee:
            return .custom("Bungee-Regular", size: size)
        case .jetbrainsMono:
            return .custom("JetBrainsMono-Bold", size: size)
        }
    }

    var previewText: String { "5:30" }

    var needsCompressedScale: Bool {
        self == .system
    }
}

nonisolated enum DrawerState {
    case collapsed
    case open
    case expanded
}

nonisolated enum AIEditStyle: String, CaseIterable, Identifiable {
    case fast = "Fast"
    case distortion = "Distortion"
    case blur = "Blur"
    case sketch = "Sketch"
    case cartoon = "Cartoon"
    case glitch = "Glitch"
    case dramatic = "Dramatic"
    case cinematica = "Cinematica"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fast: return "bolt.fill"
        case .distortion: return "water.waves"
        case .blur: return "aqi.medium"
        case .sketch: return "pencil.and.outline"
        case .cartoon: return "theatermask.and.paintbrush"
        case .glitch: return "square.stack.3d.forward.dottedline"
        case .dramatic: return "camera.filters"
        case .cinematica: return "film"
        }
    }
}
