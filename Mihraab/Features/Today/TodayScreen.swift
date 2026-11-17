import SwiftUI

struct TodayScreen: View {
  @EnvironmentObject private var model: AppModel

  var body: some View {
    TimelineView(.periodic(from: .now, by: 1)) { context in
      let now = context.date
      let live = model.isShowingToday

      ScrollView {
        if let schedule = model.schedule {
          let next = live ? schedule.upcoming(after: now) : nil
          let current = live ? schedule.current(at: now) : nil

          VStack(spacing: 10) {
            ForEach(Prayer.allCases) { prayer in
              let date = schedule.time(of: prayer)
              SkyCard(
                prayer: prayer,
                date: date,
                isNext: prayer == next,
                isCurrent: prayer == current,
                isPast: live && date <= now && prayer != current
              )
            }

            if live, let upcoming = Timetable.shared.nextPrayer(for: schedule.island, after: now) {
              NextPrayerCountdown(prayer: upcoming.prayer, date: upcoming.date, now: now)
            }
          }
          .padding(.horizontal)
          .padding(.vertical, 8)
          .animation(.smooth, value: next)
        } else {
          ContentUnavailableView(
            "No timetable",
            systemImage: "calendar.badge.exclamationmark",
            description: Text("There are no prayer times for this day.")
          )
          .padding(.top, 120)
        }
      }
    }
  }
}
