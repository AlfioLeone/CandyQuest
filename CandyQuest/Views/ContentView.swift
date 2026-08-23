import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState
    @State private var activeLevel: GameLevel? = nil
    @State private var completedLevel: (level: GameLevel, stars: Int)? = nil
    @State private var showingGoals = false

    var body: some View {
        NavigationStack {
            WorldMapView(onSelectLevel: { level in
                activeLevel = level
            })
            .navigationDestination(item: $activeLevel) { level in
                ZStack {
                    RandomBackground()
                    BackgroundContrastOverlay()
                    LevelContainerView(level: level) { stars in
                        gameState.completeLevel(level, stars: stars)
                        activeLevel = nil
                        completedLevel = (level, stars)
                    }
                }
            }
            .fullScreenCover(item: Binding(
                get: { completedLevel.map { CompletedWrapper(level: $0.level, stars: $0.stars) } },
                set: { _ in completedLevel = nil }
            )) { wrapper in
                ZStack {
                    RandomBackground()
                    BackgroundContrastOverlay()
                    SuccessView(level: wrapper.level, stars: wrapper.stars) {
                        completedLevel = nil
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingGoals = true }) {
                        Label("Goals", systemImage: "target")
                    }
                }
            }
            .sheet(isPresented: $showingGoals) {
                ZStack {
                    RandomBackground()
                    BackgroundContrastOverlay()
                    GoalsScreen(gameState: gameState)
                }
            }
        }
    }
}

/// Small Identifiable wrapper so fullScreenCover(item:) can work with a tuple-like value.
struct CompletedWrapper: Identifiable {
    let level: GameLevel
    let stars: Int
    var id: Int { level.id }
}

extension GameLevel: Hashable {
    static func == (lhs: GameLevel, rhs: GameLevel) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Random Background

/// A reusable random background view that selects one image per presentation.
struct RandomBackground: View {
    // Exact asset names supplied by the user
    private static let imageNames: [String] = [
        "Bubble_valley",
        "Candy_Future",
        "Candy_Trail",
        "candyQuestMapBackground.png",
        "Chocolate_Lolli_River",
        "Cotton_Candy_Forest",
        "Dark_Chocolate_Lolli_River",
        "Jaw_Breaker_Storm",
        "Licoriche_cave",
        "Lollipop_Valley",
        "Rock_Candy_Cavern",
        "Sugar_Sand"
    ]

    // Pick once per view instantiation to avoid changing on every state update.
    private let chosenName: String = imageNames.randomElement() ?? "Bubble_valley"

    var body: some View {
        // The fill image is placed as an overlay on a Color.clear rather than
        // used directly: an overlay never contributes to its base's layout size,
        // so a wide landscape photo scaled to fill can't inflate the enclosing
        // ZStack's width and push sibling content (e.g. task prompts) off-screen.
        // .clipped() trims the overflow that scaledToFill produces.
        Color.clear
            .overlay {
                Image(chosenName)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

/// A dark gradient overlay to improve text contrast over busy images.
struct BackgroundContrastOverlay: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.45), Color.black.opacity(0.25), Color.black.opacity(0.45)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
