//
//  SearchViewModel.swift
//  FinScope
//
//  Created by Justynka  on 04/05/2026.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var allQuotes: [StockQuote] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // Na razie tylko jeden symbol żeby oszczędzać limity API
    let symbols = ["AAPL", "IBM", "UBER", "WMT"]
    
    // Zmienna obliczeniowa, która automatycznie filtruje wyniki dla widoku
    var searchResults: [StockQuote] {
        if searchText.isEmpty {
            // Zwracamy wszystkie pobrane akcje, jeśli pasek jest pusty
            return allQuotes
        } else {
            return allQuotes.filter { result in
                result.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func loadMarket() async {
        isLoading = true
        errorMessage = nil

        var fetchedQuotes: [StockQuote] = []

        for symbol in symbols {
            do {
                // Zakładam, że Twoja struktura APIClient i funkcja fetchQuote działają poprawnie
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
            self.allQuotes = fetchedQuotes
        }

        isLoading = false
    }
}
