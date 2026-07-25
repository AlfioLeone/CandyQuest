import SwiftUI

struct MainTabView: View {
    @StateObject private var navigation = AppNavigation()

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            ContentView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(0)

            NavigationStack {
                StickerStoreView()
            }
            .tabItem {
                Label("Character", systemImage: "person.crop.circle.fill")
            }
            .tag(1)
        }
        .tint(CandyTheme.hotPink)
        .environmentObject(navigation)
    }
}
