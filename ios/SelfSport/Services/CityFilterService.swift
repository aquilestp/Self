import Foundation
import Supabase

final class CityFilterService {
    private var cachedFilters: [CityFilterRow] = []
    private var cachedLat: Double?
    private var cachedLng: Double?

    var filters: [CityFilterRow] { cachedFilters }

    func fetchNearbyFilters(latitude: Double, longitude: Double) async throws -> [CityFilterRow] {
        if latitude == cachedLat, longitude == cachedLng, !cachedFilters.isEmpty {
            return cachedFilters
        }

        let rows: [CityFilterRow] = try await supabase
            .rpc("get_nearby_filters", params: ["user_lat": latitude, "user_lng": longitude])
            .execute()
            .value

        cachedLat = latitude
        cachedLng = longitude
        cachedFilters = rows
        return rows
    }

    func clearCache() {
        cachedFilters = []
        cachedLat = nil
        cachedLng = nil
    }
}
