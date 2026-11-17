import Foundation
import SQLite3

final class Timetable {
  static let shared = Timetable()

  private var db: OpaquePointer?
  private let lock = NSLock()

  private init() {
    guard let path = Bundle.main.path(forResource: "salat", ofType: "sqlite") else {
      assertionFailure("salat.sqlite missing from bundle")
      return
    }
    if sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil) != SQLITE_OK {
      db = nil
    }
  }

  deinit {
    sqlite3_close(db)
  }

  private static let hiddenIslandIDs: Set<Int> = [199]

  lazy var islands: [Island] = {
    var result: [Island] = []
    query(
      """
      SELECT id, category_id, atoll, island, minutes, latitude, longitude
      FROM islands WHERE status = 1 ORDER BY id
      """
    ) { row in
      guard !Self.hiddenIslandIDs.contains(Int(sqlite3_column_int(row, 0))) else { return }
      result.append(
        Island(
          id: Int(sqlite3_column_int(row, 0)),
          zone: Int(sqlite3_column_int(row, 1)),
          atoll: String(cString: sqlite3_column_text(row, 2)),
          name: String(cString: sqlite3_column_text(row, 3)),
          offset: Int(sqlite3_column_int(row, 4)),
          latitude: Self.double(row, 5),
          longitude: Self.double(row, 6)
        )
      )
    }
    return result
  }()

  func island(id: Int) -> Island? {
    islands.first { $0.id == id }
  }

  func schedule(for island: Island, on date: Date) -> DaySchedule? {
    let calendar = Calendar.maldives
    let day = calendar.startOfDay(for: date)
    var minutes: [Int] = []

    query(
      """
      SELECT fajr, sunrise, dhuhr, asr, maghrib, isha
      FROM prayer_times WHERE category_id = ? AND date = ?
      """,
      bind: [island.zone, Self.tableIndex(for: day)]
    ) { row in
      minutes = (0..<6).map { Int(sqlite3_column_int(row, Int32($0))) + island.offset }
    }

    return minutes.isEmpty ? nil : DaySchedule(island: island, day: day, minutes: minutes)
  }

  func nextPrayer(for island: Island, after now: Date) -> (prayer: Prayer, date: Date)? {
    for offset in 0...1 {
      let date = Calendar.maldives.date(byAdding: .day, value: offset, to: now)!
      guard let schedule = schedule(for: island, on: date),
        let prayer = schedule.upcoming(after: now)
      else { continue }
      return (prayer, schedule.time(of: prayer))
    }
    return nil
  }

  static func tableIndex(for date: Date) -> Int {
    let calendar = Calendar.maldives
    var parts = calendar.dateComponents([.month, .day], from: date)
    parts.year = 2024
    let leapDate = calendar.date(from: parts)!
    return calendar.ordinality(of: .day, in: .year, for: leapDate)! - 1
  }

  private static func double(_ row: OpaquePointer?, _ column: Int32) -> Double? {
    guard sqlite3_column_type(row, column) != SQLITE_NULL else { return nil }
    let text = String(cString: sqlite3_column_text(row, column))
    return Double(text)
  }

  private func query(_ sql: String, bind values: [Int] = [], each: (OpaquePointer?) -> Void) {
    lock.lock()
    defer { lock.unlock() }

    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return }
    defer { sqlite3_finalize(statement) }

    for (index, value) in values.enumerated() {
      sqlite3_bind_int(statement, Int32(index + 1), Int32(value))
    }
    while sqlite3_step(statement) == SQLITE_ROW {
      each(statement)
    }
  }
}
