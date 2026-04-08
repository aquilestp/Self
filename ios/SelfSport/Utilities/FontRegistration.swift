import UIKit
import CoreText

enum FontRegistration {
    static func registerCustomFonts() {
        let fontNames = [
            "DancingScript-Bold",
            "Pacifico-Regular",
            "BebasNeue-Regular",
            "Lobster-Regular",
            "PlayfairDisplay-Bold",
            "Cinzel-Bold",
            "Righteous-Regular",
            "Bangers-Regular",
            "Bungee-Regular",
            "JetBrainsMono-Bold",
            "SpaceGrotesk-Bold",
            "Outfit-Medium",
            "PressStart2P-Regular",
            "Orbitron-Bold",
            "PermanentMarker-Regular",
            "Caveat-Bold",
            "InstrumentSerif-Italic",
            "InstrumentSerif-Regular",
        ]

        for fontName in fontNames {
            if let url = Bundle.main.url(forResource: fontName, withExtension: "ttf")
                ?? Bundle.main.url(forResource: fontName, withExtension: "ttf", subdirectory: "Fonts")
            {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}
