import XCTest

@MainActor
final class LiveActivityDemoUITests: XCTestCase {
    func testColdWarmAndRepeatedSystemURLs() throws {
        let app = XCUIApplication()
        app.terminate()
        app.open(try XCTUnwrap(URL(string: "liveactivitydemo://scenario/delivery?state=delivery-3")))
        XCTAssertTrue(app.navigationBars["Delivery"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Nearby"].firstMatch.exists)
        let sportsURL = try XCTUnwrap(URL(string: "liveactivitydemo://scenario/sports?state=sports-2"))
        XCUIDevice.shared.system.open(sportsURL)
        XCTAssertTrue(app.navigationBars["Sports"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Astana leads"].firstMatch.exists)
        XCUIDevice.shared.system.open(sportsURL)
        XCTAssertTrue(app.staticTexts["Astana leads"].firstMatch.waitForExistence(timeout: 5))
        capture("warm-sports-2-app-preview")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Activity Lab"].waitForExistence(timeout: 5))
        app.terminate()
    }

    func testEveryRecipeStateViaSystemURL() throws {
        let app = XCUIApplication()
        app.launch()
        let scenarios = [("delivery", "Delivery"), ("ride", "Ride"), ("timer", "Timer"),
                         ("sports", "Sports"), ("download", "Transfer"), ("trip", "Trip")]
        for (scenario, title) in scenarios {
            for index in 1...4 {
                let url = try XCTUnwrap(URL(string: "liveactivitydemo://scenario/\(scenario)?state=\(scenario)-\(index)"))
                XCUIDevice.shared.system.open(url)
                XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 10))
                XCTAssertEqual(app.staticTexts["selected-state-index"].label, "\(index)/4")
            }
        }
        XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: "liveactivitydemo://scenario/ride/extra?state=ride-2")))
        XCTAssertTrue(app.navigationBars["Trip"].exists)
        XCTAssertEqual(app.staticTexts["selected-state-index"].label, "4/4")
        app.terminate()
    }

    func testRealLocalActivityLifecycleAndRelaunch() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["recipe-delivery"].tap()
        let start = app.buttons["Start Live Activity"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        XCTAssertTrue(start.isEnabled)
        start.tap()
        expectStatus("running", in: app)
        let next = app.buttons["Next state"]
        next.tap()
        XCTAssertEqual(app.staticTexts["selected-state-index"].label, "2/4")
        expectStatus("running", in: app)
        XCUIDevice.shared.press(.home)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        XCTAssertTrue(springboard.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(springboard.icons.firstMatch.waitForExistence(timeout: 5))
        capture("system-home-active-delivery-2")
        app.terminate()
        app.launch()
        XCTAssertTrue(app.navigationBars["Delivery"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts["selected-state-index"].label, "2/4")
        expectStatus("running", in: app)
        capture("restored-delivery-2-app-preview")
        XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: "liveactivitydemo://scenario/sports?state=sports-3")))
        XCTAssertTrue(app.navigationBars["Sports"].waitForExistence(timeout: 10))
        expectStatus("Delivery", in: app)
        XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: "liveactivitydemo://scenario/ride/extra?state=ride-2")))
        let feedback = app.descendants(matching: .any).matching(identifier: "route-feedback").firstMatch
        XCTAssertTrue(feedback.waitForExistence(timeout: 5))
        XCTAssertTrue(feedback.label.contains("Invalid activity link"))
        expectStatus("Delivery", in: app)
        app.buttons["End Live Activity"].tap()
        expectStatus("ended", in: app)
        capture("ended-session-app-status")
        XCTAssertTrue(app.buttons["Start Live Activity"].isEnabled)
        app.buttons["Start Live Activity"].tap()
        expectStatus("running", in: app)
        app.buttons["End Live Activity"].tap()
        expectStatus("ended", in: app)
        app.terminate()
    }

    func testAccessibilityDynamicTypePreview() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: "liveactivitydemo://scenario/download?state=download-3")))
        XCTAssertTrue(app.navigationBars["Transfer"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Verifying files"].firstMatch.exists)
        capture("accessibility-xxxl-transfer-app-preview")
        app.terminate()
    }

    private func expectStatus(_ fragment: String, in app: XCUIApplication) {
        let status = app.descendants(matching: .any).matching(identifier: "activity-status").firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 10))
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", fragment)
        expectation(for: predicate, evaluatedWith: status)
        waitForExpectations(timeout: 10)
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
