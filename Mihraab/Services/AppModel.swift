import SwiftUI
import WidgetKit

@MainActor
final class AppModel: ObservableObject {
  private enum Keys {
    static let notificationsEnabled = "notificationsEnabled"
    static let notifiedPrayers = "notifiedPrayers"
  }

  @Published private(set) var island: Island
  @Published var date = Date()
  @Published private(set) var notificationsEnabled: Bool
  @Published private(set) var notifiedPrayers: Set<Prayer>

  private let defaults = UserDefaults.standard

  init() {
    island = SharedSettings.island ?? Timetable.shared.islands[0]
    notificationsEnabled = defaults.bool(forKey: Keys.notificationsEnabled)

    if let stored = defaults.array(forKey: Keys.notifiedPrayers) as? [Int] {
      notifiedPrayers = Set(stored.compactMap(Prayer.init(rawValue:)))
    } else {
      notifiedPrayers = Set(Prayer.allCases).subtracting([.sunrise])
    }
  }

  var schedule: DaySchedule? {
    Timetable.shared.schedule(for: island, on: date)
  }

  var isShowingToday: Bool {
    Calendar.maldives.isDate(date, inSameDayAs: .now)
  }

  func select(_ island: Island) {
    self.island = island
    SharedSettings.defaults.set(island.id, forKey: SharedSettings.islandKey)
    WidgetCenter.shared.reloadAllTimelines()
    refreshNotifications()
  }

  func jumpToToday() {
    date = .now
  }

  @discardableResult
  func setNotificationsEnabled(_ enabled: Bool) async -> Bool {
    if enabled, await !PrayerNotifications.requestAuthorization() {
      notificationsEnabled = false
      defaults.set(false, forKey: Keys.notificationsEnabled)
      return false
    }
    notificationsEnabled = enabled
    defaults.set(enabled, forKey: Keys.notificationsEnabled)
    refreshNotifications()
    return true
  }

  func setNotifies(_ prayer: Prayer, _ enabled: Bool) {
    if enabled {
      notifiedPrayers.insert(prayer)
    } else {
      notifiedPrayers.remove(prayer)
    }
    defaults.set(notifiedPrayers.map(\.rawValue), forKey: Keys.notifiedPrayers)
    refreshNotifications()
  }

  func refreshNotifications() {
    let island = island
    let prayers = notificationsEnabled ? notifiedPrayers : []
    Task {
      await PrayerNotifications.reschedule(for: island, prayers: prayers)
    }
  }
}
