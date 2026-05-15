import Foundation
import Combine

@MainActor
class MarketViewModel: ObservableObject {

    @Published var quotes: [StockQuote] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var favoriteSymbols: Set<String> = []
    @Published var assetType: AssetType = .stocks {
        didSet {
            quotes = []
            Task { await loadQuotes() }
        }
    }

    var sortedQuotes: [StockQuote] {
        return quotes.sorted { q1, q2 in
            let f1 = favoriteSymbols.contains(q1.symbol)
            let f2 = favoriteSymbols.contains(q2.symbol)
            if f1 != f2 { return f1 }
            return q1.symbol < q2.symbol
        }
    }

    func toggleFavorite(for symbol: String) {
        if favoriteSymbols.contains(symbol) {
            favoriteSymbols.remove(symbol)
        } else {
            favoriteSymbols.insert(symbol)
        }
    }

    func loadMarket() async {
        isLoading = true
        errorMessage = nil
        await loadQuotes()
        isLoading = false
    }

    func loadQuotes() async {
        var fetched: [StockQuote] = []
        for symbol in assetType.symbols {
            do {
                let quote = assetType.usesAssetEndpoint
                    ? try await APIClient.fetchAssetQuote(symbol: symbol)
                    : try await APIClient.fetchQuote(symbol: symbol)
                fetched.append(quote)
            } catch {
                print("⚠️ \(symbol): \(error.localizedDescription)")
            }
        }
        if fetched.isEmpty {
            errorMessage = "Failed to fetch data."
        } else {
            quotes = fetched
            errorMessage = nil
        }
    }
}
