import SwiftUI

extension PhotoEditorView {

    var filterToggles: some View {
        HStack(spacing: 8) {
            filterToggleButton(label: locationService.cityName ?? "City", icon: "building.2.fill", mode: .city)
        }
        .padding(.horizontal, 14)
    }

    func filterToggleButton(label: String, icon: String, mode: FilterMode) -> some View {
        let isActive = filterMode == mode
        return Button {
            withAnimation(.snappy(duration: 0.3)) {
                if filterMode == mode {
                    filterMode = .none
                } else {
                    filterMode = mode
                    if mode == .city { cityFilterIndex = 0 }
                    if mode == .races { raceFilterIndex = 0 }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(isActive ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .frame(height: 36)
            .background(
                isActive
                    ? AnyShapeStyle(Color.white.opacity(0.22))
                    : AnyShapeStyle(Color.white.opacity(0.08)),
                in: .capsule
            )
            .background(.ultraThinMaterial, in: .capsule)
            .overlay(
                Capsule()
                    .stroke(isActive ? Color.white.opacity(0.35) : Color.white.opacity(0.1), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isActive)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)
    }

    var photoFilterDotsView: some View {
        let allFilters = PhotoFilterType.allCases
        return HStack(spacing: 6) {
            ForEach(Array(allFilters.enumerated()), id: \.element) { idx, filter in
                let isActive = filter == activePhotoFilter
                Circle()
                    .fill(isActive ? Color.white : Color.white.opacity(0.35))
                    .frame(width: isActive ? 8 : 6, height: isActive ? 8 : 6)
                    .animation(.easeInOut(duration: 0.2), value: activePhotoFilter)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(.black.opacity(0.25), in: .capsule)
    }

    var photoFilterLabelView: some View {
        Text(filterLabelText)
            .font(.system(size: 22, weight: .bold))
            .tracking(3)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.7), radius: 8, x: 0, y: 2)
            .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
    }

    @ViewBuilder
    func activeFilterOverlay(size: CGSize) -> some View {
        switch filterMode {
        case .none:
            EmptyView()
        case .city:
            Group {
                if hasDynamicCityFilters {
                    if cityFilterIndex < dynamicCityFilters.count {
                        DynamicCityOverlay(
                            size: size,
                            overlayURL: dynamicCityFilters[cityFilterIndex].overlayURL
                        )
                    } else {
                        EmptyView()
                    }
                } else {
                    let filter = fallbackCityFilters[cityFilterIndex]
                    switch filter {
                    case .none: EmptyView()
                    case .skyline: CityOverlay_Skyline(size: size)
                    case .postcard: CityOverlay_Postcard(size: size, activity: currentActivity)
                    case .neon: CityOverlay_Neon(size: size, activity: currentActivity)
                    case .stamp: CityOverlay_Stamp(size: size, activity: currentActivity)
                    case .gps: CityOverlay_GPS(size: size, activity: currentActivity)
                    }
                }
            }
        case .races:
            let filter = raceFilters[raceFilterIndex]
            Group {
                switch filter {
                case .none: EmptyView()
                case .bibNumber: RaceOverlay_Bib(size: size)
                case .finisher: RaceOverlay_Finisher(size: size, activity: currentActivity)
                case .medal: RaceOverlay_Medal(size: size, activity: currentActivity)
                case .raceRoute: RaceOverlay_Route(size: size, activity: currentActivity)
                case .racePoster: RaceOverlay_Poster(size: size, activity: currentActivity)
                }
            }
        }
    }

    var filterOverlayId: String {
        switch filterMode {
        case .none: return "filter_none"
        case .city: return "filter_city_\(cityFilterIndex)"
        case .races: return "filter_race_\(raceFilterIndex)"
        }
    }

    var filterDots: some View {
        let count: Int
        let currentIndex: Int

        switch filterMode {
        case .none:
            if hasDynamicCityFilters {
                count = cityFilterCount
                currentIndex = cityFilterIndex
            } else {
                count = 0
                currentIndex = 0
            }
        case .city:
            count = cityFilterCount
            currentIndex = cityFilterIndex
        case .races:
            count = raceFilters.count
            currentIndex = raceFilterIndex
        }

        return HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.white : Color.white.opacity(0.35))
                    .frame(width: index == currentIndex ? 8 : 6, height: index == currentIndex ? 8 : 6)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.3)) {
                            setFilterIndex(index)
                        }
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.black.opacity(0.3), in: .capsule)
        .background(.ultraThinMaterial.opacity(0.5), in: .capsule)
    }

    func advanceFilter(by delta: Int) {
        switch filterMode {
        case .none:
            if hasDynamicCityFilters {
                guard !dynamicCityFilters.isEmpty else { return }
                if delta > 0 {
                    cityFilterIndex = 0
                } else {
                    cityFilterIndex = dynamicCityFilters.count - 1
                }
                filterMode = .city
            }
        case .city:
            let total = cityFilterCount
            guard total > 0 else { return }
            cityFilterIndex = ((cityFilterIndex + delta) % total + total) % total
        case .races:
            let newIndex = raceFilterIndex + delta
            if newIndex >= 0 && newIndex < raceFilters.count {
                raceFilterIndex = newIndex
            }
        }
    }

    func setFilterIndex(_ index: Int) {
        switch filterMode {
        case .none:
            if hasDynamicCityFilters {
                cityFilterIndex = index
                filterMode = .city
            }
        case .city: cityFilterIndex = index
        case .races: raceFilterIndex = index
        }
    }

    func loadDynamicCityFilters(lat: Double, lng: Double) async {
        isLoadingCityFilters = true
        do {
            let filters = try await cityFilterService.fetchNearbyFilters(latitude: lat, longitude: lng)
            dynamicCityFilters = filters
            if !filters.isEmpty {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    filterSwipeDirection = .trailing
                    filterMode = .city
                    cityFilterIndex = 0
                }
            }
        } catch {
            print("[CityFilters] Error loading filters: \(error)")
            dynamicCityFilters = []
        }
        isLoadingCityFilters = false
    }
}
