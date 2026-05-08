//
//  ContentView.swift
//  FinScope
//
//  Created by Justynka  on 03/05/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Zakładka 1: Rynek
            MarketView()
                .tabItem {
                    Label("Rynek", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(0)

            // Zakładka 2: Kategoria
            CategoryView()
                .tabItem {
                    Label("Kategoria", systemImage: "square.grid.2x2")
                }
                .tag(1)

            // Zakładka 3: Szukaj
            SearchStockView()
                .tabItem {
                    Label("Szukaj", systemImage: "magnifyingglass")
                }
                .tag(2)
        }
    }
}
