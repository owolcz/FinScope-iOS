//
//  MarketView.swift
//  FinScope
//
//  Created by Oskar on 18/03/2026.
//

import SwiftUI

struct MarketView: View {
    // ViewModel – tutaj trzymamy dane i logikę
    @StateObject private var viewModel = MarketViewModel()

    var body: some View {
        NavigationStack {
            Group {
                // Obsługa stanów: loading / error / success
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
                    // Lista z kursami akcji
                    List(viewModel.quotes) { quote in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(quote.symbol)
                                    .font(.headline)
                                Text("Cena: $\(quote.price, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            // Zmiana procentowa – zielona jeśli + , czerwona jeśli –
                            Text("\(quote.changePercentValue >= 0 ? "▲" : "▼") \(abs(quote.changePercentValue), specifier: "%.2f")%")
                                .foregroundColor(quote.changePercentValue >= 0 ? .green : .red)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("📈 Rynek")
            // Ładuj dane gdy widok się pojawi
            .task {
                await viewModel.loadMarket()
            }
        }
    }
}

#Preview {
    MarketView()
}
