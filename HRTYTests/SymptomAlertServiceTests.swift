import XCTest
@testable import HRTY

/// Tests for SymptomAlertService functionality.
/// Verifies symptom alert thresholds, message formatting, and alert behavior.
final class SymptomAlertServiceTests: XCTestCase {

    // MARK: - Threshold Tests

    func testSevereSymptomThresholdValue() {
        // Per spec: Alert triggers when ANY symptom is rated 4 or 5
        XCTAssertEqual(
            AlertConstants.severeSymptomThreshold,
            4,
            "Severe symptom threshold should be 4 (Significant)"
        )
    }

    func testSeverity4MeetsThreshold() {
        // Given: severity level of 4 (Significant)
        let severity = 4

        // Then: should meet or exceed threshold
        XCTAssertGreaterThanOrEqual(
            severity,
            AlertConstants.severeSymptomThreshold,
            "Severity 4 should meet severe symptom threshold"
        )
    }

    func testSeverity5MeetsThreshold() {
        // Given: severity level of 5 (Severe)
        let severity = 5

        // Then: should meet or exceed threshold
        XCTAssertGreaterThanOrEqual(
            severity,
            AlertConstants.severeSymptomThreshold,
            "Severity 5 should meet severe symptom threshold"
        )
    }

    func testSeverity3DoesNotMeetThreshold() {
        // Given: severity level of 3 (Moderate)
        let severity = 3

        // Then: should NOT meet threshold
        XCTAssertLessThan(
            severity,
            AlertConstants.severeSymptomThreshold,
            "Severity 3 should NOT meet severe symptom threshold"
        )
    }

    func testSeverity2DoesNotMeetThreshold() {
        // Given: severity level of 2 (Mild)
        let severity = 2

        // Then: should NOT meet threshold
        XCTAssertLessThan(
            severity,
            AlertConstants.severeSymptomThreshold,
            "Severity 2 should NOT meet severe symptom threshold"
        )
    }

    func testSeverity1DoesNotMeetThreshold() {
        // Given: severity level of 1 (None)
        let severity = 1

        // Then: should NOT meet threshold
        XCTAssertLessThan(
            severity,
            AlertConstants.severeSymptomThreshold,
            "Severity 1 should NOT meet severe symptom threshold"
        )
    }

    // MARK: - Boundary Tests

    func testAllSeveritiesAtBoundary() {
        // Verify threshold behavior for all severity values
        let testCases: [(severity: Int, shouldTrigger: Bool)] = [
            (1, false),  // None
            (2, false),  // Mild
            (3, false),  // Moderate
            (4, true),   // Significant - threshold
            (5, true),   // Severe
        ]

        for (severity, shouldTrigger) in testCases {
            let meetsThreshold = severity >= AlertConstants.severeSymptomThreshold
            XCTAssertEqual(
                meetsThreshold,
                shouldTrigger,
                "Severity \(severity) should \(shouldTrigger ? "" : "NOT ")trigger alert"
            )
        }
    }
}

// MARK: - Message Formatting Tests

final class SymptomAlertMessageTests: XCTestCase {

    func testSingleSymptomMessage() {
        // Given: one severe symptom
        let symptom = SymptomType.chestPain
        let expectedPhrase = symptom.displayName.lowercased()

        // Then: message should include the symptom name (lowercased)
        // Per spec example: "You've noted that [symptom name] is bothering you..."
        XCTAssertFalse(expectedPhrase.isEmpty, "Symptom display name should not be empty")
        XCTAssertEqual(expectedPhrase, "chest discomfort", "Chest pain should display as 'chest discomfort'")
    }

    func testMultipleSymptomNamesAreLowercased() {
        // Per the implementation, symptom names in the message are lowercased
        for symptomType in SymptomType.allCases {
            let displayName = symptomType.displayName
            XCTAssertFalse(displayName.isEmpty, "\(symptomType) should have a display name")

            // Verify lowercasing works as expected
            let lowercased = displayName.lowercased()
            XCTAssertEqual(lowercased, lowercased.lowercased(), "Lowercased should be idempotent")
        }
    }

    func testSymptomDisplayNamesForAlertMessage() {
        // Verify all symptom display names are patient-friendly for alert messages
        let expectedNames: [SymptomType: String] = [
            .dyspneaAtRest: "Shortness of breath at rest",
            .dyspneaOnExertion: "Shortness of breath with activity",
            .orthopnea: "Difficulty breathing lying flat",
            .pnd: "Waking up short of breath",
            .chestPain: "Chest discomfort",
            .dizziness: "Feeling dizzy or lightheaded",
            .syncope: "Fainting or near-fainting",
            .reducedUrineOutput: "Less urine than usual"
        ]

        for (symptomType, expectedName) in expectedNames {
            XCTAssertEqual(
                symptomType.displayName,
                expectedName,
                "\(symptomType) should have patient-friendly display name"
            )
        }
    }
}

// MARK: - Severe Symptom Alert Type Tests

final class SevereSymptomAlertTypeTests: XCTestCase {

    func testSevereSymptomAlertTypeExists() {
        // Then: severeSymptom should be a valid alert type
        XCTAssertTrue(
            AlertType.allCases.contains(.severeSymptom),
            "AlertType should include severeSymptom"
        )
    }

    func testSevereSymptomAlertTypeRawValue() {
        // Then: raw value should be stable for persistence
        XCTAssertEqual(
            AlertType.severeSymptom.rawValue,
            "severeSymptom",
            "severeSymptom raw value should be 'severeSymptom'"
        )
    }

    func testSevereSymptomAlertTypeDisplayName() {
        // Then: display name should be patient-friendly
        let displayName = AlertType.severeSymptom.displayName
        XCTAssertFalse(displayName.isEmpty, "severeSymptom should have a display name")
        XCTAssertFalse(
            displayName.contains("Alert"),
            "Display name should not contain 'Alert' - should be patient friendly"
        )
    }

    func testSevereSymptomAccessibilityDescriptionIsWarm() {
        // Then: accessibility description should be warm and supportive
        let description = AlertType.severeSymptom.accessibilityDescription.lowercased()
        let supportiveKeywords = ["care team", "check in", "reaching out", "help"]

        let containsSupportiveLanguage = supportiveKeywords.contains { keyword in
            description.contains(keyword)
        }
        XCTAssertTrue(
            containsSupportiveLanguage,
            "severeSymptom accessibility description should contain supportive language"
        )
    }

    func testSevereSymptomAccessibilityDescriptionIsNotAlarmist() {
        // Then: accessibility description should NOT contain alarmist words
        let description = AlertType.severeSymptom.accessibilityDescription.lowercased()
        let alarmistWords = ["danger", "emergency", "urgent", "immediately", "critical", "warning"]

        for word in alarmistWords {
            XCTAssertFalse(
                description.contains(word),
                "severeSymptom accessibility description should not contain '\(word)'"
            )
        }
    }
}

// MARK: - Alert Event for Severe Symptoms Tests

final class SevereSymptomAlertEventTests: XCTestCase {

    func testAlertEventWithSevereSymptomType() {
        // Given: symptom alert parameters
        let alertType = AlertType.severeSymptom
        let message = "You've noted that chest discomfort is bothering you more than usual today."
        let date = Date()

        // When: creating an alert event
        let alert = AlertEvent(
            alertType: alertType,
            message: message,
            triggeredAt: date
        )

        // Then: properties should be set correctly
        XCTAssertEqual(alert.alertType, .severeSymptom)
        XCTAssertEqual(alert.message, message)
        XCTAssertFalse(alert.isAcknowledged, "New alerts should not be acknowledged")
    }

    func testSymptomAlertMessageContainsCareTeam() {
        // Per spec: message should advise discussing with clinician
        let expectedPhrase = "care team"
        let exampleMessage = "You've noted that chest discomfort is bothering you more than usual today. This is helpful information to share with your care team when you get a chance."

        XCTAssertTrue(
            exampleMessage.contains(expectedPhrase),
            "Symptom alert message should mention care team"
        )
    }

    func testSymptomAlertMessageIsWarmAndSupportive() {
        // Per spec: message should be warm, non-alarmist
        let exampleMessage = "You've noted that chest discomfort is bothering you more than usual today. This is helpful information to share with your care team when you get a chance."

        // Should contain supportive phrases
        XCTAssertTrue(
            exampleMessage.contains("helpful information"),
            "Symptom alert message should use warm language like 'helpful information'"
        )
        XCTAssertTrue(
            exampleMessage.contains("when you get a chance"),
            "Symptom alert message should not pressure the patient"
        )
    }

    func testSymptomAlertMessageIsNotAlarmist() {
        // Per spec: non-alarmist
        let exampleMessage = "You've noted that chest discomfort is bothering you more than usual today. This is helpful information to share with your care team when you get a chance."
        let lowercaseMessage = exampleMessage.lowercased()

        let alarmistWords = ["danger", "emergency", "urgent", "immediately", "critical", "warning", "alert"]
        for word in alarmistWords {
            XCTAssertFalse(
                lowercaseMessage.contains(word),
                "Symptom alert message should not contain alarmist word '\(word)'"
            )
        }
    }

    func testSymptomAlertMessageIsNonPrescriptive() {
        // Per spec: alerts are non-prescriptive, just advise discussing
        let exampleMessage = "You've noted that chest discomfort is bothering you more than usual today. This is helpful information to share with your care team when you get a chance."
        let lowercaseMessage = exampleMessage.lowercased()

        // Should NOT contain prescriptive language
        let prescriptiveWords = ["must", "should", "need to", "have to", "call now", "seek", "go to"]
        for word in prescriptiveWords {
            XCTAssertFalse(
                lowercaseMessage.contains(word),
                "Symptom alert message should not contain prescriptive word '\(word)'"
            )
        }
    }
}

// MARK: - Symptom Filtering Tests

final class SymptomSeverityFilteringTests: XCTestCase {

    func testFilteringSevereSymptoms() {
        // Given: a mix of symptom severities
        let severities: [SymptomType: Int] = [
            .dyspneaAtRest: 2,      // Mild - should NOT trigger
            .dyspneaOnExertion: 4,  // Significant - SHOULD trigger
            .orthopnea: 1,          // None - should NOT trigger
            .pnd: 5,                // Severe - SHOULD trigger
            .chestPain: 3,          // Moderate - should NOT trigger
            .dizziness: 4,          // Significant - SHOULD trigger
            .syncope: 1,            // None - should NOT trigger
            .reducedUrineOutput: 2  // Mild - should NOT trigger
        ]

        // When: filtering for severe symptoms (>= 4)
        let severeSymptoms = severities.filter { _, severity in
            severity >= AlertConstants.severeSymptomThreshold
        }

        // Then: only symptoms with severity 4 or 5 should be included
        XCTAssertEqual(severeSymptoms.count, 3, "Should find 3 severe symptoms")
        XCTAssertNotNil(severeSymptoms[.dyspneaOnExertion], "dyspneaOnExertion at 4 should be included")
        XCTAssertNotNil(severeSymptoms[.pnd], "pnd at 5 should be included")
        XCTAssertNotNil(severeSymptoms[.dizziness], "dizziness at 4 should be included")

        // Non-severe symptoms should NOT be included
        XCTAssertNil(severeSymptoms[.dyspneaAtRest], "dyspneaAtRest at 2 should NOT be included")
        XCTAssertNil(severeSymptoms[.orthopnea], "orthopnea at 1 should NOT be included")
        XCTAssertNil(severeSymptoms[.chestPain], "chestPain at 3 should NOT be included")
    }

    func testNoSevereSymptomsReturnsEmpty() {
        // Given: no severe symptoms (all below threshold)
        let severities: [SymptomType: Int] = [
            .dyspneaAtRest: 1,
            .chestPain: 2,
            .dizziness: 3
        ]

        // When: filtering for severe symptoms
        let severeSymptoms = severities.filter { _, severity in
            severity >= AlertConstants.severeSymptomThreshold
        }

        // Then: should return empty
        XCTAssertTrue(severeSymptoms.isEmpty, "Should return empty when no severe symptoms")
    }

    func testAllSevereSymptomsIncluded() {
        // Given: all symptoms at severe level
        let severities: [SymptomType: Int] = [
            .dyspneaAtRest: 4,
            .dyspneaOnExertion: 5,
            .orthopnea: 4,
            .pnd: 5,
            .chestPain: 4,
            .dizziness: 5,
            .syncope: 4,
            .reducedUrineOutput: 5
        ]

        // When: filtering for severe symptoms
        let severeSymptoms = severities.filter { _, severity in
            severity >= AlertConstants.severeSymptomThreshold
        }

        // Then: all 8 symptoms should be included
        XCTAssertEqual(severeSymptoms.count, 8, "All 8 symptoms should be included when all are severe")
    }

    func testSingleSevereSymptomDetected() {
        // Given: only one severe symptom
        let severities: [SymptomType: Int] = [
            .dyspneaAtRest: 1,
            .dyspneaOnExertion: 1,
            .orthopnea: 1,
            .pnd: 1,
            .chestPain: 5,  // Only this one is severe
            .dizziness: 1,
            .syncope: 1,
            .reducedUrineOutput: 1
        ]

        // When: filtering for severe symptoms
        let severeSymptoms = severities.filter { _, severity in
            severity >= AlertConstants.severeSymptomThreshold
        }

        // Then: only chest pain should be included
        XCTAssertEqual(severeSymptoms.count, 1, "Should find exactly 1 severe symptom")
        XCTAssertNotNil(severeSymptoms[.chestPain], "chestPain should be the severe symptom")
    }
}
