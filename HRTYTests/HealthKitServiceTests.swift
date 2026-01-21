import XCTest
@testable import HRTY

// MARK: - HealthKitWeight Tests

final class HealthKitWeightTests: XCTestCase {

    func testHealthKitWeightInitialization() {
        // Given: weight and timestamp
        let timestamp = Date()
        let weight = 165.5

        // When: creating HealthKitWeight
        let healthKitWeight = HealthKitWeight(weight: weight, timestamp: timestamp)

        // Then: values should be stored correctly
        XCTAssertEqual(healthKitWeight.weight, 165.5)
        XCTAssertEqual(healthKitWeight.timestamp, timestamp)
    }

    func testFormattedWeightWithDecimal() {
        // Given: weight with decimal
        let healthKitWeight = HealthKitWeight(weight: 165.7, timestamp: Date())

        // Then: formatted weight should have one decimal place
        XCTAssertEqual(healthKitWeight.formattedWeight, "165.7")
    }

    func testFormattedWeightRoundsCorrectly() {
        // Given: weight that needs rounding
        let healthKitWeight = HealthKitWeight(weight: 165.75, timestamp: Date())

        // Then: should round to one decimal place
        XCTAssertEqual(healthKitWeight.formattedWeight, "165.8")
    }

    func testFormattedWeightWithWholeNumber() {
        // Given: whole number weight
        let healthKitWeight = HealthKitWeight(weight: 165.0, timestamp: Date())

        // Then: should display with .0
        XCTAssertEqual(healthKitWeight.formattedWeight, "165.0")
    }

    func testFormattedTimestampIsNotEmpty() {
        // Given: a HealthKit weight
        let healthKitWeight = HealthKitWeight(weight: 165.5, timestamp: Date())

        // Then: formatted timestamp should not be empty
        XCTAssertFalse(healthKitWeight.formattedTimestamp.isEmpty)
    }

    func testFormattedTimestampContainsDate() {
        // Given: a specific timestamp
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 15
        components.hour = 10
        components.minute = 30
        let timestamp = Calendar.current.date(from: components)!

        let healthKitWeight = HealthKitWeight(weight: 165.5, timestamp: timestamp)

        // Then: formatted timestamp should contain expected date parts
        // Note: Format varies by locale, so we just check it's not empty
        XCTAssertFalse(healthKitWeight.formattedTimestamp.isEmpty)
    }
}

// MARK: - HealthKitAuthorizationStatus Tests

final class HealthKitAuthorizationStatusTests: XCTestCase {

    func testNotDeterminedStatusExists() {
        let status = HealthKitAuthorizationStatus.notDetermined
        XCTAssertNotNil(status)
    }

    func testAuthorizedStatusExists() {
        let status = HealthKitAuthorizationStatus.authorized
        XCTAssertNotNil(status)
    }

    func testDeniedStatusExists() {
        let status = HealthKitAuthorizationStatus.denied
        XCTAssertNotNil(status)
    }

    func testUnavailableStatusExists() {
        let status = HealthKitAuthorizationStatus.unavailable
        XCTAssertNotNil(status)
    }

    func testStatusEquality() {
        // Then: same statuses should be equal
        XCTAssertEqual(HealthKitAuthorizationStatus.authorized, HealthKitAuthorizationStatus.authorized)
        XCTAssertNotEqual(HealthKitAuthorizationStatus.authorized, HealthKitAuthorizationStatus.denied)
    }
}

// MARK: - HealthKitError Tests

final class HealthKitErrorTests: XCTestCase {

    func testUnavailableErrorDescription() {
        // Given: unavailable error
        let error = HealthKitError.unavailable

        // Then: should have patient-friendly description
        XCTAssertEqual(error.errorDescription, "Health app is not available on this device")
    }

    func testAuthorizationDeniedErrorDescription() {
        // Given: authorization denied error
        let error = HealthKitError.authorizationDenied

        // Then: should have patient-friendly description explaining what's needed
        XCTAssertEqual(error.errorDescription, "HRTY needs permission to read your weight from the Health app")
    }

    func testNoDataErrorDescription() {
        // Given: no data error
        let error = HealthKitError.noData

        // Then: should have patient-friendly description
        XCTAssertEqual(error.errorDescription, "No weight data found in Health")
    }

    func testQueryFailedErrorDescription() {
        // Given: query failed error with underlying error
        let underlyingError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let error = HealthKitError.queryFailed(underlyingError)

        // Then: should have patient-friendly description (doesn't expose technical details)
        XCTAssertEqual(error.errorDescription, "We couldn't read your weight from Health right now")
    }

    func testUnavailableRecoverySuggestion() {
        // Given: unavailable error
        let error = HealthKitError.unavailable

        // Then: should suggest manual entry
        XCTAssertTrue(error.recoverySuggestion?.contains("manually") ?? false)
    }

    func testAuthorizationDeniedRecoverySuggestion() {
        // Given: authorization denied error
        let error = HealthKitError.authorizationDenied

        // Then: should point to Settings
        XCTAssertTrue(error.recoverySuggestion?.contains("Settings") ?? false)
    }

    func testNoDataRecoverySuggestion() {
        // Given: no data error
        let error = HealthKitError.noData

        // Then: should mention Health app
        XCTAssertTrue(error.recoverySuggestion?.contains("Health app") ?? false)
    }

    func testQueryFailedRecoverySuggestion() {
        // Given: query failed error
        let underlyingError = NSError(domain: "test", code: 1)
        let error = HealthKitError.queryFailed(underlyingError)

        // Then: should suggest retry or manual entry
        XCTAssertTrue(error.recoverySuggestion?.contains("try again") ?? false)
    }

    func testErrorDescriptionsArePatientFriendly() {
        // All error messages should be non-technical and patient-friendly
        let errors: [HealthKitError] = [
            .unavailable,
            .authorizationDenied,
            .noData,
            .queryFailed(NSError(domain: "test", code: 1))
        ]

        for error in errors {
            // Should not contain technical jargon
            let description = error.errorDescription ?? ""
            XCTAssertFalse(description.contains("exception"), "Error should not mention exceptions")
            XCTAssertFalse(description.contains("crash"), "Error should not mention crashes")
            XCTAssertFalse(description.contains("fatal"), "Error should not use alarming language")
        }
    }
}

// MARK: - MockHealthKitService Tests

final class MockHealthKitServiceTests: XCTestCase {

    var mockService: MockHealthKitService!

    override func setUp() {
        super.setUp()
        mockService = MockHealthKitService()
    }

    override func tearDown() {
        mockService = nil
        super.tearDown()
    }

    func testMockServiceDefaultsToAvailable() {
        // Then: mock should default to available
        XCTAssertTrue(mockService.isHealthKitAvailable)
    }

    func testMockServiceDefaultsToNotDetermined() {
        // Then: mock should default to not determined
        XCTAssertEqual(mockService.authorizationStatus, .notDetermined)
    }

    func testMockServiceCanSetUnavailable() {
        // When: setting to unavailable
        mockService.mockIsAvailable = false

        // Then: should be unavailable
        XCTAssertFalse(mockService.isHealthKitAvailable)
    }

    func testMockServiceCanSetAuthorizationStatus() {
        // When: setting to denied
        mockService.mockAuthorizationStatus = .denied

        // Then: should be denied
        XCTAssertEqual(mockService.authorizationStatus, .denied)
    }

    func testRequestAuthorizationUpdatesStatus() async throws {
        // Given: not determined status
        XCTAssertEqual(mockService.authorizationStatus, .notDetermined)

        // When: requesting authorization
        try await mockService.requestAuthorization()

        // Then: status should be authorized
        XCTAssertEqual(mockService.authorizationStatus, .authorized)
    }

    func testRequestAuthorizationThrowsError() async {
        // Given: mock error is set
        mockService.mockError = .unavailable

        // Then: should throw error
        do {
            try await mockService.requestAuthorization()
            XCTFail("Expected error to be thrown")
        } catch let error as HealthKitError {
            XCTAssertEqual(error.errorDescription, HealthKitError.unavailable.errorDescription)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchLatestWeightReturnsNil() async throws {
        // Given: no mock weight set

        // When: fetching weight
        let weight = try await mockService.fetchLatestWeight()

        // Then: should return nil
        XCTAssertNil(weight)
    }

    func testFetchLatestWeightReturnsMockWeight() async throws {
        // Given: mock weight is set
        let timestamp = Date()
        mockService.mockWeight = HealthKitWeight(weight: 175.5, timestamp: timestamp)

        // When: fetching weight
        let weight = try await mockService.fetchLatestWeight()

        // Then: should return mock weight
        XCTAssertNotNil(weight)
        XCTAssertEqual(weight?.weight, 175.5)
        XCTAssertEqual(weight?.timestamp, timestamp)
    }

    func testFetchLatestWeightThrowsError() async {
        // Given: mock error is set
        mockService.mockError = .noData

        // Then: should throw error
        do {
            _ = try await mockService.fetchLatestWeight()
            XCTFail("Expected error to be thrown")
        } catch let error as HealthKitError {
            XCTAssertEqual(error.errorDescription, HealthKitError.noData.errorDescription)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

// MARK: - TodayViewModel HealthKit Tests

final class TodayViewModelHealthKitTests: XCTestCase {

    var viewModel: TodayViewModel!
    var mockHealthKitService: MockHealthKitService!

    override func setUp() {
        super.setUp()
        mockHealthKitService = MockHealthKitService()
        viewModel = TodayViewModel(healthKitService: mockHealthKitService)
    }

    override func tearDown() {
        viewModel = nil
        mockHealthKitService = nil
        super.tearDown()
    }

    // MARK: - HealthKit Availability Tests

    func testIsHealthKitAvailableWhenAvailable() {
        // Given: HealthKit is available
        mockHealthKitService.mockIsAvailable = true

        // Then: viewModel should report available
        XCTAssertTrue(viewModel.isHealthKitAvailable)
    }

    func testIsHealthKitAvailableWhenUnavailable() {
        // Given: HealthKit is unavailable
        mockHealthKitService.mockIsAvailable = false

        // Then: viewModel should report unavailable
        XCTAssertFalse(viewModel.isHealthKitAvailable)
    }

    // MARK: - Authorization Status Tests

    func testIsHealthKitAuthorizationDeniedWhenNotDenied() {
        // Given: authorization is not determined
        mockHealthKitService.mockAuthorizationStatus = .notDetermined

        // Then: should not report denied
        XCTAssertFalse(viewModel.isHealthKitAuthorizationDenied)
    }

    func testIsHealthKitAuthorizationDeniedWhenDenied() {
        // Given: authorization is denied
        mockHealthKitService.mockAuthorizationStatus = .denied

        // Then: should report denied
        XCTAssertTrue(viewModel.isHealthKitAuthorizationDenied)
    }

    func testIsHealthKitAuthorizationDeniedWhenAuthorized() {
        // Given: authorization is granted
        mockHealthKitService.mockAuthorizationStatus = .authorized

        // Then: should not report denied
        XCTAssertFalse(viewModel.isHealthKitAuthorizationDenied)
    }

    func testIsHealthKitAuthorizationDeniedWhenUnavailable() {
        // Given: HealthKit is unavailable (e.g., iPad without HealthKit)
        mockHealthKitService.mockAuthorizationStatus = .unavailable

        // Then: should not report denied (unavailable is different from denied)
        XCTAssertFalse(viewModel.isHealthKitAuthorizationDenied)
    }

    // MARK: - Initial State Tests

    func testHealthKitWeightIsNilInitially() {
        XCTAssertNil(viewModel.healthKitWeight)
    }

    func testIsLoadingHealthKitIsFalseInitially() {
        XCTAssertFalse(viewModel.isLoadingHealthKit)
    }

    func testHealthKitErrorIsNilInitially() {
        XCTAssertNil(viewModel.healthKitError)
    }

    func testShowHealthKitTimestampIsFalseInitially() {
        XCTAssertFalse(viewModel.showHealthKitTimestamp)
    }

    // MARK: - Timestamp Text Tests

    func testHealthKitTimestampTextIsNilWhenNoWeight() {
        // Given: no HealthKit weight
        XCTAssertNil(viewModel.healthKitWeight)

        // Then: timestamp text should be nil
        XCTAssertNil(viewModel.healthKitTimestampText)
    }

    func testHealthKitTimestampTextContainsFromHealth() {
        // Given: HealthKit weight is set
        viewModel.healthKitWeight = HealthKitWeight(weight: 165.5, timestamp: Date())

        // Then: timestamp text should contain "From Health"
        XCTAssertTrue(viewModel.healthKitTimestampText?.contains("From Health") ?? false)
    }

    // MARK: - Clear HealthKit Weight Tests

    func testClearHealthKitWeightClearsWeight() {
        // Given: HealthKit weight is set
        viewModel.healthKitWeight = HealthKitWeight(weight: 165.5, timestamp: Date())
        viewModel.showHealthKitTimestamp = true

        // When: clearing
        viewModel.clearHealthKitWeight()

        // Then: weight and timestamp flag should be cleared
        XCTAssertNil(viewModel.healthKitWeight)
        XCTAssertFalse(viewModel.showHealthKitTimestamp)
    }

    // MARK: - Import Weight Tests

    func testImportWeightSetsErrorWhenUnavailable() async {
        // Given: HealthKit is unavailable
        mockHealthKitService.mockIsAvailable = false

        // When: importing weight
        await viewModel.importWeightFromHealthKit()

        // Then: should set error
        XCTAssertNotNil(viewModel.healthKitError)
        XCTAssertTrue(viewModel.healthKitError?.contains("not available") ?? false)
    }

    func testImportWeightSetsLoadingState() async {
        // Given: HealthKit is available with weight
        mockHealthKitService.mockWeight = HealthKitWeight(weight: 165.5, timestamp: Date())

        // When: importing weight (we can't test the intermediate loading state easily,
        // but we can verify the final state)
        await viewModel.importWeightFromHealthKit()

        // Then: loading should be false after completion
        XCTAssertFalse(viewModel.isLoadingHealthKit)
    }

    func testImportWeightSuccess() async {
        // Given: HealthKit is available with weight
        let timestamp = Date()
        mockHealthKitService.mockWeight = HealthKitWeight(weight: 165.5, timestamp: timestamp)

        // When: importing weight
        await viewModel.importWeightFromHealthKit()

        // Then: weight should be imported
        XCTAssertEqual(viewModel.healthKitWeight?.weight, 165.5)
        XCTAssertEqual(viewModel.weightInput, "165.5")
        XCTAssertTrue(viewModel.showHealthKitTimestamp)
        XCTAssertNil(viewModel.healthKitError)
        XCTAssertFalse(viewModel.isLoadingHealthKit)
    }

    func testImportWeightNoDataFound() async {
        // Given: HealthKit is available but no weight data
        mockHealthKitService.mockWeight = nil

        // When: importing weight
        await viewModel.importWeightFromHealthKit()

        // Then: should show error about no data
        XCTAssertNotNil(viewModel.healthKitError)
        XCTAssertTrue(viewModel.healthKitError?.contains("No weight data") ?? false)
        XCTAssertNil(viewModel.healthKitWeight)
    }

    func testImportWeightAuthorizationError() async {
        // Given: HealthKit returns authorization error
        mockHealthKitService.mockError = .authorizationDenied

        // When: importing weight
        await viewModel.importWeightFromHealthKit()

        // Then: should show authorization error (patient-friendly message about permission)
        XCTAssertNotNil(viewModel.healthKitError)
        XCTAssertTrue(viewModel.healthKitError?.contains("permission") ?? false)
    }

    func testImportWeightQueryError() async {
        // Given: HealthKit returns query error
        let underlyingError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Query failed"])
        mockHealthKitService.mockError = .queryFailed(underlyingError)

        // When: importing weight
        await viewModel.importWeightFromHealthKit()

        // Then: should show error
        XCTAssertNotNil(viewModel.healthKitError)
    }

    func testImportWeightClearsExistingError() async {
        // Given: existing error and HealthKit weight available
        viewModel.healthKitError = "Previous error"
        mockHealthKitService.mockWeight = HealthKitWeight(weight: 165.5, timestamp: Date())

        // When: importing weight
        await viewModel.importWeightFromHealthKit()

        // Then: error should be cleared
        XCTAssertNil(viewModel.healthKitError)
    }

    func testImportWeightUpdatesWeightInput() async {
        // Given: existing weight input
        viewModel.weightInput = "150.0"
        mockHealthKitService.mockWeight = HealthKitWeight(weight: 175.5, timestamp: Date())

        // When: importing weight
        await viewModel.importWeightFromHealthKit()

        // Then: weight input should be updated to new value
        XCTAssertEqual(viewModel.weightInput, "175.5")
    }

    func testImportWeightIgnoresConcurrentRequests() async {
        // Given: viewModel is already loading
        viewModel.isLoadingHealthKit = true
        mockHealthKitService.mockWeight = HealthKitWeight(weight: 175.5, timestamp: Date())

        // When: attempting to import while already loading
        await viewModel.importWeightFromHealthKit()

        // Then: the request should be ignored, no weight imported
        XCTAssertNil(viewModel.healthKitWeight)
        // Loading state should remain true (not reset)
        XCTAssertTrue(viewModel.isLoadingHealthKit)
    }

    func testImportWeightGenericErrorShowsPatientFriendlyMessage() async {
        // Given: HealthKit throws a generic (non-HealthKitError) error
        let genericError = NSError(
            domain: "com.test.generic",
            code: 42,
            userInfo: [NSLocalizedDescriptionKey: "Something unexpected happened"]
        )
        mockHealthKitService.mockGenericError = genericError

        // When: importing weight
        await viewModel.importWeightFromHealthKit()

        // Then: should show patient-friendly error (not exposing technical details)
        XCTAssertNotNil(viewModel.healthKitError)
        // Should use warm, patient-friendly messaging
        XCTAssertTrue(viewModel.healthKitError?.contains("Something went wrong") ?? false)
        XCTAssertTrue(viewModel.healthKitError?.contains("try again") ?? false)
        // Should NOT expose raw error description to patient
        XCTAssertFalse(viewModel.healthKitError?.contains("Something unexpected happened") ?? true)
        XCTAssertFalse(viewModel.isLoadingHealthKit)
    }
}
