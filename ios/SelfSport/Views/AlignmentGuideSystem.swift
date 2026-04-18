import SwiftUI

nonisolated struct SnapResult: Sendable {
    var adjustedOffset: CGSize
    var activeGuides: Set<GuideLineType>
}

nonisolated struct RotationSnapResult: Sendable {
    var snappedAngle: Angle
    var isSnapped: Bool
}

nonisolated enum GuideLineType: Hashable, Sendable {
    case centerH
    case centerV
    case rotation
}

@Observable
final class AlignmentGuideState {
    var activeGuides: Set<GuideLineType> = []
    var snapHapticTrigger: Int = 0
    var crossingHapticTrigger: Int = 0
    var rotationSnapped: Bool = false

    private var previouslySnapped: Set<GuideLineType> = []
    private var previousCenter: CGPoint? = nil
    private var wasRotationSnapped: Bool = false
    private var cachedCanvasCenter: CGPoint = .zero

    private let snapThreshold: CGFloat = 8
    private let rotationSnapThreshold: Double = 3.0

    func beginDrag() {
        previousCenter = nil
    }

    func beginRotation() {
        wasRotationSnapped = false
    }

    func computeRotationSnap(currentDegrees: Double) -> RotationSnapResult {
        var normalized = currentDegrees.truncatingRemainder(dividingBy: 360)
        if normalized > 180 { normalized -= 360 }
        if normalized < -180 { normalized += 360 }

        for snapAngle in [0.0, 90.0, -90.0, 180.0, -180.0] {
            let dist = abs(normalized - snapAngle)
            if dist < rotationSnapThreshold {
                let snappedDeg = currentDegrees - (normalized - snapAngle)
                if !wasRotationSnapped {
                    wasRotationSnapped = true
                    snapHapticTrigger += 1
                }
                if !rotationSnapped { rotationSnapped = true }
                if !activeGuides.contains(.rotation) {
                    activeGuides.insert(.rotation)
                }
                return RotationSnapResult(snappedAngle: .degrees(snappedDeg), isSnapped: true)
            }
        }

        if wasRotationSnapped { wasRotationSnapped = false }
        if rotationSnapped { rotationSnapped = false }
        if activeGuides.contains(.rotation) { activeGuides.remove(.rotation) }
        return RotationSnapResult(snappedAngle: .degrees(currentDegrees), isSnapped: false)
    }

    func clearRotation() {
        if rotationSnapped { rotationSnapped = false }
        wasRotationSnapped = false
        if activeGuides.contains(.rotation) { activeGuides.remove(.rotation) }
    }

    func computeSnap(
        widgetCenter: CGPoint,
        widgetSize: CGSize,
        canvasSize: CGSize
    ) -> SnapResult {
        guard widgetSize.width > 0, widgetSize.height > 0,
              canvasSize.width > 0, canvasSize.height > 0 else {
            return SnapResult(adjustedOffset: .zero, activeGuides: [])
        }

        let centerX = canvasSize.width * 0.5
        let centerY = canvasSize.height * 0.5

        var adjustX = widgetCenter.x
        var adjustY = widgetCenter.y
        var hasH = false
        var hasV = false

        if abs(widgetCenter.y - centerY) < snapThreshold {
            hasH = true
            adjustY = centerY
        }

        if abs(widgetCenter.x - centerX) < snapThreshold {
            hasV = true
            adjustX = centerX
        }

        var hapticNeeded = false
        if hasH && !previouslySnapped.contains(.centerH) { hapticNeeded = true }
        if hasV && !previouslySnapped.contains(.centerV) { hapticNeeded = true }
        if hapticNeeded { snapHapticTrigger += 1 }

        if let prev = previousCenter {
            let dx = abs(widgetCenter.x - prev.x)
            let dy = abs(widgetCenter.y - prev.y)
            if dx > 1 || dy > 1 {
                var crossed = false
                if !hasV, (prev.x - centerX) * (widgetCenter.x - centerX) < 0 { crossed = true }
                if !hasH, (prev.y - centerY) * (widgetCenter.y - centerY) < 0 { crossed = true }
                if crossed { crossingHapticTrigger += 1 }
            }
        }

        previousCenter = widgetCenter

        let newGuides: Set<GuideLineType> = {
            var s = Set<GuideLineType>()
            if hasH { s.insert(.centerH) }
            if hasV { s.insert(.centerV) }
            if activeGuides.contains(.rotation) { s.insert(.rotation) }
            return s
        }()
        if activeGuides != newGuides { activeGuides = newGuides }

        previouslySnapped = {
            var s = Set<GuideLineType>()
            if hasH { s.insert(.centerH) }
            if hasV { s.insert(.centerV) }
            return s
        }()

        return SnapResult(
            adjustedOffset: CGSize(width: adjustX - widgetCenter.x, height: adjustY - widgetCenter.y),
            activeGuides: newGuides
        )
    }

    func clearGuides() {
        if !activeGuides.isEmpty { activeGuides = [] }
        previouslySnapped = []
        previousCenter = nil
        if rotationSnapped { rotationSnapped = false }
        wasRotationSnapped = false
    }
}

nonisolated func rotatedBoundingBox(size: CGSize, rotation: Angle) -> CGSize {
    let radians = abs(rotation.radians)
    let cosA = cos(radians)
    let sinA = sin(radians)
    let w = abs(size.width * cosA) + abs(size.height * sinA)
    let h = abs(size.width * sinA) + abs(size.height * cosA)
    return CGSize(width: w, height: h)
}

struct AlignmentGuidesOverlay: View {
    let canvasSize: CGSize
    let activeGuides: Set<GuideLineType>

    private let lineColor = Color.white.opacity(0.45)
    private let dashPattern: [CGFloat] = [5, 4]

    var body: some View {
        Canvas { context, _ in
            let dash = StrokeStyle(lineWidth: 1.2, dash: dashPattern)
            let shading = GraphicsContext.Shading.color(lineColor)

            for guide in activeGuides {
                var path = Path()
                let (start, end) = lineEndpoints(for: guide)
                path.move(to: start)
                path.addLine(to: end)
                context.stroke(path, with: shading, style: dash)
            }
        }
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.12), value: activeGuides)
    }

    private func lineEndpoints(for type: GuideLineType) -> (CGPoint, CGPoint) {
        switch type {
        case .centerV:
            return (CGPoint(x: canvasSize.width / 2, y: 0), CGPoint(x: canvasSize.width / 2, y: canvasSize.height))
        case .centerH:
            return (CGPoint(x: 0, y: canvasSize.height / 2), CGPoint(x: canvasSize.width, y: canvasSize.height / 2))
        case .rotation:
            let cx = canvasSize.width / 2
            let cy = canvasSize.height / 2
            let len = max(canvasSize.width, canvasSize.height) * 0.15
            return (CGPoint(x: cx - len, y: cy), CGPoint(x: cx + len, y: cy))
        }
    }
}
