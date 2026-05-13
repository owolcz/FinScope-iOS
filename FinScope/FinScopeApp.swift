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
        let searchBarAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        searchBarAppearance.backgroundColor = UIColor(red: 0.082, green: 0.125, blue: 0.200, alpha: 0.6)
        searchBarAppearance.textColor = .white
        
        UISearchBar.appearance().tintColor = UIColor(red: 0.957, green: 0.784, blue: 0.259, alpha: 1)
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                MarketView()
                    .tabItem {
                        Label("Market", systemImage: "chart.line.uptrend.xyaxis")
                    }
                CategoryView()
                    .tabItem {
                        Label("Categories", systemImage: "square.grid.2x2")
                    }
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
            }
            .tint(Color.fsAccent)
            .preferredColorScheme(.dark)
        }
    }
}
