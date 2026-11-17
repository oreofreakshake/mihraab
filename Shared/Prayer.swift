import Foundation

enum Prayer: Int, CaseIterable, Identifiable, Codable {
  case fajr, sunrise, dhuhr, asr, maghrib, isha

  var id: Int { rawValue }

  var name: String {
    switch self {
    case .fajr: "Fajr"
    case .sunrise: "Sunrise"
    case .dhuhr: "Dhuhr"
    case .asr: "Asr"
    case .maghrib: "Maghrib"
    case .isha: "Isha"
    }
  }

  var symbol: String {
    switch self {
    case .fajr: "moon.haze"
    case .sunrise: "sunrise"
    case .dhuhr: "sun.max"
    case .asr: "sun.min"
    case .maghrib: "sunset"
    case .isha: "moon.stars"
    }
  }
}

struct Island: Identifiable, Hashable, Codable {
  let id: Int
  let zone: Int
  let atoll: String
  let name: String
  let offset: Int
  let latitude: Double?
  let longitude: Double?

  var fullName: String { "\(atoll) \(name)" }
}

struct DaySchedule: Equatable {
  let island: Island
  let day: Date
  let minutes: [Int]

  func time(of prayer: Prayer) -> Date {
    day.addingTimeInterval(TimeInterval(minutes[prayer.rawValue] * 60))
  }

  func upcoming(after now: Date) -> Prayer? {
    Prayer.allCases.first { time(of: $0) > now }
  }

  func current(at now: Date) -> Prayer? {
    Prayer.allCases.last { time(of: $0) <= now }
  }
}

extension Calendar {
  static let maldives: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Indian/Maldives")!
    return calendar
  }()
}

extension Date {
  private static let clockFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = Calendar.maldives.timeZone
    formatter.dateFormat = "HH:mm"
    return formatter
  }()

  var clockTime: String {
    Self.clockFormatter.string(from: self)
  }
}
