import SwiftUI

/// Collects the on-screen frames of the drop targets, keyed by pair id,
/// in the global coordinate space.
private struct TargetFramesKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct DragMatchView: View {
    var onComplete: (Int) -> Void

    // Generated ONCE (in init, via @State) so the word list and the target list
    // always share the exact same identifiers — this is what lets a drop be
    // recognized as a correct match. Re-deriving this data inside `body` would
    // regenerate fresh random IDs on every SwiftUI re-render and break matching.
    @State private var pairs: [MatchPair]
    @State private var shuffledEmojiSlots: [MatchPair]

    @State private var matchedIDs: Set<UUID> = []
    @State private var wrongDrops = 0

    @State private var targetFrames: [UUID: CGRect] = [:]
    @State private var dragOffsets: [UUID: CGSize] = [:]
    @State private var activeDragID: UUID? = nil
    @State private var hoveredTargetID: UUID? = nil
    @State private var shakeID: UUID? = nil

    /// How much extra room (in points) beyond the visible circle counts as a hit.
    /// Kept generous since small fingers on a small target are imprecise.
    private let hitTestPadding: CGFloat = 30

    init(level: GameLevel, onComplete: @escaping (Int) -> Void) {
        self.onComplete = onComplete
        let generated = GameData.matchPairs(for: level)
        _pairs = State(initialValue: generated)
        _shuffledEmojiSlots = State(initialValue: generated.shuffled())
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Drag each word to its match!")
                .font(.candyBody(20))
                .foregroundColor(.black.opacity(0.7))

            // Drop targets (emoji slots) — matched ones fade out. A wrapping grid
            // (rather than a fixed HStack) keeps this from overflowing the screen
            // now that rounds can have up to 5 pairs.
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 16)], spacing: 16) {
                ForEach(shuffledEmojiSlots) { pair in
                    if !matchedIDs.contains(pair.id) {
                        Text(pair.emoji)
                            .font(.system(size: 44))
                            .frame(width: 80, height: 80)
                            .background(
                                CandyCardBackground(
                                    color: hoveredTargetID == pair.id ? CandyTheme.hotPink : CandyTheme.mint
                                )
                            )
                            .scaleEffect(hoveredTargetID == pair.id ? 1.12 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: hoveredTargetID)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(key: TargetFramesKey.self, value: [pair.id: geo.frame(in: .global)])
                                }
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }

            // Draggable words — follow the finger directly, no press-and-hold needed.
            // Matched ones fade out together with their target above.
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 14)], spacing: 14) {
                ForEach(pairs) { pair in
                    if !matchedIDs.contains(pair.id) {
                        Text(pair.word)
                            .font(.candyBody(16))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(CandyCardBackground(color: CandyTheme.hotPink))
                            .offset(dragOffsets[pair.id] ?? .zero)
                            .modifier(ShakeEffect(shakes: shakeID == pair.id ? 2 : 0))
                            .zIndex(activeDragID == pair.id ? 1 : 0)
                            .transition(.scale.combined(with: .opacity))
                            .gesture(
                                DragGesture(minimumDistance: 1, coordinateSpace: .global)
                                    .onChanged { value in
                                        activeDragID = pair.id
                                        dragOffsets[pair.id] = value.translation
                                        hoveredTargetID = targetID(at: value.location)
                                    }
                                    .onEnded { value in
                                        handleDrop(of: pair, at: value.location)
                                    }
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .onPreferenceChange(TargetFramesKey.self) { targetFrames = $0 }
        .onChange(of: matchedIDs) { newValue in
            if newValue.count == pairs.count {
                let stars = wrongDrops == 0 ? 3 : (wrongDrops <= 2 ? 2 : 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onComplete(stars)
                }
            }
        }
    }

    /// Finds a target whose (padded) frame contains the given global point, if any.
    private func targetID(at point: CGPoint) -> UUID? {
        targetFrames.first { _, rect in
            rect.insetBy(dx: -hitTestPadding, dy: -hitTestPadding).contains(point)
        }?.key
    }

    private func handleDrop(of pair: MatchPair, at location: CGPoint) {
        activeDragID = nil
        hoveredTargetID = nil

        if let hitID = targetID(at: location) {
            if hitID == pair.id {
                // Correct match: both the word and its target fade out together.
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    matchedIDs.insert(pair.id)
                }
                dragOffsets[pair.id] = .zero
                return
            } else {
                wrongDrops += 1
            }
        }

        // No match (or wrong target): spring back to the tray and give a little shake.
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            dragOffsets[pair.id] = .zero
        }
        shakeID = pair.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if shakeID == pair.id { shakeID = nil }
        }
    }
}

/// A small horizontal shake used to give friendly feedback on an incorrect drop.
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
