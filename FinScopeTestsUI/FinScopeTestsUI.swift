//
//  FinScopeTestsUI.swift
//  FinScopeTestsUI
//
//  Created by Justynka  on 08/05/2026.
//

import XCTest

final class FinScopeTestsUI: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTabBarNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.navigationBars["FinScope"].exists)
        
        let categoryTab = app.tabBars.buttons["Kategoria"]
        XCTAssertTrue(categoryTab.exists)
        categoryTab.tap()
        XCTAssertTrue(app.navigationBars["Kategorie"].exists)
        
        let searchTab = app.tabBars.buttons["Szukaj"]
        XCTAssertTrue(searchTab.exists)
        searchTab.tap()
        XCTAssertTrue(app.navigationBars["Szukaj"].exists)
        
        let marketTab = app.tabBars.buttons["Rynek"]
        XCTAssertTrue(marketTab.exists)
        marketTab.tap()
        XCTAssertTrue(app.navigationBars["FinScope"].exists)
    }
    
    @MainActor
    func testMarketSegmentedControl() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["FinScope"].exists)

        let stocksButton = app.buttons["Akcje"]
        let cryptoButton = app.buttons["Crypto"]
        let forexButton = app.buttons["Forex"]

        XCTAssertTrue(stocksButton.exists)
        XCTAssertTrue(cryptoButton.exists)
        XCTAssertTrue(forexButton.exists)

        stocksButton.tap()
        cryptoButton.tap()
        forexButton.tap()
    }

    @MainActor
    func testSearchInteraction() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Szukaj"].tap()

        let searchField = app.searchFields["np. Apple, AAPL..."]
        XCTAssertTrue(searchField.exists)
        
        searchField.tap()
        searchField.typeText("Apple")
        
        let clearButton = app.buttons["Clear text"]
        if clearButton.waitForExistence(timeout: 2) {
            clearButton.tap()
            XCTAssertEqual(searchField.value as? String, "np. Apple, AAPL...")
        }
        
        searchField.tap()
        let closeButton = app.buttons["Close"]
        if closeButton.waitForExistence(timeout: 2) {
            closeButton.tap()
            XCTAssertTrue(app/*@START_MENU_TOKEN@*/.staticTexts["Szukaj"]/*[[".navigationBars",".staticTexts",".staticTexts[\"Szukaj\"]"],[[[-1,2],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.exists)
        }
    }

    @MainActor
    func testStockDetailsNavigationAndTabs() throws {
        let app = XCUIApplication()
        app.launch()

        // Próba wejścia w szczegóły pierwszej dostępnej akcji
        let firstCell = app/*@START_MENU_TOKEN@*/.staticTexts["AA"]/*[[".buttons.staticTexts[\"AA\"]",".staticTexts[\"AA\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        firstCell.tap()
            
        // Sprawdź przyciski zakresu wykresu (1D, 1W, 1M...)
        XCTAssertTrue(app.buttons["1W"].exists)
        XCTAssertTrue(app.buttons["1M"].exists)
        XCTAssertTrue(app.buttons["3M"].exists)
        
        app.buttons["1W"].tap()
        app.buttons["1M"].tap()
        app.buttons["3M"].tap()
        
        // Sprawdź sekcje (Fundamentals, News, About)
        XCTAssertTrue(app.staticTexts["Fundamentals"].exists)
        XCTAssertTrue(app.staticTexts["News"].exists)
        XCTAssertTrue(app.staticTexts["About"].exists)
        
        // Powrót
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
    }
}
