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
    case timeCombined = "Time"
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
    case blurredVerticalText = "Blurred Vertical"
    case whatsappMessage = "WhatsApp"
    case notesScreenshot = "Notes"
    case ancestralMedal = "Ancestral"
    case splitBanner = "Split Banner"
    case cityActivity = "City Activity"
    case routeDistance = "Route Dist"
    case nameStats = "Name Stats"

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
        case .timeCombined: return "timer"
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
        case .blurredVerticalText: return "list.bullet"
        case .whatsappMessage: return "bubble.right.fill"
        case .notesScreenshot: return "note.text"
        case .ancestralMedal: return "crown.fill"
        case .splitBanner: return "text.alignleft"
        case .cityActivity: return "mappin.circle.fill"
        case .routeDistance: return "point.topleft.down.to.point.bottomright.curvepath"
        case .nameStats: return "person.text.rectangle.fill"
        }
    }

    var supportsGlass: Bool {
        switch self {
        case .routeClean, .bold, .impact, .titleCard, .blurredVerticalText, .whatsappMessage, .notesScreenshot, .ancestralMedal, .splitBanner:
            return false
        case .nameStats:
            return true
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
        case .weeklyKm, .lastWeekKm, .monthlyKm, .lastMonthKm, .elevationGain, .splits, .splitsTable, .splitsFastest, .splitsBars, .bestEfforts, .distanceWords, .fullBanner, .fullBannerBottom, .splitBanner: return false
        default: return false
        }
    }

    var requiresDetail: Bool {
        switch self {
        case .splits, .splitsTable, .splitsFastest, .splitsBars, .bestEfforts, .blurredVerticalText, .cityActivity: return true
        default: return false
        }
    }

    var supportsRouteDistance: Bool {
        self == .routeDistance
    }

    var isNotesScreenshot: Bool {
        self == .notesScreenshot
    }

    var isAncestralMedal: Bool {
        self == .ancestralMedal
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
    var distanceWordsFontStyle: SplitBannerFontStyle = .system
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
    var bvtShowDate: Bool = true
    var bvtShowTime: Bool = true
    var bvtShowLocation: Bool = true
    var bvtShowDistance: Bool = true
    var bvtShowPace: Bool = true
    var bvtShowDuration: Bool = true
    var bvtShowElevation: Bool = true
    var bvtShowCalories: Bool = true
    var bvtShowBPM: Bool = true
    var bvtUnitFilter: SplitsUnitFilter = .km
    var bvtEffect: BVTEffect = .glow
    var whatsappText: String = "My coach would be proud"
    var notesUnitFilter: SplitsUnitFilter = .km
    var ancestralUnitFilter: SplitsUnitFilter = .km
    var ancestralShowPace: Bool = true
    var ancestralShowTime: Bool = true
    var splitBannerUnitFilter: SplitsUnitFilter = .km
    var splitBannerFontStyle: SplitBannerFontStyle = .system
    var cityActivityUnitFilter: SplitsUnitFilter = .km
    var routeDistanceUnitFilter: SplitsUnitFilter = .km
    var routeDistanceShowElevation: Bool = true
    var routeDistanceShowTime: Bool = true
    var routeDistanceShowSpeed: Bool = true
    var nameStatsUnitFilter: SplitsUnitFilter = .km
    var nameStatsShowDistance: Bool = true
    var nameStatsShowPace: Bool = true
    var nameStatsShowTime: Bool = true
    var nameStatsShowElevation: Bool = false
}

nonisolated enum BVTEffect: Int, CaseIterable, Identifiable {
    case glow = 0
    case stroke
    case gradient
    case glitch
    case wave
    case pixelate
    case lineBlur
    case noise
    case stretch
    case skew
    case tracking
    case gradientMask
    case echo

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .glow: return "Glow"
        case .stroke: return "Stroke"
        case .gradient: return "Gradient"
        case .glitch: return "Glitch"
        case .wave: return "Wave"
        case .pixelate: return "Pixel"
        case .lineBlur: return "Line Blur"
        case .noise: return "Noise"
        case .stretch: return "Stretch"
        case .skew: return "Skew"
        case .tracking: return "Tracking"
        case .gradientMask: return "Fade"
        case .echo: return "Echo"
        }
    }

    var icon: String {
        switch self {
        case .glow: return "sparkle"
        case .stroke: return "character.textbox"
        case .gradient: return "paintbrush.fill"
        case .glitch: return "tv"
        case .wave: return "water.waves"
        case .pixelate: return "square.grid.3x3.fill"
        case .lineBlur: return "line.3.horizontal.decrease"
        case .noise: return "antenna.radiowaves.left.and.right"
        case .stretch: return "arrow.up.and.down"
        case .skew: return "italic"
        case .tracking: return "arrow.left.and.right"
        case .gradientMask: return "rectangle.lefthalf.filled"
        case .echo: return "square.stack.fill"
        }
    }

    func next() -> BVTEffect {
        let all = BVTEffect.allCases
        let idx = (all.firstIndex(of: self) ?? 0) + 1
        return all[idx % all.count]
    }
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
    case sedgwickAve
    case sekuya
    case sixCaps

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .system: return "SF"
        case .righteous: return "Groovy"
        case .bangers: return "Comic"
        case .pressStart: return "Pixel"
        case .bungee: return "Urban"
        case .jetbrainsMono: return "Mono"
        case .sedgwickAve: return "Sedgwick"
        case .sekuya: return "Sekuya"
        case .sixCaps: return "Caps"
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
        case .sedgwickAve:
            return .custom("SedgwickAveDisplay-Regular", size: size)
        case .sekuya:
            return .custom("Sekuya-Regular", size: size)
        case .sixCaps:
            return .custom("SixCaps-Regular", size: size)
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
        case .sedgwickAve:
            return .custom("SedgwickAveDisplay-Regular", size: size)
        case .sekuya:
            return .custom("Sekuya-Regular", size: size)
        case .sixCaps:
            return .custom("SixCaps-Regular", size: size)
        }
    }

    var previewText: String { "5:30" }

    var needsCompressedScale: Bool {
        self == .system
    }
}

nonisolated enum SplitBannerFontStyle: Int, CaseIterable, Identifiable {
    case system = 0
    case righteous
    case bangers
    case pressStart
    case bungee
    case jetbrainsMono
    case metalMania
    case monofett
    case newRocker
    case rubik80sFade
    case rubikDistressed
    case rubikGlitch
    case sedgwickAve
    case sekuya
    case sixCaps

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .righteous: return "Groovy"
        case .bangers: return "Comic"
        case .pressStart: return "Pixel"
        case .bungee: return "Urban"
        case .jetbrainsMono: return "Mono"
        case .metalMania: return "Metal"
        case .monofett: return "Monofett"
        case .newRocker: return "Rocker"
        case .rubik80sFade: return "80s"
        case .rubikDistressed: return "Distress"
        case .rubikGlitch: return "Glitch"
        case .sedgwickAve: return "Sedgwick"
        case .sekuya: return "Sekuya"
        case .sixCaps: return "Caps"
        }
    }

    func font(size: CGFloat) -> Font {
        switch self {
        case .system:
            return .system(size: size, weight: .heavy, design: .default).italic().width(.expanded)
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
        case .metalMania:
            return .custom("MetalMania-Regular", size: size)
        case .monofett:
            return .custom("Monofett-Regular", size: size)
        case .newRocker:
            return .custom("NewRocker-Regular", size: size)
        case .rubik80sFade:
            return .custom("Rubik80sFade-Regular", size: size)
        case .rubikDistressed:
            return .custom("RubikDistressed-Regular", size: size)
        case .rubikGlitch:
            return .custom("RubikGlitch-Regular", size: size)
        case .sedgwickAve:
            return .custom("SedgwickAveDisplay-Regular", size: size)
        case .sekuya:
            return .custom("Sekuya-Regular", size: size)
        case .sixCaps:
            return .custom("SixCaps-Regular", size: size)
        }
    }
}

nonisolated enum DrawerState {
    case collapsed
    case open
    case expanded
}

nonisolated enum DrawerTab: String {
    case popular = "Popular"
    case recents = "Recents"
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
