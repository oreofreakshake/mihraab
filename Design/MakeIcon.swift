import AppKit
import SwiftUI

func hex(_ value: UInt32) -> Color {
  Color(
    red: Double((value >> 16) & 0xFF) / 255,
    green: Double((value >> 8) & 0xFF) / 255,
    blue: Double(value & 0xFF) / 255
  )
}

let size: CGFloat = 1024
let cream = hex(0xFBF3DF)

func archPath(center cx: CGFloat, springline ys: CGFloat, base yb: CGFloat, halfWidth a: CGFloat, radius r: CGFloat) -> Path {
  let rise = sqrt(r * r - (r - a) * (r - a))
  let steps = 120

  func arc(center: CGPoint, from start: Double, to end: Double) -> [CGPoint] {
    (0...steps).map { step in
      let angle = start + (end - start) * Double(step) / Double(steps)
      return CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
    }
  }

  let leftCenter = CGPoint(x: cx - a + r, y: ys)
  let rightCenter = CGPoint(x: cx + a - r, y: ys)
  let left = arc(center: leftCenter, from: -.pi, to: atan2(-rise, a - r))
  let right = arc(center: rightCenter, from: atan2(-rise, r - a), to: 0)

  var path = Path()
  path.move(to: CGPoint(x: cx - a, y: yb))
  left.forEach { path.addLine(to: $0) }
  right.dropFirst().forEach { path.addLine(to: $0) }
  path.addLine(to: CGPoint(x: cx + a, y: yb))
  return path
}

struct Icon: View {
  var body: some View {
    let arch = archPath(center: 512, springline: 500, base: 1024, halfWidth: 250, radius: 400)

    ZStack {
      LinearGradient(
        stops: [
          .init(color: hex(0x080B22), location: 0),
          .init(color: hex(0x1C1F4F), location: 0.45),
          .init(color: hex(0x4A2F63), location: 0.75),
          .init(color: hex(0xC9654A), location: 1),
        ],
        startPoint: .top,
        endPoint: .bottom
      )

      RadialGradient(
        colors: [hex(0xFF9A62).opacity(0.55), .clear],
        center: UnitPoint(x: 0.5, y: 1.05),
        startRadius: 0,
        endRadius: 520
      )

      Canvas { context, _ in
        var interior = arch
        interior.closeSubpath()
        context.fill(interior, with: .color(.white.opacity(0.06)))

        context.stroke(arch, with: .color(cream), style: StrokeStyle(lineWidth: 54, lineCap: .butt, lineJoin: .miter, miterLimit: 20))

        let moon = CGRect(x: 512 - 78, y: 330, width: 156, height: 156)
        context.drawLayer { layer in
          layer.fill(Path(ellipseIn: moon), with: .color(cream))
          layer.blendMode = .destinationOut
          layer.fill(Path(ellipseIn: moon.offsetBy(dx: 50, dy: -26)), with: .color(.black))
        }
      }
    }
    .frame(width: size, height: size)
  }
}

@MainActor
func export(to path: String) {
  let renderer = ImageRenderer(content: Icon())
  renderer.scale = 1
  guard let image = renderer.cgImage else { fatalError("render failed") }
  let rep = NSBitmapImageRep(cgImage: image)
  let data = rep.representation(using: .png, properties: [:])!
  try! data.write(to: URL(fileURLWithPath: path))
}

MainActor.assumeIsolated {
  export(to: CommandLine.arguments[1])
}
