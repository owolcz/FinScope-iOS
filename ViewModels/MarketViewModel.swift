import Foundation
import Combine

enum AssetType: String, CaseIterable {
    case stocks = "Akcje"
    case crypto = "Crypto"
    case forex  = "Forex"

    var symbols: [String] {
        switch self {
        case .stocks: return ["AAPL", "MSFT", "GOOGL", "AMZN", "NVDA", "META", "TSLA", "UBER", "WMT", "IBM"]
        case .crypto: return ["BTC-USD", "ETH-USD", "BNB-USD", "SOL-USD", "XRP-USD", "DOGE-USD", "ADA-USD", "AVAX-USD"]
        case .forex:  return ["EURUSD=X", "GBPUSD=X", "USDJPY=X", "AUDUSD=X", "USDCHF=X", "USDCAD=X", "NZDUSD=X"]
        }
    }

    var usesAssetEndpoint: Bool { self != .stocks }

    func displayName(for symbol: String) -> String {
        switch self {
        case .stocks:
            return symbol
        case .crypto:
            return String(symbol.split(separator: "-").first ?? Substring(symbol))
        case .forex:
            let base = symbol.replacingOccurrences(of: "=X", with: "")
            guard base.count >= 6 else { return base }
            return String(base.prefix(3)) + "/" + String(base.suffix(3))
        }
    }
}

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
        guard assetType == .stocks else { return quotes }
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
            errorMessage = "Nie udało się pobrać danych."
        } else {
            quotes = fetched
            errorMessage = nil
        }
    }
}
