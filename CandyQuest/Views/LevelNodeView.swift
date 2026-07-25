import SwiftUI

struct LevelNodeView: View {
    let level: GameLevel
    let isUnlocked: Bool
    let stars: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isUnlocked ? CandyTheme.color(for: level.category) : Color.gray.opacity(0.35))
                        .frame(width: 84, height: 84)
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 3)

                    if isUnlocked {
                        Text(CandyTheme.emoji(for: level.category))
                            .font(.system(size: 40))
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }

                Text(level.title)
                    .font(.candyBody(13))
                    .foregroundColor(isUnlocked ? .black.opacity(0.7) : .gray)
                    .multilineTextAlignment(.center)
                    .frame(width: 100)

                if isUnlocked {
                    starRow
                }
            }
        }
        .disabled(!isUnlocked)
        .buttonStyle(.plain)
    }

    private var starRow: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { i in
                Image(systemName: i < stars ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundColor(.yellow)
            }
        }
    }
}
