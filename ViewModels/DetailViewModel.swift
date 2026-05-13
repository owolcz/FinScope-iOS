import Foundation
import Combine

@MainActor
class DetailViewModel: ObservableObject {

    @Published var pricePoints: [PricePoint] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedRange: String = "1M"
    @Published var rangeChangePercent: Double = 0.0
    @Published var overview: CompanyOverview? = nil
    @Published var news: [NewsArticle] = []

    func loadHistory(symbol: String, range: String = "1M") async {
        isLoading = true
        errorMessage = nil

        var lastError: Error? = nil

        for attempt in 1...3 {
            guard !Task.isCancelled else {
                isLoading = false
                return
            }

            do {
                let response = try await APIClient.fetchHistory(symbol: symbol, range: range)

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

                lastError = nil
                break

            } catch is CancellationError {
                isLoading = false
                return
            } catch {
                lastError = error
                if attempt < 3 {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                }
            }
        }

        if let error = lastError {
            print("❌ \(error)")
            errorMessage = "Failed to fetch data. Please try again in a moment."
        }

        isLoading = false

        guard !Task.isCancelled else { return }

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    let overview = try await APIClient.fetchOverview(symbol: symbol)
                    await MainActor.run { self.overview = overview }
                } catch {
                    print("⚠️ overview: \(error)")
                }
            }
            group.addTask {
                do {
                    let response = try await APIClient.fetchNews(symbol: symbol)
                    await MainActor.run { self.news = response.news }
                } catch {
                    print("⚠️ news: \(error)")
                }
            }
        }
    }
}
