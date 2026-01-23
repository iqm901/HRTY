import XCTest
@testable import HRTY

/// Tests for MedicationConflictService functionality.
/// Verifies same-class conflicts, cross-class conflicts, and edge cases.
final class MedicationConflictServiceTests: XCTestCase {

    var sut: MedicationConflictService!

    override func setUp() {
        super.setUp()
        sut = MedicationConflictService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func makeMedication(
        name: String,
        category: HeartFailureMedication.Category?,
        isActive: Bool = true
    ) -> Medication {
        Medication(
            name: name,
            dosage: 10,
            unit: "mg",
            schedule: "Once daily",
            isDiuretic: false,
            isActive: isActive,
            categoryRawValue: category?.rawValue
        )
    }

    // MARK: - Same-Class Conflict Tests: Beta Blockers

    func testBetaBlockerConflictDetected() {
        // Given: existing beta blocker
        let metoprolol = makeMedication(name: "Metoprolol", category: .betaBlocker)

        // When: checking if adding another beta blocker would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .betaBlocker,
            existingMedications: [metoprolol]
        )

        // Then: conflict should be detected
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .sameClass(let category) = conflicts.first?.type {
            XCTAssertEqual(category, .betaBlocker, "Should be beta blocker conflict")
        } else {
            XCTFail("Should be sameClass conflict type")
        }
    }

    func testNoBetaBlockerConflictWhenNoneExists() {
        // Given: no existing beta blockers
        let lisinopril = makeMedication(name: "Lisinopril", category: .aceInhibitor)

        // When: checking if adding a beta blocker would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .betaBlocker,
            existingMedications: [lisinopril]
        )

        // Then: no conflict should be detected
        XCTAssertTrue(conflicts.isEmpty, "Should not detect any conflicts")
    }

    // MARK: - Same-Class Conflict Tests: ACE Inhibitors

    func testACEInhibitorConflictDetected() {
        // Given: existing ACE inhibitor
        let lisinopril = makeMedication(name: "Lisinopril", category: .aceInhibitor)

        // When: checking if adding another ACE inhibitor would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .aceInhibitor,
            existingMedications: [lisinopril]
        )

        // Then: conflict should be detected
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .sameClass(let category) = conflicts.first?.type {
            XCTAssertEqual(category, .aceInhibitor, "Should be ACE inhibitor conflict")
        } else {
            XCTFail("Should be sameClass conflict type")
        }
    }

    // MARK: - Same-Class Conflict Tests: ARBs

    func testARBConflictDetected() {
        // Given: existing ARB
        let losartan = makeMedication(name: "Losartan", category: .arb)

        // When: checking if adding another ARB would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .arb,
            existingMedications: [losartan]
        )

        // Then: conflict should be detected
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .sameClass(let category) = conflicts.first?.type {
            XCTAssertEqual(category, .arb, "Should be ARB conflict")
        } else {
            XCTFail("Should be sameClass conflict type")
        }
    }

    // MARK: - Same-Class Conflict Tests: MRAs

    func testMRAConflictDetected() {
        // Given: existing MRA
        let spironolactone = makeMedication(name: "Spironolactone", category: .mra)

        // When: checking if adding another MRA would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .mra,
            existingMedications: [spironolactone]
        )

        // Then: conflict should be detected
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .sameClass(let category) = conflicts.first?.type {
            XCTAssertEqual(category, .mra, "Should be MRA conflict")
        } else {
            XCTFail("Should be sameClass conflict type")
        }
    }

    // MARK: - Same-Class Conflict Tests: SGLT2 Inhibitors

    func testSGLT2InhibitorConflictDetected() {
        // Given: existing SGLT2 inhibitor
        let empagliflozin = makeMedication(name: "Empagliflozin", category: .sglt2Inhibitor)

        // When: checking if adding another SGLT2 inhibitor would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .sglt2Inhibitor,
            existingMedications: [empagliflozin]
        )

        // Then: conflict should be detected
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .sameClass(let category) = conflicts.first?.type {
            XCTAssertEqual(category, .sglt2Inhibitor, "Should be SGLT2 inhibitor conflict")
        } else {
            XCTFail("Should be sameClass conflict type")
        }
    }

    // MARK: - Cross-Class Conflict Tests: ACEi + ARB

    func testACEInhibitorARBCrossClassConflict() {
        // Given: existing ACE inhibitor
        let lisinopril = makeMedication(name: "Lisinopril", category: .aceInhibitor)

        // When: checking if adding an ARB would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .arb,
            existingMedications: [lisinopril]
        )

        // Then: cross-class conflict should be detected
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .crossClass(let cat1, let cat2) = conflicts.first?.type {
            let categories = [cat1, cat2]
            XCTAssertTrue(categories.contains(.aceInhibitor), "Should involve ACE inhibitor")
            XCTAssertTrue(categories.contains(.arb), "Should involve ARB")
        } else {
            XCTFail("Should be crossClass conflict type")
        }
    }

    func testARBACEInhibitorCrossClassConflict() {
        // Given: existing ARB
        let losartan = makeMedication(name: "Losartan", category: .arb)

        // When: checking if adding an ACE inhibitor would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .aceInhibitor,
            existingMedications: [losartan]
        )

        // Then: cross-class conflict should be detected
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .crossClass(let cat1, let cat2) = conflicts.first?.type {
            let categories = [cat1, cat2]
            XCTAssertTrue(categories.contains(.aceInhibitor), "Should involve ACE inhibitor")
            XCTAssertTrue(categories.contains(.arb), "Should involve ARB")
        } else {
            XCTFail("Should be crossClass conflict type")
        }
    }

    // MARK: - Cross-Class Conflict Tests: ACEi + ARNI

    func testACEInhibitorARNICrossClassConflict() {
        // Given: existing ACE inhibitor
        let lisinopril = makeMedication(name: "Lisinopril", category: .aceInhibitor)

        // When: checking if adding an ARNI would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .arni,
            existingMedications: [lisinopril]
        )

        // Then: cross-class conflict should be detected
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .crossClass(let cat1, let cat2) = conflicts.first?.type {
            let categories = [cat1, cat2]
            XCTAssertTrue(categories.contains(.aceInhibitor), "Should involve ACE inhibitor")
            XCTAssertTrue(categories.contains(.arni), "Should involve ARNI")
        } else {
            XCTFail("Should be crossClass conflict type")
        }
    }

    func testARNIACEInhibitorCrossClassConflict() {
        // Given: existing ARNI
        let entresto = makeMedication(name: "Entresto", category: .arni)

        // When: checking if adding an ACE inhibitor would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .aceInhibitor,
            existingMedications: [entresto]
        )

        // Then: cross-class conflict should be detected
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .crossClass(let cat1, let cat2) = conflicts.first?.type {
            let categories = [cat1, cat2]
            XCTAssertTrue(categories.contains(.aceInhibitor), "Should involve ACE inhibitor")
            XCTAssertTrue(categories.contains(.arni), "Should involve ARNI")
        } else {
            XCTFail("Should be crossClass conflict type")
        }
    }

    // MARK: - Cross-Class Conflict Tests: ARB + ARNI

    func testARBARNICrossClassConflict() {
        // Given: existing ARB
        let losartan = makeMedication(name: "Losartan", category: .arb)

        // When: checking if adding an ARNI would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .arni,
            existingMedications: [losartan]
        )

        // Then: cross-class conflict should be detected
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .crossClass(let cat1, let cat2) = conflicts.first?.type {
            let categories = [cat1, cat2]
            XCTAssertTrue(categories.contains(.arb), "Should involve ARB")
            XCTAssertTrue(categories.contains(.arni), "Should involve ARNI")
        } else {
            XCTFail("Should be crossClass conflict type")
        }
    }

    func testARNIARBCrossClassConflict() {
        // Given: existing ARNI
        let entresto = makeMedication(name: "Entresto", category: .arni)

        // When: checking if adding an ARB would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .arb,
            existingMedications: [entresto]
        )

        // Then: cross-class conflict should be detected
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .crossClass(let cat1, let cat2) = conflicts.first?.type {
            let categories = [cat1, cat2]
            XCTAssertTrue(categories.contains(.arb), "Should involve ARB")
            XCTAssertTrue(categories.contains(.arni), "Should involve ARNI")
        } else {
            XCTFail("Should be crossClass conflict type")
        }
    }

    // MARK: - No Conflict Tests

    func testNoConflictForDifferentClasses() {
        // Given: medications from different non-conflicting classes
        let metoprolol = makeMedication(name: "Metoprolol", category: .betaBlocker)
        let spironolactone = makeMedication(name: "Spironolactone", category: .mra)
        let empagliflozin = makeMedication(name: "Empagliflozin", category: .sglt2Inhibitor)

        // When: checking if adding an ACE inhibitor would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .aceInhibitor,
            existingMedications: [metoprolol, spironolactone, empagliflozin]
        )

        // Then: no conflicts should be detected
        XCTAssertTrue(conflicts.isEmpty, "Should not detect any conflicts for different classes")
    }

    func testLoopDiureticsDoNotConflict() {
        // Given: existing loop diuretic
        let furosemide = makeMedication(name: "Furosemide", category: .loopDiuretic)

        // When: checking if adding another loop diuretic would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .loopDiuretic,
            existingMedications: [furosemide]
        )

        // Then: no conflict (loop diuretics are not in single-medication categories)
        XCTAssertTrue(conflicts.isEmpty, "Loop diuretics should not trigger single-class conflict")
    }

    func testOtherCategoryDoesNotConflict() {
        // Given: existing "other" category medication
        let digoxin = makeMedication(name: "Digoxin", category: .other)

        // When: checking if adding another "other" medication would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .other,
            existingMedications: [digoxin]
        )

        // Then: no conflict (other category is not restricted)
        XCTAssertTrue(conflicts.isEmpty, "Other category should not trigger conflicts")
    }

    // MARK: - Edge Cases: Inactive Medications

    func testInactiveMedicationsAreIgnored() {
        // Given: inactive beta blocker
        let inactiveMetoprolol = makeMedication(name: "Metoprolol", category: .betaBlocker, isActive: false)

        // When: checking if adding a beta blocker would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .betaBlocker,
            existingMedications: [inactiveMetoprolol]
        )

        // Then: no conflict should be detected (inactive medication is ignored)
        XCTAssertTrue(conflicts.isEmpty, "Inactive medications should be ignored")
    }

    // MARK: - Edge Cases: Custom Medications (nil category)

    func testCustomMedicationsAreIgnored() {
        // Given: medication with no category (custom entry)
        let customMed = makeMedication(name: "Custom Med", category: nil)

        // When: finding all conflicts
        let conflicts = sut.findAllConflicts(in: [customMed])

        // Then: no conflicts (custom medications are ignored)
        XCTAssertTrue(conflicts.isEmpty, "Custom medications should be ignored")
    }

    // MARK: - Find All Conflicts Tests

    func testFindAllConflictsWithSameClass() {
        // Given: two beta blockers
        let metoprolol = makeMedication(name: "Metoprolol", category: .betaBlocker)
        let carvedilol = makeMedication(name: "Carvedilol", category: .betaBlocker)

        // When: finding all conflicts
        let conflicts = sut.findAllConflicts(in: [metoprolol, carvedilol])

        // Then: should find same-class conflict
        XCTAssertEqual(conflicts.count, 1, "Should find one conflict")
        if case .sameClass(let category) = conflicts.first?.type {
            XCTAssertEqual(category, .betaBlocker, "Should be beta blocker conflict")
        } else {
            XCTFail("Should be sameClass conflict type")
        }
    }

    func testFindAllConflictsWithCrossClass() {
        // Given: ACE inhibitor and ARB
        let lisinopril = makeMedication(name: "Lisinopril", category: .aceInhibitor)
        let losartan = makeMedication(name: "Losartan", category: .arb)

        // When: finding all conflicts
        let conflicts = sut.findAllConflicts(in: [lisinopril, losartan])

        // Then: should find cross-class conflict
        XCTAssertEqual(conflicts.count, 1, "Should find one conflict")
        if case .crossClass = conflicts.first?.type {
            // Success
        } else {
            XCTFail("Should be crossClass conflict type")
        }
    }

    func testFindAllConflictsWithMultipleConflicts() {
        // Given: two beta blockers AND ACEi + ARB
        let metoprolol = makeMedication(name: "Metoprolol", category: .betaBlocker)
        let carvedilol = makeMedication(name: "Carvedilol", category: .betaBlocker)
        let lisinopril = makeMedication(name: "Lisinopril", category: .aceInhibitor)
        let losartan = makeMedication(name: "Losartan", category: .arb)

        // When: finding all conflicts
        let conflicts = sut.findAllConflicts(in: [metoprolol, carvedilol, lisinopril, losartan])

        // Then: should find both conflicts
        XCTAssertEqual(conflicts.count, 2, "Should find two conflicts")
    }

    func testFindAllConflictsWithNoConflicts() {
        // Given: medications from different non-conflicting classes
        let metoprolol = makeMedication(name: "Metoprolol", category: .betaBlocker)
        let lisinopril = makeMedication(name: "Lisinopril", category: .aceInhibitor)
        let spironolactone = makeMedication(name: "Spironolactone", category: .mra)

        // When: finding all conflicts
        let conflicts = sut.findAllConflicts(in: [metoprolol, lisinopril, spironolactone])

        // Then: no conflicts
        XCTAssertTrue(conflicts.isEmpty, "Should not find any conflicts")
    }

    // MARK: - Message Tests

    func testConflictMessageIsWarmAndNonAlarmist() {
        // Given: existing beta blocker
        let metoprolol = makeMedication(name: "Metoprolol", category: .betaBlocker)

        // When: checking for conflicts
        let conflicts = sut.checkConflicts(
            newCategory: .betaBlocker,
            existingMedications: [metoprolol]
        )

        // Then: message should be warm and non-alarmist
        guard let message = conflicts.first?.message.lowercased() else {
            XCTFail("Should have a conflict message")
            return
        }

        // Should mention care team
        XCTAssertTrue(message.contains("care team"), "Message should mention care team")

        // Should NOT contain alarmist language
        let alarmistWords = ["danger", "emergency", "urgent", "immediately", "critical", "warning"]
        for word in alarmistWords {
            XCTAssertFalse(message.contains(word), "Message should not contain '\(word)'")
        }
    }

    func testConflictMessageMentionsExistingMedication() {
        // Given: existing medication
        let metoprolol = makeMedication(name: "Metoprolol", category: .betaBlocker)

        // When: checking for conflicts
        let conflicts = sut.checkConflicts(
            newCategory: .betaBlocker,
            existingMedications: [metoprolol]
        )

        // Then: message should mention the existing medication
        guard let message = conflicts.first?.message else {
            XCTFail("Should have a conflict message")
            return
        }

        XCTAssertTrue(message.contains("Metoprolol"), "Message should mention existing medication")
    }
}
