import SwiftUI

@main
struct CandyQuestApp: App {
    @StateObject private var gameState = GameState()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environmentObject(gameState)

                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
