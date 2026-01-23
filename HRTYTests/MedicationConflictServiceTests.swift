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

    // MARK: - Additional Edge Cases

    func testEmptyMedicationListHasNoConflicts() {
        // Given: no existing medications

        // When: checking if adding any medication would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .betaBlocker,
            existingMedications: []
        )

        // Then: no conflicts should be detected
        XCTAssertTrue(conflicts.isEmpty, "Empty medication list should have no conflicts")
    }

    func testFindAllConflictsWithEmptyList() {
        // When: finding all conflicts in empty list
        let conflicts = sut.findAllConflicts(in: [])

        // Then: no conflicts
        XCTAssertTrue(conflicts.isEmpty, "Empty medication list should have no conflicts")
    }

    func testMixedActiveAndInactiveMedications() {
        // Given: one active and one inactive beta blocker
        let activeMetoprolol = makeMedication(name: "Metoprolol", category: .betaBlocker, isActive: true)
        let inactiveCarvedilol = makeMedication(name: "Carvedilol", category: .betaBlocker, isActive: false)

        // When: finding all conflicts
        let conflicts = sut.findAllConflicts(in: [activeMetoprolol, inactiveCarvedilol])

        // Then: no conflicts (only one active medication)
        XCTAssertTrue(conflicts.isEmpty, "Should only consider active medications")
    }

    func testMixedActiveInactiveCrossClassConflict() {
        // Given: active ACE inhibitor and inactive ARB
        let activeLisinopril = makeMedication(name: "Lisinopril", category: .aceInhibitor, isActive: true)
        let inactiveLosartan = makeMedication(name: "Losartan", category: .arb, isActive: false)

        // When: finding all conflicts
        let conflicts = sut.findAllConflicts(in: [activeLisinopril, inactiveLosartan])

        // Then: no cross-class conflict (ARB is inactive)
        XCTAssertTrue(conflicts.isEmpty, "Inactive ARB should not conflict with active ACE inhibitor")
    }

    func testARNISameClassConflict() {
        // Given: existing ARNI
        let entresto = makeMedication(name: "Entresto", category: .arni)

        // When: checking if adding another ARNI would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .arni,
            existingMedications: [entresto]
        )

        // Then: should detect same-class conflict
        XCTAssertEqual(conflicts.count, 1, "Should detect one conflict")
        if case .sameClass(let category) = conflicts.first?.type {
            XCTAssertEqual(category, .arni, "Should be ARNI conflict")
        } else {
            XCTFail("Should be sameClass conflict type")
        }
    }

    func testThiazideDiureticsDoNotConflict() {
        // Given: existing thiazide diuretic
        let hctz = makeMedication(name: "HCTZ", category: .thiazideDiuretic)

        // When: checking if adding another thiazide diuretic would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .thiazideDiuretic,
            existingMedications: [hctz]
        )

        // Then: no conflict (thiazide diuretics are not in single-medication categories)
        XCTAssertTrue(conflicts.isEmpty, "Thiazide diuretics should not trigger single-class conflict")
    }

    func testTripleCrossClassScenario() {
        // Given: ACE inhibitor, ARB, and ARNI all present
        let lisinopril = makeMedication(name: "Lisinopril", category: .aceInhibitor)
        let losartan = makeMedication(name: "Losartan", category: .arb)
        let entresto = makeMedication(name: "Entresto", category: .arni)

        // When: finding all conflicts
        let conflicts = sut.findAllConflicts(in: [lisinopril, losartan, entresto])

        // Then: should detect all three cross-class conflicts
        XCTAssertEqual(conflicts.count, 3, "Should find three cross-class conflicts (ACEi+ARB, ACEi+ARNI, ARB+ARNI)")

        let conflictTypes = conflicts.map { $0.type }
        XCTAssertTrue(conflictTypes.contains(where: {
            if case .crossClass(.aceInhibitor, .arb) = $0 { return true }
            return false
        }), "Should have ACEi+ARB conflict")
        XCTAssertTrue(conflictTypes.contains(where: {
            if case .crossClass(.aceInhibitor, .arni) = $0 { return true }
            return false
        }), "Should have ACEi+ARNI conflict")
        XCTAssertTrue(conflictTypes.contains(where: {
            if case .crossClass(.arb, .arni) = $0 { return true }
            return false
        }), "Should have ARB+ARNI conflict")
    }

    func testSameClassAndCrossClassConflictsTogether() {
        // Given: two ACE inhibitors and one ARB
        let lisinopril = makeMedication(name: "Lisinopril", category: .aceInhibitor)
        let enalapril = makeMedication(name: "Enalapril", category: .aceInhibitor)
        let losartan = makeMedication(name: "Losartan", category: .arb)

        // When: finding all conflicts
        let conflicts = sut.findAllConflicts(in: [lisinopril, enalapril, losartan])

        // Then: should find both same-class (2 ACEi) and cross-class (ACEi+ARB) conflicts
        XCTAssertEqual(conflicts.count, 2, "Should find two conflicts")

        let hasSameClassConflict = conflicts.contains(where: {
            if case .sameClass(.aceInhibitor) = $0.type { return true }
            return false
        })
        let hasCrossClassConflict = conflicts.contains(where: {
            if case .crossClass = $0.type { return true }
            return false
        })

        XCTAssertTrue(hasSameClassConflict, "Should have ACE inhibitor same-class conflict")
        XCTAssertTrue(hasCrossClassConflict, "Should have cross-class conflict")
    }

    func testCheckConflictsWithOnlyInactiveMedications() {
        // Given: only inactive medications
        let inactiveMetoprolol = makeMedication(name: "Metoprolol", category: .betaBlocker, isActive: false)
        let inactiveCarvedilol = makeMedication(name: "Carvedilol", category: .betaBlocker, isActive: false)

        // When: checking if adding a beta blocker would conflict
        let conflicts = sut.checkConflicts(
            newCategory: .betaBlocker,
            existingMedications: [inactiveMetoprolol, inactiveCarvedilol]
        )

        // Then: no conflicts (all existing are inactive)
        XCTAssertTrue(conflicts.isEmpty, "Inactive medications should not cause conflicts when adding new medication")
    }

    func testFindAllConflictsWithOnlyInactiveMedications() {
        // Given: two inactive beta blockers
        let inactiveMetoprolol = makeMedication(name: "Metoprolol", category: .betaBlocker, isActive: false)
        let inactiveCarvedilol = makeMedication(name: "Carvedilol", category: .betaBlocker, isActive: false)

        // When: finding all conflicts
        let conflicts = sut.findAllConflicts(in: [inactiveMetoprolol, inactiveCarvedilol])

        // Then: no conflicts (both are inactive)
        XCTAssertTrue(conflicts.isEmpty, "Inactive medications should not conflict with each other")
    }

    // MARK: - MedicationConflict Struct Tests

    func testMedicationConflictHasUniqueId() {
        // Given: same inputs for two conflicts
        let med = makeMedication(name: "Metoprolol", category: .betaBlocker)

        // When: detecting the same conflict twice
        let conflicts1 = sut.checkConflicts(newCategory: .betaBlocker, existingMedications: [med])
        let conflicts2 = sut.checkConflicts(newCategory: .betaBlocker, existingMedications: [med])

        // Then: each conflict has a unique ID
        guard let conflict1 = conflicts1.first, let conflict2 = conflicts2.first else {
            XCTFail("Should have conflicts")
            return
        }
        XCTAssertNotEqual(conflict1.id, conflict2.id, "Each conflict should have a unique ID")
    }

    func testMedicationConflictIsIdentifiable() {
        // Given: a detected conflict
        let med = makeMedication(name: "Metoprolol", category: .betaBlocker)
        let conflicts = sut.checkConflicts(newCategory: .betaBlocker, existingMedications: [med])

        // When/Then: conflict can be used in ForEach (Identifiable conformance)
        guard let conflict = conflicts.first else {
            XCTFail("Should have a conflict")
            return
        }
        XCTAssertNotNil(conflict.id, "Conflict should have an ID for use in SwiftUI ForEach")
    }

    func testConflictTypeEqualityForSameClass() {
        // Given: two same-class conflict types
        let type1 = ConflictType.sameClass(.betaBlocker)
        let type2 = ConflictType.sameClass(.betaBlocker)
        let type3 = ConflictType.sameClass(.aceInhibitor)

        // Then: same category types are equal, different are not
        XCTAssertEqual(type1, type2, "Same category types should be equal")
        XCTAssertNotEqual(type1, type3, "Different category types should not be equal")
    }

    func testConflictTypeEqualityForCrossClass() {
        // Given: cross-class conflict types
        let type1 = ConflictType.crossClass(.aceInhibitor, .arb)
        let type2 = ConflictType.crossClass(.aceInhibitor, .arb)
        let type3 = ConflictType.crossClass(.aceInhibitor, .arni)

        // Then: same cross-class types are equal, different are not
        XCTAssertEqual(type1, type2, "Same cross-class types should be equal")
        XCTAssertNotEqual(type1, type3, "Different cross-class types should not be equal")
    }
}
