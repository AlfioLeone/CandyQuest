import Foundation

enum TaskCategory: String, Codable, CaseIterable {
    case readingTap
    case mathAddition
    case mathSubtraction
    case dragMatch
    case trace
    case orderObjects
    case oddOneOut
}

struct GameLevel: Identifiable, Codable {
    let id: Int
    let category: TaskCategory
    let title: String
    /// Difficulty scales the number ranges / content complexity (1 = easiest)
    let difficulty: Int
}

// MARK: - Reading & Tap

struct CandyOption: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let label: String
}

struct ReadingTapTask {
    let prompt: String
    let options: [CandyOption]
    let correctID: UUID
}

// MARK: - Math

struct MathProblem {
    let a: Int
    let b: Int
    let isAddition: Bool
    let choices: [Int]

    var answer: Int { isAddition ? a + b : a - b }
    var symbol: String { isAddition ? "+" : "−" }
}

// MARK: - Drag & Match

struct MatchPair: Identifiable {
    let id = UUID()
    let word: String
    let emoji: String
}

// MARK: - Trace

struct TraceTask {
    let character: String
    /// Normalized guide points (0...1 in a unit square) approximating the character's stroke path.
    let guidePoints: [CGPoint]
}

// MARK: - Order Objects

/// Which attribute the prompt sentence is asking the child to order by.
enum OrderVariant: CaseIterable {
    case size
    case color
    case shape
}

struct OrderItem: Identifiable {
    let id = UUID()
    let emoji: String
    /// The item's correct 0-indexed position in the sequence, as described by the prompt.
    let rank: Int
    /// Display size in points — used by the size-ordering variant so items are
    /// visually different sizes; other variants use a standard size.
    let size: CGFloat
}

struct OrderTask {
    /// The sentence the child must read to know the correct order — e.g.
    /// "Tap the candies from smallest to biggest!" or
    /// "Tap them in this order: red, then yellow, then blue!"
    let prompt: String
    /// Items in shuffled (display) order; each carries its own correct rank.
    let items: [OrderItem]
}

// MARK: - Stickers

struct Sticker: Identifiable, Hashable, Codable {
    let id: String
    let emoji: String
    let name: String
    /// Price in stars.
    let cost: Int
}
