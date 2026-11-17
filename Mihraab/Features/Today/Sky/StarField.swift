import SwiftUI

struct StarField: View {
  let count: Int
  let seed: Int
  let time: TimeInterval

  private let window = 6.0
  private let chance = 0.4
  private let flight = 0.9

  var body: some View {
    Canvas { context, size in
      drawStars(in: &context, size: size)
      drawShootingStar(in: &context, size: size)
    }
  }

  private func drawStars(in context: inout GraphicsContext, size: CGSize) {
    var random = SeededRandom(seed: seed)
    let clock = time.truncatingRemainder(dividingBy: 10_000)

    for _ in 0..<count {
      let point = CGPoint(x: random.next() * size.width, y: random.next() * size.height * 0.85)
      let radius = random.next(in: 0.5...1.3)
      let phase = random.next(in: 0...(2 * .pi))
      let speed = random.next(in: 0.6...1.8)

      context.opacity = 0.55 + 0.45 * sin(clock * speed + phase)
      context.fill(
        Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)),
        with: .color(.white)
      )
    }
    context.opacity = 1
  }

  private func drawShootingStar(in context: inout GraphicsContext, size: CGSize) {
    let slot = (time / window).rounded(.down)
    let elapsed = time - slot * window

    var random = SeededRandom(seed: seed &* 7919 &+ Int(slot))
    guard random.next() < chance else { return }

    let delay = random.next(in: 0...(window - flight))
    let progress = (elapsed - delay) / flight
    guard progress > 0, progress < 1 else { return }

    let start = CGPoint(x: random.next(in: 0.1...0.6) * size.width, y: random.next(in: 0.05...0.35) * size.height)
    let angle = random.next(in: 0.25...0.55)
    let travel = random.next(in: 90...140)
    let direction = CGVector(dx: cos(angle), dy: sin(angle))

    let eased = 1 - pow(1 - progress, 2)
    let head = CGPoint(x: start.x + direction.dx * travel * eased, y: start.y + direction.dy * travel * eased)
    let length = 46.0 * min(1, progress * 3)
    let tail = CGPoint(x: head.x - direction.dx * length, y: head.y - direction.dy * length)

    var streak = Path()
    streak.move(to: tail)
    streak.addLine(to: head)

    context.opacity = sin(.pi * progress)
    context.stroke(
      streak,
      with: .linearGradient(Gradient(colors: [.clear, .white]), startPoint: tail, endPoint: head),
      style: StrokeStyle(lineWidth: 1.4, lineCap: .round)
    )
    context.opacity = 1
  }
}
