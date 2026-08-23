import SwiftUI

struct OrderObjectsView: View {
    var onComplete: (Int) -> Void

    // Generated once (via @State in init) so the sentence and the items stay in
    // sync for the whole attempt, even if the parent view re-renders.
    @State private var task: OrderTask

    @State private var placedIDs: [UUID] = []
    @State private var wrongTaps = 0
    @State private var shakeID: UUID? = nil
    @State private var solved = false

    init(level: GameLevel, onComplete: @escaping (Int) -> Void) {
        self.onComplete = onComplete
        _task = State(initialValue: GameData.orderTask(for: level))
    }

    var body: some View {
        VStack(spacing: 28) {
            Text(task.prompt)
                .font(.candyTitle(22))
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.75))
                .padding(.horizontal, 20)

            slotRow

            itemGrid
        }
        .padding(.horizontal, 20)
    }

    /// Numbered slots across the top that fill in, left to right, as items are
    /// correctly tapped — gives the child a running readout of their progress.
    private var slotRow: some View {
        HStack(spacing: 12) {
            ForEach(0..<task.items.count, id: \.self) { rank in
                ZStack {
                    Circle()
                        .fill(rank < placedIDs.count ? CandyTheme.sky : Color.gray.opacity(0.15))
                        .frame(width: 52, height: 52)
                    if let placed = item(atRank: rank) {
                        Text(placed.emoji)
                            .font(.system(size: min(placed.size, 30)))
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .padding(.horizontal, 4)
                    } else {
                        Text("\(rank + 1)")
                            .font(.candyBody(18))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var itemGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 14)], alignment: .center, spacing: 14) {
                ForEach(task.items) { item in
                    let isPlaced = placedIDs.contains(item.id)
                    // Count-based items pack several emoji into one string
                    // (e.g. "🍬🍬🍬🍬🍬"); allow the cluster to wrap onto two
                    // lines and scale down so every candy stays visible instead
                    // of being truncated with an ellipsis.
                    Text(item.emoji)
                        .font(.system(size: item.size))
                        .lineLimit(2)
                        .minimumScaleFactor(0.4)
                        .multilineTextAlignment(.center)
                        .frame(width: 92, height: 74)
                        .background(
                            CandyCardBackground(color: isPlaced ? .green : CandyTheme.hotPink)
                                .opacity(isPlaced ? 0.5 : 1)
                        )
                        .modifier(ShakeEffect(shakes: shakeID == item.id ? 2 : 0))
                        .onTapGesture {
                            handleTap(item)
                        }
                        .allowsHitTesting(!isPlaced && !solved)
                }
            }
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 140, maxHeight: 260)
    }

    private func item(atRank rank: Int) -> OrderItem? {
        guard rank < placedIDs.count else { return nil }
        let id = placedIDs[rank]
        return task.items.first { $0.id == id }
    }

    private func handleTap(_ item: OrderItem) {
        guard !solved, !placedIDs.contains(item.id) else { return }

        if item.rank == placedIDs.count {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                placedIDs.append(item.id)
            }
            if placedIDs.count == task.items.count {
                solved = true
                let stars = wrongTaps == 0 ? 3 : (wrongTaps <= 2 ? 2 : 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete(stars)
                }
            }
        } else {
            wrongTaps += 1
            shakeID = item.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if shakeID == item.id { shakeID = nil }
            }
        }
    }
}

/// Shared shake effect (mirrors the one used in DragMatchView) for a wrong tap.
private struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 6 * sin(shakes * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
