//
//  SearchView.swift
//  FinScope
//
//  Created by Justynka  on 04/05/2026.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isSearching {
                    ProgressView("Szukanie...")
                } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    List(viewModel.searchResults) { stock in
                        NavigationLink(destination: StockDetailView(quote: stock)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(stock.symbol)
                                        .font(.headline)
                                    Text("Cena: $\(stock.price, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(stock.changePercentValue >= 0 ? "▲" : "▼") \(abs(stock.changePercentValue), specifier: "%.2f")%")
                                    .foregroundColor(stock.changePercentValue >= 0 ? .green : .red)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Szukaj")
            .searchable(text: $viewModel.searchText, prompt: "Wpisz symbol (np. AAPL)")
            .task {
                if viewModel.allTasks.isEmpty {
                    await viewModel.fetchAllData()
                }
            }
        }
    }
}

#Preview {
    SearchView()
}
