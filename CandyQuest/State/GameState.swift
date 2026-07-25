import Foundation
import SwiftUI
import Combine

struct MetaGoal: Identifiable, Hashable {
    let id: String
    let description: String
    let target: Int
    var progress: Int
    var isComplete: Bool { progress >= target }
    let rewardStars: Int
}

final class GameState: ObservableObject {
    @Published var starsByLevel: [Int: Int] = [:] // levelID -> best stars earned (0-3), for map display
    @Published var unlockedLevelIDs: Set<Int> = [0]

    /// Spendable currency. Unlike `starsByLevel` (which only keeps a level's
    /// *best* result), this increases by however many stars are earned on
    /// every completion — including replays — and decreases when a sticker
    /// is purchased. This intentionally makes replaying earlier levels a
    /// viable way to earn more stickers.
    @Published var starBalance: Int = 0
    @Published var ownedStickerIDs: Set<String> = []
    @Published var equippedStickerID: String? = nil

    @Published var metaGoals: [MetaGoal] = [
        MetaGoal(id: "earn10stars", description: "Earn 10 stars in one day!", target: 10, progress: 0, rewardStars: 5),
        MetaGoal(id: "noMistake3", description: "Complete 3 levels in a row with no mistakes!", target: 3, progress: 0, rewardStars: 8),
        MetaGoal(id: "allMiniGames", description: "Try every type of mini-game!", target: 6, progress: 0, rewardStars: 10)
    ]

    private let starsKey = "candyquest.starsByLevel"
    private let unlockedKey = "candyquest.unlockedLevelIDs"
    private let balanceKey = "candyquest.starBalance"
    private let ownedStickersKey = "candyquest.ownedStickerIDs"
    private let equippedStickerKey = "candyquest.equippedStickerID"

    init() {
        load()
    }

    func isUnlocked(_ level: GameLevel) -> Bool {
        unlockedLevelIDs.contains(level.id)
    }

    func stars(for level: GameLevel) -> Int {
        starsByLevel[level.id] ?? 0
    }

    /// Call when a level's task is completed successfully.
    func completeLevel(_ level: GameLevel, stars: Int) {
        let best = max(starsByLevel[level.id] ?? 0, stars)
        starsByLevel[level.id] = best
        starBalance += stars
        if let nextID = GameData.levels.first(where: { $0.id == level.id + 1 })?.id {
            unlockedLevelIDs.insert(nextID)
        }
        updateMetaGoals(for: level, stars: stars)
        save()
    }

    private func updateMetaGoals(for level: GameLevel, stars: Int) {
        // Earn 10 stars in a day (for demo, just increment ongoing)
        if let idx = metaGoals.firstIndex(where: { $0.id == "earn10stars" }) {
            metaGoals[idx].progress += stars
        }
        // Complete 3 levels in a row with no mistakes
        if let idx = metaGoals.firstIndex(where: { $0.id == "noMistake3" }) {
            if stars == 3 {
                metaGoals[idx].progress += 1
            } else {
                metaGoals[idx].progress = 0 // reset streak
            }
        }
        // Try every type of mini-game
        if let idx = metaGoals.firstIndex(where: { $0.id == "allMiniGames" }) {
            let miniGamePlayed = level.category.rawValue
            var playedSet = Set(metaGoals[idx].description.components(separatedBy: ","))
            if !playedSet.contains(miniGamePlayed) {
                playedSet.insert(miniGamePlayed)
                metaGoals[idx].progress += 1
            }
        }
    }

    var totalStars: Int {
        starsByLevel.values.reduce(0, +)
    }

    /// The sticker currently equipped as the child's character, if any.
    var equippedSticker: Sticker? {
        GameData.stickerCatalog.first { $0.id == equippedStickerID }
    }

    func isOwned(_ sticker: Sticker) -> Bool {
        ownedStickerIDs.contains(sticker.id)
    }

    /// Attempts to buy a sticker with the current star balance. Returns whether
    /// the purchase succeeded (fails silently if already owned or unaffordable,
    /// since the shop UI disables the button in both cases anyway).
    @discardableResult
    func purchase(_ sticker: Sticker) -> Bool {
        guard !isOwned(sticker), starBalance >= sticker.cost else { return false }
        starBalance -= sticker.cost
        ownedStickerIDs.insert(sticker.id)
        if equippedStickerID == nil {
            equippedStickerID = sticker.id
        }
        save()
        return true
    }

    /// Shows this sticker as the child's badge next to their star count on the map.
    func equip(_ sticker: Sticker) {
        guard isOwned(sticker) else { return }
        equippedStickerID = sticker.id
        save()
    }

    private func save() {
        let starsData = starsByLevel.map { ["id": $0.key, "stars": $0.value] }
        UserDefaults.standard.set(starsData, forKey: starsKey)
        UserDefaults.standard.set(Array(unlockedLevelIDs), forKey: unlockedKey)
        UserDefaults.standard.set(starBalance, forKey: balanceKey)
        UserDefaults.standard.set(Array(ownedStickerIDs), forKey: ownedStickersKey)
        UserDefaults.standard.set(equippedStickerID, forKey: equippedStickerKey)
    }

    private func load() {
        if let raw = UserDefaults.standard.array(forKey: starsKey) as? [[String: Int]] {
            for entry in raw {
                if let id = entry["id"], let stars = entry["stars"] {
                    starsByLevel[id] = stars
                }
            }
        }
        if let raw = UserDefaults.standard.array(forKey: unlockedKey) as? [Int] {
            unlockedLevelIDs = Set(raw)
        }
        unlockedLevelIDs.insert(0)

        starBalance = UserDefaults.standard.integer(forKey: balanceKey)
        if let raw = UserDefaults.standard.array(forKey: ownedStickersKey) as? [String] {
            ownedStickerIDs = Set(raw)
        }
        equippedStickerID = UserDefaults.standard.string(forKey: equippedStickerKey)
    }
}
