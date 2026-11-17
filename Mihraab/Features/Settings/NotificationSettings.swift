import SwiftUI

struct NotificationSettings: View {
  @EnvironmentObject private var model: AppModel
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) private var openURL

  @State private var isDenied = false

  var body: some View {
    NavigationStack {
      Form {
        Section {
          Toggle("Prayer notifications", isOn: masterToggle)
        }

        if isDenied {
          Section {
            Text("Notifications are turned off for Mihraab in Settings.")
              .foregroundStyle(.secondary)
            Button("Open Settings") {
              if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
              }
            }
          }
        }

        Section("Notify me for") {
          ForEach(Prayer.allCases) { prayer in
            Toggle(isOn: binding(for: prayer)) {
              Label(prayer.name, systemImage: prayer.symbol)
                .symbolVariant(.fill)
            }
          }
        }
        .disabled(!model.notificationsEnabled)
      }
      .navigationTitle("Notifications")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
        }
      }
      .task {
        isDenied = await PrayerNotifications.authorizationStatus() == .denied
      }
    }
  }

  private var masterToggle: Binding<Bool> {
    Binding(
      get: { model.notificationsEnabled },
      set: { enabled in
        Task {
          isDenied = await !model.setNotificationsEnabled(enabled)
        }
      }
    )
  }

  private func binding(for prayer: Prayer) -> Binding<Bool> {
    Binding(
      get: { model.notifiedPrayers.contains(prayer) },
      set: { model.setNotifies(prayer, $0) }
    )
  }
}
