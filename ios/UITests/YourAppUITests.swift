import XCTest

class YourAppUITests: XCTestCase {

    let app = XCUIApplication()
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testLocationPermission() throws {
        // Launch the app
        app.launch()

        // Find and tap the GPS button
        let gpsButton = app.buttons["GPS"]
        XCTAssertTrue(gpsButton.exists, "GPS button does not exist")
        gpsButton.tap()


        // When permission dialog appears
        let allowButton = springboard.alerts.buttons["Allow"]
        if allowButton.exists {
            allowButton.tap()
        }

        // Add your test code here to verify the app's behavior after granting permission
    }
}