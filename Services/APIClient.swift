//
//  APIClient.swift
//  FinScope
//
//  Created by Oskar on 18/03/2026.
//

import Foundation

// Klasa odpowiedzialna za całą komunikację z backendem
class APIClient {

    // Bazowy URL Twojego backendu
    // Na razie localhost – później zmienisz na publiczny URL z Railway/Render
    static let baseURL = "http://localhost:8000"

    // Pobiera aktualny kurs akcji dla podanego symbolu (np. "AAPL")
    static func fetchQuote(symbol: String) async throws -> StockQuote {
        // Budujemy URL: http://localhost:8000/stocks/AAPL/quote
        guard let url = URL(string: "\(baseURL)/stocks/\(symbol)/quote") else {
            throw URLError(.badURL)
        }

        // Wykonujemy zapytanie HTTP GET (async/await – nowoczesny Swift)
        let (data, response) = try await URLSession.shared.data(from: url)

        // Sprawdzamy czy serwer odpowiedział kodem 200
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        // Dekodujemy JSON → struct StockQuote
        let decoder = JSONDecoder()
        return try decoder.decode(StockQuote.self, from: data)
    }
}
