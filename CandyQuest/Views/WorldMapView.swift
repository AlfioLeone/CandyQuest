import SwiftUI

struct WorldMapView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var navigation: AppNavigation
    var onSelectLevel: (GameLevel) -> Void

    private let rowHeight: CGFloat = 150

    /// The generated background art is 285×1024 — this is height/width, used
    /// to size each tile so the image repeats without distorting.
    private let backgroundImageAspect: CGFloat = 1024.0 / 285.0

    var body: some View {
        ZStack {
            CandyTheme.mapBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header

                    ZStack {
                        imageBackgroundLayer
                        pathLine
                        LazyVStack(spacing: 0) {
                            ForEach(Array(GameData.levels.enumerated()), id: \.element.id) { index, level in
                                rowContent(index: index, level: level)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private var totalHeight: CGFloat {
        CGFloat(GameData.levels.count) * rowHeight
    }

    private func rowContent(index: Int, level: GameLevel) -> some View {
        HStack {
            if index % 2 == 0 { Spacer() }
            LevelNodeView(
                level: level,
                isUnlocked: gameState.isUnlocked(level),
                stars: gameState.stars(for: level)
            ) {
                if gameState.isUnlocked(level) {
                    onSelectLevel(level)
                }
            }
            if index % 2 != 0 { Spacer() }
        }
        .padding(.horizontal, 50)
        .frame(height: rowHeight)
    }

    /// The hand-generated candy-land art, tiled vertically to cover the whole
    /// scrolling map. It repeats every `tileHeight` — since the source art is
    /// a single tall illustration rather than a seamless texture, repeats
    /// will have a visible seam; that's an inherent tradeoff of tiling a
    /// one-off illustration versus a purpose-made seamless texture.
    private var imageBackgroundLayer: some View {
        GeometryReader { geo in
            let tileHeight = geo.size.width * backgroundImageAspect
            let tileCount = max(1, Int(ceil(totalHeight / tileHeight)))
            VStack(spacing: 0) {
                ForEach(0..<tileCount, id: \.self) { _ in
                    Image("MapBackground")
                        .resizable()
                        .frame(width: geo.size.width, height: tileHeight)
                }
            }
        }
        .frame(height: totalHeight)
        .clipped()
        .allowsHitTesting(false)
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                characterAvatar
                Text("🍭 Candy Quest 🍭")
                    .font(.candyTitle(34))
                    .foregroundColor(CandyTheme.purple)
            }
            HStack(spacing: 6) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text("\(gameState.starBalance) stars")
                    .font(.candyBody(18))
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 12)
    }

    /// The child's current character (equipped sticker) — tapping it jumps to
    /// the Character tab so they can change it or buy a new one.
    private var characterAvatar: some View {
        let equipped = gameState.equippedSticker
        return Button {
            navigation.selectedTab = 1
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 46, height: 46)
                    .overlay(Circle().stroke(CandyTheme.hotPink, lineWidth: 2.5))
                    .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
                Text(equipped?.emoji ?? "❓")
                    .font(.system(size: equipped == nil ? 20 : 26))
                    .opacity(equipped == nil ? 0.4 : 1)
            }
        }
        .buttonStyle(.plain)
    }

    /// A candy-cane-striped zig-zag trail behind the level nodes — this is the
    /// actual tappable route, layered on top of the illustrated background
    /// since the artwork's own painted path won't line up with node positions.
    private var pathLine: some View {
        GeometryReader { geo in
            let trail = Path { path in
                let count = GameData.levels.count
                for index in 0..<count {
                    let x = index % 2 == 0 ? geo.size.width * 0.72 : geo.size.width * 0.28
                    let y = CGFloat(index) * rowHeight + rowHeight / 2
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            ZStack {
                trail.stroke(CandyTheme.purple.opacity(0.85), style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))
                trail.stroke(CandyTheme.hotPink.opacity(0.9), style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                trail.stroke(Color.white.opacity(0.85), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [16, 16]))
            }
        }
        .frame(height: totalHeight)
    }
}
