import SwiftUI

/// The app's launch splash: a candy castle scene with a cheering cookie
/// mascot and an animated "loading" bar, shown for a couple of seconds
/// before handing off to `MainTabView`. Purely decorative/branding — it
/// does not gate on any real async work since `GameState` loads
/// synchronously from `UserDefaults`.
struct SplashScreenView: View {
    var onFinished: () -> Void

    @State private var progress: CGFloat = 0
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var mascotOpacity: Double = 0
    @State private var mascotBob: CGFloat = 0
    @State private var sparkle: Double = 0.4

    private let cream = Color(red: 1.0, green: 0.953, blue: 0.839)
    private let caramel = Color(red: 0.867, green: 0.631, blue: 0.369)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundSky

                VStack(spacing: 0) {
                    Spacer().frame(height: max(geo.safeAreaInsets.top, 24) + 20)

                    TitleBanner()
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)

                    Spacer(minLength: 12)

                    VStack(spacing: 0) {
                        CastleView()
                            .frame(height: geo.size.height * 0.26)

                        ZStack {
                            CrowdView()
                                .opacity(mascotOpacity)

                            MascotView(bob: mascotBob)
                                .frame(width: 230, height: 290)
                                .opacity(mascotOpacity)
                        }
                        .offset(y: -16)
                    }

                    Spacer(minLength: 16)
                }

                VStack {
                    Spacer()
                    LoadingPanel(progress: progress, cream: cream)
                        .frame(height: geo.size.height * 0.17)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { animateIn() }
    }

    private var backgroundSky: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.765, blue: 0.867),
                    Color(red: 0.953, green: 0.839, blue: 0.980),
                    Color(red: 1.0, green: 0.953, blue: 0.839)
                ],
                startPoint: .top, endPoint: .bottom
            )

            RadialGradient(
                colors: [Color.white.opacity(0.55 * sparkle + 0.3), Color.white.opacity(0)],
                center: .init(x: 0.5, y: 0.32), startRadius: 10, endRadius: 420
            )

            SparkleField(twinkle: sparkle)
            CloudCluster().offset(x: -110, y: -260)
            CloudCluster().offset(x: 120, y: -190).scaleEffect(0.8)
        }
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.65, dampingFraction: 0.65)) {
            titleScale = 1
            titleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.25)) {
            mascotOpacity = 1
        }
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
            mascotBob = -10
        }
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
            sparkle = 1.0
        }
        withAnimation(.easeInOut(duration: 1.5).delay(0.2)) {
            progress = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
            onFinished()
        }
    }
}

// MARK: - Title

private struct TitleBanner: View {
    private let cream = Color(red: 1.0, green: 0.953, blue: 0.839)

    var body: some View {
        ZStack {
            HStack {
                RibbonTail()
                    .fill(CandyTheme.jelloRed)
                    .overlay(RibbonTail().stroke(CandyTheme.chocolateDark, lineWidth: 3))
                    .frame(width: 30, height: 66)
                Spacer()
                RibbonTail()
                    .scale(x: -1, y: 1)
                    .fill(CandyTheme.jelloRed)
                    .overlay(RibbonTail().scale(x: -1, y: 1).stroke(CandyTheme.chocolateDark, lineWidth: 3))
                    .frame(width: 30, height: 66)
            }

            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(CandyTheme.hotPink)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(CandyTheme.chocolateDark, lineWidth: 4)
                )
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.35))
                        .frame(height: 8)
                        .padding(.horizontal, 22)
                        .padding(.top, 10)
                }
                .frame(height: 70)
                .padding(.horizontal, 30)

            OutlinedText("Candy Quest", size: 38, fill: cream, stroke: CandyTheme.chocolateDark)
        }
        .frame(height: 74)
    }
}

/// A rectangle with a triangular notch cut from its trailing edge,
/// producing a ribbon "swallowtail" end.
private struct RibbonTail: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.55, y: rect.midY))
        p.closeSubpath()
        return p
    }
}

/// Draws `text` twice — a thick stroke-colored copy fanned out in 8
/// directions behind a solid fill copy — to fake a text outline, which
/// SwiftUI's `Text` has no native support for.
private struct OutlinedText: View {
    let text: String
    var size: CGFloat
    var fill: Color
    var stroke: Color
    var weight: Font.Weight = .heavy

    init(_ text: String, size: CGFloat, fill: Color, stroke: Color, weight: Font.Weight = .heavy) {
        self.text = text
        self.size = size
        self.fill = fill
        self.stroke = stroke
        self.weight = weight
    }

    private var offsets: [CGSize] {
        let d = max(1, size * 0.035)
        return [
            CGSize(width: d, height: 0), CGSize(width: -d, height: 0),
            CGSize(width: 0, height: d), CGSize(width: 0, height: -d),
            CGSize(width: d, height: d), CGSize(width: -d, height: d),
            CGSize(width: d, height: -d), CGSize(width: -d, height: -d)
        ]
    }

    var body: some View {
        ZStack {
            ForEach(0..<offsets.count, id: \.self) { i in
                Text(text)
                    .font(.system(size: size, weight: weight, design: .rounded))
                    .foregroundColor(stroke)
                    .offset(offsets[i])
            }
            Text(text)
                .font(.system(size: size, weight: weight, design: .rounded))
                .foregroundColor(fill)
        }
        .fixedSize()
    }
}

// MARK: - Castle

private struct CastleView: View {
    private let caramel = Color(red: 0.867, green: 0.631, blue: 0.369)

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(alignment: .bottom, spacing: -12) {
                CastleTower(width: 54, height: 96, bodyColor: caramel, roofColor: CandyTheme.mint, roofStyle: .dome)
                CastleTower(width: 62, height: 168, bodyColor: caramel, roofColor: CandyTheme.jelloRed, roofStyle: .cone, hasFlag: true)
                CastleTower(width: 54, height: 96, bodyColor: caramel, roofColor: CandyTheme.lavender, roofStyle: .dome)
            }
            .padding(.bottom, 46)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(caramel)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(CandyTheme.chocolateDark, lineWidth: 4)
                )
                .overlay(wallDecor)
                .frame(height: 100)
                .padding(.horizontal, 26)

            DomeCap(color: Color(red: 1.0, green: 0.85, blue: 0.55))
                .frame(width: 62, height: 40)
                .padding(.bottom, 6)

            HStack {
                LollipopCluster(bigColor: CandyTheme.lemon, smallColor: CandyTheme.riverTealLight)
                Spacer()
                LollipopCluster(bigColor: CandyTheme.riverTeal, smallColor: CandyTheme.purple)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 30)
        }
    }

    private var wallDecor: some View {
        HStack(spacing: 60) {
            Circle().fill(CandyTheme.hotPink).frame(width: 20, height: 20)
                .overlay(Circle().stroke(CandyTheme.chocolateDark, lineWidth: 3))
            Circle().fill(CandyTheme.riverTealLight).frame(width: 20, height: 20)
                .overlay(Circle().stroke(CandyTheme.chocolateDark, lineWidth: 3))
        }
        .offset(y: -18)
    }
}

private enum RoofStyle { case cone, dome }

private struct CastleTower: View {
    var width: CGFloat
    var height: CGFloat
    var bodyColor: Color
    var roofColor: Color
    var roofStyle: RoofStyle
    var hasFlag: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if hasFlag {
                Pennant()
                    .frame(width: 22, height: 16)
                    .offset(x: 6)
                Rectangle()
                    .fill(CandyTheme.chocolateDark)
                    .frame(width: 3, height: 20)
            }

            roof
                .frame(width: width, height: width * 0.62)

            Rectangle()
                .fill(bodyColor)
                .overlay(Rectangle().stroke(CandyTheme.chocolateDark, lineWidth: 3))
                .frame(width: width, height: height)
        }
    }

    @ViewBuilder private var roof: some View {
        switch roofStyle {
        case .cone:
            CandyStripes(color1: .white, color2: roofColor, stripeWidth: 7)
                .clipShape(TriangleShape())
                .overlay(TriangleShape().stroke(CandyTheme.chocolateDark, lineWidth: 3))
        case .dome:
            DomeCap(color: roofColor)
        }
    }
}

private struct Pennant: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// A pair of candy-cane-striped lollipop poles (one tall, one short)
/// flanking the castle wall, matching the decoration in the splash art.
private struct LollipopCluster: View {
    var bigColor: Color
    var smallColor: Color

    var body: some View {
        HStack(alignment: .bottom, spacing: -6) {
            LollipopStick(headColor: smallColor, headSize: 30, stickHeight: 40)
            LollipopStick(headColor: bigColor, headSize: 42, stickHeight: 56)
        }
    }
}

private struct LollipopStick: View {
    var headColor: Color
    var headSize: CGFloat
    var stickHeight: CGFloat

    var body: some View {
        VStack(spacing: -headSize * 0.18) {
            ZStack {
                Circle().fill(headColor).frame(width: headSize, height: headSize)
                Circle().fill(Color.white.opacity(0.9)).frame(width: headSize * 0.62, height: headSize * 0.62)
                Circle().fill(headColor).frame(width: headSize * 0.32, height: headSize * 0.32)
                Circle().stroke(CandyTheme.chocolateDark, lineWidth: 3).frame(width: headSize, height: headSize)
            }
            CandyStripes(color1: .white, color2: CandyTheme.jelloRed, stripeWidth: 4)
                .frame(width: 9, height: stickHeight)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(CandyTheme.chocolateDark, lineWidth: 2))
        }
    }
}

// MARK: - Crowd

/// The cheering crowd of small candy-people scattered around the mascot,
/// each a round body with crossed candy-cane limbs and a googly-eyed face.
private struct CrowdView: View {
    private struct Figure {
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var color: Color
    }

    private let figures: [Figure] = [
        Figure(x: -148, y: -6, scale: 0.55, color: CandyTheme.riverTeal),
        Figure(x: -100, y: 38, scale: 0.7, color: CandyTheme.lemon),
        Figure(x: -168, y: 62, scale: 0.85, color: CandyTheme.purple),
        Figure(x: -112, y: 108, scale: 0.95, color: CandyTheme.jelloRed),
        Figure(x: 148, y: -6, scale: 0.55, color: CandyTheme.riverTealLight),
        Figure(x: 100, y: 34, scale: 0.7, color: CandyTheme.hotPink),
        Figure(x: 168, y: 60, scale: 0.85, color: CandyTheme.jelloRed),
        Figure(x: 112, y: 106, scale: 1.0, color: CandyTheme.riverTeal)
    ]

    var body: some View {
        ZStack {
            ForEach(0..<figures.count, id: \.self) { i in
                let f = figures[i]
                CandyPersonView(color: f.color)
                    .scaleEffect(f.scale)
                    .offset(x: f.x, y: f.y)
            }
        }
    }
}

private struct CandyPersonView: View {
    var color: Color

    var body: some View {
        ZStack {
            HStack(spacing: 30) {
                MittenLimb(color: color).scaleEffect(0.4).rotationEffect(.degrees(-105))
                MittenLimb(color: color).scaleEffect(0.4).rotationEffect(.degrees(105))
            }
            .offset(y: -8)

            HStack(spacing: 22) {
                MittenLimb(color: color).scaleEffect(0.4).rotationEffect(.degrees(24))
                MittenLimb(color: color).scaleEffect(0.4).rotationEffect(.degrees(-24))
            }
            .offset(y: 22)

            Circle()
                .fill(color)
                .frame(width: 42, height: 42)
                .overlay(Circle().stroke(CandyTheme.chocolateDark, lineWidth: 4))

            HStack(spacing: 11) {
                Circle().fill(CandyTheme.chocolateDark).frame(width: 4, height: 4)
                Circle().fill(CandyTheme.chocolateDark).frame(width: 4, height: 4)
            }
            .offset(y: -4)

            HStack(spacing: 20) {
                Circle().fill(Color.white.opacity(0.35)).frame(width: 8, height: 8)
                Circle().fill(Color.white.opacity(0.35)).frame(width: 8, height: 8)
            }
            .offset(y: 2)

            SmileShape()
                .stroke(CandyTheme.chocolateDark, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .frame(width: 13, height: 6)
                .offset(y: 6)
        }
        .frame(width: 64, height: 70)
    }
}

/// A full circle positioned so its bottom edge sits at the bottom of its
/// frame, then clipped by that (shorter) frame — a cheap way to get a
/// dome/half-circle cap without hand-rolling arc math.
private struct DomeCap: View {
    var color: Color
    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(color)
                .overlay(Circle().stroke(CandyTheme.chocolateDark, lineWidth: 3))
                .frame(width: geo.size.width, height: geo.size.width)
                .position(x: geo.size.width / 2, y: geo.size.height)
        }
        .clipped()
    }
}

private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// Diagonal candy-cane stripes, drawn once into whatever bounds it's
/// given — meant to be `.clipShape`d by the caller.
private struct CandyStripes: View {
    var color1: Color
    var color2: Color
    var stripeWidth: CGFloat

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(color1))
            let diagonal = (size.width + size.height)
            var x: CGFloat = -diagonal
            while x < diagonal {
                var stripe = Path()
                stripe.move(to: CGPoint(x: x, y: -diagonal))
                stripe.addLine(to: CGPoint(x: x + stripeWidth, y: -diagonal))
                stripe.addLine(to: CGPoint(x: x + stripeWidth + diagonal, y: diagonal))
                stripe.addLine(to: CGPoint(x: x + diagonal, y: diagonal))
                stripe.closeSubpath()
                context.fill(stripe, with: .color(color2))
                x += stripeWidth * 2
            }
        }
    }
}

// MARK: - Mascot

private struct MascotView: View {
    var bob: CGFloat
    private let caramel = Color(red: 0.867, green: 0.631, blue: 0.369)
    private let cream = Color(red: 1.0, green: 0.953, blue: 0.839)

    var body: some View {
        ZStack {
            // legs
            HStack(spacing: 34) {
                StripedLimb(length: 30, thickness: 13)
                    .rotationEffect(.degrees(20))
                StripedLimb(length: 30, thickness: 13)
                    .rotationEffect(.degrees(-20))
            }
            .offset(y: 62)

            // torso
            Ellipse()
                .fill(caramel)
                .frame(width: 122, height: 98)
                .overlay(Ellipse().stroke(CandyTheme.chocolateDark, lineWidth: 5))
                .overlay(chips)

            // arms raised in a cheer, pivoting from the shoulder so they
            // stay planted on the torso instead of swinging free of it
            RaisedArm(length: 78, thickness: 14)
                .rotationEffect(.degrees(-16), anchor: .bottom)
                .offset(x: -40, y: -68.5)
            RaisedArm(length: 78, thickness: 14)
                .rotationEffect(.degrees(16), anchor: .bottom)
                .offset(x: 40, y: -68.5)

            // cupcake-liner collar
            LinerCollar(cream: cream)
                .offset(y: -54)

            // frosting swirl: narrow at top, widest at the base
            VStack(spacing: -10) {
                frostingTier(width: 34, height: 28)
                frostingTier(width: 50, height: 34)
                frostingTier(width: 72, height: 40)
            }
            .offset(y: -96)

            face

            // cherry + stem
            ZStack {
                Capsule()
                    .fill(Color(red: 0.35, green: 0.56, blue: 0.32))
                    .frame(width: 5, height: 16)
                    .rotationEffect(.degrees(-20))
                    .offset(x: -3, y: -8)
                Circle()
                    .fill(CandyTheme.jelloRed)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(CandyTheme.chocolateDark, lineWidth: 3))
            }
            .offset(y: -146)
        }
        .offset(y: bob)
    }

    private func frostingTier(width: CGFloat, height: CGFloat) -> some View {
        Ellipse()
            .fill(CandyTheme.hotPink)
            .frame(width: width, height: height)
            .overlay(Ellipse().stroke(CandyTheme.chocolateDark, lineWidth: 3))
    }

    private var chips: some View {
        ZStack {
            Circle().fill(CandyTheme.chocolate).frame(width: 8, height: 8).offset(x: -34, y: -12)
            Circle().fill(CandyTheme.chocolate).frame(width: 7, height: 7).offset(x: 32, y: -4)
            Circle().fill(CandyTheme.chocolate).frame(width: 7, height: 7).offset(x: -12, y: 26)
            Circle().fill(CandyTheme.chocolate).frame(width: 8, height: 8).offset(x: 28, y: 24)
        }
    }

    private var face: some View {
        ZStack {
            HStack(spacing: 30) {
                Circle().fill(CandyTheme.chocolateDark).frame(width: 8, height: 8)
                Circle().fill(CandyTheme.chocolateDark).frame(width: 8, height: 8)
            }
            .offset(y: -80)

            HStack(spacing: 50) {
                Circle().fill(CandyTheme.jelloRed.opacity(0.4)).frame(width: 14, height: 14)
                Circle().fill(CandyTheme.jelloRed.opacity(0.4)).frame(width: 14, height: 14)
            }
            .offset(y: -70)

            SmileShape()
                .stroke(CandyTheme.chocolateDark, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 22, height: 10)
                .offset(y: -66)
        }
    }
}

/// The small cupcake-wrapper collar between the mascot's cookie body and
/// its frosting swirl, matching the striped paper liner in the splash art.
private struct LinerCollar: View {
    var cream: Color

    var body: some View {
        LinerShape()
            .fill(cream)
            .overlay(
                CandyStripes(color1: cream, color2: CandyTheme.pink, stripeWidth: 6)
                    .clipShape(LinerShape())
                    .opacity(0.8)
            )
            .overlay(LinerShape().stroke(CandyTheme.chocolateDark, lineWidth: 3))
            .frame(width: 62, height: 28)
    }
}

private struct LinerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// A candy-cane-striped limb with a white mitten-shaped tip — used for the
/// hero mascot's arms and legs (the crowd uses the plain `MittenLimb`).
private struct StripedLimb: View {
    var length: CGFloat
    var thickness: CGFloat

    var body: some View {
        VStack(spacing: -6) {
            CandyStripes(color1: .white, color2: CandyTheme.jelloRed, stripeWidth: 4)
                .frame(width: thickness, height: length)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(CandyTheme.chocolateDark, lineWidth: 2.5))
            Circle()
                .fill(Color(red: 1.0, green: 0.953, blue: 0.839))
                .frame(width: thickness * 1.5, height: thickness * 1.5)
                .overlay(Circle().stroke(CandyTheme.chocolateDark, lineWidth: 2.5))
                .overlay(Circle().fill(CandyTheme.jelloRed).frame(width: thickness * 0.55, height: thickness * 0.55))
        }
    }
}

/// Like `StripedLimb` but mitten-end up, bone-end down — so it can pivot
/// from its base (the shoulder) and read as an arm raised overhead rather
/// than one hanging from a fixed midpoint.
private struct RaisedArm: View {
    var length: CGFloat
    var thickness: CGFloat

    var body: some View {
        VStack(spacing: -6) {
            Circle()
                .fill(Color(red: 1.0, green: 0.953, blue: 0.839))
                .frame(width: thickness * 1.5, height: thickness * 1.5)
                .overlay(Circle().stroke(CandyTheme.chocolateDark, lineWidth: 2.5))
                .overlay(Circle().fill(CandyTheme.jelloRed).frame(width: thickness * 0.55, height: thickness * 0.55))
            CandyStripes(color1: .white, color2: CandyTheme.jelloRed, stripeWidth: 4)
                .frame(width: thickness, height: length)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(CandyTheme.chocolateDark, lineWidth: 2.5))
        }
    }
}

private struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX, y: rect.maxY))
        return p
    }
}

private struct MittenLimb: View {
    var color: Color
    private let cream = Color(red: 1.0, green: 0.953, blue: 0.839)

    var body: some View {
        VStack(spacing: -6) {
            Capsule()
                .fill(color)
                .overlay(Capsule().stroke(CandyTheme.chocolateDark, lineWidth: 3))
                .frame(width: 15, height: 46)
            Circle()
                .fill(cream)
                .overlay(Circle().stroke(CandyTheme.chocolateDark, lineWidth: 3))
                .overlay(Circle().fill(color).frame(width: 9, height: 9))
                .frame(width: 24, height: 24)
        }
    }
}

// MARK: - Sky decoration

private struct SparkleField: View {
    var twinkle: Double
    private let positions: [(CGFloat, CGFloat, CGFloat)] = [
        (-140, -300, 0.85), (150, -330, 0.6), (-160, -120, 0.7), (170, -80, 0.5), (-100, 40, 0.4)
    ]

    var body: some View {
        ZStack {
            ForEach(0..<positions.count, id: \.self) { i in
                let p = positions[i]
                Star4Shape()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .opacity(twinkle * p.2)
                    .offset(x: p.0, y: p.1)
            }
        }
    }
}

private struct Star4Shape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let cx = rect.midX, cy = rect.midY
        var p = Path()
        p.move(to: CGPoint(x: cx, y: cy - h / 2))
        p.addCurve(to: CGPoint(x: cx + w / 2, y: cy),
                   control1: CGPoint(x: cx + w * 0.15, y: cy - h * 0.3),
                   control2: CGPoint(x: cx + w * 0.3, y: cy - h * 0.15))
        p.addCurve(to: CGPoint(x: cx, y: cy + h / 2),
                   control1: CGPoint(x: cx + w * 0.3, y: cy + h * 0.15),
                   control2: CGPoint(x: cx + w * 0.15, y: cy + h * 0.3))
        p.addCurve(to: CGPoint(x: cx - w / 2, y: cy),
                   control1: CGPoint(x: cx - w * 0.15, y: cy + h * 0.3),
                   control2: CGPoint(x: cx - w * 0.3, y: cy + h * 0.15))
        p.addCurve(to: CGPoint(x: cx, y: cy - h / 2),
                   control1: CGPoint(x: cx - w * 0.3, y: cy - h * 0.15),
                   control2: CGPoint(x: cx - w * 0.15, y: cy - h * 0.3))
        p.closeSubpath()
        return p
    }
}

private struct CloudCluster: View {
    var body: some View {
        ZStack {
            Ellipse().fill(Color.white.opacity(0.85)).frame(width: 130, height: 56)
            Ellipse().fill(Color.white.opacity(0.85)).frame(width: 90, height: 46).offset(x: 50, y: -8)
            Ellipse().fill(Color.white.opacity(0.85)).frame(width: 76, height: 40).offset(x: -55, y: -6)
        }
    }
}

// MARK: - Loading panel

private struct LoadingPanel: View {
    var progress: CGFloat
    var cream: Color

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.478, green: 0.231, blue: 0.361), Color(red: 0.235, green: 0.122, blue: 0.188)],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    gumdrop(CandyTheme.riverTealLight, size: 20)
                    gumdrop(CandyTheme.lemon, size: 24)
                    gumdrop(CandyTheme.lavender, size: 20)
                }
                .padding(.top, 22)

                ZStack(alignment: .leading) {
                    Capsule().fill(cream).frame(height: 22)
                    GeometryReader { geo in
                        Capsule()
                            .fill(CandyTheme.hotPink)
                            .frame(width: max(22, geo.size.width * progress), height: 22)
                    }
                    .frame(height: 22)
                }
                .overlay(Capsule().stroke(CandyTheme.chocolateDark, lineWidth: 4))
                .padding(.horizontal, 40)

                OutlinedTextSmall("Loading your sweet adventure…", cream: cream)
            }
        }
    }

    private func gumdrop(_ color: Color, size: CGFloat) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .overlay(Circle().stroke(Color(red: 0.235, green: 0.122, blue: 0.188), lineWidth: 4))
    }
}

private struct OutlinedTextSmall: View {
    let text: String
    var cream: Color

    init(_ text: String, cream: Color) {
        self.text = text
        self.cream = cream
    }

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(cream)
            .shadow(color: Color(red: 0.235, green: 0.122, blue: 0.188), radius: 0, x: 1, y: 1)
    }
}
