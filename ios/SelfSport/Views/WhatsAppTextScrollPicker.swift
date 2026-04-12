import SwiftUI

struct WhatsAppTextScrollPicker: View {
    let presets: [String]
    let currentText: String
    let onSelectPreset: (String) -> Void

    private let itemHeight: CGFloat = 40
    private let visibleItems: Int = 5

    @State private var selectedIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    private var currentOffset: CGFloat {
        -CGFloat(selectedIndex) * itemHeight + dragOffset
    }

    var body: some View {
        let totalHeight: CGFloat = itemHeight * CGFloat(visibleItems)
        let centerY: CGFloat = totalHeight / 2

        VStack(spacing: 6) {
            ZStack {
                ForEach(Array(presets.enumerated()), id: \.offset) { idx, preset in
                    let y = centerY + CGFloat(idx) * itemHeight + currentOffset - itemHeight / 2
                    let distFromCenter = abs(y - centerY + itemHeight / 2)
                    let maxDist = totalHeight / 2
                    let normalizedDist = min(distFromCenter / maxDist, 1.0)
                    let isSelected = idx == selectedIndex && dragOffset == 0

                    presetRow(text: preset, isSelected: isSelected)
                        .frame(height: itemHeight)
                        .frame(width: 167, alignment: .trailing)
                        .opacity(1.0 - normalizedDist * 0.8)
                        .position(x: 167 / 2, y: y)
                }
            }
            .frame(width: 167, height: totalHeight)
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        let projected = value.predictedEndTranslation.height
                        let steps = -round(projected / itemHeight)
                        let clampedSteps = max(-1, min(1, Int(steps)))
                        let newIndex = max(0, min(presets.count - 1, selectedIndex + clampedSteps))

                        let previousIndex = selectedIndex
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            dragOffset = 0
                            selectedIndex = newIndex
                        }

                        if newIndex != previousIndex {
                            haptic.impactOccurred()
                            onSelectPreset(presets[newIndex])
                        }
                    }
            )
            .onAppear {
                if let idx = presets.firstIndex(of: currentText) {
                    selectedIndex = idx
                } else {
                    selectedIndex = 0
                }
            }
            .onChange(of: currentText) { _, newValue in
                if let idx = presets.firstIndex(of: newValue) {
                    guard idx != selectedIndex else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        selectedIndex = idx
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func presetRow(text: String, isSelected: Bool) -> some View {
        Text(text)
            .font(.system(size: isSelected ? 12 : 10, weight: isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? .white : .white.opacity(0.45))
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 11)
            .padding(.vertical, 4)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(Color(red: 0.00, green: 0.37, blue: 0.33))
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                            )
                    }
                }
            )
            .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}
