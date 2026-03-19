//
//  MarketViewModel.swift
//  FinScope
//
//  Created by Oskar on 18/03/2026.
//

import Foundation
import Combine

@MainActor
class MarketViewModel: ObservableObject {

    @Published var quotes: [StockQuote] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // Na razie tylko jeden symbol żeby oszczędzać limity API
    let symbols = ["AAPL", "IBM", "UBER", "WMT"]

    func loadMarket() async {
        isLoading = true
        errorMessage = nil

        var fetchedQuotes: [StockQuote] = []

        for symbol in symbols {
            do {
                let quote = try await APIClient.fetchQuote(symbol: symbol)
                fetchedQuotes.append(quote)
            } catch {
                // Pomijamy błędny symbol zamiast wysypywać całą aplikację
                print("⚠️ Błąd dla \(symbol): \(error.localizedDescription)")
            }
        }

        if fetchedQuotes.isEmpty {
            errorMessage = "Nie udało się pobrać żadnych danych."
        } else {
            self.quotes = fetchedQuotes
        }

        isLoading = false
    }
}
