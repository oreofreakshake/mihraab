import SwiftUI

extension View {
  @ViewBuilder
  func glassBadge() -> some View {
    let padded = padding(.horizontal, 12).padding(.vertical, 6)

    if #available(iOS 26, *) {
      padded.glassEffect(.regular, in: Capsule())
    } else {
      padded
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 0.5))
    }
  }
}
