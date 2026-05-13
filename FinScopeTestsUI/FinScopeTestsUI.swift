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
        
        let categoryTab = app.tabBars.buttons["Categories"]
        XCTAssertTrue(categoryTab.exists)
        categoryTab.tap()
        XCTAssertTrue(app.navigationBars["Categories"].exists)
        
        let searchTab = app.tabBars.buttons["Search"]
        XCTAssertTrue(searchTab.exists)
        searchTab.tap()
        XCTAssertTrue(app.navigationBars["Search"].exists)
        
        let marketTab = app.tabBars.buttons["Market"]
        XCTAssertTrue(marketTab.exists)
        marketTab.tap()
        XCTAssertTrue(app.navigationBars["FinScope"].exists)
    }
    
    @MainActor
    func testMarketSegmentedControl() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["FinScope"].exists)

        let stocksButton = app.buttons["Stocks"]
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

        app.tabBars.buttons["Search"].tap()

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
            XCTAssertTrue(app.staticTexts["Search"].exists)
        }
    }

    @MainActor
    func testStockDetailsNavigationAndTabs() throws {
        let app = XCUIApplication()
        app.launch()

        let firstCell = app/*@START_MENU_TOKEN@*/.staticTexts["AA"]/*[[".buttons.staticTexts[\"AA\"]",".staticTexts[\"AA\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        firstCell.tap()
            
        // Sprawdź przyciski zakresu wykresu (1D, 1W, 1M...)
        XCTAssertTrue(app.buttons["1W"].exists)
        XCTAssertTrue(app.buttons["1M"].exists)
        XCTAssertTrue(app.buttons["3M"].exists)
        
        app.buttons["1W"].tap()
        app.buttons["1M"].tap()
        app.buttons["3M"].tap()
        
        XCTAssertTrue(app.staticTexts["Fundamentals"].exists)
        XCTAssertTrue(app.staticTexts["News"].exists)
        XCTAssertTrue(app.staticTexts["About"].exists)
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
    }
}
