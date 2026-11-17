import WidgetKit

struct PrayerEntry: TimelineEntry {
  let date: Date
  let schedule: DaySchedule?
  let next: (prayer: Prayer, date: Date)?
}

struct PrayerTimelineProvider: TimelineProvider {
  func placeholder(in context: Context) -> PrayerEntry {
    entry(at: .now)
  }

  func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
    completion(entry(at: .now))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
    let now = Date.now
    var dates = [now]

    if let island = SharedSettings.island {
      for offset in 0...1 {
        let day = Calendar.maldives.date(byAdding: .day, value: offset, to: now)!
        guard let schedule = Timetable.shared.schedule(for: island, on: day) else { continue }
        dates += ([schedule.day] + Prayer.allCases.map(schedule.time(of:))).filter { $0 > now }
      }
    }

    let entries = dates.map(entry(at:))
    completion(Timeline(entries: entries, policy: .atEnd))
  }

  private func entry(at date: Date) -> PrayerEntry {
    guard let island = SharedSettings.island else {
      return PrayerEntry(date: date, schedule: nil, next: nil)
    }
    return PrayerEntry(
      date: date,
      schedule: Timetable.shared.schedule(for: island, on: date),
      next: Timetable.shared.nextPrayer(for: island, after: date)
    )
  }
}
