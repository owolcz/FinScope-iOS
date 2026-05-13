import Foundation
import Combine

struct CategoryGroup: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let symbols: [String]
}

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [CategoryGroup] = [
        CategoryGroup(
            name: "Technology",
            iconName: "laptopcomputer",
            symbols: ["AAPL", "MSFT", "NVDA", "IBM", "ORCL", "UBER"]
        ),
        CategoryGroup(
            name: "Communication Services",
            iconName: "message.fill",
            symbols: ["GOOGL", "META"]
        ),
        CategoryGroup(
            name: "Consumer Cyclical",
            iconName: "cart.fill",
            symbols: ["AMZN", "TSLA"]
        ),
        CategoryGroup(
            name: "Consumer Defensive",
            iconName: "leaf.fill",
            symbols: ["WMT"]
        ),
        CategoryGroup(
            name: "Cryptocurrencies",
            iconName: "bitcoinsign.circle.fill",
            symbols: ["BTC-USD", "ETH-USD", "BNB-USD", "SOL-USD", "XRP-USD", "DOGE-USD", "ADA-USD", "AVAX-USD"]
        ),
        CategoryGroup(
            name: "Forex",
            iconName: "dollarsign.arrow.circlepath",
            symbols: ["EURUSD=X", "GBPUSD=X", "USDJPY=X", "AUDUSD=X", "USDCHF=X", "USDCAD=X", "NZDUSD=X"]
        )
    ]
    
    @Published var expandedCategories: Set<UUID> = []
    @Published var mockQuotes: [String: StockQuote] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    init() {
        // Do not call setupMockData immediately, only through loadCategories
    }
    @MainActor
    func loadCategories() async {
        isLoading = true
        errorMessage = nil

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        setupMockData()

        // Optional: Error simulation for testing (uncomment to see error state)
        // errorMessage = "Failed to load categories. Please try again later."

        isLoading = false
    }

    
    func toggleCategory(_ categoryId: UUID) {
        if expandedCategories.contains(categoryId) {
            expandedCategories.remove(categoryId)
        } else {
            expandedCategories.insert(categoryId)
        }
    }
    
    private func setupMockData() {
        let allSymbols = categories.flatMap { $0.symbols }
        for symbol in allSymbols {
            mockQuotes[symbol] = StockQuote(
                symbol: symbol,
                price: Double.random(in: 100...500),
                change: Double.random(in: -5...5),
                changePercent: String(format: "%.2f%%", Double.random(in: -2...2)),
                volume: Int.random(in: 1000000...50000000),
                lastUpdated: nil
            )
        }
    }
}
