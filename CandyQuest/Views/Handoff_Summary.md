//
//  ContentView.swift
//  CandyQuest
//
//  Created by Steven Curtis on 28/02/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = Store()
    @State private var showSuccess = false
    @State private var showGoals = false
    @State private var levelId: UUID?
    
    var body: some View {
        NavigationStack(path: $store.path) {
            ZStack {
                RandomBackground()
                BackgroundContrastOverlay()
                LevelContainerView(level: store.level) { stars in
                    store.level.stars = stars
                    if stars > 0 { showSuccess = true }
                }
                .navigationDestination(for: Level.self) { level in
                    ZStack {
                        RandomBackground()
                        BackgroundContrastOverlay()
                        LevelContainerView(level: level) { stars in
                            store.update(level: level, stars: stars)
                            if stars > 0 { showSuccess = true }
                        }
                    }
                }
                .toolbar {
                    Button("Goals") { showGoals.toggle() }
                }
                .fullScreenCover(isPresented: $showSuccess) {
                    ZStack {
                        RandomBackground()
                        BackgroundContrastOverlay()
                        SuccessView()
                    }
                }
                .sheet(isPresented: $showGoals) {
                    ZStack {
                        RandomBackground()
                        BackgroundContrastOverlay()
                        GoalsScreen()
                    }
                }
            }
        }
    }
}

struct RandomBackground: View {
    private static let imageNames: [String] = [
        "Bubble_valley", "Candy_Future", "Candy_Trail", "candyQuestMapBackground.png",
        "Chocolate_Lolli_River", "Cotton_Candy_Forest", "Dark_Chocolate_Lolli_River",
        "Jaw_Breaker_Storm", "Licoriche_cave", "Lollipop_Valley", "Rock_Candy_Cavern", "Sugar_Sand"
    ]
    private let chosenName: String = imageNames.randomElement() ?? "Bubble_valley"
    var body: some View {
        Image(chosenName)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

struct BackgroundContrastOverlay: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.45), Color.black.opacity(0.25), Color.black.opacity(0.45)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
