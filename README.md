# 🍭 Candy Quest — Learning Adventure

A kids' (ages 6-8) iOS learning game with a Candy Crush-style world map. Instead of
match-3 puzzles, each level asks the child to:

- **Read & Tap** — read a short prompt and tap the matching candy/picture
- **Math (Addition)** — count candy piles and tap the correct sum
- **Math (Subtraction)** — count candy piles and tap the correct difference
- **Drag & Match** — drag a word onto its matching candy emoji
- **Trace** — trace a letter shape with a finger
- **Order Objects** — read a sentence describing an order (by size, color, or
  shape) and tap the objects in that sequence

Completing a level's task awards 1-3 stars and unlocks the next level on the map.

## What's included

This is a complete set of **SwiftUI source files** (iOS 16+, Swift 5.9+), organized
by responsibility:

```
CandyQuest/
├── CandyQuestApp.swift          — App entry point
├── Theme/
│   └── CandyTheme.swift         — Colors, fonts, button/card styles
├── Models/
│   ├── GameModels.swift         — Level & task data structures
│   └── GameData.swift           — Level list + sample content/generators
├── State/
│   └── GameState.swift          — Progress tracking, unlocking, persistence
└── Views/
    ├── ContentView.swift        — Root navigation
    ├── WorldMapView.swift       — Candy trail level map
    ├── LevelNodeView.swift      — Individual candy level button
    ├── LevelContainerView.swift — Routes to the right task view
    ├── SuccessView.swift        — Stars + confetti celebration screen
    ├── ConfettiView.swift       — Confetti particle effect
    └── Tasks/
        ├── ReadingTapView.swift
        ├── MathTaskView.swift
        ├── DragMatchView.swift
        ├── TraceView.swift
        └── OrderObjectsView.swift
```

## How to open this in Xcode

Because a hand-built `.xcodeproj` file is fragile and often fails to open reliably,
the safest path is to let Xcode generate the project file itself, then drop these
source files in — takes about 2 minutes:

1. Open **Xcode** → **File → New → Project…**
2. Choose **iOS → App**, click Next.
3. Product Name: `CandyQuest`. Interface: **SwiftUI**. Language: **Swift**.
   Leave "Use Core Data" and "Include Tests" unchecked (not needed).
4. Save it anywhere you like.
5. In the Xcode project navigator, **delete** the default `ContentView.swift`
   that Xcode generates (Move to Trash).
6. Drag the entire `CandyQuest` folder from this download (all the `.swift`
   files and subfolders) into your Xcode project navigator. When prompted,
   check **"Copy items if needed"** and **"Create groups."**
7. Select the top-level project → your target → **General** tab →
   set **Minimum Deployments** to **iOS 16.0** (needed for `NavigationStack`,
   `.draggable`, and `.dropDestination`).
8. Press **Run** (▶) with an iPhone simulator selected (e.g. iPhone 15).

That's it — the world map should appear with the first level unlocked.

## Customizing content

- **More/different levels:** the level list is procedurally generated in
  `GameData.generateLevels(count:)` — currently set to 200 via
  `GameData.totalLevelCount`. Categories cycle through a fixed rotation
  (addition → reading → subtraction → drag-match → trace → order-objects) and
  difficulty ramps up in thirds across the map. Titles are pulled from a
  themed word bank per category in `titleBanks`; add more entries there for
  more variety before titles start repeating with a round number. To change
  the total level count, just edit `totalLevelCount`.
- **Math difficulty:** tweak the `maxNum` switch in
  `GameData.mathProblem(for:)`.
- **Reading/drag-match/trace content:** add more entries to the pools in
  `GameData.swift` — they cycle based on level id, so adding more variety
  avoids repeats as kids replay.
- **Colors/theme:** all colors and fonts live in `Theme/CandyTheme.swift`.
- **Stars/scoring:** each task view awards 3 stars for a first-try correct
  answer, fewer for retries — logic lives at the bottom of each task view.

## Notes

- Progress (stars + unlocked levels) is saved locally via `UserDefaults`, so
  it persists between app launches.
- No external dependencies — pure SwiftUI, no third-party packages.
- Art currently uses system emoji for a fast, colorful placeholder look.
  Swap `Text("🍬")` calls for custom image assets anytime for a more
  polished/branded look.
