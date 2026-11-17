import SwiftUI
import UserNotifications

@main
struct MihraabApp: App {
  @StateObject private var model = AppModel()

  init() {
    UNUserNotificationCenter.current().delegate = NotificationPresenter.shared
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(model)
    }
  }
}
