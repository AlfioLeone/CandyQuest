import SwiftUI

struct SuccessView: View {
    @EnvironmentObject var gameState: GameState
    let level: GameLevel
    let stars: Int
    var onDismiss: () -> Void

    @State private var showStars = false
    @State private var celebrate = false

    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            ConfettiView()

            VStack(spacing: 20) {
                if let sticker = gameState.equippedSticker {
                    Text(sticker.emoji)
                        .font(.system(size: 60))
                        .rotationEffect(.degrees(celebrate ? -12 : 12))
                        .scaleEffect(celebrate ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true), value: celebrate)
                }

                Text("🎉 Great Job! 🎉")
                    .font(.candyTitle(32))
                    .foregroundColor(CandyTheme.purple)

                Text(level.title)
                    .font(.candyBody(20))
                    .foregroundColor(.black.opacity(0.6))

                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.system(size: 44))
                            .foregroundColor(.yellow)
                            .scaleEffect(showStars ? 1.0 : 0.1)
                            .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(Double(i) * 0.15), value: showStars)
                    }
                }
                .padding(.vertical, 12)

                Button("Back to Map") {
                    onDismiss()
                }
                .buttonStyle(CandyButtonStyle(color: CandyTheme.hotPink))
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.white.opacity(0.9))
                    .shadow(radius: 10)
            )
            .padding(.horizontal, 30)
        }
        .onAppear {
            showStars = true
            celebrate = true
        }
    }
}
