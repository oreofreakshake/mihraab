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
        .safeAreaInset(edge: .bottom) {
          if !model.isShowingToday {
            backToToday
              .padding(.bottom, 8)
              .transition(.move(edge: .bottom).combined(with: .opacity))
          }
        }
        .animation(.smooth, value: model.isShowingToday)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          if #available(iOS 26, *) {
            location.sharedBackgroundVisibility(.hidden)
          } else {
            location
          }
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              isEditingNotifications = true
            } label: {
              Label("Notifications", systemImage: model.notificationsEnabled ? "bell.fill" : "bell")
                .labelStyle(.iconOnly)
            }
          }
          if #available(iOS 26, *) {
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
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

  private var backToToday: some View {
    Button(action: model.jumpToToday) {
      HStack(spacing: 10) {
        Text(model.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
          .foregroundStyle(.secondary)
        Label("Today", systemImage: "arrow.uturn.backward")
          .foregroundStyle(Color.accentColor)
      }
      .font(.subheadline.weight(.semibold))
      .padding(.horizontal, 6)
      .padding(.vertical, 4)
      .glassBadge()
      .contentShape(Capsule())
    }
    .buttonStyle(.plain)
    .accessibilityLabel("Viewing \(model.date.formatted(date: .complete, time: .omitted)). Back to today")
  }

  private var location: some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      VStack(alignment: .leading, spacing: 1) {
        Text("Mihraab")
          .font(.headline)
        Text(model.island.fullName)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .fixedSize()
      .accessibilityElement(children: .combine)
    }
  }
}
