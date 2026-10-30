import Foundation
import XCTest

final class FitTrackUITests: XCTestCase {
    private var application: XCUIApplication?

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        application?.terminate()
        application = nil
        super.tearDown()
    }

    func testSavedProfileSurvivesRelaunch() {
        let app = makeApplication()
        app.launch()
        let field = app.textFields["profile.name"]
        XCTAssertTrue(field.waitForExistence(timeout: 8))
        field.click()
        field.typeText("Taylor")
        app.buttons["profile.save"].click()
        XCTAssertTrue(app.staticTexts["profile.saved"].waitForExistence(timeout: 5))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.textFields["profile.name"].waitForExistence(timeout: 8))
        XCTAssertEqual(app.textFields["profile.name"].value as? String, "Taylor")
    }

    func testOpeningFailureCanBeRetriedWithoutResettingData() {
        let app = makeApplication(extraArguments: ["--ui-test-fail-first-open"])
        app.launch()
        let retry = app.buttons["store.retry"]
        XCTAssertTrue(retry.waitForExistence(timeout: 8))
        retry.click()
        XCTAssertTrue(app.textFields["profile.name"].waitForExistence(timeout: 8))
    }

    func testQuitSavesUnsavedDraftBeforeTerminating() {
        let app = makeApplication()
        app.launch()
        let field = app.textFields["profile.name"]
        XCTAssertTrue(field.waitForExistence(timeout: 8))
        field.click()
        field.typeText("Nova")
        app.typeKey("q", modifierFlags: .command)
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 8))
        app.launch()
        XCTAssertTrue(app.textFields["profile.name"].waitForExistence(timeout: 8))
        XCTAssertEqual(app.textFields["profile.name"].value as? String, "Nova")
    }

    private func makeApplication(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing", "--ui-test-store-id", UUID().uuidString,
            "-AppleLanguages", "(es)", "-AppleLocale", "es_ES"
        ] + extraArguments
        application = app
        return app
    }
}
