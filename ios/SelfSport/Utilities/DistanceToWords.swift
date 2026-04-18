import Foundation

nonisolated enum DistanceToWords {

    static func convert(distanceMeters: Double, unit: SplitsUnitFilter) -> (numberText: String, unitText: String) {
        let value: Double
        let unitLabel: String
        switch unit {
        case .km:
            value = distanceMeters / 1000.0
            unitLabel = value >= 1.95 && fractionSuffix(for: value) == nil ? "kilometers" : (value < 1.5 ? "kilometer" : "kilometers")
        case .miles:
            value = distanceMeters / 1609.34
            unitLabel = value >= 1.95 && fractionSuffix(for: value) == nil ? "miles" : (value < 1.5 ? "mile" : "miles")
        }

        let whole = Int(value)
        let decimal = value - Double(whole)

        let fraction = fractionSuffix(for: value)

        if whole == 0 {
            if let fraction {
                return (fraction, unitLabel)
            }
            return ("zero", unitLabel)
        }

        let wholeWords = numberToWords(whole)

        if let fraction {
            let correctedUnit: String
            switch unit {
            case .km: correctedUnit = "kilometers"
            case .miles: correctedUnit = "miles"
            }
            return ("\(wholeWords) \(fraction)", correctedUnit)
        }

        if decimal >= 0.05 {
            let rounded = Int((value * 10).rounded())
            let roundedWhole = rounded / 10
            let roundedTenth = rounded % 10
            if roundedTenth != 0 {
                let correctedUnit: String
                switch unit {
                case .km: correctedUnit = "kilometers"
                case .miles: correctedUnit = "miles"
                }
                return ("\(numberToWords(roundedWhole)) point \(singleDigitWord(roundedTenth))", correctedUnit)
            }
        }

        return (wholeWords, unitLabel)
    }

    private static func fractionSuffix(for value: Double) -> String? {
        let decimal = value - Double(Int(value))
        if decimal >= 0.20 && decimal < 0.30 { return "and a quarter" }
        if decimal >= 0.45 && decimal < 0.55 { return "and a half" }
        if decimal >= 0.70 && decimal < 0.80 { return "and three quarters" }
        return nil
    }

    private static func singleDigitWord(_ n: Int) -> String {
        let ones = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
        guard n >= 0, n <= 9 else { return "\(n)" }
        return ones[n]
    }

    private static func numberToWords(_ n: Int) -> String {
        guard n > 0 else { return "zero" }

        let ones = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
                     "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen",
                     "seventeen", "eighteen", "nineteen"]
        let tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]

        if n < 20 { return ones[n] }
        if n < 100 {
            let t = tens[n / 10]
            let o = n % 10
            return o == 0 ? t : "\(t) \(ones[o])"
        }
        if n < 1000 {
            let h = ones[n / 100]
            let remainder = n % 100
            if remainder == 0 { return "\(h) hundred" }
            return "\(h) hundred \(numberToWords(remainder))"
        }
        let thousands = n / 1000
        let remainder = n % 1000
        let prefix = numberToWords(thousands)
        if remainder == 0 { return "\(prefix) thousand" }
        return "\(prefix) thousand \(numberToWords(remainder))"
    }
}
