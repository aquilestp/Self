import SwiftUI

extension PhotoEditorView {

    var expandedDrawer: some View {
        GeometryReader { geo in
            let isExpanded = drawerState == .expanded
            let drawerHeight = isExpanded ? geo.size.height * 0.75 : 0

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 0) {
                    Capsule()
                        .fill(.white.opacity(0.35))
                        .frame(width: 36, height: 4)
                        .padding(.top, 10)
                        .padding(.bottom, 6)

                    drawerTabPills
                        .padding(.top, 6)
                        .padding(.bottom, 10)

                    if isExpanded {
                        expandedGrid
                            .transition(.opacity)
                    } else {
                        compactStatsList
                            .transition(.opacity)
                    }
                }
                .frame(height: isExpanded ? drawerHeight : nil)
                .background(.black.opacity(0.55))
                .background(.ultraThinMaterial)
                .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
                .contentShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
                .onTapGesture {
                    if drawerState == .open {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                            drawerState = .expanded
                        }
                    }
                }
                .offset(y: drawerDragOffset)
                .gesture(drawerDragGesture)
            }
        }
    }

    private var drawerTabPills: some View {
        HStack(spacing: 6) {
            drawerPill(tab: .popular, icon: "flame.fill")
            drawerPill(tab: .recents, icon: "clock.arrow.circlepath")
        }
        .padding(.horizontal, 14)
    }

    private func drawerPill(tab: DrawerTab, icon: String) -> some View {
        let isSelected = drawerTab == tab
        return Button {
            guard drawerTab != tab else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                drawerTab = tab
            }
            HapticService.selection.selectionChanged()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                Text(tab.rawValue)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(isSelected ? 1.0 : 0.45))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.3) : Color.clear, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    var activeWidgetTypes: Set<StatWidgetType> {
        Set(placedWidgets.map(\.type))
    }

    func sortedWidgetTypes() -> [StatWidgetType] {
        let all = StatWidgetType.allCases.filter { $0 != .fullBanner && $0 != .fullBannerBottom && $0 != .ancestralMedal }
        switch drawerTab {
        case .popular:
            return all.sorted { a, b in
                let countA = widgetPopularityMap[a.rawValue] ?? 0
                let countB = widgetPopularityMap[b.rawValue] ?? 0
                if countA != countB { return countA > countB }
                return (all.firstIndex(of: a) ?? 0) < (all.firstIndex(of: b) ?? 0)
            }
        case .recents:
            if userRecentsMap.isEmpty {
                return all.sorted { a, b in
                    let countA = widgetPopularityMap[a.rawValue] ?? 0
                    let countB = widgetPopularityMap[b.rawValue] ?? 0
                    if countA != countB { return countA > countB }
                    return (all.firstIndex(of: a) ?? 0) < (all.firstIndex(of: b) ?? 0)
                }
            }
            return all.sorted { a, b in
                let dateA = userRecentsMap[a.rawValue]
                let dateB = userRecentsMap[b.rawValue]
                if let dA = dateA, let dB = dateB { return dA > dB }
                if dateA != nil { return true }
                if dateB != nil { return false }
                return (all.firstIndex(of: a) ?? 0) < (all.firstIndex(of: b) ?? 0)
            }
        }
    }

    var gridStatTypes: [StatWidgetType] {
        cachedSortedWidgetTypes.isEmpty ? sortedWidgetTypes() : cachedSortedWidgetTypes
    }

    var compactStatsList: some View {
        let activeTypes = activeWidgetTypes
        let types = gridStatTypes
        let hasText = !placedTexts.isEmpty
        return VStack(spacing: 10) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2),
                spacing: 10
            ) {
                textThumbnail(isActive: hasText)
                ForEach(Array(types.prefix(3)), id: \.rawValue) { type in
                    widgetThumbnail(type: type, isActive: activeTypes.contains(type), large: true)
                }
            }
            .padding(.horizontal, 14)

            fullWidthThumbnail(type: .fullBanner, isActive: activeTypes.contains(.fullBanner))
                .padding(.horizontal, 14)

            fullWidthThumbnail(type: .fullBannerBottom, isActive: activeTypes.contains(.fullBannerBottom))
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
        }
        .frame(maxHeight: 320, alignment: .top)
        .clipped()
    }

    var expandedGrid: some View {
        let activeTypes = activeWidgetTypes
        let types = gridStatTypes
        let hasText = !placedTexts.isEmpty
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2),
                    spacing: 10
                ) {
                    textThumbnail(isActive: hasText)
                    ForEach(types, id: \.rawValue) { type in
                        widgetThumbnail(type: type, isActive: activeTypes.contains(type), large: true)
                    }
                }

                fullWidthThumbnail(type: .fullBanner, isActive: activeTypes.contains(.fullBanner))

                fullWidthThumbnail(type: .fullBannerBottom, isActive: activeTypes.contains(.fullBannerBottom))
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 20)
        }
    }

    var drawerDragGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                let translation = value.translation.height
                if drawerState == .open {
                    drawerDragOffset = translation < 0 ? translation * 0.5 : translation
                } else if drawerState == .expanded {
                    drawerDragOffset = translation > 0 ? translation * 0.5 : 0
                }
            }
            .onEnded { value in
                let translation = value.translation.height
                let velocity = value.predictedEndTranslation.height
                withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                    drawerDragOffset = 0
                    if drawerState == .open {
                        if translation < -50 || velocity < -200 {
                            drawerState = .expanded
                        } else if translation > 60 || velocity > 300 {
                            drawerState = .collapsed
                        }
                    } else if drawerState == .expanded {
                        if translation > 50 || velocity > 200 {
                            drawerState = .open
                        }
                    }
                }
            }
    }

    func textThumbnail(isActive: Bool) -> some View {
        let h: CGFloat = 106
        return Button {
            hapticLight.impactOccurred()
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                drawerState = .collapsed
            }
            startNewTextEditing()
        } label: {
            VStack(spacing: 4) {
                Text("Aa")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundStyle(.white.opacity(0.9))
                Text("Text")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
            .frame(height: h)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isActive ? Color.white.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 0.5)
            )
            .clipShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isActive)
    }

    func widgetThumbnail(type: StatWidgetType, isActive: Bool, large: Bool = false) -> some View {
        let h: CGFloat = large ? 106 : 90
        let scale: CGFloat = 1.45
        let hPad: CGFloat = 10
        let vPad: CGFloat = 8
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                toggleWidget(type)
            }
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                drawerState = .collapsed
            }
        } label: {
            GeometryReader { geo in
                let innerW = max(0, geo.size.width - hPad * 2)
                let innerH = max(0, geo.size.height - vPad * 2)
                ZStack {
                    miniWidgetPreview(type: type)
                        .frame(width: innerW / scale, height: innerH / scale)
                        .scaleEffect(scale)
                        .frame(width: innerW, height: innerH)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(maxWidth: large ? .infinity : nil)
            .frame(width: large ? nil : 119, height: h)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isActive ? Color.white.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 0.5)
            )
            .clipShape(.rect(cornerRadius: 14))
            .scaleEffect(isActive ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isActive)
    }

    func fullWidthThumbnail(type: StatWidgetType, isActive: Bool) -> some View {
        let scale: CGFloat = 1.45
        let hPad: CGFloat = 14
        let vPad: CGFloat = 10
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                toggleWidget(type)
            }
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                drawerState = .collapsed
            }
        } label: {
            GeometryReader { geo in
                let innerW = max(0, geo.size.width - hPad * 2)
                let innerH = max(0, geo.size.height - vPad * 2)
                ZStack {
                    miniWidgetPreview(type: type)
                        .frame(width: innerW / scale, height: innerH / scale)
                        .scaleEffect(scale)
                        .frame(width: innerW, height: innerH)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isActive ? Color.white.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 0.5)
            )
            .clipShape(.rect(cornerRadius: 14))
            .scaleEffect(isActive ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isActive)
    }
}
