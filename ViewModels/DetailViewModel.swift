//
//  DetailViewModel.swift
//  FinScope
//
//  Created by Oskar on 19/03/2026.
//

import Foundation
import Combine

@MainActor
class DetailViewModel: ObservableObject {

    @Published var pricePoints: [PricePoint] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedRange: String = "1M"
    @Published var rangeChangePercent: Double = 0.0  // ← nowe pole
    @Published var overview: CompanyOverview? = nil

    func loadHistory(symbol: String, range: String = "1M") async {
        isLoading = true
        errorMessage = nil

        // Ładujemy historię i overview równolegle – szybciej niż po kolei
        async let historyTask = APIClient.fetchHistory(symbol: symbol, range: range)
        async let overviewTask = APIClient.fetchOverview(symbol: symbol)

        do {
            let response = try await historyTask

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            let points = response.history.compactMap { entry -> PricePoint? in
                guard let date = formatter.date(from: entry.date) else { return nil }
                return PricePoint(date: date, close: entry.close)
            }

            self.pricePoints = points.sorted { $0.date < $1.date }

            if let first = self.pricePoints.first, let last = self.pricePoints.last {
                self.rangeChangePercent = ((last.close - first.close) / first.close) * 100
            }
        } catch {
            print("❌ Błąd historii: \(error)")
            errorMessage = "Nie udało się pobrać historii: \(error.localizedDescription)"
        }

        do {
            self.overview = try await overviewTask
        } catch {
            // Overview nie jest krytyczne – nie blokujemy ekranu
            print("⚠️ Błąd overview: \(error)")
        }

        isLoading = false
    }
}
