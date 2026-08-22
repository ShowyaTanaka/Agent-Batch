//
//  Agent_BatchUITests.swift
//  Agent_BatchUITests
import XCTest

final class Agent_BatchUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testDeleteSelectedItemAfterAddingMultipleItems() throws {
        let app = XCUIApplication()
        app.launch()

        let addButton = app.buttons["list-action-add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))

        addButton.click()
        addButton.click()
        addButton.click()

        let item = app.buttons["catalog-item-title-GitHub MCP"]
        XCTAssertTrue(item.waitForExistence(timeout: 2))
        item.click()

        let deleteButton = app.buttons["list-action-delete"]
        XCTAssertTrue(deleteButton.isEnabled)
        deleteButton.click()

        XCTAssertFalse(app.buttons["catalog-item-title-GitHub MCP"].exists)
    }

    @MainActor
    func testDeletingImmediatelyAfterMultipleAddsRemovesTheCurrentItem() throws {
        let app = XCUIApplication()
        app.launch()

        let addButton = app.buttons["list-action-add"]
        addButton.click()
        addButton.click()
        addButton.click()

        let newItemTitles = app.buttons.matching(identifier: "catalog-item-title-新しいMCP")
        XCTAssertEqual(newItemTitles.count, 3)

        app.buttons["list-action-delete"].click()

        XCTAssertEqual(newItemTitles.count, 2)
    }

    @MainActor
    func testTwentyRapidAddsThenDeletingAnExistingItem() throws {
        let app = XCUIApplication()
        app.launch()

        let addButton = app.buttons["list-action-add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))

        let interval = 1.0 / 3.0
        var nextTapTime = Date()

        for _ in 0..<20 {
            nextTapTime = nextTapTime.addingTimeInterval(interval)
            addButton.click()

            let remainingInterval = nextTapTime.timeIntervalSinceNow
            if remainingInterval > 0 {
                Thread.sleep(forTimeInterval: remainingInterval)
            }
        }

        let newItemTitles = app.buttons.matching(identifier: "catalog-item-title-新しいMCP")
        XCTAssertEqual(newItemTitles.count, 20)

        let slackItem = app.buttons["catalog-item-title-Slack MCP"]
        XCTAssertTrue(slackItem.waitForExistence(timeout: 2))
        slackItem.click()

        app.buttons["list-action-delete"].click()

        XCTAssertFalse(app.buttons["catalog-item-title-Slack MCP"].exists)
    }

    @MainActor
    func testDeletingEveryItemLeavesAnEmptySidebarWithoutCrashing() throws {
        let app = XCUIApplication()
        app.launch()

        let deleteButton = app.buttons["list-action-delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))

        for itemIdentifier in [
            "catalog-item-title-Filesystem MCP",
            "catalog-item-title-GitHub MCP",
            "catalog-item-title-Slack MCP"
        ] {
            let item = app.buttons[itemIdentifier]
            deleteButton.click()

            let disappearance = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "exists == false"),
                object: item
            )
            XCTAssertEqual(XCTWaiter().wait(for: [disappearance], timeout: 2), .completed)
        }

        XCTAssertFalse(deleteButton.isEnabled)
        XCTAssertTrue(app.staticTexts["項目を選択してください"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
