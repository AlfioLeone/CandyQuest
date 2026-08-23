import SwiftUI

struct DragMatchView: View {
    let onComplete: (Int) -> Void
    private let level: GameLevel

    // Generate once to keep stable IDs across renders
    @State private var pairs: [MatchPair]
    @State private var shuffledTargets: [MatchPair]

    // Simple state, inspired by ReadingTapView
    @State private var matchedIDs: Set<UUID> = []
    @State private var wrongDrops = 0
    @State private var hoveredTargetID: UUID? = nil
    @State private var shakeID: UUID? = nil

    init(level: GameLevel, onComplete: @escaping (Int) -> Void) {
        self.level = level
        self.onComplete = onComplete
        let generated = GameData.matchPairs(for: level)
        _pairs = State(initialValue: generated)
        _shuffledTargets = State(initialValue: generated.shuffled())
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)
            Text("Drag each word to its match!")
                .font(.candyBody(20))
                .foregroundColor(.black.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                let spacing: CGFloat = 6
                let targetSize: CGFloat = 76
                let wordFont: CGFloat = 16
                let columns = [GridItem(.adaptive(minimum: targetSize, maximum: 120), spacing: spacing, alignment: .center)]

                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(shuffledTargets, id: \.id) { target in
                        if !matchedIDs.contains(target.id) {
                            let isHovered: Bool = (hoveredTargetID == target.id)

                            TargetDropCell(
                                target: target,
                                size: targetSize,
                                isHovered: isHovered,
                                onDropMatch: { droppedID in
                                    if let dropped = pairs.first(where: { $0.id == droppedID }) {
                                        handleDrop(dropped: dropped, onto: target)
                                    }
                                },
                                onHoverChange: { hovering in
                                    hoveredTargetID = hovering ? target.id : nil
                                }
                            )
                        }
                    }
                }
                .padding(.vertical, 6)
                .frame(maxWidth: 320, alignment: .center)
                .frame(maxWidth: .infinity)

                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(pairs, id: \.id) { pair in
                        if !matchedIDs.contains(pair.id) {
                            DraggableWord(pair: pair, fontSize: wordFont, minWidth: targetSize)
                                .modifier(ShakeEffect(shakes: shakeID == pair.id ? 2 : 0))
                                .draggable(pair.id, preview: {
                                    Text(pair.word)
                                        .padding(8)
                                        .background(CandyCardBackground(color: CandyTheme.hotPink))
                                })
                        }
                    }
                }
                .padding(.vertical, 6)
                .frame(maxWidth: 320, alignment: .center)
                .frame(maxWidth: .infinity)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onChange(of: matchedIDs) { newValue in
            if newValue.count == pairs.count {
                let stars = wrongDrops == 0 ? 3 : (wrongDrops <= 2 ? 2 : 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onComplete(stars)
                }
            }
        }
        .onAppear {
            if pairs.isEmpty { regeneratePairs() }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 24)
    }

    // MARK: - Logic

    private func handleDrop(dropped: MatchPair, onto target: MatchPair) {
        if dropped.id == target.id {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                matchedIDs.insert(target.id)
            }
        } else {
            wrongDrops += 1
            shakeID = dropped.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if shakeID == dropped.id { shakeID = nil }
            }
        }
    }

    private func regeneratePairs() {
        let generated = GameData.matchPairs(for: level)
        pairs = generated
        shuffledTargets = generated.shuffled()
        matchedIDs.removeAll()
        wrongDrops = 0
    }
}

// MARK: - Subviews

private struct TargetDropCell: View {
    let target: MatchPair
    let size: CGFloat
    let isHovered: Bool
    let onDropMatch: (UUID) -> Void
    let onHoverChange: (Bool) -> Void

    var body: some View {
        TargetCard(emoji: target.emoji, size: size, hovered: isHovered)
            .scaleEffect(isHovered ? 1.08 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHovered)
            .dropDestination(for: UUID.self) { (items: [UUID], _) -> Bool in
                guard let droppedID = items.first else { return false }
                onDropMatch(droppedID)
                return true
            } isTargeted: { hovering in
                onHoverChange(hovering)
            }
    }
}

private struct TargetCard: View {
    let emoji: String
    let size: CGFloat
    let hovered: Bool
    var body: some View {
        Text(emoji)
            .font(.system(size: size * 0.55))
            .frame(width: size, height: size)
            .background(CandyCardBackground(color: hovered ? CandyTheme.hotPink : CandyTheme.mint))
            .accessibilityLabel("Target \(emoji)")
    }
}

private struct DraggableWord: View {
    let pair: MatchPair
    let fontSize: CGFloat
    let minWidth: CGFloat

    var body: some View {
        Text(pair.word)
            .foregroundColor(.black)
            .font(.candyBody(fontSize))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, minWidth < 70 ? 8 : 14)
            .padding(.vertical, minWidth < 70 ? 6 : 10)
            .background(CandyCardBackground(color: CandyTheme.hotPink))
            .accessibilityLabel("Word \(pair.word)")
    }
}
import UniformTypeIdentifiers

extension UUID: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .data) { uuid in
            withUnsafeBytes(of: uuid.uuid) { Data($0) }
        } importing: { data in
            guard data.count == 16 else { throw CocoaError(.coderInvalidValue) }
            let tuple = data.withUnsafeBytes { ptr -> uuid_t in
                let b = ptr.bindMemory(to: UInt8.self)
                return (b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9], b[10], b[11], b[12], b[13], b[14], b[15])
            }
            return UUID(uuid: tuple)
        }
    }
}

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
