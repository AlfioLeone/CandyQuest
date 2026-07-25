import SwiftUI
import Combine

/// Lets views in different tabs coordinate simple navigation — currently just
/// which bottom tab is selected, so the map's character avatar can jump
/// straight to the Character/Sticker Shop tab when tapped.
final class AppNavigation: ObservableObject {
    @Published var selectedTab: Int = 0
}
