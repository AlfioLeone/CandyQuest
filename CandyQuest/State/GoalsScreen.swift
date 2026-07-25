import SwiftUI

struct GoalsScreen: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(gameState.metaGoals) { goal in
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(goal.description)
                                .font(.headline)
                            ProgressView(value: Float(goal.progress), total: Float(goal.target))
                                .frame(maxWidth: 180)
                            HStack(spacing: 8) {
                                Text("Progress: \(goal.progress)/\(goal.target)")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                if goal.isComplete {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "star")
                                .foregroundColor(.yellow)
                            Text("Reward: \(goal.rewardStars)")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.vertical, 5)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Goals & Rewards")
        }
    }
}

#Preview {
    GoalsScreen(gameState: GameState())
}
