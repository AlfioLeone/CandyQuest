import SwiftUI

struct StickerStoreView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            CandyTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    characterShowcase

                    Text("All Stickers")
                        .font(.candyBody(16))
                        .foregroundColor(.black.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 16)], spacing: 20) {
                        ForEach(GameData.stickerCatalog) { sticker in
                            StickerTile(sticker: sticker)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Your Character")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("🎁 Sticker Shop 🎁")
                .font(.candyTitle(30))
                .foregroundColor(CandyTheme.purple)
            HStack(spacing: 6) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text("\(gameState.starBalance) stars to spend")
                    .font(.candyBody(16))
                    .foregroundColor(.gray)
            }
            Text("Earn stars by completing levels, then pick a sticker to be your character!")
                .font(.candyBody(13))
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding(.top, 20)
    }

    /// A large hero card showing whichever sticker is currently equipped as
    /// the child's "character" — this is what shows up on the map too.
    private var characterShowcase: some View {
        let equipped = gameState.equippedSticker

        return VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(CandyTheme.mapBackground)
                    .frame(width: 140, height: 140)
                    .overlay(Circle().stroke(CandyTheme.hotPink, lineWidth: 4))
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 4)

                if let equipped {
                    Text(equipped.emoji)
                        .font(.system(size: 70))
                } else {
                    Text("❓")
                        .font(.system(size: 56))
                        .opacity(0.4)
                }
            }

            Text(equipped?.name ?? "No character yet")
                .font(.candyTitle(18))
                .foregroundColor(.black.opacity(0.75))

            if equipped == nil {
                Text("Buy a sticker below and tap \"Use\" to make it your character!")
                    .font(.candyBody(13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.vertical, 16)
    }
}

private struct StickerTile: View {
    @EnvironmentObject var gameState: GameState
    let sticker: Sticker

    private var isOwned: Bool { gameState.isOwned(sticker) }
    private var isEquipped: Bool { gameState.equippedStickerID == sticker.id }
    private var canAfford: Bool { gameState.starBalance >= sticker.cost }

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Text(sticker.emoji)
                    .font(.system(size: 42))
                    .frame(width: 88, height: 88)
                    .background(
                        CandyCardBackground(color: isEquipped ? .green : (isOwned ? CandyTheme.mint : CandyTheme.lavender))
                    )
                    .opacity(isOwned || canAfford ? 1 : 0.6)

                if isEquipped {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                        .background(Circle().fill(.white))
                        .offset(x: 4, y: -4)
                }
            }

            Text(sticker.name)
                .font(.candyBody(13))
                .foregroundColor(.black.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)

            actionButton
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if isEquipped {
            Text("Equipped")
                .font(.candyBody(12))
                .foregroundColor(.green)
                .padding(.vertical, 8)
        } else if isOwned {
            Button("Use") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    gameState.equip(sticker)
                }
            }
            .buttonStyle(SmallCandyButtonStyle(color: CandyTheme.purple))
        } else {
            Button {
                gameState.purchase(sticker)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                    Text("\(sticker.cost)")
                }
            }
            .buttonStyle(SmallCandyButtonStyle(color: canAfford ? CandyTheme.hotPink : .gray))
            .disabled(!canAfford)
        }
    }
}
