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

    var activeWidgetTypes: Set<StatWidgetType> {
        Set(placedWidgets.map(\.type))
    }

    var gridStatTypes: [StatWidgetType] {
        StatWidgetType.allCases.filter { $0 != .fullBanner && $0 != .fullBannerBottom }
    }

    var compactStatsList: some View {
        let activeTypes = activeWidgetTypes
        let types = gridStatTypes
        return VStack(spacing: 10) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                spacing: 10
            ) {
                ForEach(Array(types.prefix(6))) { type in
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
        .frame(maxHeight: 262, alignment: .top)
        .clipped()
    }

    var expandedGrid: some View {
        let activeTypes = activeWidgetTypes
        let types = gridStatTypes
        let firstTwo = Array(types.prefix(6))
        let rest = Array(types.dropFirst(6))
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                    spacing: 10
                ) {
                    ForEach(firstTwo) { type in
                        widgetThumbnail(type: type, isActive: activeTypes.contains(type), large: true)
                    }
                }

                fullWidthThumbnail(type: .fullBanner, isActive: activeTypes.contains(.fullBanner))

                fullWidthThumbnail(type: .fullBannerBottom, isActive: activeTypes.contains(.fullBannerBottom))

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                    spacing: 10
                ) {
                    ForEach(rest) { type in
                        widgetThumbnail(type: type, isActive: activeTypes.contains(type), large: true)
                    }
                }
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

    func widgetThumbnail(type: StatWidgetType, isActive: Bool, large: Bool = false) -> some View {
        let h: CGFloat = large ? 80 : 72
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                toggleWidget(type)
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                miniWidgetPreview(type: type)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 8)
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
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                toggleWidget(type)
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                miniWidgetPreview(type: type)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 8)
            .frame(maxWidth: .infinity)
            .frame(height: 94)
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
