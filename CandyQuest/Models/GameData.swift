import Foundation
import CoreGraphics

enum GameData {

    // MARK: Level Layout
    // 200 levels, procedurally generated. Categories cycle in a fixed rotation so
    // every task type appears regularly throughout the map, and difficulty ramps
    // up in thirds (levels 1-66 easy, 67-132 medium, 133-200 hard). Titles are
    // pulled from a themed word bank per category, cycling with a "round number"
    // suffix once a bank is exhausted, so 200 levels don't need 200 hand-written names.
    static let totalLevelCount = 200

    static let levels: [GameLevel] = generateLevels(count: totalLevelCount)

    private static let categoryCycle: [TaskCategory] = [
        .mathAddition, .readingTap, .mathSubtraction, .dragMatch, .trace, .orderObjects, .oddOneOut,
    ]

    private static let titleBanks: [TaskCategory: [String]] = [
        .mathAddition: [
            "Gumdrop Addition", "Jellybean Jars", "Chocolate Chips", "Sprinkle Sums",
            "Candy Corn Count", "Peppermint Plus", "Toffee Totals", "Marshmallow Math",
            "Bonbon Bunches", "Honeycomb Heap", "Sugar Cube Sums", "Caramel Count-Up",
        ],
        .mathSubtraction: [
            "Lollipop Take-Away", "Cupcake Count", "Cookie Jar", "Candy Cane Minus",
            "Gumball Giveaway", "Fudge Fewer", "Nougat Take-Away", "Wafer Withdraw",
            "Jelly Jar Minus", "Popsicle Subtract", "Brownie Break-Off", "Taffy Trim",
        ],
        .readingTap: [
            "Candy Words", "Read & Tap", "Story Time", "Sweet Sentences",
            "Candy Clues", "Tasty Tales", "Word Wrapper", "Flavor Facts",
            "Rhyme Time", "Sugar Story",
        ],
        .dragMatch: [
            "Sweet Matching", "Flavor Pairs", "Candy Connections", "Match & Munch",
            "Pairing Party", "Treat Twins", "Sticker Sync", "Grand Finale Match",
        ],
        .trace: [
            "Trace the Treat", "Letter Swirls", "Sugar Script", "Candy Cursive",
            "Sweet Strokes", "Frosting Fonts",
        ],
        .orderObjects: [
            "Line Them Up", "Order It Right", "Sequence Sweets", "Candy Countdown",
            "Rank the Treats", "Sort & Sweeten",
        ],
        .oddOneOut: [
            "Spot the Odd Candy", "Find the Odd One", "Sweet Oddball", "Candy Oddities",
            "Odd Candy Out", "Find the Outlier", "Candy Outcast", "The Odd Sweet",
        ],
    ]

    private static func generateLevels(count: Int) -> [GameLevel] {
        let third = max(1, count / 3)
        return (0..<count).map { i in
            let category = categoryCycle[i % categoryCycle.count]
            let difficulty = min(3, 1 + i / third)
            let bank = titleBanks[category] ?? ["Candy Quest"]
            let roundIndex = i / categoryCycle.count // how many times this category has appeared so far
            let base = bank[roundIndex % bank.count]
            let round = roundIndex / bank.count + 1
            let title = round > 1 ? "\(base) \(round)" : base
            return GameLevel(id: i, category: category, title: title, difficulty: difficulty)
        }
    }

    // MARK: Math generator (addition & subtraction, scaled by difficulty)
    static func mathProblem(for level: GameLevel) -> MathProblem {
        let isAddition = level.category == .mathAddition
        let maxNum: Int
        switch level.difficulty {
        case 1: maxNum = 5
        case 2: maxNum = 10
        default: maxNum = 20
        }

        var a = Int.random(in: 1...maxNum)
        var b = Int.random(in: 1...maxNum)
        if !isAddition && b > a { swap(&a, &b) } // keep subtraction non-negative

        let answer = isAddition ? a + b : a - b
        var choices = Set<Int>([answer])
        while choices.count < 3 {
            let delta = Int.random(in: -4...4)
            let wrong = answer + delta
            if wrong >= 0 && delta != 0 { choices.insert(wrong) }
        }
        return MathProblem(a: a, b: b, isAddition: isAddition, choices: choices.shuffled())
    }

    // MARK: Reading & Tap content pools — now dynamic!
    private static let readingColors: [(name: String, emoji: String)] = [
        ("red", "🍎"), ("yellow", "🍋"), ("purple", "🍇"), ("green", "🍏"), ("blue", "🫐"), ("pink", "🍬")
    ]
    private static let readingTreats: [(name: String, emoji: String)] = [
        ("candy", "🍬"), ("cookie", "🍪"), ("cake", "🎂"), ("ice cream", "🍦"), ("donut", "🍩"), ("cupcake", "🧁")
    ]
    
    /// Dynamically generates a reading tap prompt and options.
    static func readingTapTask(for level: GameLevel) -> ReadingTapTask {
        // Pick a (pseudo-)random color/treat combo based on level.id to keep deterministic
        let colorIndex = (level.id * 931) % readingColors.count
        let treatIndex = (level.id * 487) % readingTreats.count
        let color = readingColors[colorIndex]
        let treat = readingTreats[treatIndex]
        let correctEmoji = treat.emoji
        let correctLabel = "the \(color.name) \(treat.name)"
        let others = readingTreats.shuffled().filter { $0 != treat }.prefix(2)
        let options = ([treat] + others).shuffled().enumerated().map { idx, t in
            CandyOption(emoji: t.emoji, label: t.name)
        }
        let prompt = "Tap the \(color.name) \(treat.name)!"
        // Set correctID to match the correct option
        let correctID = options.first { $0.emoji == correctEmoji }?.id ?? options[0].id
        return ReadingTapTask(prompt: prompt, options: options, correctID: correctID)
    }

    // MARK: Drag & Match content pools
    // A large shared pool of word/picture pairs — every emoji and word here is
    // unique across the whole pool, so any random subset drawn from it can't
    // produce two different words pointing at the same picture.
    static let matchPairPool: [MatchPair] = [
        MatchPair(word: "sweet", emoji: "🍭"),
        MatchPair(word: "cold", emoji: "🍦"),
        MatchPair(word: "round", emoji: "🍩"),
        MatchPair(word: "melty", emoji: "🍫"),
        MatchPair(word: "fruity", emoji: "🍇"),
        MatchPair(word: "wrapped", emoji: "🍬"),
        MatchPair(word: "birthday", emoji: "🎂"),
        MatchPair(word: "gummy", emoji: "🐻"),
        MatchPair(word: "crunchy", emoji: "🍪"),
        MatchPair(word: "fizzy", emoji: "🥤"),
        MatchPair(word: "sticky", emoji: "🍯"),
        MatchPair(word: "juicy", emoji: "🍓"),
        MatchPair(word: "frosted", emoji: "🧁"),
        MatchPair(word: "seedy", emoji: "🍉"),
        MatchPair(word: "sour", emoji: "🍋"),
        MatchPair(word: "salty", emoji: "🍿"),
        MatchPair(word: "layered", emoji: "🍰"),
        MatchPair(word: "icy", emoji: "🧊"),
        MatchPair(word: "tropical", emoji: "🍍"),
        MatchPair(word: "berry", emoji: "🫐"),
        // Newly added pairs for more variety:
        MatchPair(word: "chewy", emoji: "🍬"),
        MatchPair(word: "nutty", emoji: "🥜"),
        MatchPair(word: "spicy", emoji: "🌶"),
        MatchPair(word: "crispy", emoji: "🍟"),
        MatchPair(word: "gooey", emoji: "🍯"),
        MatchPair(word: "fluffy", emoji: "🍞"),
        MatchPair(word: "zesty", emoji: "🍋"),
        MatchPair(word: "sweetheart", emoji: "❤️"),
        MatchPair(word: "sugary", emoji: "🍭"),
        MatchPair(word: "minty", emoji: "🌿"),
        MatchPair(word: "cheesey", emoji: "🧀"),
        MatchPair(word: "bubbly", emoji: "🥂"),
    ]

    /// Always draws pairs from the pool. Higher difficulty levels use 4 or 5 pairs,
    /// and occasionally include a decoy pair (word and emoji that don't match the real set).
    static func matchPairs(for level: GameLevel) -> [MatchPair] {
        let baseCount: Int
        switch level.difficulty {
        case 1: baseCount = 3
        case 2: baseCount = 4
        default: baseCount = 5
        }
        
        var selectedPairs = Array(matchPairPool.shuffled().prefix(baseCount))
        // Introduce a decoy pair occasionally at higher difficulty
        if level.difficulty >= 2 && Bool.random() {
            let decoy = MatchPair(word: "decoy", emoji: "❓")
            selectedPairs.append(decoy)
        }
        return selectedPairs.shuffled()
    }

    // MARK: Trace content pool — guide points (unit square 0...1) approximating
    // each uppercase letter's stroke path, lowercase letters, numbers, and simple shapes.
    // Not a precise font outline, just a handful of waypoints a child's finger should pass near while tracing.
    private static let traceGuides: [(String, [CGPoint])] = [
        // Uppercase letters
        ("A", [CGPoint(x: 0.5, y: 0.05), CGPoint(x: 0.2, y: 0.9), CGPoint(x: 0.35, y: 0.55),
               CGPoint(x: 0.65, y: 0.55), CGPoint(x: 0.8, y: 0.9)]),
        ("B", [CGPoint(x: 0.2, y: 0.1), CGPoint(x: 0.2, y: 0.9), CGPoint(x: 0.6, y: 0.15),
               CGPoint(x: 0.75, y: 0.3), CGPoint(x: 0.55, y: 0.5), CGPoint(x: 0.75, y: 0.7), CGPoint(x: 0.6, y: 0.85)]),
        ("C", [CGPoint(x: 0.8, y: 0.15), CGPoint(x: 0.5, y: 0.05), CGPoint(x: 0.2, y: 0.2),
               CGPoint(x: 0.1, y: 0.5), CGPoint(x: 0.2, y: 0.8), CGPoint(x: 0.5, y: 0.95), CGPoint(x: 0.8, y: 0.85)]),
        ("D", [CGPoint(x: 0.2, y: 0.1), CGPoint(x: 0.2, y: 0.9), CGPoint(x: 0.6, y: 0.85),
               CGPoint(x: 0.8, y: 0.5), CGPoint(x: 0.6, y: 0.15)]),
        ("E", [CGPoint(x: 0.75, y: 0.1), CGPoint(x: 0.2, y: 0.1), CGPoint(x: 0.2, y: 0.9),
               CGPoint(x: 0.75, y: 0.9), CGPoint(x: 0.2, y: 0.5), CGPoint(x: 0.55, y: 0.5)]),
        ("F", [CGPoint(x: 0.75, y: 0.1), CGPoint(x: 0.2, y: 0.1), CGPoint(x: 0.2, y: 0.9),
               CGPoint(x: 0.2, y: 0.5), CGPoint(x: 0.55, y: 0.5)]),
        ("G", [CGPoint(x: 0.8, y: 0.15), CGPoint(x: 0.5, y: 0.05), CGPoint(x: 0.2, y: 0.2),
               CGPoint(x: 0.1, y: 0.5), CGPoint(x: 0.2, y: 0.8), CGPoint(x: 0.5, y: 0.95),
               CGPoint(x: 0.8, y: 0.85), CGPoint(x: 0.8, y: 0.55), CGPoint(x: 0.55, y: 0.55)]),
        ("H", [CGPoint(x: 0.2, y: 0.1), CGPoint(x: 0.2, y: 0.9), CGPoint(x: 0.2, y: 0.5),
               CGPoint(x: 0.8, y: 0.5), CGPoint(x: 0.8, y: 0.1), CGPoint(x: 0.8, y: 0.9)]),
        ("I", [CGPoint(x: 0.3, y: 0.1), CGPoint(x: 0.7, y: 0.1), CGPoint(x: 0.5, y: 0.1),
               CGPoint(x: 0.5, y: 0.9), CGPoint(x: 0.3, y: 0.9), CGPoint(x: 0.7, y: 0.9)]),
        ("J", [CGPoint(x: 0.7, y: 0.1), CGPoint(x: 0.7, y: 0.7), CGPoint(x: 0.6, y: 0.9),
               CGPoint(x: 0.35, y: 0.9), CGPoint(x: 0.2, y: 0.75)]),
        ("K", [CGPoint(x: 0.2, y: 0.1), CGPoint(x: 0.2, y: 0.9), CGPoint(x: 0.2, y: 0.5),
               CGPoint(x: 0.75, y: 0.1), CGPoint(x: 0.2, y: 0.5), CGPoint(x: 0.75, y: 0.9)]),
        ("L", [CGPoint(x: 0.2, y: 0.1), CGPoint(x: 0.2, y: 0.5), CGPoint(x: 0.2, y: 0.9), CGPoint(x: 0.8, y: 0.9)]),
        ("M", [CGPoint(x: 0.15, y: 0.9), CGPoint(x: 0.15, y: 0.1), CGPoint(x: 0.5, y: 0.55),
               CGPoint(x: 0.85, y: 0.1), CGPoint(x: 0.85, y: 0.9)]),
        ("N", [CGPoint(x: 0.2, y: 0.9), CGPoint(x: 0.2, y: 0.1), CGPoint(x: 0.8, y: 0.9), CGPoint(x: 0.8, y: 0.1)]),
        ("O", [CGPoint(x: 0.5, y: 0.05), CGPoint(x: 0.8, y: 0.2), CGPoint(x: 0.9, y: 0.5),
               CGPoint(x: 0.8, y: 0.8), CGPoint(x: 0.5, y: 0.95), CGPoint(x: 0.2, y: 0.8),
               CGPoint(x: 0.1, y: 0.5), CGPoint(x: 0.2, y: 0.2)]),
        ("P", [CGPoint(x: 0.2, y: 0.9), CGPoint(x: 0.2, y: 0.1), CGPoint(x: 0.6, y: 0.15),
               CGPoint(x: 0.75, y: 0.3), CGPoint(x: 0.6, y: 0.5), CGPoint(x: 0.2, y: 0.5)]),
        ("Q", [CGPoint(x: 0.5, y: 0.05), CGPoint(x: 0.8, y: 0.2), CGPoint(x: 0.9, y: 0.5),
               CGPoint(x: 0.8, y: 0.8), CGPoint(x: 0.5, y: 0.95), CGPoint(x: 0.2, y: 0.8),
               CGPoint(x: 0.1, y: 0.5), CGPoint(x: 0.2, y: 0.2), CGPoint(x: 0.6, y: 0.7), CGPoint(x: 0.85, y: 0.95)]),
        ("R", [CGPoint(x: 0.2, y: 0.9), CGPoint(x: 0.2, y: 0.1), CGPoint(x: 0.6, y: 0.15),
               CGPoint(x: 0.75, y: 0.3), CGPoint(x: 0.6, y: 0.5), CGPoint(x: 0.2, y: 0.5), CGPoint(x: 0.75, y: 0.9)]),
        ("S", [CGPoint(x: 0.75, y: 0.15), CGPoint(x: 0.3, y: 0.1), CGPoint(x: 0.15, y: 0.3),
               CGPoint(x: 0.4, y: 0.5), CGPoint(x: 0.85, y: 0.6), CGPoint(x: 0.7, y: 0.85), CGPoint(x: 0.25, y: 0.9)]),
        ("T", [CGPoint(x: 0.15, y: 0.1), CGPoint(x: 0.85, y: 0.1), CGPoint(x: 0.5, y: 0.1), CGPoint(x: 0.5, y: 0.9)]),
        ("U", [CGPoint(x: 0.2, y: 0.1), CGPoint(x: 0.2, y: 0.7), CGPoint(x: 0.35, y: 0.9),
               CGPoint(x: 0.65, y: 0.9), CGPoint(x: 0.8, y: 0.7), CGPoint(x: 0.8, y: 0.1)]),
        ("V", [CGPoint(x: 0.15, y: 0.1), CGPoint(x: 0.5, y: 0.9), CGPoint(x: 0.85, y: 0.1)]),
        ("W", [CGPoint(x: 0.1, y: 0.1), CGPoint(x: 0.3, y: 0.9), CGPoint(x: 0.5, y: 0.4),
               CGPoint(x: 0.7, y: 0.9), CGPoint(x: 0.9, y: 0.1)]),
        ("X", [CGPoint(x: 0.15, y: 0.1), CGPoint(x: 0.85, y: 0.9), CGPoint(x: 0.5, y: 0.5),
               CGPoint(x: 0.85, y: 0.1), CGPoint(x: 0.15, y: 0.9)]),
        ("Y", [CGPoint(x: 0.15, y: 0.1), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.85, y: 0.1),
               CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.5, y: 0.9)]),
        ("Z", [CGPoint(x: 0.15, y: 0.1), CGPoint(x: 0.85, y: 0.1), CGPoint(x: 0.15, y: 0.9), CGPoint(x: 0.85, y: 0.9)]),

        // Lowercase letters (simplified and roughly mimicking uppercase shapes)
        ("a", [CGPoint(x: 0.5, y: 0.7), CGPoint(x: 0.65, y: 0.7), CGPoint(x: 0.65, y: 0.5), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.5, y: 0.9)]),
        ("b", [CGPoint(x: 0.3, y: 0.1), CGPoint(x: 0.3, y: 0.9), CGPoint(x: 0.5, y: 0.75), CGPoint(x: 0.3, y: 0.5)]),
        ("c", [CGPoint(x: 0.7, y: 0.6), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.3, y: 0.6), CGPoint(x: 0.5, y: 0.8)]),
        ("d", [CGPoint(x: 0.7, y: 0.1), CGPoint(x: 0.7, y: 0.9), CGPoint(x: 0.5, y: 0.75), CGPoint(x: 0.7, y: 0.5)]),
        ("e", [CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.5, y: 0.7), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.5, y: 0.6)]),
        ("f", [CGPoint(x: 0.5, y: 0.1), CGPoint(x: 0.5, y: 0.7), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.7, y: 0.5)]),
        ("g", [CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.7, y: 0.5), CGPoint(x: 0.7, y: 0.9), CGPoint(x: 0.3, y: 0.9)]),
        ("h", [CGPoint(x: 0.3, y: 0.1), CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.5, y: 0.7), CGPoint(x: 0.5, y: 0.5)]),
        ("i", [CGPoint(x: 0.5, y: 0.3), CGPoint(x: 0.5, y: 0.7), CGPoint(x: 0.5, y: 0.1)]),
        ("j", [CGPoint(x: 0.5, y: 0.3), CGPoint(x: 0.5, y: 0.8), CGPoint(x: 0.3, y: 0.9)]),
        ("k", [CGPoint(x: 0.3, y: 0.1), CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.5, y: 0.7)]),
        ("l", [CGPoint(x: 0.3, y: 0.1), CGPoint(x: 0.3, y: 0.7)]),
        ("m", [CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.5, y: 0.7), CGPoint(x: 0.7, y: 0.5), CGPoint(x: 0.7, y: 0.7)]),
        ("n", [CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.5, y: 0.7), CGPoint(x: 0.5, y: 0.5)]),
        ("o", [CGPoint(x: 0.5, y: 0.7), CGPoint(x: 0.7, y: 0.6), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.3, y: 0.6)]),
        ("p", [CGPoint(x: 0.3, y: 0.1), CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.3, y: 0.5)]),
        ("q", [CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.7, y: 0.7), CGPoint(x: 0.7, y: 0.3), CGPoint(x: 0.5, y: 0.5)]),
        ("r", [CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.5, y: 0.5)]),
        ("s", [CGPoint(x: 0.7, y: 0.6), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.3, y: 0.6), CGPoint(x: 0.5, y: 0.7)]),
        ("t", [CGPoint(x: 0.5, y: 0.3), CGPoint(x: 0.5, y: 0.7), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.7, y: 0.5)]),
        ("u", [CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.7, y: 0.5), CGPoint(x: 0.7, y: 0.7)]),
        ("v", [CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.7, y: 0.7)]),
        ("w", [CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.4, y: 0.5), CGPoint(x: 0.5, y: 0.7), CGPoint(x: 0.6, y: 0.5), CGPoint(x: 0.7, y: 0.7)]),
        ("x", [CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.7, y: 0.7), CGPoint(x: 0.5, y: 0.6), CGPoint(x: 0.7, y: 0.5), CGPoint(x: 0.3, y: 0.7)]),
        ("y", [CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.5, y: 0.6), CGPoint(x: 0.7, y: 0.7), CGPoint(x: 0.5, y: 0.9)]),
        ("z", [CGPoint(x: 0.3, y: 0.7), CGPoint(x: 0.7, y: 0.7), CGPoint(x: 0.3, y: 0.5), CGPoint(x: 0.7, y: 0.5)]),

        // Numbers 0-9
        ("0", [CGPoint(x: 0.5, y: 0.05), CGPoint(x: 0.75, y: 0.3), CGPoint(x: 0.75, y: 0.7), CGPoint(x: 0.5, y: 0.95),
               CGPoint(x: 0.25, y: 0.7), CGPoint(x: 0.25, y: 0.3), CGPoint(x: 0.5, y: 0.05)]),
        ("1", [CGPoint(x: 0.5, y: 0.1), CGPoint(x: 0.5, y: 0.9)]),
        ("2", [CGPoint(x: 0.25, y: 0.3), CGPoint(x: 0.5, y: 0.1), CGPoint(x: 0.75, y: 0.3),
               CGPoint(x: 0.25, y: 0.9), CGPoint(x: 0.75, y: 0.9)]),
        ("3", [CGPoint(x: 0.25, y: 0.1), CGPoint(x: 0.75, y: 0.1), CGPoint(x: 0.5, y: 0.5),
               CGPoint(x: 0.75, y: 0.9), CGPoint(x: 0.25, y: 0.9)]),
        ("4", [CGPoint(x: 0.75, y: 0.7), CGPoint(x: 0.75, y: 0.1), CGPoint(x: 0.25, y: 0.5), CGPoint(x: 0.75, y: 0.5)]),
        ("5", [CGPoint(x: 0.75, y: 0.1), CGPoint(x: 0.25, y: 0.1), CGPoint(x: 0.25, y: 0.5),
               CGPoint(x: 0.75, y: 0.5), CGPoint(x: 0.75, y: 0.9), CGPoint(x: 0.25, y: 0.9)]),
        ("6", [CGPoint(x: 0.75, y: 0.1), CGPoint(x: 0.25, y: 0.5), CGPoint(x: 0.25, y: 0.9),
               CGPoint(x: 0.75, y: 0.9), CGPoint(x: 0.75, y: 0.5), CGPoint(x: 0.25, y: 0.7)]),
        ("7", [CGPoint(x: 0.25, y: 0.1), CGPoint(x: 0.75, y: 0.1), CGPoint(x: 0.5, y: 0.9)]),
        ("8", [CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.75, y: 0.3), CGPoint(x: 0.75, y: 0.7),
               CGPoint(x: 0.5, y: 0.9), CGPoint(x: 0.25, y: 0.7), CGPoint(x: 0.25, y: 0.3)]),
        ("9", [CGPoint(x: 0.75, y: 0.7), CGPoint(x: 0.75, y: 0.1), CGPoint(x: 0.25, y: 0.1),
               CGPoint(x: 0.25, y: 0.5), CGPoint(x: 0.75, y: 0.5)]),

        // Simple shapes
        ("circle", [
            CGPoint(x: 0.5, y: 0.05), CGPoint(x: 0.75, y: 0.2), CGPoint(x: 0.9, y: 0.5),
            CGPoint(x: 0.75, y: 0.8), CGPoint(x: 0.5, y: 0.95), CGPoint(x: 0.25, y: 0.8),
            CGPoint(x: 0.1, y: 0.5), CGPoint(x: 0.25, y: 0.2), CGPoint(x: 0.5, y: 0.05)
        ]),
        ("square", [
            CGPoint(x: 0.2, y: 0.2), CGPoint(x: 0.8, y: 0.2), CGPoint(x: 0.8, y: 0.8), CGPoint(x: 0.2, y: 0.8), CGPoint(x: 0.2, y: 0.2)
        ]),
        ("triangle", [
            CGPoint(x: 0.5, y: 0.05), CGPoint(x: 0.9, y: 0.85), CGPoint(x: 0.1, y: 0.85), CGPoint(x: 0.5, y: 0.05)
        ]),
        ("heart", [
            CGPoint(x: 0.5, y: 0.9), CGPoint(x: 0.15, y: 0.6), CGPoint(x: 0.35, y: 0.25),
            CGPoint(x: 0.5, y: 0.4), CGPoint(x: 0.65, y: 0.25), CGPoint(x: 0.85, y: 0.6), CGPoint(x: 0.5, y: 0.9)
        ]),
        ("star", [
            CGPoint(x: 0.5, y: 0.05), CGPoint(x: 0.6, y: 0.35), CGPoint(x: 0.9, y: 0.35),
            CGPoint(x: 0.65, y: 0.55), CGPoint(x: 0.75, y: 0.85), CGPoint(x: 0.5, y: 0.65),
            CGPoint(x: 0.25, y: 0.85), CGPoint(x: 0.35, y: 0.55), CGPoint(x: 0.1, y: 0.35),
            CGPoint(x: 0.4, y: 0.35), CGPoint(x: 0.5, y: 0.05)
        ]),
    ]

    /// Trace levels progress alphabetically: the Nth trace level (by its position
    /// among trace levels specifically, not its overall level id) gets the Nth
    /// trace guide, cycling back to the start if there are more trace levels than guides.
    static func traceTask(for level: GameLevel) -> TraceTask {
        let occurrence = level.id / categoryCycle.count
        let choice = traceGuides[occurrence % traceGuides.count]
        return TraceTask(character: choice.0, guidePoints: choice.1)
    }

    // MARK: Order Objects — read a sentence, then tap items in the order it describes

    private static let colorPalette: [(name: String, emoji: String)] = [
        ("red", "🔴"), ("yellow", "🟡"), ("blue", "🔵"),
        ("green", "🟢"), ("purple", "🟣"), ("orange", "🟠"),
        ("pink", "🌸"), ("brown", "🟤"), ("black", "⚫️"), ("white", "⚪️"),
    ]

    private static let shapePalette: [(name: String, emoji: String)] = [
        ("circle", "⚪️"), ("star", "⭐️"), ("square", "🟥"),
        ("triangle", "🔺"), ("diamond", "🔷"), ("heart", "❤️"),
        ("hexagon", "⬡"), ("pentagon", "⬠"),
    ]

    private static let sizeCandyEmojis = ["🍬", "🍭", "🍩", "🧁"]
    private static let ascendingSizes: [CGFloat] = [26, 36, 46, 56, 66]

    enum OrderVariant: CaseIterable {
        case size
        case color
        case shape
        case count
    }

    static func orderTask(for level: GameLevel) -> OrderTask {
        let count: Int
        switch level.difficulty {
        case 1: count = 3
        case 2: count = 4
        default: count = 5
        }

        switch OrderVariant.allCases.randomElement()! {
        case .size:
            return sizeOrderTask(count: min(count, ascendingSizes.count))
        case .color:
            return attributeOrderTask(count: min(count, colorPalette.count), palette: colorPalette, noun: "candies")
        case .shape:
            return attributeOrderTask(count: min(count, shapePalette.count), palette: shapePalette, noun: "shapes")
        case .count:
            return countOrderTask(count: count)
        }
    }

    private static func sizeOrderTask(count: Int) -> OrderTask {
        let ascending = Bool.random()
        let sizes = ascending ? Array(ascendingSizes.prefix(count)) : Array(ascendingSizes.prefix(count).reversed())
        let emoji = sizeCandyEmojis.randomElement()!
        let items = sizes.enumerated().map { rank, size in OrderItem(emoji: emoji, rank: rank, size: size) }
        let prompt = ascending
            ? "Tap the candies in order from smallest to biggest!"
            : "Tap the candies in order from biggest to smallest!"
        return OrderTask(prompt: prompt, items: items.shuffled())
    }

    private static func attributeOrderTask(count: Int, palette: [(name: String, emoji: String)], noun: String) -> OrderTask {
        let chosen = Array(palette.shuffled().prefix(count))
        let sequence = chosen.map(\.name).joined(separator: ", then ")
        let prompt = "Tap the \(noun) in this order: \(sequence)!"
        let items = chosen.enumerated().map { rank, entry in OrderItem(emoji: entry.emoji, rank: rank, size: 44) }
        return OrderTask(prompt: prompt, items: items.shuffled())
    }

    private static func countOrderTask(count: Int) -> OrderTask {
        // Create items with the same emoji but different counts (1 to count)
        let emoji = sizeCandyEmojis.randomElement()!
        let counts = (1...count).shuffled()
        let items = counts.enumerated().map { rank, number in
            OrderItem(emoji: String(repeating: emoji, count: number), rank: rank, size: 44)
        }
        let prompt = "Tap the candies in order from fewest to most!"
        return OrderTask(prompt: prompt, items: items.shuffled())
    }

    // MARK: Odd One Out

    struct OddOneOutTask {
        let prompt: String
        let options: [CandyOption]
        let oddOneOutID: UUID
    }

    private static let oddOneOutPool: [(name: String, emoji: String, category: String)] = [
        ("apple", "🍎", "fruit"),
        ("banana", "🍌", "fruit"),
        ("grapes", "🍇", "fruit"),
        ("carrot", "🥕", "vegetable"),
        ("broccoli", "🥦", "vegetable"),
        ("cucumber", "🥒", "vegetable"),
        ("cake", "🎂", "dessert"),
        ("cookie", "🍪", "dessert"),
        ("ice cream", "🍦", "dessert"),
        ("popcorn", "🍿", "snack"),
        ("pretzel", "🥨", "snack"),
        ("chips", "🍟", "snack"),
    ]

    /// Generates an odd one out task: choose 3-5 options with one that doesn't fit the group.
    static func oddOneOutTask(for level: GameLevel) -> OddOneOutTask {
        // Group options by category
        let categories = Dictionary(grouping: oddOneOutPool, by: { $0.category })
        // Pick a common category and an odd category
        let validCategories = categories.keys.sorted()
        guard validCategories.count >= 2 else {
            // Fallback in case not enough categories
            let options = oddOneOutPool.shuffled().prefix(4).map {
                CandyOption(emoji: $0.emoji, label: $0.name)
            }
            let oddOneOutID = options[0].id
            let prompt = "Find the odd one out!"
            return OddOneOutTask(prompt: prompt, options: options, oddOneOutID: oddOneOutID)
        }

        // Choose main category with at least 3 items
        let mainCategory = validCategories.first(where: { categories[$0]?.count ?? 0 >= 3 }) ?? validCategories[0]
        // Choose odd category different from main
        let oddCategory = validCategories.first(where: { $0 != mainCategory }) ?? validCategories[0]

        // Select main items and odd one out item
        let mainItems = categories[mainCategory]!.shuffled().prefix(3)
        let oddItem = categories[oddCategory]!.randomElement()!

        // Combine options and shuffle
        var combined = Array(mainItems) + [oddItem]
        combined.shuffle()

        let options = combined.map { CandyOption(emoji: $0.emoji, label: $0.name) }
        let oddOneOutID = options.first(where: { $0.emoji == oddItem.emoji })?.id ?? options[0].id
        let prompt = "Tap the candy that doesn't belong!"
        return OddOneOutTask(prompt: prompt, options: options, oddOneOutID: oddOneOutID)
    }

    // MARK: Sticker Shop

    /// Stickers a child can buy with stars earned from completing levels.
    /// Costs are ordered roughly from "quick win" to "big goal."
    static let stickerCatalog: [Sticker] = [
        Sticker(id: "lollipop", emoji: "🍭", name: "Lollipop", cost: 5),
        Sticker(id: "gummy_bear", emoji: "🐻", name: "Gummy Bear", cost: 8),
        Sticker(id: "donut", emoji: "🍩", name: "Donut", cost: 8),
        Sticker(id: "cupcake", emoji: "🧁", name: "Cupcake", cost: 10),
        Sticker(id: "ice_cream", emoji: "🍦", name: "Ice Cream", cost: 10),
        Sticker(id: "cookie", emoji: "🍪", name: "Cookie", cost: 12),
        Sticker(id: "cake", emoji: "🎂", name: "Birthday Cake", cost: 15),
        Sticker(id: "candy", emoji: "🍬", name: "Sweet Candy", cost: 15),
        Sticker(id: "honey", emoji: "🍯", name: "Honey Pot", cost: 18),
        Sticker(id: "watermelon", emoji: "🍉", name: "Watermelon", cost: 18),
        Sticker(id: "pineapple", emoji: "🍍", name: "Pineapple", cost: 20),
        Sticker(id: "berries", emoji: "🫐", name: "Blueberries", cost: 20),
        Sticker(id: "rainbow", emoji: "🌈", name: "Rainbow", cost: 25),
        Sticker(id: "gold_star", emoji: "⭐️", name: "Golden Star", cost: 25),
        Sticker(id: "unicorn", emoji: "🦄", name: "Unicorn", cost: 40),
        Sticker(id: "crown", emoji: "👑", name: "Candy Crown", cost: 50),
        Sticker(id: "trophy", emoji: "🏆", name: "Champion Trophy", cost: 75),
        Sticker(id: "castle", emoji: "🏰", name: "Candy Castle", cost: 100),
    ]

}
