import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel = MarketViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fsBackground.ignoresSafeArea()

                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(Color.fsAccent)
                        Text("Loading data...")
                            .foregroundColor(Color.fsSecondary)
                            .font(.subheadline)
                    }

                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(Color.fsRed)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.fsSecondary)
                            .padding(.horizontal)
                        Button("Try again") {
                            Task { await viewModel.loadMarket() }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.fsBackground)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 13)
                        .background(Color.fsAccent)
                        .cornerRadius(12)
                    }

                } else {
                    VStack(spacing: 0) {
                        Picker("", selection: $viewModel.assetType) {
                            ForEach(AssetType.allCases, id: \.self) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.sortedQuotes) { quote in
                                    NavigationLink(
                                        destination: StockDetailView(
                                            quote: quote,
                                            assetType: viewModel.assetType
                                        )
                                    ) {
                                        QuoteRowCard(
                                            quote: quote,
                                            assetType: viewModel.assetType,
                                            isFavorite: viewModel.favoriteSymbols.contains(quote.symbol),
                                            onToggleFavorite: {
                                                viewModel.toggleFavorite(for: quote.symbol)
                                            }
                                        )
                                        .accessibilityIdentifier("QuoteCard")

                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("FinScope")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadMarket()
            }
        }
    }
}

struct QuoteRowCard: View {
    let quote: StockQuote
    let assetType: AssetType
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    private var isPositive: Bool { quote.changePercentValue >= 0 }
    private var displayName: String { assetType.displayName(for: quote.symbol) }
    private var changeColor: Color { isPositive ? Color.fsGreen : Color.fsRed }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.fsSurface2)
                    .frame(width: 46, height: 46)
                Text(String(displayName.prefix(2)).uppercased())
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.fsAccent)
            }

            Text(displayName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .accessibilityIdentifier("symbolText")

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text(marketFormattedPrice(quote.price, type: assetType))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 3) {
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10, weight: .bold))
                    Text("\(abs(quote.changePercentValue), specifier: "%.2f")%")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(changeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(changeColor.opacity(0.15))
                .cornerRadius(6)
            }

            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.system(size: 16))
                    .foregroundColor(isFavorite ? Color.fsAccent : Color.fsSecondary.opacity(0.5))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("favouriteButton")
            .accessibilityLabel(isFavorite ? "Favorite" : "Add to favorites")
        }
        .accessibilityElement(children: .contain)
        .padding(14)

        .background(Color.fsSurface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isFavorite ? Color.fsAccent.opacity(0.4) : Color.fsBorder, lineWidth: 1)
        )
    }
}

private func marketFormattedPrice(_ price: Double, type: AssetType) -> String {
    switch type {
    case .stocks, .crypto:
        return price >= 1000
            ? String(format: "$%.0f", price)
            : String(format: "$%.2f", price)
    case .forex:
        return String(format: "%.4f", price)
    }
}

#Preview {
    MarketView()
}
