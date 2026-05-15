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
        XCTAssertTrue(app.navigationBars["Browse Categories"].exists)
        
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

        let searchField = app.searchFields["e.g. Apple, AAPL..."]
        XCTAssertTrue(searchField.exists)
        
        searchField.tap()
        searchField.typeText("Apple")
        
        let clearButton = app.buttons["Clear text"]
        if clearButton.waitForExistence(timeout: 2) {
            clearButton.tap()
            XCTAssertEqual(searchField.value as? String, "e.g. Apple, AAPL...")
        }
        
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.waitForExistence(timeout: 2) {
            cancelButton.tap()
            XCTAssertTrue(app.navigationBars["Search"].exists)
        }
    }

    @MainActor
    func testStockDetailsNavigationAndTabs() throws {
        let app = XCUIApplication()
        app.launch()

        let firstCell = app.buttons.staticTexts["AA"].firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        firstCell.tap()
            
        // Check chart range buttons
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

    @MainActor
    func testCategoriesExpansionAndNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.tabBars.buttons["Categories"].tap()
        
        let techSection = app.buttons["Technology"]
        XCTAssertTrue(techSection.waitForExistence(timeout: 5))
        techSection.tap()
        
        let stockCard = app.buttons.staticTexts["AAPL"].firstMatch
        XCTAssertTrue(stockCard.waitForExistence(timeout: 5), "Stock cards should appear after expanding section")
        stockCard.tap()
        
        XCTAssertTrue(app.buttons["1W"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        techSection.tap()
    }

    @MainActor
    func testSearchAndNavigateToDetails() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.tabBars.buttons["Search"].tap()
        let searchField = app.searchFields["e.g. Apple, AAPL..."]
        searchField.tap()
        searchField.typeText("Apple")
        app.keyboards.buttons["Search"].tap()
        
        let resultCell = app.buttons.staticTexts["AAPL"].firstMatch
        XCTAssertTrue(resultCell.waitForExistence(timeout: 5), "Search result for AAPL should appear")
        resultCell.tap()
        
        XCTAssertTrue(app.navigationBars["AAPL"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Fundamentals"].exists)
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Search"].exists)
    }
}
