import SwiftUI

struct NextPrayerCountdown: View {
  let prayer: Prayer
  let date: Date
  let now: Date

  private var isTomorrow: Bool {
    !Calendar.maldives.isDate(date, inSameDayAs: now)
  }

  var body: some View {
    VStack(spacing: 12) {
      HStack(spacing: 8) {
        Image(systemName: prayer.symbol)
          .symbolVariant(.fill)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
        Text(isTomorrow ? "\(prayer.name) tomorrow" : prayer.name)
      }
      .font(.subheadline.weight(.semibold))
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(Color.accentColor.opacity(0.1), in: Capsule())

      Text(timerInterval: now...date, countsDown: true)
        .font(.system(size: 44, weight: .semibold, design: .rounded).monospacedDigit())
        .contentTransition(.numericText(countsDown: true))
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 8)
    .accessibilityElement(children: .combine)
  }
}
