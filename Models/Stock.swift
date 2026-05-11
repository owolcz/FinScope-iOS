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
