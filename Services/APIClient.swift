import Foundation

class APIClient {

    static let baseURL = "http://localhost:8000"

    static func fetchQuote(symbol: String) async throws -> StockQuote {
        guard let url = URL(string: "\(baseURL)/stocks/\(symbol)/quote") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(StockQuote.self, from: data)
    }

    static func fetchHistory(symbol: String, range: String = "1M") async throws -> StockHistoryResponse {
        guard let url = URL(string: "\(baseURL)/stocks/\(symbol)/history?range=\(range)") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(StockHistoryResponse.self, from: data)
    }

    static func fetchSearch(query: String) async throws -> SearchResponse {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "\(baseURL)/search?q=\(encoded)") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(SearchResponse.self, from: data)
    }

    static func fetchAssetQuote(symbol: String) async throws -> StockQuote {
        let encoded = symbol.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? symbol
        guard let url = URL(string: "\(baseURL)/stocks/assets/\(encoded)/quote") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(StockQuote.self, from: data)
    }

    static func fetchNews(symbol: String) async throws -> NewsResponse {
        guard let url = URL(string: "\(baseURL)/stocks/\(symbol)/news") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(NewsResponse.self, from: data)
    }

    static func fetchOverview(symbol: String) async throws -> CompanyOverview {
        guard let url = URL(string: "\(baseURL)/stocks/\(symbol)/overview") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(CompanyOverview.self, from: data)
    }
}
