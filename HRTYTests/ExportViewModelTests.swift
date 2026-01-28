import XCTest
@testable import HRTY

final class ExportViewModelTests: XCTestCase {

    var viewModel: ExportViewModel!

    override func setUp() {
        super.setUp()
        // Clear UserDefaults to ensure clean state for tests
        UserDefaults.standard.removeObject(forKey: "patientIdentifier")
        viewModel = ExportViewModel()
    }

    override func tearDown() {
        // Clean up UserDefaults after tests
        UserDefaults.standard.removeObject(forKey: "patientIdentifier")
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialStateIsIdle() {
        // Then: generation state should be idle initially
        XCTAssertEqual(viewModel.generationState, .idle)
    }

    func testPatientIdentifierInitiallyEmpty() {
        // Then: patient identifier should be empty initially
        XCTAssertEqual(viewModel.patientIdentifier, "")
    }

    func testShowShareSheetInitiallyFalse() {
        // Then: share sheet should not be shown initially
        XCTAssertFalse(viewModel.showShareSheet)
    }

    // MARK: - Patient Identifier Tests

    func testPatientIdentifierForExportReturnsNilWhenEmpty() {
        // Given: empty patient identifier
        viewModel.patientIdentifier = ""

        // Then: export identifier should be nil
        XCTAssertNil(viewModel.patientIdentifierForExport)
    }

    func testPatientIdentifierForExportReturnsNilWhenWhitespace() {
        // Given: whitespace-only identifier
        viewModel.patientIdentifier = "   "

        // Then: export identifier should be nil
        XCTAssertNil(viewModel.patientIdentifierForExport)
    }

    func testPatientIdentifierForExportTrimsWhitespace() {
        // Given: identifier with leading/trailing whitespace
        viewModel.patientIdentifier = "  John Doe  "

        // Then: export identifier should be trimmed
        XCTAssertEqual(viewModel.patientIdentifierForExport, "John Doe")
    }

    func testPatientIdentifierForExportPreservesValidInput() {
        // Given: valid identifier
        viewModel.patientIdentifier = "Patient-12345"

        // Then: export identifier should match
        XCTAssertEqual(viewModel.patientIdentifierForExport, "Patient-12345")
    }

    func testPatientIdentifierForExportHandlesNewlines() {
        // Given: identifier with newlines
        viewModel.patientIdentifier = "\nJane Smith\n"

        // Then: export identifier should be trimmed
        XCTAssertEqual(viewModel.patientIdentifierForExport, "Jane Smith")
    }

    // MARK: - Date Range Tests

    func testStartDateIs29DaysAgo() {
        // Given: the view model's end date (today)
        let calendar = Calendar.current

        // When: getting start and end dates from the same view model
        let startDate = viewModel.startDate
        let endDate = viewModel.endDate

        // Then: start should be 29 days before end (for 30-day range including both dates)
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        XCTAssertEqual(components.day, 29)
    }

    func testEndDateIsToday() {
        // Given: current date
        let calendar = Calendar.current

        // When: getting end date
        let endDate = viewModel.endDate

        // Then: should be today
        XCTAssertTrue(calendar.isDateInToday(endDate))
    }

    func testDateRangeTextContainsDates() {
        // When: getting date range text
        let dateRangeText = viewModel.dateRangeText

        // Then: should contain a dash separator
        XCTAssertTrue(dateRangeText.contains(" - "))
    }

    func testDateRangeTextIsNotEmpty() {
        // When: getting date range text
        let dateRangeText = viewModel.dateRangeText

        // Then: should not be empty
        XCTAssertFalse(dateRangeText.isEmpty)
    }

    // MARK: - Generation State Tests

    func testIsGeneratingReturnsFalseWhenIdle() {
        // Given: idle state
        viewModel.generationState = .idle

        // Then: isGenerating should be false
        XCTAssertFalse(viewModel.isGenerating)
    }

    func testIsGeneratingReturnsTrueWhenLoading() {
        // Given: loading state
        viewModel.generationState = .loading

        // Then: isGenerating should be true
        XCTAssertTrue(viewModel.isGenerating)
    }

    func testIsGeneratingReturnsFalseWhenSuccess() {
        // Given: success state
        viewModel.generationState = .success(Data())

        // Then: isGenerating should be false
        XCTAssertFalse(viewModel.isGenerating)
    }

    func testIsGeneratingReturnsFalseWhenError() {
        // Given: error state
        viewModel.generationState = .error("Test error")

        // Then: isGenerating should be false
        XCTAssertFalse(viewModel.isGenerating)
    }

    // MARK: - Success State Tests

    func testDidSucceedReturnsFalseWhenIdle() {
        // Given: idle state
        viewModel.generationState = .idle

        // Then: didSucceed should be false
        XCTAssertFalse(viewModel.didSucceed)
    }

    func testDidSucceedReturnsFalseWhenLoading() {
        // Given: loading state
        viewModel.generationState = .loading

        // Then: didSucceed should be false
        XCTAssertFalse(viewModel.didSucceed)
    }

    func testDidSucceedReturnsTrueWhenSuccess() {
        // Given: success state
        viewModel.generationState = .success(Data())

        // Then: didSucceed should be true
        XCTAssertTrue(viewModel.didSucceed)
    }

    func testDidSucceedReturnsFalseWhenError() {
        // Given: error state
        viewModel.generationState = .error("Test error")

        // Then: didSucceed should be false
        XCTAssertFalse(viewModel.didSucceed)
    }

    // MARK: - PDF Data Tests

    func testPdfDataReturnsNilWhenIdle() {
        // Given: idle state
        viewModel.generationState = .idle

        // Then: pdfData should be nil
        XCTAssertNil(viewModel.pdfData)
    }

    func testPdfDataReturnsNilWhenLoading() {
        // Given: loading state
        viewModel.generationState = .loading

        // Then: pdfData should be nil
        XCTAssertNil(viewModel.pdfData)
    }

    func testPdfDataReturnsDataWhenSuccess() {
        // Given: success state with data
        let testData = "Test PDF content".data(using: .utf8)!
        viewModel.generationState = .success(testData)

        // Then: pdfData should return the data
        XCTAssertEqual(viewModel.pdfData, testData)
    }

    func testPdfDataReturnsNilWhenError() {
        // Given: error state
        viewModel.generationState = .error("Test error")

        // Then: pdfData should be nil
        XCTAssertNil(viewModel.pdfData)
    }

    // MARK: - Error Message Tests

    func testErrorMessageReturnsNilWhenIdle() {
        // Given: idle state
        viewModel.generationState = .idle

        // Then: errorMessage should be nil
        XCTAssertNil(viewModel.errorMessage)
    }

    func testErrorMessageReturnsNilWhenLoading() {
        // Given: loading state
        viewModel.generationState = .loading

        // Then: errorMessage should be nil
        XCTAssertNil(viewModel.errorMessage)
    }

    func testErrorMessageReturnsNilWhenSuccess() {
        // Given: success state
        viewModel.generationState = .success(Data())

        // Then: errorMessage should be nil
        XCTAssertNil(viewModel.errorMessage)
    }

    func testErrorMessageReturnsMessageWhenError() {
        // Given: error state with message
        let errorText = "Unable to generate PDF"
        viewModel.generationState = .error(errorText)

        // Then: errorMessage should return the message
        XCTAssertEqual(viewModel.errorMessage, errorText)
    }

    // MARK: - Reset Tests

    func testResetSetsStateToIdle() {
        // Given: success state
        viewModel.generationState = .success(Data())

        // When: resetting
        viewModel.reset()

        // Then: state should be idle
        XCTAssertEqual(viewModel.generationState, .idle)
    }

    func testResetHidesShareSheet() {
        // Given: share sheet is showing
        viewModel.showShareSheet = true

        // When: resetting
        viewModel.reset()

        // Then: share sheet should be hidden
        XCTAssertFalse(viewModel.showShareSheet)
    }

    func testResetFromErrorState() {
        // Given: error state
        viewModel.generationState = .error("Some error")

        // When: resetting
        viewModel.reset()

        // Then: state should be idle
        XCTAssertEqual(viewModel.generationState, .idle)
    }

    func testResetFromLoadingState() {
        // Given: loading state
        viewModel.generationState = .loading

        // When: resetting
        viewModel.reset()

        // Then: state should be idle
        XCTAssertEqual(viewModel.generationState, .idle)
    }

    // MARK: - Patient Identifier Edge Cases

    func testPatientIdentifierWithSpecialCharacters() {
        // Given: identifier with special characters
        viewModel.patientIdentifier = "Patient #123 (Test)"

        // Then: should preserve special characters
        XCTAssertEqual(viewModel.patientIdentifierForExport, "Patient #123 (Test)")
    }

    func testPatientIdentifierWithNumbers() {
        // Given: numeric identifier
        viewModel.patientIdentifier = "12345"

        // Then: should preserve numbers
        XCTAssertEqual(viewModel.patientIdentifierForExport, "12345")
    }

    func testPatientIdentifierPreservesInternalWhitespace() {
        // Given: identifier with internal spaces
        viewModel.patientIdentifier = "John Michael Doe"

        // Then: should preserve internal spaces
        XCTAssertEqual(viewModel.patientIdentifierForExport, "John Michael Doe")
    }
}

// MARK: - PDFGenerationState Tests

final class PDFGenerationStateTests: XCTestCase {

    func testIdleStateEquality() {
        // Given: two idle states
        let state1 = PDFGenerationState.idle
        let state2 = PDFGenerationState.idle

        // Then: should be equal
        XCTAssertEqual(state1, state2)
    }

    func testLoadingStateEquality() {
        // Given: two loading states
        let state1 = PDFGenerationState.loading
        let state2 = PDFGenerationState.loading

        // Then: should be equal
        XCTAssertEqual(state1, state2)
    }

    func testSuccessStateEqualityWithSameData() {
        // Given: two success states with same data
        let data = "test".data(using: .utf8)!
        let state1 = PDFGenerationState.success(data)
        let state2 = PDFGenerationState.success(data)

        // Then: should be equal
        XCTAssertEqual(state1, state2)
    }

    func testSuccessStateInequalityWithDifferentData() {
        // Given: two success states with different data
        let data1 = "test1".data(using: .utf8)!
        let data2 = "test2".data(using: .utf8)!
        let state1 = PDFGenerationState.success(data1)
        let state2 = PDFGenerationState.success(data2)

        // Then: should not be equal
        XCTAssertNotEqual(state1, state2)
    }

    func testErrorStateEqualityWithSameMessage() {
        // Given: two error states with same message
        let state1 = PDFGenerationState.error("Error occurred")
        let state2 = PDFGenerationState.error("Error occurred")

        // Then: should be equal
        XCTAssertEqual(state1, state2)
    }

    func testErrorStateInequalityWithDifferentMessages() {
        // Given: two error states with different messages
        let state1 = PDFGenerationState.error("Error 1")
        let state2 = PDFGenerationState.error("Error 2")

        // Then: should not be equal
        XCTAssertNotEqual(state1, state2)
    }

    func testIdleNotEqualToLoading() {
        // Given: idle and loading states
        let idle = PDFGenerationState.idle
        let loading = PDFGenerationState.loading

        // Then: should not be equal
        XCTAssertNotEqual(idle, loading)
    }

    func testSuccessNotEqualToError() {
        // Given: success and error states
        let success = PDFGenerationState.success(Data())
        let error = PDFGenerationState.error("Error")

        // Then: should not be equal
        XCTAssertNotEqual(success, error)
    }
}

// MARK: - ExportData Structure Tests

final class ExportDataTests: XCTestCase {

    func testExportDataInitialization() {
        // Given: export data components
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 30, to: startDate)!
        let weightEntries = [WeightDataPoint(date: Date(), weight: 180.0)]
        let symptomEntries = [SymptomDataPoint(date: Date(), symptomType: .chestPain, severity: 2, hasAlert: false)]
        let diureticDoses: [DiureticDoseData] = []
        let alertEvents: [AlertEventData] = []
        let medicationChangeInsights: [MedicationChangeInsight] = []

        // When: creating ExportData
        let emptyRegimen = MedicationHistoryService.RegimenSnapshot(date: startDate, medications: [])
        let exportData = ExportData(
            dateRange: (startDate, endDate),
            patientIdentifier: "Test Patient",
            clinicalProfile: nil,
            weightEntries: weightEntries,
            symptomEntries: symptomEntries,
            diureticDoses: diureticDoses,
            alertEvents: alertEvents,
            medicationChangeInsights: medicationChangeInsights,
            startRegimen: emptyRegimen,
            endRegimen: emptyRegimen,
            medicationTimeline: [],
            medicationComparisons: []
        )

        // Then: values should be set correctly
        XCTAssertEqual(exportData.dateRange.start, startDate)
        XCTAssertEqual(exportData.dateRange.end, endDate)
        XCTAssertEqual(exportData.patientIdentifier, "Test Patient")
        XCTAssertEqual(exportData.weightEntries.count, 1)
        XCTAssertEqual(exportData.symptomEntries.count, 1)
        XCTAssertTrue(exportData.diureticDoses.isEmpty)
        XCTAssertTrue(exportData.alertEvents.isEmpty)
        XCTAssertTrue(exportData.medicationChangeInsights.isEmpty)
    }

    func testExportDataWithNilPatientIdentifier() {
        // Given: export data without patient identifier
        let startDate = Date()
        let endDate = Date()
        let emptyRegimen = MedicationHistoryService.RegimenSnapshot(date: startDate, medications: [])

        // When: creating ExportData with nil identifier
        let exportData = ExportData(
            dateRange: (startDate, endDate),
            patientIdentifier: nil,
            clinicalProfile: nil,
            weightEntries: [],
            symptomEntries: [],
            diureticDoses: [],
            alertEvents: [],
            medicationChangeInsights: [],
            startRegimen: emptyRegimen,
            endRegimen: emptyRegimen,
            medicationTimeline: [],
            medicationComparisons: []
        )

        // Then: patient identifier should be nil
        XCTAssertNil(exportData.patientIdentifier)
    }

    func testExportDataWithEmptyCollections() {
        // Given: export data with empty collections
        let startDate = Date()
        let endDate = Date()
        let emptyRegimen = MedicationHistoryService.RegimenSnapshot(date: startDate, medications: [])

        // When: creating ExportData
        let exportData = ExportData(
            dateRange: (startDate, endDate),
            patientIdentifier: nil,
            clinicalProfile: nil,
            weightEntries: [],
            symptomEntries: [],
            diureticDoses: [],
            alertEvents: [],
            medicationChangeInsights: [],
            startRegimen: emptyRegimen,
            endRegimen: emptyRegimen,
            medicationTimeline: [],
            medicationComparisons: []
        )

        // Then: all collections should be empty
        XCTAssertTrue(exportData.weightEntries.isEmpty)
        XCTAssertTrue(exportData.symptomEntries.isEmpty)
        XCTAssertTrue(exportData.diureticDoses.isEmpty)
        XCTAssertTrue(exportData.alertEvents.isEmpty)
        XCTAssertTrue(exportData.medicationChangeInsights.isEmpty)
    }
}

// MARK: - DiureticDoseData Tests

final class DiureticDoseDataTests: XCTestCase {

    func testDiureticDoseDataInitialization() {
        // Given: dose data values
        let date = Date()
        let medicationName = "Furosemide"
        let dosageAmount = 40.0
        let unit = "mg"
        let isExtraDose = false

        // When: creating DiureticDoseData
        let doseData = DiureticDoseData(
            date: date,
            medicationName: medicationName,
            dosageAmount: dosageAmount,
            unit: unit,
            isExtraDose: isExtraDose
        )

        // Then: values should be set correctly
        XCTAssertEqual(doseData.date, date)
        XCTAssertEqual(doseData.medicationName, medicationName)
        XCTAssertEqual(doseData.dosageAmount, dosageAmount)
        XCTAssertEqual(doseData.unit, unit)
        XCTAssertEqual(doseData.isExtraDose, isExtraDose)
    }

    func testDiureticDoseDataHasUniqueId() {
        // Given: two dose data with same values
        let date = Date()
        let dose1 = DiureticDoseData(date: date, medicationName: "Test", dosageAmount: 10, unit: "mg", isExtraDose: false)
        let dose2 = DiureticDoseData(date: date, medicationName: "Test", dosageAmount: 10, unit: "mg", isExtraDose: false)

        // Then: IDs should be different (UUID)
        XCTAssertNotEqual(dose1.id, dose2.id)
    }

    func testDiureticDoseDataWithExtraDose() {
        // Given: an extra dose
        let doseData = DiureticDoseData(
            date: Date(),
            medicationName: "Bumetanide",
            dosageAmount: 1.0,
            unit: "mg",
            isExtraDose: true
        )

        // Then: isExtraDose should be true
        XCTAssertTrue(doseData.isExtraDose)
    }

    func testDiureticDoseDataIsIdentifiable() {
        // Given: a dose data
        let doseData = DiureticDoseData(date: Date(), medicationName: "Test", dosageAmount: 10, unit: "mg", isExtraDose: false)

        // Then: should have a valid UUID
        XCTAssertFalse(doseData.id.uuidString.isEmpty)
    }
}

// MARK: - AlertEventData Tests

final class AlertEventDataTests: XCTestCase {

    func testAlertEventDataInitialization() {
        // Given: alert event values
        let date = Date()
        let alertType = AlertType.weightGain24h
        let message = "Your weight has changed. Consider reaching out to your care team."

        // When: creating AlertEventData
        let eventData = AlertEventData(
            date: date,
            alertType: alertType,
            message: message
        )

        // Then: values should be set correctly
        XCTAssertEqual(eventData.date, date)
        XCTAssertEqual(eventData.alertType, alertType)
        XCTAssertEqual(eventData.message, message)
    }

    func testAlertEventDataHasUniqueId() {
        // Given: two event data with same values
        let date = Date()
        let event1 = AlertEventData(date: date, alertType: .weightGain24h, message: "Test")
        let event2 = AlertEventData(date: date, alertType: .weightGain24h, message: "Test")

        // Then: IDs should be different (UUID)
        XCTAssertNotEqual(event1.id, event2.id)
    }

    func testAlertEventDataWithDifferentAlertTypes() {
        // Given: events with different alert types
        let event24h = AlertEventData(date: Date(), alertType: .weightGain24h, message: "24h alert")
        let event7d = AlertEventData(date: Date(), alertType: .weightGain7d, message: "7d alert")
        let eventSymptom = AlertEventData(date: Date(), alertType: .severeSymptom, message: "Symptom alert")

        // Then: alert types should be correctly assigned
        XCTAssertEqual(event24h.alertType, .weightGain24h)
        XCTAssertEqual(event7d.alertType, .weightGain7d)
        XCTAssertEqual(eventSymptom.alertType, .severeSymptom)
    }

    func testAlertEventDataIsIdentifiable() {
        // Given: an event data
        let eventData = AlertEventData(date: Date(), alertType: .severeSymptom, message: "Test")

        // Then: should have a valid UUID
        XCTAssertFalse(eventData.id.uuidString.isEmpty)
    }

    func testAlertEventDataMessageIsPatientFriendly() {
        // Given: typical alert messages
        let messages = [
            "Your weight has changed. Consider reaching out to your care team.",
            "Some symptoms need attention. It might be helpful to contact your clinician."
        ]

        // Then: messages should not contain alarmist language
        for message in messages {
            XCTAssertFalse(message.lowercased().contains("danger"))
            XCTAssertFalse(message.lowercased().contains("emergency"))
            XCTAssertFalse(message.lowercased().contains("warning"))
            XCTAssertFalse(message.lowercased().contains("critical"))
        }
    }
}
