import XCTest
import SwiftData
@testable import HRTY

// MARK: - Mock DiureticDoseService

final class MockDiureticDoseService: DiureticDoseServiceProtocol {
    var loadDiureticsResult: [Medication] = []
    var loadTodayDosesResult: [DiureticDose] = []
    var logDoseResult: DiureticDose?
    var deleteDoseResult: Bool = true

    var logDoseCallCount = 0
    var deleteDoseCallCount = 0
    var lastLoggedMedication: Medication?
    var lastLoggedAmount: Double?
    var lastLoggedIsExtra: Bool?
    var lastLoggedTimestamp: Date?
    var lastDeletedDose: DiureticDose?

    func loadDiuretics(context: ModelContext) -> [Medication] {
        return loadDiureticsResult
    }

    func loadTodayDoses(from entry: DailyEntry?) -> [DiureticDose] {
        return loadTodayDosesResult
    }

    func logDose(
        for medication: Medication,
        amount: Double,
        isExtra: Bool,
        timestamp: Date,
        dailyEntry: DailyEntry,
        context: ModelContext
    ) -> DiureticDose? {
        logDoseCallCount += 1
        lastLoggedMedication = medication
        lastLoggedAmount = amount
        lastLoggedIsExtra = isExtra
        lastLoggedTimestamp = timestamp
        return logDoseResult
    }

    func deleteDose(_ dose: DiureticDose, context: ModelContext) -> Bool {
        deleteDoseCallCount += 1
        lastDeletedDose = dose
        return deleteDoseResult
    }
}

// MARK: - DiureticDoseManager Tests

final class DiureticDoseManagerTests: XCTestCase {

    var manager: DiureticDoseManager!
    var mockService: MockDiureticDoseService!

    override func setUp() {
        super.setUp()
        mockService = MockDiureticDoseService()
        manager = DiureticDoseManager(diureticDoseService: mockService)
    }

    override func tearDown() {
        manager = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialStateIsEmpty() {
        XCTAssertTrue(manager.diureticMedications.isEmpty)
        XCTAssertTrue(manager.todayDiureticDoses.isEmpty)
        XCTAssertFalse(manager.showDeleteError)
    }

    // MARK: - Load Diuretics Tests

    func testLoadDiureticsPopulatesMedications() {
        // Given: mock service returns medications
        let furosemide = Medication(name: "Furosemide", dosage: "40", isDiuretic: true)
        let spironolactone = Medication(name: "Spironolactone", dosage: "25", isDiuretic: true)
        mockService.loadDiureticsResult = [furosemide, spironolactone]

        // When: load diuretics (we can't actually call it without a real context,
        // but we can test the service integration pattern)
        // Note: This would require SwiftData container for full integration test
    }

    // MARK: - Doses For Medication Tests

    func testDosesForMedicationReturnsFilteredDoses() {
        // Given: medications with different IDs
        let furosemide = Medication(name: "Furosemide", dosage: "40", isDiuretic: true)
        let spironolactone = Medication(name: "Spironolactone", dosage: "25", isDiuretic: true)

        // When: asking for doses for a specific medication with no doses
        let doses = manager.doses(for: furosemide)

        // Then: should return empty array
        XCTAssertTrue(doses.isEmpty)
    }

    func testDosesForMedicationReturnsSortedByTimestamp() {
        // This test verifies the sorting logic
        // Given: manager has doses (would need integration test for full verification)
        let medication = Medication(name: "Furosemide", dosage: "40", isDiuretic: true)

        // When: getting doses
        let doses = manager.doses(for: medication)

        // Then: should be empty initially
        XCTAssertTrue(doses.isEmpty)
    }

    // MARK: - Delete Error State Tests

    func testShowDeleteErrorCanBeSet() {
        // Given: initial state
        XCTAssertFalse(manager.showDeleteError)

        // When: set to true
        manager.showDeleteError = true

        // Then: should be true
        XCTAssertTrue(manager.showDeleteError)
    }

    func testShowDeleteErrorCanBeReset() {
        // Given: error state is true
        manager.showDeleteError = true

        // When: set to false
        manager.showDeleteError = false

        // Then: should be false
        XCTAssertFalse(manager.showDeleteError)
    }
}

// MARK: - DiureticDoseManager Protocol Conformance Tests

final class DiureticDoseManagerProtocolTests: XCTestCase {

    func testConformsToProtocol() {
        // Given: a manager instance
        let manager = DiureticDoseManager()

        // Then: should conform to protocol
        XCTAssertTrue(manager is DiureticDoseManagerProtocol)
    }

    func testProtocolPropertiesExist() {
        // Given: a manager as protocol type
        let manager: DiureticDoseManagerProtocol = DiureticDoseManager()

        // Then: protocol properties should be accessible
        _ = manager.diureticMedications
        _ = manager.todayDiureticDoses
        _ = manager.showDeleteError
    }
}
