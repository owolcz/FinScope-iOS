import Foundation

struct PricePoint: Identifiable {
    let id = UUID()
    let date: Date
    let close: Double
}

struct StockHistoryResponse: Codable {
    let symbol: String
    let history: [HistoryEntry]
}

struct HistoryEntry: Codable {
    let date: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int
}

struct CompanyOverview: Codable {
    let symbol: String
    let name: String
    let description: String?
    let sector: String?
    let industry: String?
    let marketCap: String?
    let peRatio: String?
    let weekHigh52: String?
    let weekLow52: String?
    let dividendYield: String?
    let country: String?

    enum CodingKeys: String, CodingKey {
        case symbol, name, description, sector, industry, country
        case marketCap      = "market_cap"
        case peRatio        = "pe_ratio"
        case weekHigh52     = "52_week_high"
        case weekLow52      = "52_week_low"
        case dividendYield  = "dividend_yield"
    }
}
