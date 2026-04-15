import SwiftUI

struct PaletteSelectorView: View {
    let targetWidget: PlacedWidget?
    let showPaletteSelector: Bool
    let waPresetTexts: [String]
    let updateWidget: (String, (inout PlacedWidget) -> Void) -> Void
    let resetHideTimer: () -> Void

    private let hapticLight = HapticService.light

    private var widget: PlacedWidget? { targetWidget }

    private var paletteCount: Int { WidgetPalette.allCases.count }

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            paletteButtons
            glassToggle
            bestEffortsSection
            splitsSection
            distanceWordsSection
            basicFieldsSection
            boldImpactSection
            heroStatSection
            fullBannerSection
            bvtSection
            ancestralMedalSection
            splitBannerSection
            whatsappSection
        }
        .padding(.vertical, 10)
        .padding(.leading, 6)
        .padding(.trailing, 12)
    }

    // MARK: - Palette Color Buttons

    @ViewBuilder
    private var paletteButtons: some View {
        let type = widget?.type
        let hideColors = type == .whatsappMessage || type == .ancestralMedal
        if !hideColors {
            let currentPalette = widget?.colorStyle.palette ?? .classic
            ForEach(Array(WidgetPalette.allCases.enumerated()), id: \.element.id) { index, palette in
                let isActive = currentPalette == palette
                animatedButton(delay: Double(index) * 0.04) {
                    mutate { $0.colorStyle.setPalette(palette) }
                } label: {
                    paletteCircleLabel(palette: palette, isActive: isActive)
                }
            }
        }
    }

    // MARK: - Glass Toggle

    @ViewBuilder
    private var glassToggle: some View {
        let type = widget?.type
        let supportsGlass = type?.supportsGlass ?? false
        let isWhatsapp = type == .whatsappMessage
        if supportsGlass && !isWhatsapp {
            let glassOn = widget?.useGlassBackground ?? false
            separator(delay: Double(paletteCount) * 0.04)
            animatedButton(delay: Double(paletteCount) * 0.04 + 0.02) {
                mutate { $0.useGlassBackground.toggle() }
            } label: {
                circleButton(
                    icon: glassOn ? "square.fill.on.square.fill" : "square.dashed",
                    isActive: glassOn
                )
            }
        }
    }

    // MARK: - Best Efforts

    @ViewBuilder
    private var bestEffortsSection: some View {
        if widget?.type == .bestEfforts {
            let current = widget?.bestEffortsFilter ?? .km
            separator(delay: Double(paletteCount) * 0.04 + 0.04)
            ForEach(Array(BestEffortsUnitFilter.allCases.enumerated()), id: \.element.id) { filterIdx, filter in
                let isActive = current == filter
                animatedButton(delay: Double(paletteCount) * 0.04 + 0.06 + Double(filterIdx) * 0.03) {
                    mutate { $0.bestEffortsFilter = filter }
                } label: {
                    textCircleButton(text: filter.label, isActive: isActive)
                }
            }
        }
    }

    // MARK: - Splits

    @ViewBuilder
    private var splitsSection: some View {
        let type = widget?.type
        let isSplits = type == .splits || type == .splitsTable || type == .splitsFastest || type == .splitsBars
        if isSplits {
            let current = widget?.splitsFilter ?? .km
            separator(delay: Double(paletteCount) * 0.04 + 0.04)
            unitToggle(current: current, delay: Double(paletteCount) * 0.04 + 0.06) {
                mutate { $0.splitsFilter = $0.splitsFilter == .km ? .miles : .km }
            }
        }
    }

    // MARK: - Distance Words

    @ViewBuilder
    private var distanceWordsSection: some View {
        if widget?.type.isDistanceWords ?? false {
            let baseDelay = Double(paletteCount) * 0.04
            let current = widget?.distanceWordsFilter ?? .km
            let currentFont = widget?.distanceWordsFontStyle ?? .system
            separator(delay: baseDelay + 0.04)
            unitToggle(current: current, delay: baseDelay + 0.06) {
                mutate { $0.distanceWordsFilter = $0.distanceWordsFilter == .km ? .miles : .km }
            }
            SplitBannerFontScrollPicker(
                currentStyle: currentFont,
                onSelectStyle: { style in
                    mutate { $0.distanceWordsFontStyle = style }
                }
            )
            .offset(x: 12)
            .scaleEffect(showPaletteSelector ? 1 : 0.3)
            .opacity(showPaletteSelector ? 1 : 0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.7).delay(baseDelay + 0.08),
                value: showPaletteSelector
            )
        }
    }

    // MARK: - Basic Field Visibility

    @ViewBuilder
    private var basicFieldsSection: some View {
        if widget?.type.supportsBasicFieldVisibility ?? false {
            let baseDelay = Double(paletteCount) * 0.04
            separator(delay: baseDelay + 0.04)
            visToggle(icon: "textformat", isOn: widget?.showActivityName ?? true, delay: baseDelay + 0.06) {
                mutate { $0.showActivityName.toggle() }
            }
            visToggle(icon: "calendar", isOn: widget?.showDate ?? true, delay: baseDelay + 0.09) {
                mutate { $0.showDate.toggle() }
            }
            visToggle(icon: "ruler", isOn: widget?.showDistance ?? true, delay: baseDelay + 0.12) {
                mutate { $0.showDistance.toggle() }
            }
            visToggle(icon: "speedometer", isOn: widget?.showPace ?? true, delay: baseDelay + 0.15) {
                mutate { $0.showPace.toggle() }
            }
            visToggle(icon: "clock", isOn: widget?.showTime ?? true, delay: baseDelay + 0.18) {
                mutate { $0.showTime.toggle() }
            }
            basicUnitSection
        }
    }

    @ViewBuilder
    private var basicUnitSection: some View {
        let current = widget?.basicUnitFilter ?? .km
        let baseDelay = Double(paletteCount) * 0.04
        separator(delay: baseDelay + 0.20)
        unitToggle(current: current, delay: baseDelay + 0.22) {
            mutate { $0.basicUnitFilter = $0.basicUnitFilter == .km ? .miles : .km }
        }
    }

    // MARK: - Bold / Impact

    @ViewBuilder
    private var boldImpactSection: some View {
        let type = widget?.type
        if type == .bold || type == .impact {
            let baseDelay = Double(paletteCount) * 0.04
            separator(delay: baseDelay + 0.04)
            visToggle(icon: "textformat", isOn: widget?.showTitle ?? true, delay: baseDelay + 0.06) {
                mutate { $0.showTitle.toggle() }
            }
            visToggle(icon: "speedometer", isOn: widget?.showPace ?? true, delay: baseDelay + 0.09) {
                mutate { $0.showPace.toggle() }
            }
            visToggle(icon: "clock", isOn: widget?.showTime ?? true, delay: baseDelay + 0.12) {
                mutate { $0.showTime.toggle() }
            }
            visToggle(icon: "mountain.2", isOn: widget?.showElevation ?? true, delay: baseDelay + 0.15) {
                mutate { $0.showElevation.toggle() }
            }
        }
    }

    // MARK: - Hero Stat

    @ViewBuilder
    private var heroStatSection: some View {
        if widget?.type == .heroStat {
            let baseDelay = Double(paletteCount) * 0.04
            separator(delay: baseDelay + 0.04)
            visToggle(icon: "speedometer", isOn: widget?.showPace ?? true, delay: baseDelay + 0.06) {
                mutate { $0.showPace.toggle() }
            }
            visToggle(icon: "clock", isOn: widget?.showTime ?? true, delay: baseDelay + 0.09) {
                mutate { $0.showTime.toggle() }
            }
        }
    }

    // MARK: - Full Banner

    @ViewBuilder
    private var fullBannerSection: some View {
        let type = widget?.type
        if type == .fullBanner || type == .fullBannerBottom {
            let baseDelay = Double(paletteCount) * 0.04
            let current = widget?.fullBannerUnitFilter ?? .km
            separator(delay: baseDelay + 0.04)
            unitToggle(current: current, delay: baseDelay + 0.06) {
                mutate { $0.fullBannerUnitFilter = $0.fullBannerUnitFilter == .km ? .miles : .km }
            }
            separator(delay: baseDelay + 0.12)
            visToggle(icon: "clock", isOn: widget?.fullBannerShowTime ?? true, delay: baseDelay + 0.14) {
                mutate { $0.fullBannerShowTime.toggle() }
            }
            visToggle(icon: "ruler", isOn: widget?.fullBannerShowDistance ?? true, delay: baseDelay + 0.17) {
                mutate { $0.fullBannerShowDistance.toggle() }
            }
            visToggle(icon: "speedometer", isOn: widget?.fullBannerShowPace ?? true, delay: baseDelay + 0.20) {
                mutate { $0.fullBannerShowPace.toggle() }
            }
            visToggle(icon: "mountain.2", isOn: widget?.fullBannerShowElevation ?? true, delay: baseDelay + 0.23) {
                mutate { $0.fullBannerShowElevation.toggle() }
            }
        }
    }

    // MARK: - BVT

    @ViewBuilder
    private var bvtSection: some View {
        if widget?.type == .blurredVerticalText {
            let baseDelay = Double(paletteCount) * 0.04
            let current = widget?.bvtUnitFilter ?? .km
            let currentEffect = widget?.bvtEffect ?? .glow
            separator(delay: baseDelay + 0.04)
            unitToggle(current: current, delay: baseDelay + 0.06) {
                mutate { $0.bvtUnitFilter = $0.bvtUnitFilter == .km ? .miles : .km }
            }
            BVTEffectScrollPicker(
                currentEffect: currentEffect,
                onSelectEffect: { effect in
                    mutate { $0.bvtEffect = effect }
                }
            )
            .scaleEffect(showPaletteSelector ? 1 : 0.3)
            .opacity(showPaletteSelector ? 1 : 0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.7).delay(baseDelay + 0.08),
                value: showPaletteSelector
            )
        }
    }

    // MARK: - Ancestral Medal

    @ViewBuilder
    private var ancestralMedalSection: some View {
        if widget?.type == .ancestralMedal {
            let baseDelay = Double(paletteCount) * 0.04
            let current = widget?.ancestralUnitFilter ?? .km
            separator(delay: baseDelay + 0.04)
            unitToggle(current: current, delay: baseDelay + 0.06) {
                mutate { $0.ancestralUnitFilter = $0.ancestralUnitFilter == .km ? .miles : .km }
            }
            separator(delay: baseDelay + 0.10)
            visToggle(icon: "speedometer", isOn: widget?.ancestralShowPace ?? true, delay: baseDelay + 0.12) {
                mutate { $0.ancestralShowPace.toggle() }
            }
            visToggle(icon: "clock", isOn: widget?.ancestralShowTime ?? true, delay: baseDelay + 0.15) {
                mutate { $0.ancestralShowTime.toggle() }
            }
        }
    }

    // MARK: - Split Banner

    @ViewBuilder
    private var splitBannerSection: some View {
        if widget?.type == .splitBanner {
            let baseDelay = Double(paletteCount) * 0.04
            let current = widget?.splitBannerUnitFilter ?? .km
            let currentFont = widget?.splitBannerFontStyle ?? .system
            separator(delay: baseDelay + 0.04)
            unitToggle(current: current, delay: baseDelay + 0.06) {
                mutate { $0.splitBannerUnitFilter = $0.splitBannerUnitFilter == .km ? .miles : .km }
            }
            SplitBannerFontScrollPicker(
                currentStyle: currentFont,
                onSelectStyle: { style in
                    mutate { $0.splitBannerFontStyle = style }
                }
            )
            .offset(x: 12)
            .scaleEffect(showPaletteSelector ? 1 : 0.3)
            .opacity(showPaletteSelector ? 1 : 0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.7).delay(baseDelay + 0.08),
                value: showPaletteSelector
            )
        }
    }

    // MARK: - WhatsApp

    @ViewBuilder
    private var whatsappSection: some View {
        if widget?.type == .whatsappMessage {
            let baseDelay = Double(paletteCount) * 0.04
            let currentText = widget?.whatsappText ?? ""
            separator(delay: baseDelay + 0.04)
            WhatsAppTextScrollPicker(
                presets: waPresetTexts,
                currentText: currentText,
                onSelectPreset: { preset in
                    mutate { $0.whatsappText = preset }
                }
            )
            .scaleEffect(showPaletteSelector ? 1 : 0.3)
            .opacity(showPaletteSelector ? 1 : 0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.7).delay(baseDelay + 0.06),
                value: showPaletteSelector
            )
        }
    }

    // MARK: - Reusable Components

    private func mutate(_ transform: @escaping (inout PlacedWidget) -> Void) {
        guard let id = widget?.id else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            updateWidget(id, transform)
        }
        hapticLight.impactOccurred()
        resetHideTimer()
    }

    private func separator(delay: Double) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(width: 20, height: 1)
            .scaleEffect(showPaletteSelector ? 1 : 0.3)
            .opacity(showPaletteSelector ? 1 : 0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.7).delay(delay),
                value: showPaletteSelector
            )
    }

    private func animatedButton(delay: Double, action: @escaping () -> Void, @ViewBuilder label: () -> some View) -> some View {
        Button(action: action) { label() }
            .buttonStyle(.plain)
            .scaleEffect(showPaletteSelector ? 1 : 0.3)
            .opacity(showPaletteSelector ? 1 : 0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.7).delay(delay),
                value: showPaletteSelector
            )
    }

    private func unitToggle(current: SplitsUnitFilter, delay: Double, action: @escaping () -> Void) -> some View {
        animatedButton(delay: delay, action: action) {
            Text(current.label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))
                .contentTransition(.numericText())
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.25), in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1.5))
        }
    }

    private func visToggle(icon: String, isOn: Bool, delay: Double, action: @escaping () -> Void) -> some View {
        animatedButton(delay: delay, action: action) {
            ZStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isOn ? .white.opacity(0.9) : .white.opacity(0.3))
                if !isOn {
                    Rectangle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 22, height: 1.5)
                        .rotationEffect(.degrees(-45))
                }
            }
            .frame(width: 36, height: 36)
            .background(isOn ? Color.white.opacity(0.25) : Color.black.opacity(0.45), in: Circle())
            .overlay(
                Circle().stroke(
                    isOn ? Color.white.opacity(0.6) : Color.white.opacity(0.15),
                    lineWidth: isOn ? 1.5 : 0.5
                )
            )
        }
    }

    private func circleButton(icon: String, isActive: Bool) -> some View {
        Image(systemName: icon)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(isActive ? .white.opacity(0.9) : .white.opacity(0.5))
            .frame(width: 36, height: 36)
            .background(isActive ? Color.white.opacity(0.25) : Color.black.opacity(0.45), in: Circle())
            .overlay(
                Circle().stroke(
                    isActive ? Color.white.opacity(0.6) : Color.white.opacity(0.15),
                    lineWidth: isActive ? 1.5 : 0.5
                )
            )
    }

    private func textCircleButton(text: String, isActive: Bool) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(isActive ? .white.opacity(0.9) : .white.opacity(0.5))
            .frame(width: 36, height: 36)
            .background(isActive ? Color.white.opacity(0.25) : Color.black.opacity(0.45), in: Circle())
            .overlay(
                Circle().stroke(
                    isActive ? Color.white.opacity(0.6) : Color.white.opacity(0.15),
                    lineWidth: isActive ? 1.5 : 0.5
                )
            )
    }

    private func paletteCircleLabel(palette: WidgetPalette, isActive: Bool) -> some View {
        ZStack {
            let previewColors = palette.previewColors
            ForEach(Array(previewColors.enumerated()), id: \.offset) { i, color in
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(Color.black.opacity(0.25), lineWidth: 0.5))
                    .offset(
                        x: i == 0 ? -6 : i == 1 ? 6 : 0,
                        y: i == 0 ? -4 : i == 1 ? -4 : 6
                    )
            }
        }
        .frame(width: 36, height: 36)
        .background(isActive ? Color.white.opacity(0.25) : Color.black.opacity(0.45), in: Circle())
        .overlay(
            Circle().stroke(
                isActive ? Color.white.opacity(0.6) : Color.white.opacity(0.15),
                lineWidth: isActive ? 1.5 : 0.5
            )
        )
    }

}
