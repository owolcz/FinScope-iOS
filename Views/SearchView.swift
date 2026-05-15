import SwiftUI
import Combine
import UIKit

@MainActor
class SearchViewModel: ObservableObject {
    @Published var results: [SearchResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var assetType: AssetType = .stocks

    var filteredResults: [SearchResult] {
        if results.isEmpty { return [] }
        let filtered = results.filter { result in
            let symbol = result.symbol.uppercased()
            let type = result.type?.lowercased() ?? ""
            
            switch assetType {
            case .stocks:
                // If it's explicitly krypto or forex, exclude. Otherwise, keep it.
                let isCrypto = symbol.contains("-USD") || type.contains("crypto") || type.contains("digital currency")
                let isForex = symbol.contains("=X") || type.contains("currency") || type.contains("forex")
                return !isCrypto && !isForex
            case .crypto:
                return symbol.contains("-USD") || type.contains("crypto") || type.contains("digital currency")
            case .forex:
                return symbol.contains("=X") || type.contains("currency") || type.contains("forex")
            }
        }
        
        return filtered
    }

    func search(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            results = []
            errorMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        do {
            let response = try await APIClient.fetchSearch(query: trimmed)
            self.results = response.results
            if results.isEmpty {
                errorMessage = "No results found for \"\(trimmed)\""
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

                VStack(spacing: 0) {
                    if !viewModel.results.isEmpty || !query.isEmpty {
                        Picker("", selection: $viewModel.assetType) {
                            ForEach(AssetType.allCases, id: \.self) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }

                    if isLoadingQuote {
                        Spacer()
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(Color.fsAccent)
                            Text("Fetching company data...")
                                .foregroundColor(Color.fsSecondary)
                                .font(.subheadline)
                        }
                        Spacer()

                    } else if viewModel.isLoading {
                        Spacer()
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(Color.fsAccent)
                            Text("Searching...")
                                .foregroundColor(Color.fsSecondary)
                                .font(.subheadline)
                        }
                        Spacer()

                    } else if let error = viewModel.errorMessage {
                        Spacer()
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
                        Spacer()

                    } else if viewModel.results.isEmpty {
                        Spacer()
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
                        Spacer()

                    } else if viewModel.filteredResults.isEmpty {
                        Spacer()
                        VStack(spacing: 14) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 40))
                                .foregroundColor(Color.fsSecondary)
                            Text("No results for \(viewModel.assetType.rawValue) category")
                                .foregroundColor(Color.fsSecondary)
                                .font(.subheadline)
                        }
                        Spacer()

                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.filteredResults) { result in
                                    Button {
                                        Task { await loadAndNavigate(symbol: result.symbol) }
                                    } label: {
                                        SearchResultCard(result: result, assetType: viewModel.assetType)
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
            }
            .navigationTitle("Search")
            .searchable(text: $query, prompt: "e.g. Apple, AAPL...")
            .onChange(of: query) { oldValue, newValue in
                if newValue.isEmpty {
                    viewModel.results = []
                    viewModel.errorMessage = nil
                } else if newValue.count >= 2 {
                    Task {
                        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s debounce
                        if query == newValue {
                            await viewModel.search(query: newValue)
                        }
                    }
                }
            }
            .onSubmit(of: .search) {
                Task { await viewModel.search(query: query) }
            }
            .navigationDestination(item: $selectedQuote) { quote in
                StockDetailView(quote: quote, assetType: viewModel.assetType)
            }
        }
    }

    private func loadAndNavigate(symbol: String) async {
        isLoadingQuote = true
        do {
            let quote = viewModel.assetType.usesAssetEndpoint
                ? try await APIClient.fetchAssetQuote(symbol: symbol)
                : try await APIClient.fetchQuote(symbol: symbol)
            selectedQuote = quote
        } catch {
            print("⚠️ \(symbol): \(error)")
        }
        isLoadingQuote = false
    }
}

struct SearchResultCard: View {
    let result: SearchResult
    let assetType: AssetType

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.fsSurface2)
                    .frame(width: 46, height: 46)
                Text(String(assetType.displayName(for: result.symbol).prefix(2)).uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.fsAccent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(assetType.displayName(for: result.symbol))
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

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
