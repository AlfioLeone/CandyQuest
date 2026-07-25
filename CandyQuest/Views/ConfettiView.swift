import SwiftUI

struct ConfettiView: View {
    private let pieceCount = 28
    private let emojis = ["🍬", "🍭", "🎉", "⭐️", "🧁"]

    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<pieceCount, id: \.self) { i in
                    Text(emojis[i % emojis.count])
                        .font(.system(size: CGFloat.random(in: 18...30)))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: animate ? geo.size.height + 40 : -40
                        )
                        .animation(
                            .linear(duration: Double.random(in: 2.5...4.5))
                                .delay(Double.random(in: 0...1.2))
                                .repeatForever(autoreverses: false),
                            value: animate
                        )
                }
            }
        }
        .onAppear { animate = true }
        .allowsHitTesting(false)
    }
}
