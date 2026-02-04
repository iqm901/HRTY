import XCTest
@testable import HRTY

final class MedicationAvoidServiceTests: XCTestCase {
    var sut: MedicationAvoidService!

    override func setUp() {
        super.setUp()
        sut = MedicationAvoidService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - NSAID Detection Tests

    func testDetectsIbuprofen() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Ibuprofen")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .nsaid)
    }

    func testDetectsIbuprofenCaseInsensitive() {
        let warning = sut.checkIfShouldAvoid(medicationName: "IBUPROFEN")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .nsaid)
    }

    func testDetectsAdvil() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Advil")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .nsaid)
    }

    func testDetectsMotrin() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Motrin")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .nsaid)
    }

    func testDetectsIbuprofenWithBrandName() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Ibuprofen (Advil/Motrin)")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .nsaid)
    }

    func testDetectsNaproxen() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Naproxen")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .nsaid)
    }

    func testDetectsAleve() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Aleve")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .nsaid)
    }

    func testDetectsCelecoxib() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Celecoxib")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .nsaid)
    }

    func testDetectsCelebrex() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Celebrex")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .nsaid)
    }

    func testDetectsMeloxicam() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Meloxicam")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .nsaid)
    }

    // MARK: - Cold Medicine Detection Tests

    func testDetectsPseudoephedrine() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Pseudoephedrine")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .coldMedicine)
    }

    func testDetectsSudafed() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Sudafed")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .coldMedicine)
    }

    func testDetectsDayquil() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Dayquil")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .coldMedicine)
    }

    func testDetectsNyquil() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Nyquil")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .coldMedicine)
    }

    func testDetectsPhenylephrine() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Phenylephrine")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .coldMedicine)
    }

    // MARK: - Herbal Supplement Detection Tests

    func testDetectsGinseng() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Ginseng")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .herbalSupplement)
    }

    func testDetectsGinkgo() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Ginkgo Biloba")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .herbalSupplement)
    }

    func testDetectsStJohnsWort() {
        let warning = sut.checkIfShouldAvoid(medicationName: "St. John's Wort")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .herbalSupplement)
    }

    func testDetectsHawthorn() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Hawthorn")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .herbalSupplement)
    }

    // MARK: - Calcium Channel Blocker Detection Tests

    func testDetectsDiltiazem() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Diltiazem")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .calciumChannelBlocker)
    }

    func testDetectsVerapamil() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Verapamil")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .calciumChannelBlocker)
    }

    func testDetectsCardizem() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Cardizem")
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.category, .calciumChannelBlocker)
    }

    // MARK: - Safe Medications Tests

    func testDoesNotFlagAcetaminophen() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Acetaminophen")
        XCTAssertNil(warning)
    }

    func testDoesNotFlagTylenol() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Tylenol")
        XCTAssertNil(warning)
    }

    func testDoesNotFlagMetoprolol() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Metoprolol")
        XCTAssertNil(warning)
    }

    func testDoesNotFlagLisinopril() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Lisinopril")
        XCTAssertNil(warning)
    }

    func testDoesNotFlagFurosemide() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Furosemide")
        XCTAssertNil(warning)
    }

    func testDoesNotFlagAmlodipine() {
        // Amlodipine is a safer calcium channel blocker for heart failure
        let warning = sut.checkIfShouldAvoid(medicationName: "Amlodipine")
        XCTAssertNil(warning)
    }

    // MARK: - shouldAvoid Convenience Method Tests

    func testShouldAvoidReturnsTrue() {
        XCTAssertTrue(sut.shouldAvoid(medicationName: "Ibuprofen"))
    }

    func testShouldAvoidReturnsFalse() {
        XCTAssertFalse(sut.shouldAvoid(medicationName: "Acetaminophen"))
    }

    // MARK: - Warning Message Tests

    func testNSAIDWarningMessageExists() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Ibuprofen")
        XCTAssertFalse(warning?.message.isEmpty ?? true)
        XCTAssertTrue(warning?.message.contains("NSAID") ?? false)
    }

    func testColdMedicineWarningMessageExists() {
        let warning = sut.checkIfShouldAvoid(medicationName: "Sudafed")
        XCTAssertFalse(warning?.message.isEmpty ?? true)
        XCTAssertTrue(warning?.message.contains("Decongestant") ?? false)
    }

    // MARK: - Category Display Name Tests

    func testNSAIDDisplayName() {
        XCTAssertEqual(AvoidCategory.nsaid.displayName, "NSAID (Pain Reliever)")
    }

    func testColdMedicineDisplayName() {
        XCTAssertEqual(AvoidCategory.coldMedicine.displayName, "Cold & Cough Medicine")
    }

    func testHerbalSupplementDisplayName() {
        XCTAssertEqual(AvoidCategory.herbalSupplement.displayName, "Herbal Supplement")
    }

    func testCalciumChannelBlockerDisplayName() {
        XCTAssertEqual(AvoidCategory.calciumChannelBlocker.displayName, "Calcium Channel Blocker")
    }
}
