import SwiftUI

struct SkyScene {
  let colors: [Color]
  let stars: Int

  static func `for`(_ prayer: Prayer) -> SkyScene {
    switch prayer {
    case .fajr:
      SkyScene(colors: [Color(hex: 0x141836), Color(hex: 0x3A3566), Color(hex: 0x8A5A78)], stars: 18)
    case .sunrise:
      SkyScene(colors: [Color(hex: 0x3D5F93), Color(hex: 0xB77E7A), Color(hex: 0xE9A46A)], stars: 0)
    case .dhuhr:
      SkyScene(colors: [Color(hex: 0x1E64A8), Color(hex: 0x4C93D1)], stars: 0)
    case .asr:
      SkyScene(colors: [Color(hex: 0x2C6496), Color(hex: 0x6D98B8), Color(hex: 0xC9A16A)], stars: 0)
    case .maghrib:
      SkyScene(colors: [Color(hex: 0x241A45), Color(hex: 0x7A3D5E), Color(hex: 0xD9694A)], stars: 0)
    case .isha:
      SkyScene(colors: [Color(hex: 0x05081A), Color(hex: 0x141C45)], stars: 34)
    }
  }
}

extension Color {
  init(hex: UInt32) {
    self.init(
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255
    )
  }
}

struct SeededRandom {
  private var state: UInt64

  init(seed: Int) {
    state = UInt64(truncatingIfNeeded: seed) &+ 0x9E37_79B9_7F4A_7C15
  }

  mutating func next() -> Double {
    state &+= 0x9E37_79B9_7F4A_7C15
    var z = state
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    z ^= z >> 31
    return Double(z >> 11) / Double(1 << 53)
  }

  mutating func next(in range: ClosedRange<Double>) -> Double {
    range.lowerBound + next() * (range.upperBound - range.lowerBound)
  }
}
