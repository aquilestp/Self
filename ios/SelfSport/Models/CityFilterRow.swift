import Foundation

nonisolated struct CityFilterRow: Codable, Sendable, Identifiable {
    let filter_id: String
    let filter_name: String
    let overlay_url: String
    let sort_order: Int
    let zone_id: String
    let city_name: String
    let distance_km: Double

    var id: String { filter_id }

    var overlayURL: URL? {
        URL(string: overlay_url)
    }
}
