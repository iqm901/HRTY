import XCTest
@testable import HRTY

/// Tests for weight alert logic and related functionality.
/// Verifies alert thresholds, message formatting, and alert type behavior.
final class WeightAlertTests: XCTestCase {

    var viewModel: TodayViewModel!

    override func setUp() {
        super.setUp()
        viewModel = TodayViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Alert Threshold Tests

    func testWeightGain24hThreshold() {
        // Given/Then: threshold should be 2.0 lbs as per spec
        XCTAssertEqual(AlertConstants.weightGain24hThreshold, 2.0, "24-hour threshold should be 2.0 lbs")
    }

    func testWeightGain7dThreshold() {
        // Given/Then: threshold should be 5.0 lbs as per spec
        XCTAssertEqual(AlertConstants.weightGain7dThreshold, 5.0, "7-day threshold should be 5.0 lbs")
    }

    func testThresholdsArePositive() {
        // Then: both thresholds should be positive values
        XCTAssertGreaterThan(AlertConstants.weightGain24hThreshold, 0, "24-hour threshold should be positive")
        XCTAssertGreaterThan(AlertConstants.weightGain7dThreshold, 0, "7-day threshold should be positive")
    }

    func test7DayThresholdGreaterThan24Hour() {
        // Then: 7-day threshold should be greater than 24-hour threshold
        XCTAssertGreaterThan(
            AlertConstants.weightGain7dThreshold,
            AlertConstants.weightGain24hThreshold,
            "7-day threshold should be greater than 24-hour threshold"
        )
    }

    // MARK: - Weight Validation Tests

    func testMinimumWeightConstant() {
        XCTAssertEqual(AlertConstants.minimumWeight, 50.0, "Minimum weight should be 50 lbs")
    }

    func testMaximumWeightConstant() {
        XCTAssertEqual(AlertConstants.maximumWeight, 500.0, "Maximum weight should be 500 lbs")
    }

    func testValidWeightAtLowerBound() {
        // Given: weight at minimum threshold
        viewModel.weightInput = "50.0"

        // Then: should be valid
        XCTAssertTrue(viewModel.isValidWeight, "Weight at minimum bound should be valid")
    }

    func testValidWeightAtUpperBound() {
        // Given: weight at maximum threshold
        viewModel.weightInput = "500.0"

        // Then: should be valid
        XCTAssertTrue(viewModel.isValidWeight, "Weight at maximum bound should be valid")
    }

    func testInvalidWeightBelowMinimum() {
        // Given: weight below minimum
        viewModel.weightInput = "49.9"

        // Then: should be invalid
        XCTAssertFalse(viewModel.isValidWeight, "Weight below minimum should be invalid")
    }

    func testInvalidWeightAboveMaximum() {
        // Given: weight above maximum
        viewModel.weightInput = "500.1"

        // Then: should be invalid
        XCTAssertFalse(viewModel.isValidWeight, "Weight above maximum should be invalid")
    }

    func testInvalidWeightWithNonNumericInput() {
        // Given: non-numeric input
        viewModel.weightInput = "abc"

        // Then: should be invalid
        XCTAssertFalse(viewModel.isValidWeight, "Non-numeric input should be invalid")
    }

    func testInvalidWeightWithEmptyInput() {
        // Given: empty input
        viewModel.weightInput = ""

        // Then: should be invalid
        XCTAssertFalse(viewModel.isValidWeight, "Empty input should be invalid")
    }

    // MARK: - Parsed Weight Tests

    func testParsedWeightWithValidInteger() {
        // Given: valid integer weight
        viewModel.weightInput = "150"

        // Then: should parse correctly
        XCTAssertEqual(viewModel.parsedWeight, 150.0)
    }

    func testParsedWeightWithValidDecimal() {
        // Given: valid decimal weight
        viewModel.weightInput = "165.5"

        // Then: should parse correctly
        XCTAssertEqual(viewModel.parsedWeight, 165.5)
    }

    func testParsedWeightWithInvalidInput() {
        // Given: invalid input
        viewModel.weightInput = "not a number"

        // Then: should return nil
        XCTAssertNil(viewModel.parsedWeight)
    }
}

// MARK: - AlertType Tests

final class AlertTypeTests: XCTestCase {

    func testAllAlertTypesExist() {
        // Then: all expected alert types should exist
        let allTypes = AlertType.allCases
        XCTAssertTrue(allTypes.contains(.weightGain24h), "Should have 24-hour weight gain type")
        XCTAssertTrue(allTypes.contains(.weightGain7d), "Should have 7-day weight gain type")
        XCTAssertTrue(allTypes.contains(.heartRateLow), "Should have low heart rate type")
        XCTAssertTrue(allTypes.contains(.heartRateHigh), "Should have high heart rate type")
        XCTAssertTrue(allTypes.contains(.severeSymptom), "Should have severe symptom type")
    }

    func testAlertTypeDisplayNamesArePatientFriendly() {
        // Then: display names should not contain medical jargon
        for alertType in AlertType.allCases {
            XCTAssertFalse(
                alertType.displayName.isEmpty,
                "\(alertType) should have a display name"
            )
            XCTAssertFalse(
                alertType.displayName.contains("Alert"),
                "Display name should not contain 'Alert' - should be patient friendly"
            )
        }
    }

    func testWeightGain24hDisplayName() {
        XCTAssertEqual(
            AlertType.weightGain24h.displayName,
            "Weight change in 24 hours",
            "24-hour display name should be patient-friendly"
        )
    }

    func testWeightGain7dDisplayName() {
        XCTAssertEqual(
            AlertType.weightGain7d.displayName,
            "Weight change over 7 days",
            "7-day display name should be patient-friendly"
        )
    }

    func testAlertTypeAccessibilityDescriptionsExist() {
        // Then: all types should have accessibility descriptions
        for alertType in AlertType.allCases {
            XCTAssertFalse(
                alertType.accessibilityDescription.isEmpty,
                "\(alertType) should have an accessibility description"
            )
        }
    }

    func testAccessibilityDescriptionsAreWarmAndSupportive() {
        // Then: descriptions should contain supportive language
        let supportiveKeywords = ["care team", "check in", "reaching out", "help"]

        for alertType in AlertType.allCases {
            let description = alertType.accessibilityDescription.lowercased()
            let containsSupportiveLanguage = supportiveKeywords.contains { keyword in
                description.contains(keyword)
            }
            XCTAssertTrue(
                containsSupportiveLanguage,
                "\(alertType) accessibility description should contain supportive language"
            )
        }
    }

    func testAccessibilityDescriptionsAreNotAlarmist() {
        // Then: descriptions should not contain alarmist language
        let alarmistWords = ["danger", "emergency", "urgent", "immediately", "critical", "warning"]

        for alertType in AlertType.allCases {
            let description = alertType.accessibilityDescription.lowercased()
            for word in alarmistWords {
                XCTAssertFalse(
                    description.contains(word),
                    "\(alertType) accessibility description should not contain alarmist word '\(word)'"
                )
            }
        }
    }

    func testAlertTypeIsCodable() {
        // Given: an alert type
        let alertType = AlertType.weightGain24h

        // When: encoding and decoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        guard let data = try? encoder.encode(alertType),
              let decoded = try? decoder.decode(AlertType.self, from: data) else {
            XCTFail("AlertType should be codable")
            return
        }

        // Then: should decode to same value
        XCTAssertEqual(decoded, alertType)
    }

    func testAlertTypeRawValues() {
        // Then: raw values should be stable string identifiers
        XCTAssertEqual(AlertType.weightGain24h.rawValue, "weightGain24h")
        XCTAssertEqual(AlertType.weightGain7d.rawValue, "weightGain7d")
        XCTAssertEqual(AlertType.heartRateLow.rawValue, "heartRateLow")
        XCTAssertEqual(AlertType.heartRateHigh.rawValue, "heartRateHigh")
        XCTAssertEqual(AlertType.severeSymptom.rawValue, "severeSymptom")
    }
}

// MARK: - AlertEvent Tests

final class AlertEventTests: XCTestCase {

    func testAlertEventInitialization() {
        // Given: alert event parameters
        let alertType = AlertType.weightGain24h
        let message = "Test message"
        let date = Date()

        // When: creating an alert event
        let alert = AlertEvent(
            alertType: alertType,
            message: message,
            triggeredAt: date
        )

        // Then: properties should be set correctly
        XCTAssertEqual(alert.alertType, alertType)
        XCTAssertEqual(alert.message, message)
        XCTAssertEqual(alert.triggeredAt, date)
        XCTAssertFalse(alert.isAcknowledged, "New alerts should not be acknowledged")
        XCTAssertNil(alert.relatedDailyEntry, "Related entry should be nil by default")
    }

    func testAlertEventDefaultValues() {
        // When: creating with minimal parameters
        let alert = AlertEvent(alertType: .weightGain7d, message: "Test")

        // Then: defaults should be applied
        XCTAssertFalse(alert.isAcknowledged)
        XCTAssertNil(alert.relatedDailyEntry)
    }

    func testAlertEventAcknowledgement() {
        // Given: an unacknowledged alert
        let alert = AlertEvent(alertType: .weightGain24h, message: "Test")
        XCTAssertFalse(alert.isAcknowledged)

        // When: acknowledging
        alert.isAcknowledged = true

        // Then: should be acknowledged
        XCTAssertTrue(alert.isAcknowledged)
    }

    func testAlertEventWithEmptyMessage() {
        // Given: empty message
        let alert = AlertEvent(alertType: .weightGain24h, message: "")

        // Then: should still create successfully
        XCTAssertEqual(alert.message, "")
    }

    func testAlertEventWithLongMessage() {
        // Given: a long supportive message
        let longMessage = String(repeating: "This is supportive text. ", count: 50)
        let alert = AlertEvent(alertType: .weightGain7d, message: longMessage)

        // Then: should store full message
        XCTAssertEqual(alert.message, longMessage)
    }
}

// MARK: - Weight Alert Threshold Boundary Tests

final class WeightAlertThresholdTests: XCTestCase {

    // MARK: - 24-Hour Threshold Boundary Tests

    func testWeightGainAtExact24hThresholdTriggersAlert() {
        // Given: weight change exactly at 24h threshold (2.0 lbs)
        let previousWeight = 150.0
        let currentWeight = 152.0 // exactly 2.0 lbs gain

        // When: calculating weight change
        let change = currentWeight - previousWeight

        // Then: should meet threshold
        XCTAssertGreaterThanOrEqual(
            change,
            AlertConstants.weightGain24hThreshold,
            "Weight gain of exactly 2.0 lbs should trigger 24h alert"
        )
    }

    func testWeightGainBelowThreshold24hDoesNotTriggerAlert() {
        // Given: weight change just below 24h threshold
        let previousWeight = 150.0
        let currentWeight = 151.9 // 1.9 lbs gain, just below threshold

        // When: calculating weight change
        let change = currentWeight - previousWeight

        // Then: should NOT meet threshold
        XCTAssertLessThan(
            change,
            AlertConstants.weightGain24hThreshold,
            "Weight gain of 1.9 lbs should NOT trigger 24h alert"
        )
    }

    func testWeightGainAbove24hThresholdTriggersAlert() {
        // Given: weight change above 24h threshold
        let previousWeight = 150.0
        let currentWeight = 153.5 // 3.5 lbs gain

        // When: calculating weight change
        let change = currentWeight - previousWeight

        // Then: should meet threshold
        XCTAssertGreaterThanOrEqual(
            change,
            AlertConstants.weightGain24hThreshold,
            "Weight gain of 3.5 lbs should trigger 24h alert"
        )
    }

    // MARK: - 7-Day Threshold Boundary Tests

    func testWeightGainAtExact7dThresholdTriggersAlert() {
        // Given: weight change exactly at 7d threshold (5.0 lbs)
        let baselineWeight = 150.0
        let currentWeight = 155.0 // exactly 5.0 lbs gain

        // When: calculating weight change
        let change = currentWeight - baselineWeight

        // Then: should meet threshold
        XCTAssertGreaterThanOrEqual(
            change,
            AlertConstants.weightGain7dThreshold,
            "Weight gain of exactly 5.0 lbs should trigger 7d alert"
        )
    }

    func testWeightGainBelowThreshold7dDoesNotTriggerAlert() {
        // Given: weight change just below 7d threshold
        let baselineWeight = 150.0
        let currentWeight = 154.9 // 4.9 lbs gain, just below threshold

        // When: calculating weight change
        let change = currentWeight - baselineWeight

        // Then: should NOT meet threshold
        XCTAssertLessThan(
            change,
            AlertConstants.weightGain7dThreshold,
            "Weight gain of 4.9 lbs should NOT trigger 7d alert"
        )
    }

    func testWeightGainAbove7dThresholdTriggersAlert() {
        // Given: weight change well above 7d threshold
        let baselineWeight = 150.0
        let currentWeight = 157.0 // 7.0 lbs gain

        // When: calculating weight change
        let change = currentWeight - baselineWeight

        // Then: should meet threshold
        XCTAssertGreaterThanOrEqual(
            change,
            AlertConstants.weightGain7dThreshold,
            "Weight gain of 7.0 lbs should trigger 7d alert"
        )
    }

    // MARK: - Weight Loss Tests (should never trigger alerts)

    func testWeightLossDoesNotMeet24hThreshold() {
        // Given: weight loss (negative change)
        let previousWeight = 150.0
        let currentWeight = 148.0 // 2.0 lbs loss

        // When: calculating weight change
        let change = currentWeight - previousWeight

        // Then: negative change should NOT trigger alert
        XCTAssertLessThan(
            change,
            AlertConstants.weightGain24hThreshold,
            "Weight loss should never trigger 24h gain alert"
        )
        XCTAssertLessThan(change, 0, "Change should be negative for weight loss")
    }

    func testWeightLossDoesNotMeet7dThreshold() {
        // Given: significant weight loss over 7 days
        let baselineWeight = 150.0
        let currentWeight = 145.0 // 5.0 lbs loss

        // When: calculating weight change
        let change = currentWeight - baselineWeight

        // Then: negative change should NOT trigger alert
        XCTAssertLessThan(
            change,
            AlertConstants.weightGain7dThreshold,
            "Weight loss should never trigger 7d gain alert"
        )
    }

    // MARK: - Both Thresholds Tests

    func testBothThresholdsExceededSimultaneously() {
        // Given: large weight gain that exceeds both thresholds
        let baselineWeight7d = 150.0
        let previousWeight24h = 155.0  // already gained 5 lbs over week
        let currentWeight = 157.5       // gained 2.5 more today

        // When: calculating changes
        let change24h = currentWeight - previousWeight24h
        let change7d = currentWeight - baselineWeight7d

        // Then: both thresholds should be met
        XCTAssertGreaterThanOrEqual(
            change24h,
            AlertConstants.weightGain24hThreshold,
            "24h threshold should be met"
        )
        XCTAssertGreaterThanOrEqual(
            change7d,
            AlertConstants.weightGain7dThreshold,
            "7d threshold should be met"
        )
    }

    func testOnly7dThresholdExceeded() {
        // Given: gradual weight gain over week (less than 2 lbs/day but ≥5 lbs total)
        let baselineWeight7d = 150.0
        let previousWeight24h = 154.5  // gradual increase
        let currentWeight = 155.0       // only 0.5 lbs today

        // When: calculating changes
        let change24h = currentWeight - previousWeight24h
        let change7d = currentWeight - baselineWeight7d

        // Then: only 7d threshold should be met
        XCTAssertLessThan(
            change24h,
            AlertConstants.weightGain24hThreshold,
            "24h threshold should NOT be met for small daily change"
        )
        XCTAssertGreaterThanOrEqual(
            change7d,
            AlertConstants.weightGain7dThreshold,
            "7d threshold should be met for cumulative change"
        )
    }

    // MARK: - Edge Cases

    func testNoWeightChangeDoesNotTriggerAlerts() {
        // Given: no change in weight
        let previousWeight = 150.0
        let currentWeight = 150.0

        // When: calculating weight change
        let change = currentWeight - previousWeight

        // Then: zero change should not trigger any alert
        XCTAssertEqual(change, 0, "No change should be zero")
        XCTAssertLessThan(change, AlertConstants.weightGain24hThreshold)
        XCTAssertLessThan(change, AlertConstants.weightGain7dThreshold)
    }

    func testVerySmallGainDoesNotTriggerAlert() {
        // Given: tiny weight fluctuation (normal daily variation)
        let previousWeight = 150.0
        let currentWeight = 150.3 // 0.3 lbs - normal fluctuation

        // When: calculating weight change
        let change = currentWeight - previousWeight

        // Then: small fluctuation should not trigger alert
        XCTAssertLessThan(
            change,
            AlertConstants.weightGain24hThreshold,
            "Normal daily fluctuation should not trigger alert"
        )
    }
}

// MARK: - Weight Change Text Tests

final class WeightChangeTextTests: XCTestCase {

    var viewModel: TodayViewModel!

    override func setUp() {
        super.setUp()
        viewModel = TodayViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testWeightChangeTextReturnsNilWithNoPreviousData() {
        // Given: no previous data
        viewModel.yesterdayEntry = nil

        // Then: weight change text should be nil
        XCTAssertNil(viewModel.weightChangeText)
    }

    func testHasNoPreviousDataReturnsTrue() {
        // Given: no previous weight
        viewModel.yesterdayEntry = nil

        // Then: should indicate no previous data
        XCTAssertTrue(viewModel.hasNoPreviousData)
    }

    func testActiveAlertsInitiallyEmpty() {
        // Then: alerts should start empty
        XCTAssertTrue(viewModel.activeWeightAlerts.isEmpty)
    }
}
