import UserNotifications

enum PrayerNotifications {
  private static let limit = 64
  private static let daysAhead = 12

  private static var center: UNUserNotificationCenter { .current() }

  static func requestAuthorization() async -> Bool {
    (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
  }

  static func authorizationStatus() async -> UNAuthorizationStatus {
    await center.notificationSettings().authorizationStatus
  }

  static func reschedule(for island: Island, prayers: Set<Prayer>, from now: Date = .now) async {
    center.removeAllPendingNotificationRequests()
    guard !prayers.isEmpty, await authorizationStatus() == .authorized else { return }

    var scheduled = 0
    for offset in 0..<daysAhead {
      let day = Calendar.maldives.date(byAdding: .day, value: offset, to: now)!
      guard let schedule = Timetable.shared.schedule(for: island, on: day) else { continue }

      for prayer in Prayer.allCases where prayers.contains(prayer) {
        let date = schedule.time(of: prayer)
        guard date > now else { continue }
        guard scheduled < limit else { return }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSince(now), repeats: false)
        let request = UNNotificationRequest(
          identifier: "\(prayer.name)-\(Int(date.timeIntervalSince1970))",
          content: content(for: prayer),
          trigger: trigger
        )
        try? await center.add(request)
        scheduled += 1
      }
    }
  }

  private static func message(for prayer: Prayer) -> String {
    switch prayer {
    case .fajr: "Start your day with prayer."
    case .sunrise: "Fajr time has ended."
    case .dhuhr: "Pause for Dhuhr."
    case .asr: "Take a moment for Asr."
    case .maghrib: "The sun has set. Time for Maghrib."
    case .isha: "End your day with Isha."
    }
  }

  private static func content(for prayer: Prayer) -> UNNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = prayer.name
    content.body = message(for: prayer)
    content.sound = .default
    content.interruptionLevel = .timeSensitive
    return content
  }
}
