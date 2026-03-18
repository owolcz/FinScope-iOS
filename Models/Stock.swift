//
//  Stock.swift
//  FinScope
//
//  Created by Oskar on 18/03/2026.
//

import Foundation

struct StockQuote: Codable, Identifiable {
    let id: UUID = UUID()
    let symbol: String
    let price: Double
    let change: Double
    let changePercent: String
    let volume: Int
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case symbol
        case price
        case change
        case changePercent = "change_percent"
        case volume
        case lastUpdated   = "last_updated"
    }

    var changePercentValue: Double {
        let cleaned = changePercent
            .replacingOccurrences(of: "%", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Double(cleaned) ?? 0.0
    }
}
