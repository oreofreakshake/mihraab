import SwiftUI

struct RootView: View {
  @EnvironmentObject private var model: AppModel
  @Environment(\.scenePhase) private var scenePhase
  @State private var isPickingIsland = false
  @State private var isPickingDate = false
  @State private var isEditingNotifications = false

  var body: some View {
    NavigationStack {
      TodayScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            VStack(spacing: 1) {
              Text(model.island.fullName)
                .font(.headline)
              Text(model.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
          }
          ToolbarItem(placement: .topBarLeading) {
            if !model.isShowingToday {
              Button("Today", action: model.jumpToToday)
            }
          }
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              isEditingNotifications = true
            } label: {
              Label("Notifications", systemImage: model.notificationsEnabled ? "bell.fill" : "bell")
                .labelStyle(.iconOnly)
            }
          }
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              isPickingDate = true
            } label: {
              Label("Choose date", systemImage: "calendar")
                .labelStyle(.iconOnly)
            }
            .popover(isPresented: $isPickingDate) {
              DatePicker("Date", selection: $model.date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .frame(width: 320)
                .padding()
                .presentationCompactAdaptation(.popover)
                .onChange(of: model.date) {
                  isPickingDate = false
                }
            }
          }
          ToolbarItem(placement: .bottomBar) {
            Button {
              isPickingIsland = true
            } label: {
              Label("Choose island, currently \(model.island.name)", systemImage: "location.fill")
                .labelStyle(.iconOnly)
            }
          }
        }
    }
    .sheet(isPresented: $isPickingIsland) {
      IslandPicker(selected: model.island) { island in
        model.select(island)
      }
    }
    .sheet(isPresented: $isEditingNotifications) {
      NotificationSettings()
    }
    .onChange(of: scenePhase, initial: true) {
      if scenePhase == .active {
        model.refreshNotifications()
      }
    }
  }
}
