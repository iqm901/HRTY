import XCTest
@testable import HRTY

final class SettingsViewModelTests: XCTestCase {

    var viewModel: SettingsViewModel!

    override func setUp() {
        super.setUp()
        // Clear UserDefaults to ensure clean state for tests
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.reminderEnabled)
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.reminderHour)
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.reminderMinute)
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.patientIdentifier)
        viewModel = SettingsViewModel()
    }

    override func tearDown() {
        // Clean up UserDefaults after tests
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.reminderEnabled)
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.reminderHour)
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.reminderMinute)
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.patientIdentifier)
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testReminderEnabledDefaultsToFalse() {
        // Then: reminder should be disabled by default
        XCTAssertFalse(viewModel.reminderEnabled)
    }

    func testPatientIdentifierDefaultsToEmpty() {
        // Then: patient identifier should be empty by default
        XCTAssertEqual(viewModel.patientIdentifier, "")
    }

    func testDefaultReminderTimeIs8AM() {
        // Given: a fresh view model
        // When: getting the reminder time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: viewModel.reminderTime)

        // Then: should default to 8:00 AM
        XCTAssertEqual(components.hour, 8)
        XCTAssertEqual(components.minute, 0)
    }

    // MARK: - Reminder Time Tests

    func testReminderTimeCanBeSet() {
        // Given: a new time
        var components = DateComponents()
        components.hour = 14
        components.minute = 30
        let newTime = Calendar.current.date(from: components)!

        // When: setting the reminder time
        viewModel.reminderTime = newTime

        // Then: the time should be updated
        let resultComponents = Calendar.current.dateComponents([.hour, .minute], from: viewModel.reminderTime)
        XCTAssertEqual(resultComponents.hour, 14)
        XCTAssertEqual(resultComponents.minute, 30)
    }

    func testReminderTimeHandlesMidnight() {
        // Given: midnight time
        var components = DateComponents()
        components.hour = 0
        components.minute = 0
        let midnight = Calendar.current.date(from: components)!

        // When: setting to midnight
        viewModel.reminderTime = midnight

        // Then: should store correctly
        let resultComponents = Calendar.current.dateComponents([.hour, .minute], from: viewModel.reminderTime)
        XCTAssertEqual(resultComponents.hour, 0)
        XCTAssertEqual(resultComponents.minute, 0)
    }

    func testReminderTimeHandles1159PM() {
        // Given: 11:59 PM
        var components = DateComponents()
        components.hour = 23
        components.minute = 59
        let lateNight = Calendar.current.date(from: components)!

        // When: setting to 11:59 PM
        viewModel.reminderTime = lateNight

        // Then: should store correctly
        let resultComponents = Calendar.current.dateComponents([.hour, .minute], from: viewModel.reminderTime)
        XCTAssertEqual(resultComponents.hour, 23)
        XCTAssertEqual(resultComponents.minute, 59)
    }

    // MARK: - Formatted Reminder Time Tests

    func testFormattedReminderTimeIsNotEmpty() {
        // Then: formatted time should not be empty
        XCTAssertFalse(viewModel.formattedReminderTime.isEmpty)
    }

    func testFormattedReminderTimeChangesWithTime() {
        // Given: the initial formatted time
        let initialFormatted = viewModel.formattedReminderTime

        // When: changing to a different time (3:45 PM)
        var components = DateComponents()
        components.hour = 15
        components.minute = 45
        viewModel.reminderTime = Calendar.current.date(from: components)!

        // Then: formatted time should change
        let newFormatted = viewModel.formattedReminderTime
        XCTAssertNotEqual(initialFormatted, newFormatted)
    }

    // MARK: - Patient Identifier Tests

    func testPatientIdentifierCanBeSet() {
        // When: setting a patient identifier
        viewModel.patientIdentifier = "John Doe"

        // Then: it should be stored
        XCTAssertEqual(viewModel.patientIdentifier, "John Doe")
    }

    func testClearPatientIdentifierEmptiesValue() {
        // Given: a patient identifier is set
        viewModel.patientIdentifier = "Test Patient"

        // When: clearing it
        viewModel.clearPatientIdentifier()

        // Then: it should be empty
        XCTAssertEqual(viewModel.patientIdentifier, "")
    }

    func testPatientIdentifierWithSpecialCharacters() {
        // Given: identifier with special characters
        let identifier = "Patient #123 (Test-User)"

        // When: setting it
        viewModel.patientIdentifier = identifier

        // Then: should preserve special characters
        XCTAssertEqual(viewModel.patientIdentifier, identifier)
    }

    func testPatientIdentifierWithNumbers() {
        // Given: numeric identifier
        viewModel.patientIdentifier = "12345"

        // Then: should preserve numbers
        XCTAssertEqual(viewModel.patientIdentifier, "12345")
    }

    func testPatientIdentifierWithWhitespace() {
        // Given: identifier with spaces
        viewModel.patientIdentifier = "John Michael Doe"

        // Then: should preserve internal spaces
        XCTAssertEqual(viewModel.patientIdentifier, "John Michael Doe")
    }

    // MARK: - Reset Reminder Tests

    func testResetReminderToDefaultSetsCorrectTime() {
        // Given: a non-default time is set
        var components = DateComponents()
        components.hour = 15
        components.minute = 30
        viewModel.reminderTime = Calendar.current.date(from: components)!

        // When: resetting to default
        viewModel.resetReminderToDefault()

        // Then: should be 8:00 AM
        let resultComponents = Calendar.current.dateComponents([.hour, .minute], from: viewModel.reminderTime)
        XCTAssertEqual(resultComponents.hour, 8)
        XCTAssertEqual(resultComponents.minute, 0)
    }

    // MARK: - Version Info Tests

    func testAppVersionIsNotEmpty() {
        // Then: app version should not be empty
        XCTAssertFalse(viewModel.appVersion.isEmpty)
    }

    func testBuildNumberIsNotEmpty() {
        // Then: build number should not be empty
        XCTAssertFalse(viewModel.buildNumber.isEmpty)
    }

    func testVersionStringContainsVersion() {
        // Then: version string should contain "Version"
        XCTAssertTrue(viewModel.versionString.contains("Version"))
    }

    func testVersionStringContainsAppVersion() {
        // Then: version string should contain the app version
        XCTAssertTrue(viewModel.versionString.contains(viewModel.appVersion))
    }

    func testVersionStringContainsBuildNumber() {
        // Then: version string should contain the build number in parentheses
        XCTAssertTrue(viewModel.versionString.contains("(\(viewModel.buildNumber))"))
    }

    func testVersionStringFormat() {
        // Then: version string should match expected format
        let expectedFormat = "Version \(viewModel.appVersion) (\(viewModel.buildNumber))"
        XCTAssertEqual(viewModel.versionString, expectedFormat)
    }

    // MARK: - Persistence Tests

    func testReminderEnabledPersists() {
        // Given: reminder is enabled
        viewModel.reminderEnabled = true

        // When: creating a new view model
        let newViewModel = SettingsViewModel()

        // Then: reminder should still be enabled
        XCTAssertTrue(newViewModel.reminderEnabled)
    }

    func testPatientIdentifierPersists() {
        // Given: a patient identifier is set
        viewModel.patientIdentifier = "Persisted Patient"

        // When: creating a new view model
        let newViewModel = SettingsViewModel()

        // Then: identifier should persist
        XCTAssertEqual(newViewModel.patientIdentifier, "Persisted Patient")
    }

    func testReminderTimePersists() {
        // Given: a specific time is set
        var components = DateComponents()
        components.hour = 17
        components.minute = 45
        viewModel.reminderTime = Calendar.current.date(from: components)!

        // When: creating a new view model
        let newViewModel = SettingsViewModel()

        // Then: time should persist
        let resultComponents = Calendar.current.dateComponents([.hour, .minute], from: newViewModel.reminderTime)
        XCTAssertEqual(resultComponents.hour, 17)
        XCTAssertEqual(resultComponents.minute, 45)
    }
}

// MARK: - AppStorageKeys Tests

final class AppStorageKeysTests: XCTestCase {

    func testReminderEnabledKeyIsCorrect() {
        XCTAssertEqual(AppStorageKeys.reminderEnabled, "reminderEnabled")
    }

    func testReminderHourKeyIsCorrect() {
        XCTAssertEqual(AppStorageKeys.reminderHour, "reminderHour")
    }

    func testReminderMinuteKeyIsCorrect() {
        XCTAssertEqual(AppStorageKeys.reminderMinute, "reminderMinute")
    }

    func testPatientIdentifierKeyIsCorrect() {
        XCTAssertEqual(AppStorageKeys.patientIdentifier, "patientIdentifier")
    }

    func testAllKeysAreUnique() {
        // Given: all keys
        let keys = [
            AppStorageKeys.reminderEnabled,
            AppStorageKeys.reminderHour,
            AppStorageKeys.reminderMinute,
            AppStorageKeys.patientIdentifier
        ]

        // Then: all keys should be unique
        let uniqueKeys = Set(keys)
        XCTAssertEqual(keys.count, uniqueKeys.count, "All AppStorage keys should be unique")
    }
}
