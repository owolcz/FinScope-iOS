//
//  FinScopeTests.swift
//  FinScopeTests
//
//  Created by Justynka  on 08/05/2026.
//

import XCTest
@testable import FinScope

final class FinScopeTests: XCTestCase {
    
    func testStockQuoteChangePercentValue() {
        // Test parsing of various percentage string formats
        let testCases: [(String, Double)] = [
            (" 1.25% ", 1.25),
            ("-2.50%", -2.5),
            ("+0.72%", 0.72),
            ("0%", 0.0),
            ("invalid", 0.0),
            ("", 0.0)
        ]
        
        for (input, expected) in testCases {
            let quote = StockQuote(
                symbol: "TEST",
                price: 100.0,
                change: 0.0,
                changePercent: input,
                volume: 0,
                lastUpdated: nil
            )
            XCTAssertEqual(quote.changePercentValue, expected, accuracy: 0.001, "Failed for input: \(input)")
        }
    }
    
    func testNewsArticlePublishedDate() {
        // Test date formatting from Unix timestamp
        // 1715589300 = May 13, 2024, 8:35 AM UTC
        let timestamp = 1715589300
        let article = NewsArticle(
            headline: "Test",
            summary: "Test",
            source: "Test",
            url: "https://test.com",
            image: nil,
            datetime: timestamp
        )
        
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        let expected = f.string(from: date)
        
        XCTAssertEqual(article.publishedDate, expected)
        
        // Test nil case
        let nilArticle = NewsArticle(
            headline: "Test",
            summary: "Test",
            source: "Test",
            url: nil,
            image: nil,
            datetime: nil
        )
        XCTAssertNil(nilArticle.publishedDate)
    }
    
    func testAssetTypeDisplayNames() {
        let stocks = AssetType.stocks
        let crypto = AssetType.crypto
        let forex = AssetType.forex
        
        XCTAssertEqual(stocks.displayName(for: "AAPL"), "AAPL")
        XCTAssertEqual(crypto.displayName(for: "BTC-USD"), "BTC")
        XCTAssertEqual(forex.displayName(for: "EURUSD=X"), "EUR/USD")
    }
}
