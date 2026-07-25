import SwiftUI

struct ReadingTapView: View {
    let task: ReadingTapTask
    var onComplete: (Int) -> Void

    @State private var wrongTaps = 0
    @State private var selectedID: UUID? = nil
    @State private var showCorrect = false

    var body: some View {
        VStack(spacing: 36) {
            Text(task.prompt)
                .font(.candyTitle(26))
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.75))
                .padding(.horizontal, 24)

            HStack(spacing: 20) {
                ForEach(task.options) { option in
                    Button {
                        handleTap(option)
                    } label: {
                        VStack {
                            Text(option.emoji).font(.system(size: 56))
                        }
                        .frame(width: 96, height: 96)
                        .background(
                            CandyCardBackground(color: borderColor(for: option))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(showCorrect)
                }
            }
        }
    }

    private func borderColor(for option: CandyOption) -> Color {
        guard selectedID == option.id else { return CandyTheme.hotPink }
        return option.id == task.correctID ? .green : .red
    }

    private func handleTap(_ option: CandyOption) {
        selectedID = option.id
        if option.id == task.correctID {
            showCorrect = true
            let stars = wrongTaps == 0 ? 3 : (wrongTaps == 1 ? 2 : 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete(stars)
            }
        } else {
            wrongTaps += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                selectedID = nil
            }
        }
    }
}
