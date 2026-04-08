import SwiftUI
import UIKit

class StatTransformGestureRecognizer: UIGestureRecognizer {
    private(set) var translationDelta: CGPoint = .zero
    private(set) var scaleDelta: CGFloat = 1.0
    private(set) var rotationDelta: CGFloat = 0.0
    private(set) var activeTouchCount: Int = 0
    private(set) var currentGlobalLocation: CGPoint = .zero
    private(set) var isTap: Bool = false

    var widgetVisualCenter: CGPoint = .zero
    var widgetVisualSize: CGSize = .zero
    var widgetRotationRadians: CGFloat = 0
    var isLocked: Bool = false

    private var trackedTouches: [UITouch] = []
    private var previousWindowCentroid: CGPoint = .zero
    private var previousDistance: CGFloat = 0
    private var previousAngle: CGFloat = 0
    private var initialCentroid: CGPoint = .zero
    private var totalMovement: CGFloat = 0

    private let minPinchDistance: CGFloat = 10
    private let maxTranslationDelta: CGFloat = 50
    private let tapMovementThreshold: CGFloat = 4

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            if !trackedTouches.contains(touch) {
                trackedTouches.append(touch)
            }
        }
        activeTouchCount = trackedTouches.count
        previousWindowCentroid = windowCentroid(of: trackedTouches)

        if trackedTouches.count >= 2 {
            previousDistance = windowDistance(between: trackedTouches)
            previousAngle = windowAngle(between: trackedTouches)
        }

        if state == .possible {
            if isLocked {
                state = .failed
                return
            }
            initialCentroid = previousWindowCentroid
            totalMovement = 0
            isTap = true
            state = .began
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard state == .began || state == .changed else { return }

        let currentCentroid = windowCentroid(of: trackedTouches)
        var dx = currentCentroid.x - previousWindowCentroid.x
        var dy = currentCentroid.y - previousWindowCentroid.y
        dx = max(-maxTranslationDelta, min(maxTranslationDelta, dx))
        dy = max(-maxTranslationDelta, min(maxTranslationDelta, dy))
        translationDelta = CGPoint(x: dx, y: dy)
        currentGlobalLocation = currentCentroid
        totalMovement += sqrt(dx * dx + dy * dy)
        if totalMovement > tapMovementThreshold {
            isTap = false
        }

        if trackedTouches.count >= 2 {
            let currentDistance = windowDistance(between: trackedTouches)
            let currentAngle = windowAngle(between: trackedTouches)

            if previousDistance > minPinchDistance && currentDistance > minPinchDistance {
                scaleDelta = currentDistance / previousDistance
            } else {
                scaleDelta = 1.0
            }
            rotationDelta = currentAngle - previousAngle

            previousDistance = currentDistance
            previousAngle = currentAngle
        } else {
            scaleDelta = 1.0
            rotationDelta = 0
        }

        previousWindowCentroid = currentCentroid
        activeTouchCount = trackedTouches.count
        state = .changed
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        trackedTouches.removeAll { touches.contains($0) }
        activeTouchCount = trackedTouches.count

        if trackedTouches.isEmpty {
            state = .ended
        } else {
            previousWindowCentroid = windowCentroid(of: trackedTouches)
            if trackedTouches.count >= 2 {
                previousDistance = windowDistance(between: trackedTouches)
                previousAngle = windowAngle(between: trackedTouches)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        trackedTouches.removeAll { touches.contains($0) }
        activeTouchCount = trackedTouches.count
        if trackedTouches.isEmpty {
            state = .cancelled
        } else {
            previousWindowCentroid = windowCentroid(of: trackedTouches)
        }
    }

    func updateWidgetBounds(center: CGPoint, size: CGSize, rotationRadians: CGFloat) {
        widgetVisualCenter = center
        widgetVisualSize = size
        widgetRotationRadians = rotationRadians
    }

    override func reset() {
        trackedTouches.removeAll()
        translationDelta = .zero
        scaleDelta = 1.0
        rotationDelta = 0
        activeTouchCount = 0
        previousWindowCentroid = .zero
        previousDistance = 0
        previousAngle = 0
        currentGlobalLocation = .zero
        isTap = false
        initialCentroid = .zero
        totalMovement = 0
    }

    private func windowCentroid(of touches: [UITouch]) -> CGPoint {
        guard !touches.isEmpty else { return .zero }
        let target = view?.window ?? view
        var sum = CGPoint.zero
        for t in touches {
            let loc = t.location(in: target)
            sum.x += loc.x
            sum.y += loc.y
        }
        let count = CGFloat(touches.count)
        return CGPoint(x: sum.x / count, y: sum.y / count)
    }

    private func windowDistance(between touches: [UITouch]) -> CGFloat {
        guard touches.count >= 2 else { return 0 }
        let target = view?.window ?? view
        let p1 = touches[0].location(in: target)
        let p2 = touches[1].location(in: target)
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(dx * dx + dy * dy)
    }

    private func windowAngle(between touches: [UITouch]) -> CGFloat {
        guard touches.count >= 2 else { return 0 }
        let target = view?.window ?? view
        let p1 = touches[0].location(in: target)
        let p2 = touches[1].location(in: target)
        return atan2(p2.y - p1.y, p2.x - p1.x)
    }
}

class StatGesturePassthroughView: UIView {
    weak var gestureRecognizerRef: StatTransformGestureRecognizer?
}

struct StatGestureOverlay: UIViewRepresentable {
    var widgetVisualCenter: CGPoint = .zero
    var widgetVisualSize: CGSize = .zero
    var widgetRotationRadians: CGFloat = 0
    var isLocked: Bool = false
    var onTranslationChanged: (CGSize) -> Void
    var onTranslationEnded: (CGSize, CGPoint) -> Void
    var onScaleChanged: (CGFloat) -> Void
    var onScaleEnded: (CGFloat) -> Void
    var onRotationChanged: (Angle) -> Void
    var onRotationEnded: (Angle) -> Void
    var onDragStarted: () -> Void
    var onGlobalLocationChanged: (CGPoint) -> Void
    var onTapped: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> StatGesturePassthroughView {
        let view = StatGesturePassthroughView()
        view.backgroundColor = .clear
        view.isMultipleTouchEnabled = true

        let gesture = StatTransformGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTransform(_:))
        )
        view.addGestureRecognizer(gesture)
        view.gestureRecognizerRef = gesture
        context.coordinator.transformGesture = gesture

        return view
    }

    func updateUIView(_ uiView: StatGesturePassthroughView, context: Context) {
        context.coordinator.parent = self
        if let gesture = uiView.gestureRecognizerRef {
            gesture.isLocked = isLocked
            gesture.updateWidgetBounds(
                center: widgetVisualCenter,
                size: widgetVisualSize,
                rotationRadians: widgetRotationRadians
            )
        }
    }

    class Coordinator: NSObject {
        var parent: StatGestureOverlay
        weak var transformGesture: StatTransformGestureRecognizer?

        private var accumulatedTranslation: CGSize = .zero
        private var accumulatedScale: CGFloat = 1.0
        private var accumulatedRotation: Double = 0.0
        private var lastReportedScale: CGFloat = 1.0
        private var lastReportedRotation: Double = 0.0
        private var started: Bool = false

        init(parent: StatGestureOverlay) {
            self.parent = parent
        }

        @MainActor @objc func handleTransform(_ gesture: StatTransformGestureRecognizer) {
            switch gesture.state {
            case .began:
                accumulatedTranslation = .zero
                accumulatedScale = 1.0
                accumulatedRotation = 0.0
                lastReportedScale = 1.0
                lastReportedRotation = 0.0
                started = true
                parent.onDragStarted()

            case .changed:
                guard started else { return }

                accumulatedTranslation.width += gesture.translationDelta.x
                accumulatedTranslation.height += gesture.translationDelta.y
                parent.onTranslationChanged(accumulatedTranslation)

                parent.onGlobalLocationChanged(gesture.currentGlobalLocation)

                if gesture.activeTouchCount >= 2 {
                    accumulatedScale *= gesture.scaleDelta
                    let clampedScale = min(max(accumulatedScale, 0.3), 4.0)
                    parent.onScaleChanged(clampedScale)
                    lastReportedScale = clampedScale

                    accumulatedRotation += Double(gesture.rotationDelta)
                    parent.onRotationChanged(Angle(radians: accumulatedRotation))
                    lastReportedRotation = accumulatedRotation
                }

            case .ended:
                guard started else { return }
                if gesture.isTap {
                    parent.onTapped?()
                }
                parent.onTranslationEnded(accumulatedTranslation, gesture.currentGlobalLocation)
                parent.onScaleEnded(lastReportedScale)
                parent.onRotationEnded(Angle(radians: lastReportedRotation))
                started = false

            case .cancelled, .failed:
                guard started else { return }
                parent.onTranslationEnded(accumulatedTranslation, gesture.currentGlobalLocation)
                parent.onScaleEnded(lastReportedScale)
                parent.onRotationEnded(Angle(radians: lastReportedRotation))
                started = false

            default:
                break
            }
        }
    }
}
