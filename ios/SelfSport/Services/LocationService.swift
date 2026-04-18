import CoreLocation

@Observable
class LocationService: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var cityName: String?
    var latitude: Double?
    var longitude: Double?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isLoading: Bool = false
    var permissionDenied: Bool = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = manager.authorizationStatus
    }

    func requestLocationIfNeeded() {
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            fetchLocation()
        } else {
            permissionDenied = true
        }
    }

    private func fetchLocation() {
        isLoading = true
        manager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                permissionDenied = false
                if cityName == nil {
                    fetchLocation()
                }
            } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
                permissionDenied = true
                isLoading = false
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            Task { @MainActor in
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                self.cityName = placemarks?.first?.locality
                self.isLoading = false
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            isLoading = false
        }
    }
}
