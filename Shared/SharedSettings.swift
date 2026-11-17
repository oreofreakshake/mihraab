import Foundation

enum SharedSettings {
  static let appGroup = "group.com.yazak.Mihraab"
  static let islandKey = "selectedIslandID"

  static let defaultIslandID = 102

  static var defaults: UserDefaults {
    UserDefaults(suiteName: appGroup) ?? .standard
  }

  static var island: Island? {
    let id = defaults.object(forKey: islandKey) as? Int ?? defaultIslandID
    return Timetable.shared.island(id: id) ?? Timetable.shared.island(id: defaultIslandID)
  }
}
