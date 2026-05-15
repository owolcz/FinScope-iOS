import Foundation

struct StockQuote: Codable, Identifiable, Hashable {
    let id: UUID = UUID()
    let symbol: String
    let price: Double
    let change: Double
    let changePercent: String
    let volume: Int
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case symbol
        case price
        case change
        case changePercent = "change_percent"
        case volume
        case lastUpdated   = "last_updated"
    }

    var changePercentValue: Double {
        let cleaned = changePercent
            .replacingOccurrences(of: "%", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Double(cleaned) ?? 0.0
    }
}

struct SearchResult: Codable, Identifiable {
    let symbol: String
    let name: String?
    let type: String?
    let region: String?
    let currency: String?
    let matchScore: String?

    var id: String { symbol }

    enum CodingKeys: String, CodingKey {
        case symbol, name, type, region, currency
        case matchScore = "match_score"
    }
}

struct SearchResponse: Codable {
    let query: String
    let results: [SearchResult]
}

struct NewsArticle: Codable, Identifiable {
    let headline: String?
    let summary: String?
    let source: String?
    let url: String?
    let image: String?
    let datetime: Int?

    var id: Int { datetime ?? Int.random(in: 0...Int.max) }

    var publishedDate: String? {
        guard let ts = datetime else { return nil }
        let date = Date(timeIntervalSince1970: TimeInterval(ts))
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

struct NewsResponse: Codable {
    let symbol: String
    let news: [NewsArticle]
}

enum AssetType: String, CaseIterable {
    case stocks = "Stocks"
    case crypto = "Crypto"
    case forex  = "Forex"

    var symbols: [String] {
        switch self {
        case .stocks: return ["AAPL", "MSFT", "GOOGL", "AMZN", "NVDA", "META", "TSLA", "UBER", "WMT", "IBM", "ORCL"]
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

