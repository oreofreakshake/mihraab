import SwiftUI
import WidgetKit

@main
struct MihraabWidgets: WidgetBundle {
  var body: some Widget {
    PrayerWidget()
  }
}

struct PrayerWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "PrayerWidget", provider: PrayerTimelineProvider()) { entry in
      PrayerWidgetView(entry: entry)
    }
    .configurationDisplayName("Prayer Times")
    .description("The next prayer and today's timetable for your island.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
