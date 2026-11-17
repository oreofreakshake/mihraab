import CoreLocation

@MainActor
final class Locator: NSObject, ObservableObject, CLLocationManagerDelegate {
  enum LocatorError: LocalizedError {
    case denied
    case unavailable
    case outsideMaldives

    var errorDescription: String? {
      switch self {
      case .denied: "Location access is turned off. You can enable it in Settings."
      case .unavailable: "Couldn't find your location. Try again in a moment."
      case .outsideMaldives: "You don't seem to be in the Maldives. Pick an island from the list instead."
      }
    }
  }

  private static let maximumDistance: CLLocationDistance = 60_000

  @Published private(set) var isLocating = false

  private let manager = CLLocationManager()
  private var continuation: CheckedContinuation<CLLocation, Error>?

  override init() {
    super.init()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyKilometer
  }

  func nearestIsland() async throws -> Island {
    let location = try await locate()
    let candidates = Timetable.shared.islands.compactMap { island -> (Island, CLLocationDistance)? in
      guard let lat = island.latitude, let lon = island.longitude else { return nil }
      return (island, location.distance(from: CLLocation(latitude: lat, longitude: lon)))
    }
    guard let nearest = candidates.min(by: { $0.1 < $1.1 }) else { throw LocatorError.unavailable }
    guard nearest.1 < Self.maximumDistance else { throw LocatorError.outsideMaldives }
    return nearest.0
  }

  private func locate() async throws -> CLLocation {
    switch manager.authorizationStatus {
    case .denied, .restricted:
      throw LocatorError.denied
    default:
      break
    }

    isLocating = true
    defer { isLocating = false }

    return try await withCheckedThrowingContinuation { continuation in
      self.continuation?.resume(throwing: CancellationError())
      self.continuation = continuation
      if manager.authorizationStatus == .notDetermined {
        manager.requestWhenInUseAuthorization()
      } else {
        manager.requestLocation()
      }
    }
  }

  private func finish(_ result: Result<CLLocation, Error>) {
    continuation?.resume(with: result)
    continuation = nil
  }

  nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    let status = manager.authorizationStatus
    Task { @MainActor in
      guard continuation != nil else { return }
      switch status {
      case .authorizedWhenInUse, .authorizedAlways:
        self.manager.requestLocation()
      case .denied, .restricted:
        finish(.failure(LocatorError.denied))
      default:
        break
      }
    }
  }

  nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    Task { @MainActor in finish(.success(location)) }
  }

  nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    Task { @MainActor in finish(.failure(LocatorError.unavailable)) }
  }
}
