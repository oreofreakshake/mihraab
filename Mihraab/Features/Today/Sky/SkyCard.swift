import SwiftUI

struct SkyCard: View {
  let prayer: Prayer
  let date: Date
  let isNext: Bool
  let isCurrent: Bool
  let isPast: Bool

  private var scene: SkyScene { .for(prayer) }

  private let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)

  var body: some View {
    HStack(alignment: .center) {
      HStack(spacing: 12) {
        Image(systemName: prayer.symbol)
          .symbolVariant(.fill)
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: 24, weight: .medium))
          .frame(width: 32)
        Text(prayer.name)
          .font(.system(.title2, design: .rounded).weight(.semibold))
      }
      Spacer()
      if isCurrent {
        HStack(spacing: 8) {
          Image(systemName: "arrow.left")
            .font(.subheadline.weight(.bold))
          time
        }
        .glassBadge()
        .environment(\.colorScheme, .dark)
        .padding(.trailing, -12)
      } else {
        time
      }
    }
    .foregroundStyle(.white)
    .padding(.horizontal, 20)
    .frame(height: 78)
    .background {
      sky.overlay(scrim)
    }
    .clipShape(shape)
    .overlay {
      shape.strokeBorder(.white.opacity(isNext ? 0.6 : 0.08), lineWidth: isNext ? 1.5 : 1)
    }
    .saturation(isPast ? 0.5 : 1)
    .accessibilityElement(children: .combine)
  }

  private var time: some View {
    Text(date.clockTime)
      .font(.system(.title2, design: .rounded).weight(.semibold).monospacedDigit())
  }

  private var scrim: some View {
    LinearGradient(
      stops: [
        .init(color: .black.opacity(0.3), location: 0),
        .init(color: .clear, location: 0.42),
        .init(color: .clear, location: 0.68),
        .init(color: .black.opacity(0.25), location: 1),
      ],
      startPoint: .leading,
      endPoint: .trailing
    )
  }

  @ViewBuilder
  private var sky: some View {
    let gradient = LinearGradient(colors: scene.colors, startPoint: .top, endPoint: .bottom)

    if scene.stars > 0 {
      TimelineView(.animation(minimumInterval: 1 / 30, paused: isPast)) { context in
        gradient.overlay {
          StarField(count: scene.stars, seed: prayer.rawValue, time: context.date.timeIntervalSinceReferenceDate)
        }
      }
    } else {
      gradient
    }
  }
}
