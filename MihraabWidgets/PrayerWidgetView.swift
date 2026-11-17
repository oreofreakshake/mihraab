import SwiftUI
import WidgetKit

struct PrayerWidgetView: View {
  let entry: PrayerEntry

  @Environment(\.widgetFamily) private var family

  var body: some View {
    Group {
      if let schedule = entry.schedule, let next = entry.next {
        switch family {
        case .systemMedium: medium(schedule: schedule, next: next)
        default: small(island: schedule.island, next: next)
        }
      } else {
        Text("No upcoming prayer")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .containerBackground(.background, for: .widget)
  }

  private func small(island: Island, next: (prayer: Prayer, date: Date)) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      location(island)

      Spacer()

      HStack(spacing: 6) {
        Image(systemName: next.prayer.symbol)
          .symbolVariant(.fill)
          .foregroundStyle(Color.brand)
        Text(next.prayer.name)
          .font(.headline)
        Text(next.date.clockTime)
          .font(.caption.weight(.semibold).monospacedDigit())
          .foregroundStyle(.secondary)
      }

      Text(next.date, style: .timer)
        .font(.system(size: 30, weight: .semibold, design: .rounded))
        .monospacedDigit()
        .padding(.top, 2)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func medium(schedule: DaySchedule, next: (prayer: Prayer, date: Date)) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .firstTextBaseline) {
        Text(next.date, style: .timer)
          .font(.system(.title, design: .rounded).weight(.semibold))
          .monospacedDigit()

        Spacer()

        location(schedule.island)
      }

      Spacer()

      HStack(spacing: 4) {
        ForEach(Prayer.allCases) { prayer in
          let date = schedule.time(of: prayer)
          column(prayer, at: date, isNext: prayer == next.prayer && date == next.date)
        }
      }
      .padding(.horizontal, -3)
    }
  }

  private func column(_ prayer: Prayer, at date: Date, isNext: Bool) -> some View {
    VStack(spacing: 9) {
      Text(prayer.name)
        .font(.system(size: 10, weight: .medium))
        .lineLimit(1)
        .minimumScaleFactor(0.7)

      Image(systemName: prayer.symbol)
        .symbolVariant(.fill)
        .symbolRenderingMode(.hierarchical)
        .font(.subheadline)
        .frame(height: 18)
        .foregroundStyle(Color.brand)

      Text(date.clockTime)
        .font(.system(size: 12, weight: .semibold, design: .rounded))
    }
    .foregroundStyle(.primary)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 8)
    .background(tile.fill(isNext ? Color.brand.opacity(0.3) : Color.primary.opacity(0.05)))
    .overlay(tile.strokeBorder(Color.primary.opacity(isNext ? 0 : 0.08)))
  }

  private var tile: RoundedRectangle {
    RoundedRectangle(cornerRadius: 8, style: .continuous)
  }

  private func location(_ island: Island) -> some View {
    HStack(spacing: 4) {
      Image(systemName: "location.fill")
        .font(.system(size: 9, weight: .bold))
        .foregroundStyle(Color.brand)
      Text(island.atoll)
        .foregroundStyle(.secondary)
      + Text(" \(island.name)")
        .foregroundStyle(.primary)
    }
    .font(.caption.weight(.semibold))
    .lineLimit(1)
  }
}
