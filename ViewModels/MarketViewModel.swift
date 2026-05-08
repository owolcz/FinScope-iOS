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
    @Published var favoriteSymbols: Set<String> = []

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
    
    // Zwraca posortowaną listę (ulubione na górze)
    var sortedQuotes: [StockQuote] {
        quotes.sorted { quote1, quote2 in
            let isQ1Favorite = favoriteSymbols.contains(quote1.symbol)
            let isQ2Favorite = favoriteSymbols.contains(quote2.symbol)
            
            // Jeśli jedno jest ulubione, a drugie nie, to ulubione idzie wyżej
            if isQ1Favorite != isQ2Favorite {
                return isQ1Favorite
            }
            
            // W przeciwnym razie zostawiamy domyślną kolejność
            return quote1.symbol < quote2.symbol
        }
    }

    // Funkcja do przełączania statusu ulubionych
    func toggleFavorite(for symbol: String) {
        if favoriteSymbols.contains(symbol) {
            favoriteSymbols.remove(symbol)
        } else {
            favoriteSymbols.insert(symbol)
        }
    }
}
