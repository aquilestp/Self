import SwiftUI
import UIKit

enum TextStyleType: String, CaseIterable, Identifiable, Sendable {
    case classic
    case bold
    case italic
    case dancingScript
    case pacifico
    case bebasNeue
    case lobster
    case playfairDisplay
    case cinzel
    case spaceGrotesk
    case outfit
    case pressStart2P
    case orbitron
    case permanentMarker
    case caveat

    var id: String { rawValue }

    var label: String {
        switch self {
        case .classic: return "Classic"
        case .bold: return "Bold"
        case .italic: return "Italic"
        case .dancingScript: return "Dancing"
        case .pacifico: return "Pacifico"
        case .bebasNeue: return "Bebas"
        case .lobster: return "Lobster"
        case .playfairDisplay: return "Playfair"
        case .cinzel: return "Cinzel"
        case .spaceGrotesk: return "Grotesk"
        case .outfit: return "Outfit"
        case .pressStart2P: return "Pixel"
        case .orbitron: return "Orbitron"
        case .permanentMarker: return "Marker"
        case .caveat: return "Caveat"
        }
    }

    private var isCustomFont: Bool {
        switch self {
        case .classic, .bold, .italic: return false
        default: return true
        }
    }

    private var postScriptName: String {
        switch self {
        case .dancingScript: return "DancingScript-Bold"
        case .pacifico: return "Pacifico-Regular"
        case .bebasNeue: return "BebasNeue-Regular"
        case .lobster: return "Lobster-Regular"
        case .playfairDisplay: return "PlayfairDisplay-Bold"
        case .cinzel: return "Cinzel-Bold"
        case .spaceGrotesk: return "SpaceGrotesk-Bold"
        case .outfit: return "Outfit-Medium"
        case .pressStart2P: return "PressStart2P-Regular"
        case .orbitron: return "Orbitron-Bold"
        case .permanentMarker: return "PermanentMarker-Regular"
        case .caveat: return "Caveat-Bold"
        default: return ""
        }
    }

    var swiftUIFont: Font {
        switch self {
        case .classic:
            return .system(size: 24, weight: .semibold, design: .default)
        case .bold:
            return .system(size: 24, weight: .bold, design: .default)
        case .italic:
            return .system(size: 24, weight: .regular, design: .default)
        default:
            return .custom(postScriptName, size: 24)
        }
    }

    var isItalic: Bool {
        self == .italic
    }

    var isCondensed: Bool {
        false
    }

    func uiFont(size: CGFloat) -> UIFont {
        switch self {
        case .classic:
            return UIFont.systemFont(ofSize: size, weight: .semibold)
        case .bold:
            return UIFont.systemFont(ofSize: size, weight: .bold)
        case .italic:
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
            if let italicDescriptor = descriptor.withSymbolicTraits(.traitItalic) {
                return UIFont(descriptor: italicDescriptor, size: size)
            }
            return UIFont.italicSystemFont(ofSize: size)
        default:
            if let font = UIFont(name: postScriptName, size: size) {
                return font
            }
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
    }

    func previewFont(size: CGFloat) -> Font {
        switch self {
        case .classic:
            return .system(size: size, weight: .semibold, design: .default)
        case .bold:
            return .system(size: size, weight: .bold, design: .default)
        case .italic:
            return .system(size: size, weight: .regular, design: .default)
        default:
            return .custom(postScriptName, size: size)
        }
    }
}

let textStylePresetColors: [Color] = [
    .white,
    Color(red: 1.0, green: 0.23, blue: 0.19),
    Color(red: 0.0, green: 0.48, blue: 1.0),
    Color(red: 0.2, green: 0.84, blue: 0.29),
    Color(red: 1.0, green: 0.8, blue: 0.0),
    Color(red: 1.0, green: 0.18, blue: 0.56),
    Color(red: 1.0, green: 0.58, blue: 0.0),
    Color(red: 0.69, green: 0.32, blue: 0.87),
]
