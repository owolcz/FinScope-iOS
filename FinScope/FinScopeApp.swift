import SwiftUI

@main
struct FinScopeApp: App {

    init() {
        let navBg = UIColor(red: 0.039, green: 0.086, blue: 0.157, alpha: 1)
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = navBg
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(red: 0.039, green: 0.086, blue: 0.157, alpha: 1)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        UISegmentedControl.appearance().selectedSegmentTintColor =
            UIColor(red: 0.957, green: 0.784, blue: 0.259, alpha: 1)
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white], for: .normal)
        UISegmentedControl.appearance().backgroundColor =
            UIColor(red: 0.059, green: 0.118, blue: 0.220, alpha: 1)
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                MarketView()
                    .tabItem {
                        Label("Rynek", systemImage: "chart.line.uptrend.xyaxis")
                    }
                CategoryView()
                    .tabItem {
                        Label("Kategoria", systemImage: "square.grid.2x2")
                    }
                SearchView()
                    .tabItem {
                        Label("Szukaj", systemImage: "magnifyingglass")
                    }
            }
            .tint(Color.fsAccent)
            .preferredColorScheme(.dark)
        }
    }
}
