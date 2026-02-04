import XCTest

final class MedicationCautionDemoTest: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddIbuprofenShowsCautionWarning() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Medications tab
        let medicationsTab = app.tabBars.buttons["Medications"]
        XCTAssertTrue(medicationsTab.waitForExistence(timeout: 5))
        medicationsTab.tap()

        // Wait for medications view to load
        sleep(1)

        // Tap the + button to open the menu
        let addButton = app.navigationBars["Medications"].buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Tap "Add Medication" from the menu
        let addMedicationButton = app.buttons["Add Medication"]
        XCTAssertTrue(addMedicationButton.waitForExistence(timeout: 3))
        addMedicationButton.tap()

        // Wait for the form to appear
        sleep(1)

        // Switch to "Other Medications" tab
        let otherMedsTab = app.buttons["Other Medications"]
        if otherMedsTab.exists {
            otherMedsTab.tap()
            sleep(1)
        }

        // Search for Ibuprofen
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("Ibuprofen")
            sleep(1)
        }

        // Tap on Ibuprofen result
        let ibuprofenCell = app.staticTexts["Ibuprofen (Advil/Motrin)"]
        if ibuprofenCell.waitForExistence(timeout: 3) {
            ibuprofenCell.tap()
            sleep(1)
        }

        // Select a dosage
        let dosage800 = app.buttons["800"]
        if dosage800.waitForExistence(timeout: 3) {
            dosage800.tap()
        }

        // Tap Save/Add button
        let saveButton = app.buttons["Save Medication"]
        if saveButton.waitForExistence(timeout: 3) {
            saveButton.tap()
        }

        // Verify the caution alert appears
        let cautionAlert = app.alerts["Medication Caution"]
        XCTAssertTrue(cautionAlert.waitForExistence(timeout: 5), "Caution alert should appear")

        // Take a screenshot of the alert
        let alertScreenshot = XCUIScreen.main.screenshot()
        let alertAttachment = XCTAttachment(screenshot: alertScreenshot)
        alertAttachment.name = "Caution Alert"
        alertAttachment.lifetime = .keepAlways
        add(alertAttachment)

        // Tap "Add Anyway" to add the medication
        let addAnywayButton = cautionAlert.buttons["Add Anyway"]
        XCTAssertTrue(addAnywayButton.exists)
        addAnywayButton.tap()

        // Wait for the medication to be added
        sleep(2)

        // Dismiss the form if still showing
        let doneButton = app.buttons["Done"]
        if doneButton.exists {
            doneButton.tap()
        }

        // Wait for the list to update
        sleep(1)

        // Take a screenshot showing the Caution badge
        let listScreenshot = XCUIScreen.main.screenshot()
        let listAttachment = XCTAttachment(screenshot: listScreenshot)
        listAttachment.name = "Medication List with Caution Badge"
        listAttachment.lifetime = .keepAlways
        add(listAttachment)

        // Verify Ibuprofen is in the list with Caution badge
        let ibuprofenInList = app.staticTexts["Ibuprofen (Advil/Motrin)"]
        XCTAssertTrue(ibuprofenInList.waitForExistence(timeout: 5), "Ibuprofen should be in the list")

        // Check for Caution badge
        let cautionBadge = app.staticTexts["Caution"]
        XCTAssertTrue(cautionBadge.exists, "Caution badge should be visible")
    }
}
