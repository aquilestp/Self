import SwiftUI

struct PlacedText: Identifiable {
    let id: String = UUID().uuidString
    var text: String
    var position: CGSize
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    var styleType: TextStyleType = .classic
    var styleColor: Color = .white
}

struct DraggableTextWidget: View {
    @Binding var textWidget: PlacedText
    let canvasSize: CGSize
    var canvasGlobalOrigin: CGPoint = .zero
    var guideState: AlignmentGuideState? = nil
    var activeWidgetId: String? = nil
    var isEditing: Bool = false
    var onDragStarted: ((String) -> Void)? = nil
    var onDragChanged: ((String, CGPoint) -> Void)? = nil
    var onDragEnded: ((String, CGPoint) -> Bool)? = nil
    var onTapped: ((String) -> Void)? = nil

    @State private var dragOffset: CGSize = .zero
    @State private var snapAdjustment: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var isBeingDeleted: Bool = false
    @State private var measuredSize: CGSize = CGSize(width: 100, height: 40)
    @State private var liveScale: CGFloat = 1.0
    @State private var liveRotation: Angle = .zero
    @State private var isRotating: Bool = false
    @State private var cachedBoundingSize: CGSize = .zero
    @State private var tapDetected: Bool = false


    var body: some View {
        textContent
            .onGeometryChange(for: CGSize.self, of: \.size) { newSize in
                if newSize.width > 0, newSize.height > 0 {
                    measuredSize = newSize
                }
            }
            .allowsHitTesting(false)
            .overlay {
                if !isEditing {
                    StatGestureOverlay(
                        widgetVisualCenter: widgetVisualCenter,
                        widgetVisualSize: widgetVisualBoundingSize,
                        widgetRotationRadians: CGFloat((textWidget.rotation + liveRotation).radians),
                        isLocked: activeWidgetId != nil && activeWidgetId != textWidget.id,
                        onTranslationChanged: { translation in
                            if !isDragging {
                                isDragging = true
                                guideState?.beginDrag()
                                if measuredSize.width > 0, measuredSize.height > 0 {
                                    let scaledSize = CGSize(width: measuredSize.width * textWidget.scale, height: measuredSize.height * textWidget.scale)
                                    cachedBoundingSize = rotatedBoundingBox(size: scaledSize, rotation: textWidget.rotation)
                                }
                                onDragStarted?(textWidget.id)
                            }
                            dragOffset = translation

                            if let guideState, cachedBoundingSize.width > 0 {
                                let widgetCenter = CGPoint(
                                    x: canvasSize.width * 0.5 + textWidget.position.width + translation.width,
                                    y: canvasSize.height * 0.5 + textWidget.position.height + translation.height
                                )
                                let result = guideState.computeSnap(widgetCenter: widgetCenter, widgetSize: cachedBoundingSize, canvasSize: canvasSize)
                                snapAdjustment = result.adjustedOffset
                            }
                        },
                        onTranslationEnded: { translation, globalLocation in
                            let movedDistance = sqrt(translation.width * translation.width + translation.height * translation.height)
                            if movedDistance < 4 {
                                onTapped?(textWidget.id)
                            }

                            isDragging = false
                            isRotating = false
                            guideState?.clearGuides()
                            guideState?.clearRotation()
                            let finalSnap = snapAdjustment
                            let wasDeleted = onDragEnded?(textWidget.id, globalLocation) ?? false
                            if wasDeleted {
                                textWidget.position.width += translation.width + finalSnap.width
                                textWidget.position.height += translation.height + finalSnap.height
                                dragOffset = .zero
                                snapAdjustment = .zero
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    isBeingDeleted = true
                                }
                            } else {
                                textWidget.position.width += translation.width + finalSnap.width
                                textWidget.position.height += translation.height + finalSnap.height
                                dragOffset = .zero
                                snapAdjustment = .zero
                            }
                        },
                        onScaleChanged: { scale in
                            liveScale = scale
                        },
                        onScaleEnded: { scale in
                            textWidget.scale *= scale
                            textWidget.scale = min(max(textWidget.scale, 0.3), 4.0)
                            liveScale = 1.0
                        },
                        onRotationChanged: { angle in
                            if !isRotating {
                                isRotating = true
                                guideState?.beginRotation()
                            }
                            if let guideState {
                                let totalDeg = textWidget.rotation.degrees + angle.degrees
                                let result = guideState.computeRotationSnap(currentDegrees: totalDeg)
                                liveRotation = result.snappedAngle - textWidget.rotation
                            } else {
                                liveRotation = angle
                            }
                        },
                        onRotationEnded: { _ in
                            textWidget.rotation += liveRotation
                            liveRotation = .zero
                            isRotating = false
                            guideState?.clearRotation()
                        },
                        onDragStarted: {},
                        onGlobalLocationChanged: { location in
                            onDragChanged?(textWidget.id, location)
                        }
                    )

                }
            }
        .scaleEffect(isBeingDeleted ? 0.01 : textWidget.scale * liveScale)
        .rotationEffect(textWidget.rotation + liveRotation)
        .opacity(isBeingDeleted ? 0 : 1)
        .offset(
            x: textWidget.position.width + dragOffset.width + snapAdjustment.width,
            y: textWidget.position.height + dragOffset.height + snapAdjustment.height
        )
        .transition(.scale.combined(with: .opacity))
    }

    private var widgetVisualCenter: CGPoint {
        CGPoint(
            x: canvasGlobalOrigin.x + canvasSize.width * 0.5 + textWidget.position.width + dragOffset.width + snapAdjustment.width,
            y: canvasGlobalOrigin.y + canvasSize.height * 0.5 + textWidget.position.height + dragOffset.height + snapAdjustment.height
        )
    }

    private var widgetVisualBoundingSize: CGSize {
        if isDragging, cachedBoundingSize.width > 0 {
            return cachedBoundingSize
        }
        let currentScale = textWidget.scale * liveScale
        let scaledSize = CGSize(width: measuredSize.width * currentScale, height: measuredSize.height * currentScale)
        return rotatedBoundingBox(size: scaledSize, rotation: textWidget.rotation + liveRotation)
    }

    private var textContent: some View {
        StyledCanvasText(
            text: textWidget.text.isEmpty ? " " : textWidget.text,
            styleType: textWidget.styleType,
            styleColor: textWidget.styleColor,
            maxWidth: canvasSize.width * 0.8
        )
    }
}
