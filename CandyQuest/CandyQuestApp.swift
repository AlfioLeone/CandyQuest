import SwiftUI

@main
struct CandyQuestApp: App {
    @StateObject private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(gameState)
                .preferredColorScheme(.light)
        }
    }
}
