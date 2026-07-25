import SwiftUI

struct LevelContainerView: View {
    @EnvironmentObject var gameState: GameState
    let level: GameLevel
    /// Called with a star rating (1-3) once the level's task is completed.
    var onComplete: (Int) -> Void

    @State private var bounce = false

    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            VStack {
                HStack(spacing: 10) {
                    if let sticker = gameState.equippedSticker {
                        Text(sticker.emoji)
                            .font(.system(size: 32))
                            .offset(y: bounce ? -5 : 0)
                            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: bounce)
                    }
                    Text(level.title)
                        .font(.candyTitle(24))
                        .foregroundColor(CandyTheme.color(for: level.category))
                }
                .padding(.top, 20)

                Spacer()

                switch level.category {
                case .readingTap:
                    ReadingTapView(task: GameData.readingTapTask(for: level), onComplete: onComplete)
                case .mathAddition, .mathSubtraction:
                    MathTaskView(level: level, onComplete: onComplete)
                case .dragMatch:
                    DragMatchView(level: level, onComplete: onComplete)
                case .trace:
                    TraceView(task: GameData.traceTask(for: level), onComplete: onComplete)
                case .orderObjects:
                    OrderObjectsView(level: level, onComplete: onComplete)
                case .oddOneOut:
                    OddOneOutView(task: GameData.oddOneOutTask(for: level), onComplete: onComplete)
                }

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { bounce = true }
    }
}

struct OddOneOutView: View {
    let task: GameData.OddOneOutTask
    var onComplete: (Int) -> Void
    @State private var selectedID: UUID? = nil
    @State private var showCorrect = false
    @State private var wrongTaps = 0
    @State private var solved = false

    var body: some View {
        VStack(spacing: 32) {
            Text(task.prompt)
                .font(.candyTitle(22))
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.75))
                .padding(.horizontal, 20)

            HStack(spacing: 20) {
                ForEach(task.options) { option in
                    Button {
                        handleTap(option)
                    } label: {
                        VStack {
                            Text(option.emoji)
                                .font(.system(size: 56))
                        }
                        .frame(width: 96, height: 96)
                        .background(
                            CandyCardBackground(color: borderColor(for: option))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(showCorrect || solved)
                }
            }

            if showCorrect || solved {
                Button("Continue") {
                    onComplete(score)
                }
                .buttonStyle(CandyButtonStyle(color: CandyTheme.hotPink))
            }
        }
    }

    private var score: Int {
        wrongTaps == 0 ? 3 : (wrongTaps == 1 ? 2 : 1)
    }

    private func borderColor(for option: CandyOption) -> Color {
        guard selectedID == option.id else { return CandyTheme.hotPink }
        return option.id == task.oddOneOutID ? .green : .red
    }

    private func handleTap(_ option: CandyOption) {
        selectedID = option.id
        if option.id == task.oddOneOutID {
            showCorrect = true
            solved = true
        } else {
            wrongTaps += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                selectedID = nil
            }
        }
    }
}

