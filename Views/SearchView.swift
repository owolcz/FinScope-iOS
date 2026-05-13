import SwiftUI
import Combine
import UIKit

@MainActor
class SearchViewModel: ObservableObject {
    @Published var results: [SearchResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func search(query: String) async {
        guard !query.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        results = []
        do {
            let response = try await APIClient.fetchSearch(query: query)
            self.results = response.results
            if results.isEmpty {
                errorMessage = "No results found for \"\(query)\""
            }
        } catch {
            errorMessage = "Search failed. Please check your connection and try again."
        }
        isLoading = false
    }
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var query = ""
    @State private var selectedQuote: StockQuote? = nil
    @State private var isLoadingQuote = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fsBackground.ignoresSafeArea()

                if isLoadingQuote {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(Color.fsAccent)
                        Text("Fetching company data...")
                            .foregroundColor(Color.fsSecondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(Color.fsAccent)
                        Text("Searching...")
                            .foregroundColor(Color.fsSecondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 14) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(Color.fsSecondary)
                        Text(error)
                            .foregroundColor(Color.fsSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button("Try again") {
                            Task { await viewModel.search(query: query) }
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.fsBackground)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.fsAccent)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if viewModel.results.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.fsAccent, Color.fsAccent.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Enter a name or stock symbol")
                            .foregroundColor(Color.fsSecondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.results) { result in
                                Button {
                                    Task { await loadAndNavigate(symbol: result.symbol) }
                                } label: {
                                    SearchResultCard(result: result)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                            .opacity(0.3)
                            .ignoresSafeArea()
                    )
                }
            }
            .navigationTitle("Search")
            .searchable(text: $query, prompt: "e.g. Apple, AAPL...")
            .onSubmit(of: .search) {
                Task { await viewModel.search(query: query) }
            }
            .navigationDestination(item: $selectedQuote) { quote in
                StockDetailView(quote: quote)
            }
        }
    }

    private func loadAndNavigate(symbol: String) async {
        isLoadingQuote = true
        do {
            let quote = try await APIClient.fetchQuote(symbol: symbol)
            selectedQuote = quote
        } catch {
            print("⚠️ \(symbol): \(error)")
        }
        isLoadingQuote = false
    }
}

struct SearchResultCard: View {
    let result: SearchResult

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.fsSurface2)
                    .frame(width: 46, height: 46)
                Text(String(result.symbol.prefix(2)))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.fsAccent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(result.symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text(result.name ?? result.symbol)
                    .font(.subheadline)
                    .foregroundColor(Color.fsSecondary)
                    .lineLimit(1)
                if let region = result.region {
                    Text(region)
                        .font(.caption)
                        .foregroundColor(Color.fsSecondary.opacity(0.7))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.fsSecondary)
        }
        .padding(14)
        .background(Color.fsSurface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.fsBorder, lineWidth: 1)
        )
    }
}

#Preview {
    SearchView()
}

// MARK: - VisualEffectView
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
