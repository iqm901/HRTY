import XCTest
@testable import HRTY

final class SymptomTypeTests: XCTestCase {

    func testAllSymptomsExist() {
        // Verify all 8 symptoms are defined per spec
        XCTAssertEqual(SymptomType.allCases.count, 8, "Should have exactly 8 symptoms")
        XCTAssertTrue(SymptomType.allCases.contains(.dyspneaAtRest))
        XCTAssertTrue(SymptomType.allCases.contains(.dyspneaOnExertion))
        XCTAssertTrue(SymptomType.allCases.contains(.orthopnea))
        XCTAssertTrue(SymptomType.allCases.contains(.pnd))
        XCTAssertTrue(SymptomType.allCases.contains(.chestPain))
        XCTAssertTrue(SymptomType.allCases.contains(.dizziness))
        XCTAssertTrue(SymptomType.allCases.contains(.syncope))
        XCTAssertTrue(SymptomType.allCases.contains(.reducedUrineOutput))
    }

    func testDisplayNamesArePatientFriendly() {
        // Per spec: use patient-friendly names, not medical jargon
        XCTAssertEqual(SymptomType.dyspneaAtRest.displayName, "Shortness of breath at rest")
        XCTAssertEqual(SymptomType.dyspneaOnExertion.displayName, "Shortness of breath with activity")
        XCTAssertEqual(SymptomType.orthopnea.displayName, "Difficulty breathing lying flat")
        XCTAssertEqual(SymptomType.pnd.displayName, "Waking up short of breath")
        XCTAssertEqual(SymptomType.chestPain.displayName, "Chest discomfort")
        XCTAssertEqual(SymptomType.dizziness.displayName, "Feeling dizzy or lightheaded")
        XCTAssertEqual(SymptomType.syncope.displayName, "Fainting or near-fainting")
        XCTAssertEqual(SymptomType.reducedUrineOutput.displayName, "Less urine than usual")
    }

    func testDisplayNamesDoNotContainMedicalJargon() {
        // Ensure display names don't use medical terminology
        let medicalTerms = ["dyspnea", "orthopnea", "pnd", "syncope", "paroxysmal"]

        for symptom in SymptomType.allCases {
            let displayName = symptom.displayName.lowercased()
            for term in medicalTerms {
                XCTAssertFalse(
                    displayName.contains(term),
                    "\(symptom.displayName) should not contain medical term '\(term)'"
                )
            }
        }
    }

    func testSymptomTypeIsCodable() {
        // Verify SymptomType can be encoded and decoded (for persistence)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for symptom in SymptomType.allCases {
            do {
                let encoded = try encoder.encode(symptom)
                let decoded = try decoder.decode(SymptomType.self, from: encoded)
                XCTAssertEqual(symptom, decoded, "\(symptom) should encode/decode correctly")
            } catch {
                XCTFail("Failed to encode/decode \(symptom): \(error)")
            }
        }
    }

    func testSymptomTypeCanBeUsedAsDictionaryKey() {
        // Verify SymptomType can be used as dictionary key (needed for symptomSeverities)
        var severities: [SymptomType: Int] = [:]

        for (index, symptom) in SymptomType.allCases.enumerated() {
            severities[symptom] = index + 1
        }

        XCTAssertEqual(severities.count, SymptomType.allCases.count)
        XCTAssertEqual(severities[.dyspneaAtRest], 1)
        XCTAssertEqual(severities[.reducedUrineOutput], 8)
    }
}

final class SeverityLevelTests: XCTestCase {

    func testAllSeverityLevelsExist() {
        // Verify all 5 severity levels (1-5) are defined
        XCTAssertEqual(SeverityLevel.allCases.count, 5, "Should have exactly 5 severity levels")
    }

    func testSeverityRawValues() {
        // Verify severity levels map to correct integers
        XCTAssertEqual(SeverityLevel.none.rawValue, 1)
        XCTAssertEqual(SeverityLevel.mild.rawValue, 2)
        XCTAssertEqual(SeverityLevel.moderate.rawValue, 3)
        XCTAssertEqual(SeverityLevel.significant.rawValue, 4)
        XCTAssertEqual(SeverityLevel.severe.rawValue, 5)
    }

    func testSeverityLabels() {
        // Verify human-readable labels
        XCTAssertEqual(SeverityLevel.none.label, "None")
        XCTAssertEqual(SeverityLevel.mild.label, "Mild")
        XCTAssertEqual(SeverityLevel.moderate.label, "Moderate")
        XCTAssertEqual(SeverityLevel.significant.label, "Significant")
        XCTAssertEqual(SeverityLevel.severe.label, "Severe")
    }

    func testSeverityInitializationFromValidRawValue() {
        // Verify initialization with valid raw values (1-5)
        XCTAssertEqual(SeverityLevel(rawValue: 1), SeverityLevel.none)
        XCTAssertEqual(SeverityLevel(rawValue: 2), SeverityLevel.mild)
        XCTAssertEqual(SeverityLevel(rawValue: 3), SeverityLevel.moderate)
        XCTAssertEqual(SeverityLevel(rawValue: 4), SeverityLevel.significant)
        XCTAssertEqual(SeverityLevel(rawValue: 5), SeverityLevel.severe)
    }

    func testSeverityInitializationFromInvalidRawValue() {
        // Verify initialization fails for invalid raw values
        XCTAssertNil(SeverityLevel(rawValue: 0), "0 is below valid range")
        XCTAssertNil(SeverityLevel(rawValue: -1), "Negative values are invalid")
        XCTAssertNil(SeverityLevel(rawValue: 6), "6 is above valid range")
        XCTAssertNil(SeverityLevel(rawValue: 100), "Large values are invalid")
    }

    func testSeverityColorsExist() {
        // Verify each severity level has a color
        for level in SeverityLevel.allCases {
            // Colors are opaque types, we just verify they exist without crashing
            _ = level.color
        }
    }

    func testSeverityLevelOrder() {
        // Verify severity levels are ordered by raw value (1=least severe, 5=most severe)
        let ordered = SeverityLevel.allCases.sorted { $0.rawValue < $1.rawValue }
        XCTAssertEqual(ordered[0], SeverityLevel.none)
        XCTAssertEqual(ordered[1], .mild)
        XCTAssertEqual(ordered[2], .moderate)
        XCTAssertEqual(ordered[3], .significant)
        XCTAssertEqual(ordered[4], .severe)
    }
}

final class SymptomEntryTests: XCTestCase {

    func testDefaultSeverityIsOne() {
        // Per spec: defaults to 1 (none) for new entries
        let entry = SymptomEntry(symptomType: .dyspneaAtRest)
        XCTAssertEqual(entry.severity, 1, "Default severity should be 1")
    }

    func testSeverityClampingLowerBound() {
        // Severity should be clamped to minimum of 1
        let entry = SymptomEntry(symptomType: .chestPain, severity: 0)
        XCTAssertEqual(entry.severity, 1, "Severity below 1 should be clamped to 1")

        let entryNegative = SymptomEntry(symptomType: .chestPain, severity: -5)
        XCTAssertEqual(entryNegative.severity, 1, "Negative severity should be clamped to 1")
    }

    func testSeverityClampingUpperBound() {
        // Severity should be clamped to maximum of 5
        let entry = SymptomEntry(symptomType: .dizziness, severity: 6)
        XCTAssertEqual(entry.severity, 5, "Severity above 5 should be clamped to 5")

        let entryLarge = SymptomEntry(symptomType: .dizziness, severity: 100)
        XCTAssertEqual(entryLarge.severity, 5, "Large severity should be clamped to 5")
    }

    func testValidSeverityValues() {
        // Verify all valid severity values (1-5) are accepted
        for severity in 1...5 {
            let entry = SymptomEntry(symptomType: .syncope, severity: severity)
            XCTAssertEqual(entry.severity, severity, "Severity \(severity) should be accepted")
        }
    }

    func testSymptomTypeIsStored() {
        // Verify symptom type is correctly stored
        for symptomType in SymptomType.allCases {
            let entry = SymptomEntry(symptomType: symptomType)
            XCTAssertEqual(entry.symptomType, symptomType)
        }
    }

    func testDailyEntryRelationshipIsOptional() {
        // Verify entry can be created without a daily entry relationship
        let entry = SymptomEntry(symptomType: .orthopnea, severity: 2)
        XCTAssertNil(entry.dailyEntry, "Daily entry should be nil by default")
    }
}
