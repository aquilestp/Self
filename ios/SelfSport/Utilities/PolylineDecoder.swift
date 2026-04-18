import Foundation
import CoreLocation

nonisolated enum PolylineDecoder {
    static func decode(_ encoded: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        let bytes = Array(encoded.utf8)
        let length = bytes.count
        var index = 0
        var lat = 0.0
        var lng = 0.0

        while index < length {
            var result = 0
            var shift = 0
            var byte: Int

            repeat {
                byte = Int(bytes[index]) - 63
                index += 1
                result |= (byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20

            let deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
            lat += Double(deltaLat)

            result = 0
            shift = 0

            repeat {
                byte = Int(bytes[index]) - 63
                index += 1
                result |= (byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20

            let deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
            lng += Double(deltaLng)

            coordinates.append(CLLocationCoordinate2D(latitude: lat / 1e5, longitude: lng / 1e5))
        }

        return coordinates
    }

    static func normalizedPoints(from encoded: String) -> [CGPoint] {
        let coords = decode(encoded)
        guard coords.count >= 2 else { return [] }

        let lats = coords.map(\.latitude)
        let lngs = coords.map(\.longitude)

        guard let minLat = lats.min(), let maxLat = lats.max(),
              let minLng = lngs.min(), let maxLng = lngs.max() else { return [] }

        let latRange = maxLat - minLat
        let lngRange = maxLng - minLng

        guard latRange > 0 || lngRange > 0 else { return [] }

        let midLat = (minLat + maxLat) / 2.0
        let cosLat = cos(midLat * .pi / 180.0)
        let adjustedLngRange = lngRange * cosLat

        let scale = max(latRange, adjustedLngRange)
        guard scale > 0 else { return [] }

        let centerLat = (minLat + maxLat) / 2.0
        let centerLng = (minLng + maxLng) / 2.0

        return coords.map { coord in
            let x = ((coord.longitude - centerLng) * cosLat) / scale + 0.5
            let y = 0.5 - (coord.latitude - centerLat) / scale
            let paddedX = 0.03 + x * 0.94
            let paddedY = 0.03 + y * 0.94
            return CGPoint(x: paddedX, y: paddedY)
        }
    }
}
