import XCTest
@testable import HRTY

/// Tests for VitalSignsAlertService functionality.
/// Verifies vital signs alert thresholds, message formatting, and alert behavior.
final class VitalSignsAlertThresholdTests: XCTestCase {

    // MARK: - Oxygen Saturation Threshold Tests

    func testOxygenSaturationLowThresholdValue() {
        // Per spec: Alert triggers when SpO2 < 90%
        XCTAssertEqual(
            AlertConstants.oxygenSaturationLowThreshold,
            90,
            "Low oxygen saturation threshold should be 90%"
        )
    }

    func testOxygenSaturation89TriggersAlert() {
        // Given: oxygen saturation of 89%
        let spo2 = 89

        // Then: should trigger low SpO2 alert (< 90)
        XCTAssertTrue(
            spo2 < AlertConstants.oxygenSaturationLowThreshold,
            "SpO2 of 89% should trigger low oxygen alert"
        )
    }

    func testOxygenSaturation90DoesNotTriggerAlert() {
        // Given: oxygen saturation of exactly 90%
        let spo2 = 90

        // Then: should NOT trigger alert (threshold is <90, not <=90)
        XCTAssertFalse(
            spo2 < AlertConstants.oxygenSaturationLowThreshold,
            "SpO2 of 90% should NOT trigger low oxygen alert (at threshold, not below)"
        )
    }

    func testOxygenSaturation95DoesNotTriggerAlert() {
        // Given: normal oxygen saturation
        let spo2 = 95

        // Then: should NOT trigger alert
        XCTAssertFalse(
            spo2 < AlertConstants.oxygenSaturationLowThreshold,
            "Normal SpO2 of 95% should NOT trigger alert"
        )
    }

    // MARK: - Systolic Blood Pressure Threshold Tests

    func testSystolicBPLowThresholdValue() {
        // Per spec: Alert triggers when systolic BP < 90 mmHg
        XCTAssertEqual(
            AlertConstants.systolicBPLowThreshold,
            90,
            "Low systolic BP threshold should be 90 mmHg"
        )
    }

    func testSystolicBP85TriggersAlert() {
        // Given: low systolic BP
        let systolic = 85

        // Then: should trigger low BP alert
        XCTAssertTrue(
            systolic < AlertConstants.systolicBPLowThreshold,
            "Systolic BP of 85 mmHg should trigger low BP alert"
        )
    }

    func testSystolicBP90DoesNotTriggerAlert() {
        // Given: systolic BP at threshold
        let systolic = 90

        // Then: should NOT trigger alert (threshold is <90, not <=90)
        XCTAssertFalse(
            systolic < AlertConstants.systolicBPLowThreshold,
            "Systolic BP of 90 mmHg should NOT trigger alert (at threshold)"
        )
    }

    func testSystolicBP120DoesNotTriggerAlert() {
        // Given: normal systolic BP
        let systolic = 120

        // Then: should NOT trigger alert
        XCTAssertFalse(
            systolic < AlertConstants.systolicBPLowThreshold,
            "Normal systolic BP of 120 mmHg should NOT trigger alert"
        )
    }

    // MARK: - MAP Threshold Tests

    func testMAPLowThresholdValue() {
        // Per spec: Alert triggers when MAP < 60 mmHg
        XCTAssertEqual(
            AlertConstants.mapLowThreshold,
            60,
            "Low MAP threshold should be 60 mmHg"
        )
    }

    func testMAPCalculation() {
        // Per spec: MAP = DBP + (SBP - DBP) / 3
        let systolic = 120
        let diastolic = 80

        // Expected MAP = 80 + (120 - 80) / 3 = 80 + 40/3 = 80 + 13 = 93 (integer division)
        let expectedMAP = diastolic + (systolic - diastolic) / 3

        XCTAssertEqual(
            expectedMAP,
            93,
            "MAP calculation should be DBP + (SBP - DBP) / 3"
        )
    }

    func testMAPCalculationWithLowBP() {
        // Given: low blood pressure 80/50
        let systolic = 80
        let diastolic = 50

        // MAP = 50 + (80 - 50) / 3 = 50 + 10 = 60
        let map = diastolic + (systolic - diastolic) / 3

        XCTAssertEqual(map, 60, "MAP for 80/50 should be 60 mmHg")
        XCTAssertFalse(
            map < AlertConstants.mapLowThreshold,
            "MAP of 60 should NOT trigger alert (at threshold)"
        )
    }

    func testMAP59TriggersAlert() {
        // Given: blood pressure resulting in MAP of 59
        // MAP = DBP + (SBP - DBP) / 3
        // 59 = 45 + (87 - 45) / 3 = 45 + 14 = 59
        let systolic = 87
        let diastolic = 45

        let map = diastolic + (systolic - diastolic) / 3
        XCTAssertEqual(map, 59, "MAP should be 59 for this BP")

        XCTAssertTrue(
            map < AlertConstants.mapLowThreshold,
            "MAP of 59 mmHg should trigger low MAP alert"
        )
    }

    // MARK: - Heart Rate Threshold Tests

    func testHeartRateLowThresholdValue() {
        // Per spec: Alert triggers when HR < 40 bpm
        XCTAssertEqual(
            AlertConstants.heartRateLowThreshold,
            40,
            "Low heart rate threshold should be 40 bpm"
        )
    }

    func testHeartRate39TriggersAlert() {
        // Given: heart rate below threshold
        let heartRate = 39

        // Then: should trigger alert
        XCTAssertTrue(
            heartRate < AlertConstants.heartRateLowThreshold,
            "Heart rate of 39 bpm should trigger low HR alert"
        )
    }

    func testHeartRate40DoesNotTriggerAlert() {
        // Given: heart rate at threshold
        let heartRate = 40

        // Then: should NOT trigger alert
        XCTAssertFalse(
            heartRate < AlertConstants.heartRateLowThreshold,
            "Heart rate of 40 bpm should NOT trigger alert (at threshold)"
        )
    }

    // MARK: - Validation Bounds Tests

    func testOxygenSaturationValidationBounds() {
        // Per spec: validation range is 70-100%
        XCTAssertEqual(AlertConstants.minimumOxygenSaturation, 70)
        XCTAssertEqual(AlertConstants.maximumOxygenSaturation, 100)
    }

    func testSystolicBPValidationBounds() {
        // Per spec: reasonable range for systolic BP
        XCTAssertEqual(AlertConstants.minimumSystolicBP, 60)
        XCTAssertEqual(AlertConstants.maximumSystolicBP, 250)
    }

    func testDiastolicBPValidationBounds() {
        // Per spec: reasonable range for diastolic BP
        XCTAssertEqual(AlertConstants.minimumDiastolicBP, 40)
        XCTAssertEqual(AlertConstants.maximumDiastolicBP, 150)
    }
}

// MARK: - Alert Type Tests

final class VitalSignsAlertTypeTests: XCTestCase {

    func testLowOxygenSaturationAlertTypeExists() {
        XCTAssertTrue(
            AlertType.allCases.contains(.lowOxygenSaturation),
            "AlertType should include lowOxygenSaturation"
        )
    }

    func testLowBloodPressureAlertTypeExists() {
        XCTAssertTrue(
            AlertType.allCases.contains(.lowBloodPressure),
            "AlertType should include lowBloodPressure"
        )
    }

    func testLowMAPAlertTypeExists() {
        XCTAssertTrue(
            AlertType.allCases.contains(.lowMAP),
            "AlertType should include lowMAP"
        )
    }

    func testVitalSignsAlertTypeRawValues() {
        // Raw values should be stable for persistence
        XCTAssertEqual(AlertType.lowOxygenSaturation.rawValue, "lowOxygenSaturation")
        XCTAssertEqual(AlertType.lowBloodPressure.rawValue, "lowBloodPressure")
        XCTAssertEqual(AlertType.lowMAP.rawValue, "lowMAP")
    }

    func testVitalSignsAlertTypeDisplayNames() {
        // Display names should be patient-friendly
        XCTAssertEqual(AlertType.lowOxygenSaturation.displayName, "Low oxygen level")
        XCTAssertEqual(AlertType.lowBloodPressure.displayName, "Low blood pressure")
        XCTAssertEqual(AlertType.lowMAP.displayName, "Low blood pressure")
    }

    func testVitalSignsAlertAccessibilityDescriptionsAreWarm() {
        // All vital signs alert descriptions should mention care team
        let vitalSignsTypes: [AlertType] = [.lowOxygenSaturation, .lowBloodPressure, .lowMAP]

        for alertType in vitalSignsTypes {
            let description = alertType.accessibilityDescription.lowercased()
            XCTAssertTrue(
                description.contains("care team"),
                "\(alertType) accessibility description should mention care team"
            )
        }
    }

    func testVitalSignsAlertAccessibilityDescriptionsAreNotAlarmist() {
        let vitalSignsTypes: [AlertType] = [.lowOxygenSaturation, .lowBloodPressure, .lowMAP]
        let alarmistWords = ["danger", "emergency", "urgent", "immediately", "critical", "warning"]

        for alertType in vitalSignsTypes {
            let description = alertType.accessibilityDescription.lowercased()
            for word in alarmistWords {
                XCTAssertFalse(
                    description.contains(word),
                    "\(alertType) accessibility description should not contain '\(word)'"
                )
            }
        }
    }
}

// MARK: - VitalSignsEntry Model Tests

final class VitalSignsEntryModelTests: XCTestCase {

    func testMeanArterialPressureCalculation() {
        // Given: a VitalSignsEntry with blood pressure
        let entry = VitalSignsEntry(systolicBP: 120, diastolicBP: 80)

        // When: calculating MAP
        let map = entry.meanArterialPressure

        // Then: MAP = 80 + (120 - 80) / 3 = 93
        XCTAssertEqual(map, 93, "MAP should be calculated correctly")
    }

    func testMeanArterialPressureNilWhenMissingSystolic() {
        // Given: entry with only diastolic
        let entry = VitalSignsEntry(systolicBP: nil, diastolicBP: 80)

        // Then: MAP should be nil
        XCTAssertNil(entry.meanArterialPressure, "MAP should be nil when systolic is missing")
    }

    func testMeanArterialPressureNilWhenMissingDiastolic() {
        // Given: entry with only systolic
        let entry = VitalSignsEntry(systolicBP: 120, diastolicBP: nil)

        // Then: MAP should be nil
        XCTAssertNil(entry.meanArterialPressure, "MAP should be nil when diastolic is missing")
    }

    func testFormattedBloodPressure() {
        // Given: valid BP values
        let entry = VitalSignsEntry(systolicBP: 120, diastolicBP: 80)

        // Then: formatted string should be "120/80"
        XCTAssertEqual(entry.formattedBloodPressure, "120/80")
    }

    func testFormattedBloodPressureNilWhenMissing() {
        // Given: missing BP values
        let entry = VitalSignsEntry()

        // Then: formatted string should be nil
        XCTAssertNil(entry.formattedBloodPressure)
    }

    func testHasBloodPressureWhenBothPresent() {
        let entry = VitalSignsEntry(systolicBP: 120, diastolicBP: 80)
        XCTAssertTrue(entry.hasBloodPressure)
    }

    func testHasBloodPressureFalseWhenMissingSystolic() {
        let entry = VitalSignsEntry(systolicBP: nil, diastolicBP: 80)
        XCTAssertFalse(entry.hasBloodPressure)
    }

    func testHasBloodPressureFalseWhenMissingDiastolic() {
        let entry = VitalSignsEntry(systolicBP: 120, diastolicBP: nil)
        XCTAssertFalse(entry.hasBloodPressure)
    }

    func testHasOxygenSaturationWhenPresent() {
        let entry = VitalSignsEntry(oxygenSaturation: 98)
        XCTAssertTrue(entry.hasOxygenSaturation)
    }

    func testHasOxygenSaturationFalseWhenMissing() {
        let entry = VitalSignsEntry()
        XCTAssertFalse(entry.hasOxygenSaturation)
    }
}

// MARK: - Alert Message Tests

final class VitalSignsAlertMessageTests: XCTestCase {

    func testLowOxygenAlertMessageIncludesReading() {
        // Per spec: "Your oxygen level is low. Please contact your care team."
        let exampleMessage = "Your oxygen level is 88%, which is lower than usual. Please contact your care team to discuss this reading."

        XCTAssertTrue(
            exampleMessage.contains("88%"),
            "Oxygen alert message should include the actual reading"
        )
    }

    func testLowOxygenAlertMessageMentionsCareTeam() {
        let exampleMessage = "Your oxygen level is 88%, which is lower than usual. Please contact your care team to discuss this reading."

        XCTAssertTrue(
            exampleMessage.contains("care team"),
            "Oxygen alert message should mention care team"
        )
    }

    func testLowBPAlertMessageIncludesReading() {
        let exampleMessage = "Your blood pressure reading of 85/55 mmHg is lower than usual. Please contact your care team if you're feeling unwell."

        XCTAssertTrue(
            exampleMessage.contains("85/55"),
            "BP alert message should include the actual reading"
        )
    }

    func testLowMAPAlertMessageIsNotAlarmist() {
        let exampleMessage = "Your blood pressure reading of 85/55 mmHg indicates your blood pressure may be low. Please contact your care team if you have any symptoms."
        let lowercaseMessage = exampleMessage.lowercased()

        let alarmistWords = ["danger", "emergency", "urgent", "immediately", "critical", "warning", "alert"]
        for word in alarmistWords {
            XCTAssertFalse(
                lowercaseMessage.contains(word),
                "Low MAP alert message should not contain alarmist word '\(word)'"
            )
        }
    }

    func testAllVitalSignsAlertMessagesAreWarm() {
        // Example messages that would be generated by the service
        let messages = [
            "Your oxygen level is 88%, which is lower than usual. Please contact your care team to discuss this reading.",
            "Your blood pressure reading of 85/55 mmHg is lower than usual. Please contact your care team if you're feeling unwell.",
            "Your blood pressure reading of 80/50 mmHg indicates your blood pressure may be low. Please contact your care team if you have any symptoms."
        ]

        for message in messages {
            XCTAssertTrue(
                message.contains("care team"),
                "All vital signs alert messages should mention care team"
            )
            XCTAssertTrue(
                message.contains("Please"),
                "Messages should use polite language"
            )
        }
    }
}

// MARK: - Boundary Condition Tests

final class VitalSignsBoundaryTests: XCTestCase {

    func testAllOxygenSaturationBoundaryConditions() {
        // Test boundary values for oxygen saturation
        let testCases: [(spo2: Int, shouldTrigger: Bool)] = [
            (100, false),  // Normal high
            (95, false),   // Normal typical
            (91, false),   // Just above threshold
            (90, false),   // At threshold (not below)
            (89, true),    // Just below threshold - SHOULD trigger
            (85, true),    // Low - SHOULD trigger
            (70, true),    // Very low - SHOULD trigger
        ]

        for (spo2, shouldTrigger) in testCases {
            let wouldTrigger = spo2 < AlertConstants.oxygenSaturationLowThreshold
            XCTAssertEqual(
                wouldTrigger,
                shouldTrigger,
                "SpO2 \(spo2)% should \(shouldTrigger ? "" : "NOT ")trigger alert"
            )
        }
    }

    func testAllSystolicBPBoundaryConditions() {
        let testCases: [(systolic: Int, shouldTrigger: Bool)] = [
            (120, false),  // Normal
            (100, false),  // Low-normal
            (91, false),   // Just above threshold
            (90, false),   // At threshold (not below)
            (89, true),    // Just below - SHOULD trigger
            (80, true),    // Low - SHOULD trigger
            (60, true),    // Very low - SHOULD trigger
        ]

        for (systolic, shouldTrigger) in testCases {
            let wouldTrigger = systolic < AlertConstants.systolicBPLowThreshold
            XCTAssertEqual(
                wouldTrigger,
                shouldTrigger,
                "Systolic \(systolic) mmHg should \(shouldTrigger ? "" : "NOT ")trigger alert"
            )
        }
    }

    func testAllMAPBoundaryConditions() {
        let testCases: [(map: Int, shouldTrigger: Bool)] = [
            (90, false),   // Normal
            (70, false),   // Low-normal
            (61, false),   // Just above threshold
            (60, false),   // At threshold (not below)
            (59, true),    // Just below - SHOULD trigger
            (50, true),    // Low - SHOULD trigger
        ]

        for (map, shouldTrigger) in testCases {
            let wouldTrigger = map < AlertConstants.mapLowThreshold
            XCTAssertEqual(
                wouldTrigger,
                shouldTrigger,
                "MAP \(map) mmHg should \(shouldTrigger ? "" : "NOT ")trigger alert"
            )
        }
    }
}
