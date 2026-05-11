import SwiftUI
import Charts

struct StockDetailView: View {
    let quote: StockQuote
    var assetType: AssetType = .stocks

    @StateObject private var viewModel = DetailViewModel()

    let ranges = ["1W", "1M", "3M"]

    private var isPositive: Bool { viewModel.rangeChangePercent >= 0 }
    private var trendColor: Color { isPositive ? Color.fsGreen : Color.fsRed }

    var body: some View {
        ZStack {
            Color.fsBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    VStack(alignment: .leading, spacing: 10) {
                        Text(viewModel.overview?.name ?? assetType.displayName(for: quote.symbol))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.fsSecondary)
                            .lineLimit(2)

                        Text(detailFormattedPrice(quote.price, type: assetType))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 6) {
                            Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 12, weight: .bold))
                            Text("\(isPositive ? "+" : "")\(viewModel.rangeChangePercent, specifier: "%.2f")%")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(trendColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(trendColor.opacity(0.15))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(Color.fsAccent)
                            Text("Ładowanie wykresu...")
                                .font(.subheadline)
                                .foregroundColor(Color.fsSecondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)

                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Text(error)
                                .foregroundColor(Color.fsRed)
                                .multilineTextAlignment(.center)
                            Button("Spróbuj ponownie") {
                                Task {
                                    await viewModel.loadHistory(
                                        symbol: quote.symbol,
                                        range: viewModel.selectedRange
                                    )
                                }
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.fsBackground)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.fsAccent)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, minHeight: 200)

                    } else if !viewModel.pricePoints.isEmpty {
                        Chart(viewModel.pricePoints) { point in
                            LineMark(
                                x: .value("Data", point.date),
                                y: .value("Cena", point.close)
                            )
                            .foregroundStyle(trendColor)
                            .lineStyle(StrokeStyle(lineWidth: 2))

                            AreaMark(
                                x: .value("Data", point.date),
                                y: .value("Cena", point.close)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [trendColor.opacity(0.3), trendColor.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 4)) {
                                AxisGridLine()
                                    .foregroundStyle(Color.fsBorder)
                                AxisValueLabel()
                                    .foregroundStyle(Color.fsSecondary)
                                    .font(.caption2)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic(desiredCount: 4)) {
                                AxisGridLine()
                                    .foregroundStyle(Color.fsBorder)
                                AxisValueLabel()
                                    .foregroundStyle(Color.fsSecondary)
                                    .font(.caption2)
                            }
                        }
                        .frame(height: 220)
                        .padding(.horizontal)
                    }

                    HStack(spacing: 8) {
                        ForEach(ranges, id: \.self) { range in
                            Button(action: { viewModel.selectedRange = range }) {
                                Text(range)
                                    .font(.system(
                                        size: 13,
                                        weight: viewModel.selectedRange == range ? .bold : .medium
                                    ))
                                    .foregroundColor(
                                        viewModel.selectedRange == range
                                            ? Color.fsBackground
                                            : Color.fsSecondary
                                    )
                                    .frame(minWidth: 52)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        viewModel.selectedRange == range
                                            ? Color.fsAccent
                                            : Color.fsSurface
                                    )
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                viewModel.selectedRange == range
                                                    ? Color.clear
                                                    : Color.fsBorder,
                                                lineWidth: 1
                                            )
                                    )
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    if assetType == .stocks, let overview = viewModel.overview {
                        DetailSectionCard(title: "Fundamentals") {
                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 10
                            ) {
                                DarkTile(label: "Sector", value: overview.sector ?? "—")
                                DarkTile(label: "Industry", value: overview.industry ?? "—")
                                DarkTile(label: "Country", value: overview.country ?? "—")
                                DarkTile(label: "P/E Ratio", value: overview.peRatio ?? "—")
                                DarkTile(
                                    label: "52W High",
                                    value: overview.weekHigh52.map { "$\($0)" } ?? "—"
                                )
                                DarkTile(
                                    label: "52W Low",
                                    value: overview.weekLow52.map { "$\($0)" } ?? "—"
                                )
                                DarkTile(
                                    label: "Market Cap",
                                    value: overview.marketCap.flatMap { Double($0) }
                                        .map { formatMarketCap($0) } ?? "—"
                                )
                                DarkTile(
                                    label: "Dividend Yield",
                                    value: overview.dividendYield.flatMap { Double($0) }
                                        .map { String(format: "%.2f%%", $0) } ?? "—"
                                )
                            }
                        }
                    }

                    if assetType == .stocks, !viewModel.news.isEmpty {
                        DetailSectionCard(title: "News") {
                            VStack(spacing: 10) {
                                ForEach(viewModel.news) { article in
                                    if let urlString = article.url, let url = URL(string: urlString) {
                                        Link(destination: url) {
                                            NewsItemCard(article: article)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }

                    if assetType == .stocks,
                       let overview = viewModel.overview,
                       let desc = overview.description {
                        DetailSectionCard(title: "About") {
                            Text(desc)
                                .font(.subheadline)
                                .foregroundColor(Color.fsSecondary)
                                .lineSpacing(4)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(assetType.displayName(for: quote.symbol))
        .navigationBarTitleDisplayMode(.large)
        .task(id: viewModel.selectedRange) {
            await viewModel.loadHistory(symbol: quote.symbol, range: viewModel.selectedRange)
        }
    }
}

struct DetailSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
            content()
        }
        .padding(16)
        .background(Color.fsSurface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.fsBorder, lineWidth: 1))
        .padding(.horizontal)
    }
}

struct DarkTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(Color.fsSecondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.fsSurface2)
        .cornerRadius(10)
    }
}

struct NewsItemCard: View {
    let article: NewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(article.headline ?? "")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
            HStack {
                if let source = article.source {
                    Text(source)
                        .font(.caption)
                        .foregroundColor(Color.fsAccent)
                }
                Spacer()
                if let date = article.publishedDate {
                    Text(date)
                        .font(.caption)
                        .foregroundColor(Color.fsSecondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fsSurface2)
        .cornerRadius(10)
    }
}

private func detailFormattedPrice(_ price: Double, type: AssetType) -> String {
    switch type {
    case .stocks, .crypto:
        return price >= 1000
            ? String(format: "$%.0f", price)
            : String(format: "$%.2f", price)
    case .forex:
        return String(format: "%.4f", price)
    }
}

func formatMarketCap(_ value: Double) -> String {
    switch value {
    case 1_000_000_000_000...:
        return String(format: "$%.2fT", value / 1_000_000_000_000)
    case 1_000_000_000...:
        return String(format: "$%.2fB", value / 1_000_000_000)
    case 1_000_000...:
        return String(format: "$%.2fM", value / 1_000_000)
    default:
        return String(format: "$%.0f", value)
    }
}
