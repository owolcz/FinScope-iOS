import SwiftUI

struct CategoryView: View {
    @StateObject private var viewModel = CategoryViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fsBackground.ignoresSafeArea()
                
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(Color.fsAccent)
                        Text("Loading categories...")
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
                            Task { await viewModel.loadCategories() }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.fsBackground)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 13)
                        .background(Color.fsAccent)
                        .cornerRadius(12)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(viewModel.categories) { category in
                                CategorySection(
                                    category: category,
                                    isExpanded: viewModel.expandedCategories.contains(category.id),
                                    quotes: viewModel.mockQuotes,
                                    onToggle: { viewModel.toggleCategory(category.id) }
                                )
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Browse Categories")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadCategories()
            }
        }
    }
}

struct CategorySection: View {
    let category: CategoryGroup
    let isExpanded: Bool
    let quotes: [String: StockQuote]
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    // Ikona kategorii
                    Image(systemName: category.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(Color.fsAccent)
                        .frame(width: 30)
                    
                    Text(category.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.fsSecondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.fsSurface)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.fsBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)

            // Horizontal Scrollable List
            if isExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(category.symbols, id: \.self) { symbol in
                            if let quote = quotes[symbol] {
                                NavigationLink(destination: StockDetailView(quote: quote)) {
                                    CategoryStockCard(quote: quote)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)
    }
}

struct CategoryStockCard: View {
    let quote: StockQuote
    
    private var isPositive: Bool { quote.changePercentValue >= 0 }
    private var changeColor: Color { isPositive ? Color.fsGreen : Color.fsRed }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color.fsAccent)
            
            Text(String(format: "$%.2f", quote.price))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(quote.changePercent)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(changeColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(changeColor.opacity(0.15))
                .cornerRadius(4)
        }
        .frame(width: 110)
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
    CategoryView()
}
