//
//  MarketView.swift
//  FinScope
//
//  Created by Oskar on 18/03/2026.
//

import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel = MarketViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Ładowanie danych...")
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button("Spróbuj ponownie") {
                            Task { await viewModel.loadMarket() }
                        }
                    }
                    .padding()
                } else {
                    // ZMIANA 1: Używamy posortowanej listy z ViewModelu
                    List(viewModel.sortedQuotes) { quote in
                        NavigationLink(destination: StockDetailView(quote: quote)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(quote.symbol)
                                            .font(.headline)
                                        
                                        // ZMIANA 2: Pokazujemy gwiazdkę, jeśli element jest w ulubionych
                                        if viewModel.favoriteSymbols.contains(quote.symbol) {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                        }
                                    }
                                    Text("Cena: $\(quote.price, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(quote.changePercentValue >= 0 ? "▲" : "▼") \(abs(quote.changePercentValue), specifier: "%.2f")%")
                                    .foregroundColor(quote.changePercentValue >= 0 ? .green : .red)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                        // ZMIANA 3: Dodajemy akcję po przesunięciu wiersza palcem (od lewej do prawej)
                        .swipeActions(edge: .leading) {
                            Button {
                                // Wywołujemy funkcję z ViewModelu po kliknięciu
                                viewModel.toggleFavorite(for: quote.symbol)
                            } label: {
                                // Dynamicznie zmieniamy wygląd przycisku (Dodaj/Usuń)
                                let isFav = viewModel.favoriteSymbols.contains(quote.symbol)
                                Label(isFav ? "Usuń" : "Ulubione", systemImage: isFav ? "star.slash.fill" : "star.fill")
                            }
                            .tint(viewModel.favoriteSymbols.contains(quote.symbol) ? .red : .yellow)
                        }
                    }
//                    // Mechanizm pociągnij-aby-odświeżyć
//                    .refreshable {
//                        await viewModel.loadMarket()
//                    }
                }
            }
            .navigationTitle("📈 Rynek")
            .task {
                await viewModel.loadMarket()
            }
        }
    }
}

#Preview {
    MarketView()
}
