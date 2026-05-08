//
//  StockDetailView 2.swift
//  FinScope
//
//  Created by Justynka  on 03/05/2026.
//


//  StockDetailView.swift
//  FinScope

import SwiftUI
import Charts

struct StockDetailView: View {
    let quote: StockQuote

    @StateObject private var viewModel = DetailViewModel()

    let ranges = ["1W", "1M", "3M"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // --- Cena i zmiana ---
                VStack(alignment: .leading, spacing: 4) {
                    Text("$\(quote.price, specifier: "%.2f")")
                        .font(.system(size: 36, weight: .bold))

                    let change = viewModel.rangeChangePercent
                    Text("\(change >= 0 ? "▲" : "▼") \(abs(change), specifier: "%.2f")%")
                        .font(.title3)
                        .foregroundColor(change >= 0 ? .green : .red)
                }
                .padding(.horizontal)

                // --- Wykres ---
                if viewModel.isLoading {
                    ProgressView("Ładowanie wykresu...")
                        .frame(maxWidth: .infinity, minHeight: 200)

                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)

                } else if !viewModel.pricePoints.isEmpty {
                    Chart(viewModel.pricePoints) { point in
                        LineMark(
                            x: .value("Data", point.date),
                            y: .value("Cena", point.close)
                        )
                        .foregroundStyle(
                            viewModel.rangeChangePercent >= 0 ? Color.green : Color.red
                        )
                        AreaMark(
                            x: .value("Data", point.date),
                            y: .value("Cena", point.close)
                        )
                        .foregroundStyle(
                            (viewModel.rangeChangePercent >= 0 ? Color.green : Color.red)
                                .opacity(0.1)
                        )
                    }
                    .frame(height: 220)
                    .padding(.horizontal)
                }

                // --- Przyciski zakresu ---
                HStack(spacing: 8) {
                    ForEach(ranges, id: \.self) { range in
                        Button(action: {
                            viewModel.selectedRange = range
                            Task {
                                await viewModel.loadHistory(
                                    symbol: quote.symbol,
                                    range: range
                                )
                            }
                        }) {
                            Text(range)
                                .font(.subheadline)
                                .fontWeight(viewModel.selectedRange == range ? .bold : .regular)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    viewModel.selectedRange == range
                                        ? Color.blue
                                        : Color(.systemGray5)
                                )
                                .foregroundColor(
                                    viewModel.selectedRange == range ? .white : .primary
                                )
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)

                // --- Wolumen i data ---
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    HStack {
                        Label("Volume", systemImage: "chart.bar")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(quote.volume)")
                            .bold()
                    }
                    if let updated = quote.lastUpdated {
                        HStack {
                            Label("Last Updated", systemImage: "clock")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(updated)
                                .bold()
                        }
                    }
                }
                .padding(.horizontal)

                // --- Informacje o spółce ---
                if let overview = viewModel.overview {
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()

                        Text("About")
                            .font(.headline)
                            .padding(.horizontal)

                        if let desc = overview.description {
                            Text(desc)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                // lineLimit usunięty – pełny opis
                                .padding(.horizontal)
                        }

                        Divider()

                        Text("Fundamentals")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 12
                        ) {
                            OverviewTile(label: "Sector", value: overview.sector ?? "—")
                            OverviewTile(label: "Industry", value: overview.industry ?? "—")
                            OverviewTile(label: "Country", value: overview.country ?? "—")
                            OverviewTile(label: "P/E Ratio", value: overview.peRatio ?? "—")
                            OverviewTile(label: "52W High", value: overview.weekHigh52.map { "$\($0)" } ?? "—")
                            OverviewTile(label: "52W Low", value: overview.weekLow52.map { "$\($0)" } ?? "—")
                            OverviewTile(
                                label: "Market Cap",
                                value: overview.marketCap.flatMap { Double($0) }.map { formatMarketCap($0) } ?? "—"
                            )
                            OverviewTile(
                                label: "Dividend Yield",
                                value: overview.dividendYield.flatMap { Double($0) }.map {
                                    String(format: "%.2f%%", $0 * 100)
                                } ?? "—"
                            )
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(quote.symbol)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadHistory(symbol: quote.symbol, range: "1M")
        }
    }
}