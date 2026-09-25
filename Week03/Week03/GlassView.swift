import SwiftUI

let glassColors: [Color] = [
    Color(red: 0.16, green: 0.33, blue: 0.72),
    Color(red: 0.48, green: 0.25, blue: 0.66),
    Color(red: 0.73, green: 0.18, blue: 0.28),
    Color(red: 0.95, green: 0.67, blue: 0.22),
    Color(red: 0.13, green: 0.57, blue: 0.43),
    Color(red: 0.26, green: 0.65, blue: 0.78)
]

let glassColorNames = ["Sapphire", "Amethyst", "Ruby", "Amber", "Emerald", "Aquamarine"]
let columns = 6
let rows = 12

struct GlassPiece {
    var goesDown: Bool
    var firstColor: Int
    var secondColor: Int
}

func makeGlass() -> [GlassPiece] {
    var pieces: [GlassPiece] = []

    for _ in 0..<(columns * rows) {
        let first = Int.random(in: 0..<glassColors.count)
        let offset = Int.random(in: 1..<glassColors.count)
        let second = (first + offset) % glassColors.count
        let piece = GlassPiece(goesDown: Bool.random(), firstColor: first, secondColor: second)
        pieces.append(piece)
    }

    return pieces
}

struct WindowArch: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.36))
        path.addCurve(to: CGPoint(x: w / 2, y: 0),
                      control1: CGPoint(x: 0, y: h * 0.16),
                      control2: CGPoint(x: w * 0.26, y: h * 0.04))
        path.addCurve(to: CGPoint(x: w, y: h * 0.36),
                      control1: CGPoint(x: w * 0.74, y: h * 0.04),
                      control2: CGPoint(x: w, y: h * 0.16))
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        return path
    }
}

struct GlassView: View {
    let pieces: [GlassPiece]

    var body: some View {
        Canvas { context, size in
            let cellWidth = size.width / Double(columns)
            let cellHeight = size.height / Double(rows)

            for index in 0..<pieces.count {
                let piece = pieces[index]
                let x = Double(index % columns) * cellWidth
                let y = Double(index / columns) * cellHeight
                let topLeft = CGPoint(x: x, y: y)
                let topRight = CGPoint(x: x + cellWidth, y: y)
                let bottomLeft = CGPoint(x: x, y: y + cellHeight)
                let bottomRight = CGPoint(x: x + cellWidth, y: y + cellHeight)

                var first = Path()
                var second = Path()

                if piece.goesDown {
                    first.move(to: topLeft)
                    first.addLine(to: topRight)
                    first.addLine(to: bottomRight)
                    second.move(to: topLeft)
                    second.addLine(to: bottomLeft)
                    second.addLine(to: bottomRight)
                } else {
                    first.move(to: topLeft)
                    first.addLine(to: topRight)
                    first.addLine(to: bottomLeft)
                    second.move(to: topRight)
                    second.addLine(to: bottomRight)
                    second.addLine(to: bottomLeft)
                }

                first.closeSubpath()
                second.closeSubpath()
                context.fill(first, with: .color(glassColors[piece.firstColor]))
                context.fill(second, with: .color(glassColors[piece.secondColor]))
                context.stroke(first, with: .color(Color(white: 0.08)), lineWidth: 2.5)
                context.stroke(second, with: .color(Color(white: 0.08)), lineWidth: 2.5)
            }
        }
        .overlay {
            LinearGradient(colors: [.white.opacity(0.20), .clear, .black.opacity(0.18)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        .clipShape(WindowArch())
        .overlay {
            WindowArch().stroke(Color(red: 0.29, green: 0.26, blue: 0.21), lineWidth: 12)
        }
        .overlay {
            WindowArch().stroke(Color(red: 0.69, green: 0.55, blue: 0.34), lineWidth: 2)
        }
        .padding(8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("An arched stained-glass window with colorful triangular panes")
    }
}
