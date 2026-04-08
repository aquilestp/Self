import SwiftUI
import UIKit

class PhotoTransformGestureRecognizer: UIGestureRecognizer {
    private(set) var translationDelta: CGPoint = .zero
    private(set) var scaleDelta: CGFloat = 1.0
    private(set) var rotationDelta: CGFloat = 0.0
    private(set) var activeTouchCount: Int = 0

    var photoCenter: CGPoint = .zero
    var photoDisplaySize: CGSize = .zero
    var photoRotationRadians: CGFloat = 0
    var boundsCheckEnabled: Bool = false

    private var trackedTouches: [UITouch] = []
    private var previousCentroid: CGPoint = .zero
    private var previousDistance: CGFloat = 0
    private var previousAngle: CGFloat = 0
    private var everHadTwoTouches: Bool = false

    private func isCentroidOnPhoto(_ centroid: CGPoint) -> Bool {
        guard boundsCheckEnabled, photoDisplaySize.width > 0, photoDisplaySize.height > 0 else { return true }
        let dx = centroid.x - photoCenter.x
        let dy = centroid.y - photoCenter.y
        let cosR = cos(-photoRotationRadians)
        let sinR = sin(-photoRotationRadians)
        let localX = dx * cosR - dy * sinR
        let localY = dx * sinR + dy * cosR
        let halfW = photoDisplaySize.width * 0.5
        let halfH = photoDisplaySize.height * 0.5
        return abs(localX) <= halfW && abs(localY) <= halfH
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            if !trackedTouches.contains(touch) {
                trackedTouches.append(touch)
            }
        }
        activeTouchCount = trackedTouches.count

        if trackedTouches.count >= 2 {
            everHadTwoTouches = true
            previousCentroid = centroid(of: trackedTouches)
            previousDistance = distance(between: trackedTouches)
            previousAngle = angle(between: trackedTouches)
            if state == .possible {
                if !isCentroidOnPhoto(previousCentroid) {
                    state = .failed
                    return
                }
                state = .began
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard state == .began || state == .changed else { return }

        let currentCentroid = centroid(of: trackedTouches)
        translationDelta = CGPoint(
            x: currentCentroid.x - previousCentroid.x,
            y: currentCentroid.y - previousCentroid.y
        )

        if trackedTouches.count >= 2 {
            let currentDistance = distance(between: trackedTouches)
            let currentAngle = angle(between: trackedTouches)

            scaleDelta = previousDistance > 0 ? currentDistance / previousDistance : 1.0
            rotationDelta = currentAngle - previousAngle

            previousDistance = currentDistance
            previousAngle = currentAngle
        } else {
            scaleDelta = 1.0
            rotationDelta = 0
        }

        previousCentroid = currentCentroid
        activeTouchCount = trackedTouches.count
        state = .changed
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        trackedTouches.removeAll { touches.contains($0) }
        activeTouchCount = trackedTouches.count

        if trackedTouches.isEmpty {
            if everHadTwoTouches {
                state = .ended
            } else {
                state = .failed
            }
        } else {
            previousCentroid = centroid(of: trackedTouches)
            if trackedTouches.count >= 2 {
                previousDistance = distance(between: trackedTouches)
                previousAngle = angle(between: trackedTouches)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        trackedTouches.removeAll { touches.contains($0) }
        activeTouchCount = trackedTouches.count
        if trackedTouches.isEmpty {
            state = .cancelled
        }
    }

    override func reset() {
        trackedTouches.removeAll()
        translationDelta = .zero
        scaleDelta = 1.0
        rotationDelta = 0
        activeTouchCount = 0
        previousCentroid = .zero
        previousDistance = 0
        previousAngle = 0
        everHadTwoTouches = false
    }

    func updatePhotoBounds(center: CGPoint, displaySize: CGSize, rotationRadians: CGFloat, enabled: Bool) {
        photoCenter = center
        photoDisplaySize = displaySize
        photoRotationRadians = rotationRadians
        boundsCheckEnabled = enabled
    }

    private func centroid(of touches: [UITouch]) -> CGPoint {
        guard !touches.isEmpty, let v = view else { return .zero }
        var sum = CGPoint.zero
        for t in touches {
            let loc = t.location(in: v)
            sum.x += loc.x
            sum.y += loc.y
        }
        let count = CGFloat(touches.count)
        return CGPoint(x: sum.x / count, y: sum.y / count)
    }

    private func distance(between touches: [UITouch]) -> CGFloat {
        guard touches.count >= 2, let v = view else { return 0 }
        let p1 = touches[0].location(in: v)
        let p2 = touches[1].location(in: v)
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(dx * dx + dy * dy)
    }

    private func angle(between touches: [UITouch]) -> CGFloat {
        guard touches.count >= 2, let v = view else { return 0 }
        let p1 = touches[0].location(in: v)
        let p2 = touches[1].location(in: v)
        return atan2(p2.y - p1.y, p2.x - p1.x)
    }
}

class PhotoGesturePassthroughView: UIView {
    weak var gestureRecognizerRef: PhotoTransformGestureRecognizer?
}

struct PhotoGestureOverlay: UIViewRepresentable {
    var photoCenter: CGPoint = .zero
    var photoDisplaySize: CGSize = .zero
    var photoRotationRadians: CGFloat = 0
    var boundsCheckEnabled: Bool = false
    var isDisabled: Bool = false
    var onPanChanged: (CGSize) -> Void
    var onPanEnded: (CGSize) -> Void
    var onPinchChanged: (CGFloat) -> Void
    var onPinchEnded: (CGFloat) -> Void
    var onRotationChanged: (Angle) -> Void
    var onRotationEnded: (Angle) -> Void
    var onSessionStarted: () -> Void
    var onSessionEnded: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> PhotoGesturePassthroughView {
        let view = PhotoGesturePassthroughView()
        view.backgroundColor = .clear
        view.isMultipleTouchEnabled = true

        let gesture = PhotoTransformGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTransform(_:))
        )
        view.addGestureRecognizer(gesture)
        view.gestureRecognizerRef = gesture
        context.coordinator.transformGesture = gesture

        return view
    }

    func updateUIView(_ uiView: PhotoGesturePassthroughView, context: Context) {
        context.coordinator.parent = self
        if let gesture = uiView.gestureRecognizerRef {
            gesture.isEnabled = !isDisabled
            gesture.updatePhotoBounds(
                center: photoCenter,
                displaySize: photoDisplaySize,
                rotationRadians: photoRotationRadians,
                enabled: boundsCheckEnabled
            )
        }
    }

    class Coordinator: NSObject {
        var parent: PhotoGestureOverlay
        weak var transformGesture: PhotoTransformGestureRecognizer?

        private var accumulatedTranslation: CGSize = .zero
        private var accumulatedScale: CGFloat = 1.0
        private var accumulatedRotation: Double = 0.0
        private var sessionFired: Bool = false
        private var lastReportedScale: CGFloat = 1.0
        private var lastReportedRotation: Double = 0.0

        init(parent: PhotoGestureOverlay) {
            self.parent = parent
        }

        @MainActor @objc func handleTransform(_ gesture: PhotoTransformGestureRecognizer) {
            switch gesture.state {
            case .began:
                accumulatedTranslation = .zero
                accumulatedScale = 1.0
                accumulatedRotation = 0.0
                lastReportedScale = 1.0
                lastReportedRotation = 0.0
                sessionFired = true
                parent.onSessionStarted()

            case .changed:
                guard sessionFired else { return }

                accumulatedTranslation.width += gesture.translationDelta.x
                accumulatedTranslation.height += gesture.translationDelta.y
                parent.onPanChanged(accumulatedTranslation)

                if gesture.activeTouchCount >= 2 {
                    accumulatedScale *= gesture.scaleDelta
                    let clampedScale = min(max(accumulatedScale, 0.1), 10.0)
                    parent.onPinchChanged(clampedScale)
                    lastReportedScale = clampedScale

                    accumulatedRotation += Double(gesture.rotationDelta)
                    parent.onRotationChanged(Angle(radians: accumulatedRotation))
                    lastReportedRotation = accumulatedRotation
                }

            case .ended:
                guard sessionFired else { return }
                parent.onPanEnded(accumulatedTranslation)
                parent.onPinchEnded(lastReportedScale)
                parent.onRotationEnded(Angle(radians: lastReportedRotation))
                sessionFired = false
                parent.onSessionEnded()

            case .cancelled, .failed:
                guard sessionFired else { return }
                parent.onPanEnded(accumulatedTranslation)
                parent.onPinchEnded(lastReportedScale)
                parent.onRotationEnded(Angle(radians: lastReportedRotation))
                sessionFired = false
                parent.onSessionEnded()

            default:
                break
            }
        }
    }
}
