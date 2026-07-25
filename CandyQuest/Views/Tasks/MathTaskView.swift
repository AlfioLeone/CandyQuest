import SwiftUI

struct MathTaskView: View {
    let level: GameLevel
    var onComplete: (Int) -> Void

    @State private var problem: MathProblem
    @State private var wrongTaps = 0
    @State private var selected: Int? = nil
    @State private var solved = false

    init(level: GameLevel, onComplete: @escaping (Int) -> Void) {
        self.level = level
        self.onComplete = onComplete
        _problem = State(initialValue: GameData.mathProblem(for: level))
    }

    var body: some View {
        VStack(spacing: 32) {
            candyRow(count: problem.a)

            Text(problem.symbol)
                .font(.candyTitle(30))
                .foregroundColor(CandyTheme.purple)

            candyRow(count: problem.b)

            Text("\(problem.a) \(problem.symbol) \(problem.b) = ?")
                .font(.candyTitle(28))
                .foregroundColor(.black.opacity(0.75))
                .padding(.top, 8)

            HStack(spacing: 18) {
                ForEach(problem.choices, id: \.self) { choice in
                    Button {
                        handleTap(choice)
                    } label: {
                        Text("\(choice)")
                            .font(.candyTitle(26))
                            .frame(width: 72, height: 72)
                            .background(CandyCardBackground(color: borderColor(for: choice)))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .disabled(solved)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func candyRow(count: Int) -> some View {
        let emoji = level.category == .mathAddition ? "🍬" : "🍩"
        return HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { _ in
                Text(emoji).font(.system(size: 26))
            }
        }
        .frame(minHeight: 30)
    }

    private func borderColor(for choice: Int) -> Color {
        guard selected == choice else { return CandyTheme.hotPink }
        return choice == problem.answer ? .green : .red
    }

    private func handleTap(_ choice: Int) {
        selected = choice
        if choice == problem.answer {
            solved = true
            let stars = wrongTaps == 0 ? 3 : (wrongTaps == 1 ? 2 : 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete(stars)
            }
        } else {
            wrongTaps += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                selected = nil
            }
        }
    }
}
