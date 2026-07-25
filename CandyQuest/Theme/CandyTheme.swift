import SwiftUI

enum CandyTheme {
    static let pink = Color(red: 1.0, green: 0.75, blue: 0.85)
    static let hotPink = Color(red: 1.0, green: 0.45, blue: 0.65)
    static let mint = Color(red: 0.68, green: 0.93, blue: 0.85)
    static let lavender = Color(red: 0.82, green: 0.78, blue: 1.0)
    static let lemon = Color(red: 1.0, green: 0.93, blue: 0.6)
    static let purple = Color(red: 0.62, green: 0.45, blue: 0.9)
    static let sky = Color(red: 0.75, green: 0.9, blue: 1.0)
    static let grass = Color(red: 0.7, green: 0.9, blue: 0.65)
    static let treeGreen = Color(red: 0.45, green: 0.75, blue: 0.45)
    static let marshmallow = Color(red: 1.0, green: 0.98, blue: 0.95)
    static let chocolate = Color(red: 0.42, green: 0.26, blue: 0.15)
    static let chocolateDark = Color(red: 0.3, green: 0.17, blue: 0.09)
    static let jelloRed = Color(red: 1.0, green: 0.35, blue: 0.45)
    static let jelloGreen = Color(red: 0.4, green: 0.85, blue: 0.55)
    static let jelloBlue = Color(red: 0.4, green: 0.6, blue: 1.0)
    static let riverTeal = Color(red: 0.15, green: 0.78, blue: 0.75)
    static let riverTealLight = Color(red: 0.55, green: 0.95, blue: 0.9)
    static let background = LinearGradient(
        colors: [Color(red: 1.0, green: 0.94, blue: 0.97), Color(red: 0.93, green: 0.96, blue: 1.0)],
        startPoint: .top, endPoint: .bottom
    )
    /// A soft pastel sky gradient — blue up top drifting into a gentle
    /// pink haze — used behind the world map.
    static let mapBackground = LinearGradient(
        colors: [
            Color(red: 0.68, green: 0.85, blue: 0.98),
            Color(red: 0.88, green: 0.85, blue: 0.97),
            Color(red: 0.98, green: 0.85, blue: 0.9),
        ],
        startPoint: .top, endPoint: .bottom
    )

    static func color(for category: TaskCategory) -> Color {
        switch category {
        case .readingTap: return hotPink
        case .mathAddition, .mathSubtraction: return purple
        case .dragMatch: return mint.opacity(1)
        case .trace: return lemon
        case .orderObjects: return sky
        case .oddOneOut: return mint.opacity(1)
        }
    }

    static func emoji(for category: TaskCategory) -> String {
        switch category {
        case .readingTap: return "🍭"
        case .mathAddition: return "🍬"
        case .mathSubtraction: return "🍩"
        case .dragMatch: return "🧁"
        case .trace: return "🍫"
        case .orderObjects: return "🔢"
        case .oddOneOut: return "🔢"
        }
    }
}

extension Font {
    static func candyTitle(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    static func candyBody(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
}

struct CandyButtonStyle: ButtonStyle {
    var color: Color = CandyTheme.hotPink
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.candyBody(20))
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color)
                    .shadow(color: color.opacity(0.5), radius: configuration.isPressed ? 2 : 6, y: configuration.isPressed ? 1 : 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct CandyCardBackground: View {
    var color: Color
    var body: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(color.opacity(0.25))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(color, lineWidth: 3)
            )
    }
}

/// A smaller pill-shaped button, used where CandyButtonStyle would be too large
/// (e.g. inside grid tiles in the sticker shop).
struct SmallCandyButtonStyle: ButtonStyle {
    var color: Color = CandyTheme.hotPink
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.candyBody(13))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(color)
                    .shadow(color: color.opacity(0.4), radius: configuration.isPressed ? 1 : 3, y: configuration.isPressed ? 1 : 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
