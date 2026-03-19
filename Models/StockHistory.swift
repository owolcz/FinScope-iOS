//
//  StockHistory.swift
//  FinScope
//
//  Created by Oskar on 19/03/2026.
//

import Foundation

// Jeden punkt na wykresie: data + cena zamknięcia
struct PricePoint: Identifiable {
    let id = UUID()
    let date: Date
    let close: Double
}

// Backend zwraca obiekt z kluczem "history" zawierający tablicę wpisów
struct StockHistoryResponse: Codable {
    let symbol: String
    let history: [HistoryEntry]
}

// Pojedynczy dzień w historii cen
struct HistoryEntry: Codable {
    let date: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int
}

// Model dla danych z endpointu /overview
struct CompanyOverview: Codable {
    let symbol: String
    let name: String
    let description: String?
    let sector: String?
    let industry: String?
    let marketCap: String?
    let peRatio: String?
    let weekHigh52: String?
    let weekLow52: String?
    let dividendYield: String?
    let country: String?

    enum CodingKeys: String, CodingKey {
        case symbol, name, description, sector, industry, country
        case marketCap      = "market_cap"
        case peRatio        = "pe_ratio"
        case weekHigh52     = "52_week_high"
        case weekLow52      = "52_week_low"
        case dividendYield  = "dividend_yield"
    }
}
