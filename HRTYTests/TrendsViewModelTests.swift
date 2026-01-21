import XCTest
@testable import HRTY

final class TrendsViewModelTests: XCTestCase {

    var viewModel: TrendsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = TrendsViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Empty State Tests

    func testHasNoWeightDataWhenEmpty() {
        // Given: no weight entries
        viewModel.weightEntries = []

        // Then: hasWeightData should be false
        XCTAssertFalse(viewModel.hasWeightData)
    }

    func testHasWeightDataWhenEntriesExist() {
        // Given: weight entries
        viewModel.weightEntries = [
            WeightDataPoint(date: Date(), weight: 180.0)
        ]

        // Then: hasWeightData should be true
        XCTAssertTrue(viewModel.hasWeightData)
    }

    func testDaysWithDataCountsCorrectly() {
        // Given: 5 weight entries
        let calendar = Calendar.current
        viewModel.weightEntries = (0..<5).map { i in
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            return WeightDataPoint(date: date, weight: 180.0 + Double(i))
        }

        // Then: daysWithData should be 5
        XCTAssertEqual(viewModel.daysWithData, 5)
    }

    // MARK: - Current Weight Tests

    func testCurrentWeightReturnsLastEntry() {
        // Given: multiple entries (sorted by date)
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -2, to: Date())!, weight: 182.0),
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -1, to: Date())!, weight: 181.0),
            WeightDataPoint(date: Date(), weight: 180.0)
        ]

        // Then: current weight should be the last entry
        XCTAssertEqual(viewModel.currentWeight, 180.0)
    }

    func testCurrentWeightReturnsNilWhenEmpty() {
        // Given: no entries
        viewModel.weightEntries = []

        // Then: currentWeight should be nil
        XCTAssertNil(viewModel.currentWeight)
    }

    func testStartingWeightReturnsFirstEntry() {
        // Given: multiple entries
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -2, to: Date())!, weight: 182.0),
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -1, to: Date())!, weight: 181.0),
            WeightDataPoint(date: Date(), weight: 180.0)
        ]

        // Then: starting weight should be the first entry
        XCTAssertEqual(viewModel.startingWeight, 182.0)
    }

    // MARK: - Weight Change Calculation Tests

    func testWeightChangeCalculatesGain() {
        // Given: weight increased from 180 to 185
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 180.0),
            WeightDataPoint(date: Date(), weight: 185.0)
        ]

        // Then: weight change should be +5
        XCTAssertEqual(viewModel.weightChange, 5.0)
    }

    func testWeightChangeCalculatesLoss() {
        // Given: weight decreased from 185 to 180
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 185.0),
            WeightDataPoint(date: Date(), weight: 180.0)
        ]

        // Then: weight change should be -5
        XCTAssertEqual(viewModel.weightChange, -5.0)
    }

    func testWeightChangeReturnsNilWithSingleEntry() {
        // Given: only one entry
        viewModel.weightEntries = [
            WeightDataPoint(date: Date(), weight: 180.0)
        ]

        // Then: weight change should be nil (can't calculate change from one point)
        XCTAssertNil(viewModel.weightChange)
    }

    func testWeightChangeReturnsNilWhenEmpty() {
        // Given: no entries
        viewModel.weightEntries = []

        // Then: weight change should be nil
        XCTAssertNil(viewModel.weightChange)
    }

    // MARK: - Weight Change Text Tests

    func testWeightChangeTextShowsGain() {
        // Given: weight gained 3.5 lbs
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 180.0),
            WeightDataPoint(date: Date(), weight: 183.5)
        ]

        // Then: should show positive change with plus sign
        XCTAssertEqual(viewModel.weightChangeText, "+3.5 lbs")
    }

    func testWeightChangeTextShowsLoss() {
        // Given: weight lost 2.5 lbs
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 182.5),
            WeightDataPoint(date: Date(), weight: 180.0)
        ]

        // Then: should show negative change with minus sign
        XCTAssertEqual(viewModel.weightChangeText, "-2.5 lbs")
    }

    func testWeightChangeTextShowsStable() {
        // Given: weight stayed the same (within 0.1 threshold)
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 180.0),
            WeightDataPoint(date: Date(), weight: 180.05)
        ]

        // Then: should show "Stable" - warmer messaging for patients
        XCTAssertEqual(viewModel.weightChangeText, "Stable")
    }

    func testWeightChangeTextReturnsNilWhenNoData() {
        // Given: no entries
        viewModel.weightEntries = []

        // Then: weightChangeText should be nil
        XCTAssertNil(viewModel.weightChangeText)
    }

    // MARK: - Weight Trend Description Tests

    func testWeightTrendDescriptionShowsGained() {
        // Given: weight gained
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 180.0),
            WeightDataPoint(date: Date(), weight: 185.0)
        ]

        // Then: trend description should be "gained"
        XCTAssertEqual(viewModel.weightTrendDescription, "gained")
    }

    func testWeightTrendDescriptionShowsLost() {
        // Given: weight lost
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 185.0),
            WeightDataPoint(date: Date(), weight: 180.0)
        ]

        // Then: trend description should be "lost"
        XCTAssertEqual(viewModel.weightTrendDescription, "lost")
    }

    func testWeightTrendDescriptionShowsMaintained() {
        // Given: weight maintained (within threshold)
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 180.0),
            WeightDataPoint(date: Date(), weight: 180.05)
        ]

        // Then: trend description should be "maintained"
        XCTAssertEqual(viewModel.weightTrendDescription, "maintained")
    }

    // MARK: - Formatted Weight Tests

    func testFormattedCurrentWeightWithValidWeight() {
        // Given: weight entry
        viewModel.weightEntries = [
            WeightDataPoint(date: Date(), weight: 182.5)
        ]

        // Then: should format with one decimal place
        XCTAssertEqual(viewModel.formattedCurrentWeight, "182.5 lbs")
    }

    func testFormattedCurrentWeightReturnsNilWhenEmpty() {
        // Given: no entries
        viewModel.weightEntries = []

        // Then: should return nil
        XCTAssertNil(viewModel.formattedCurrentWeight)
    }

    func testFormattedCurrentWeightRoundsCorrectly() {
        // Given: weight with more decimal places
        viewModel.weightEntries = [
            WeightDataPoint(date: Date(), weight: 182.456)
        ]

        // Then: should round to one decimal place
        XCTAssertEqual(viewModel.formattedCurrentWeight, "182.5 lbs")
    }

    // MARK: - Date Range Tests

    func testChartStartDateIs29DaysAgo() {
        // Given: current date
        let today = Date()
        let calendar = Calendar.current

        // When: getting chart start date
        let startDate = viewModel.chartStartDate

        // Then: should be 29 days ago (for 30 day range including today)
        let expectedStart = calendar.date(byAdding: .day, value: -29, to: today)!
        XCTAssertEqual(calendar.dateComponents([.day], from: startDate, to: expectedStart).day, 0)
    }

    func testChartEndDateIsToday() {
        // Given: current date
        let today = Date()
        let calendar = Calendar.current

        // When: getting chart end date
        let endDate = viewModel.chartEndDate

        // Then: should be today
        XCTAssertTrue(calendar.isDateInToday(endDate))
    }

    func testDateRangeTextContainsDates() {
        // When: getting date range text
        let dateRangeText = viewModel.dateRangeText

        // Then: should contain a dash separator
        XCTAssertTrue(dateRangeText.contains(" - "))
    }

    // MARK: - Accessibility Summary Tests

    func testAccessibilitySummaryWithNoData() {
        // Given: no entries
        viewModel.weightEntries = []

        // Then: should provide appropriate message
        XCTAssertEqual(viewModel.accessibilitySummary, "No weight data recorded in the past 30 days")
    }

    func testAccessibilitySummaryIncludesDaysCount() {
        // Given: multiple entries
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 180.0),
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -3, to: Date())!, weight: 181.0),
            WeightDataPoint(date: Date(), weight: 182.0)
        ]

        // Then: should mention number of days
        XCTAssertTrue(viewModel.accessibilitySummary.contains("3 days of data"))
    }

    func testAccessibilitySummaryIncludesCurrentWeight() {
        // Given: weight entries
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 180.0),
            WeightDataPoint(date: Date(), weight: 185.0)
        ]

        // Then: should mention current weight
        XCTAssertTrue(viewModel.accessibilitySummary.contains("Current weight: 185.0 lbs"))
    }

    func testAccessibilitySummaryIncludesTrendDirection() {
        // Given: weight gain entries
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 180.0),
            WeightDataPoint(date: Date(), weight: 185.0)
        ]

        // Then: should mention trend direction with warm, neutral language
        XCTAssertTrue(viewModel.accessibilitySummary.contains("up"))
    }

    // MARK: - Loading State Tests

    func testIsLoadingInitiallyFalse() {
        // Then: isLoading should be false initially
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Edge Case Tests

    func testWeightChangeWithExactThresholdValue() {
        // Given: weight change of exactly 0.1 (at threshold)
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 180.0),
            WeightDataPoint(date: Date(), weight: 180.1)
        ]

        // Then: should be considered "Stable" (0.1 is not > 0.1)
        XCTAssertEqual(viewModel.weightChangeText, "Stable")
    }

    func testWeightChangeJustAboveThreshold() {
        // Given: weight change of 0.2 (just above threshold)
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 180.0),
            WeightDataPoint(date: Date(), weight: 180.2)
        ]

        // Then: should show positive change
        XCTAssertEqual(viewModel.weightChangeText, "+0.2 lbs")
    }

    func testWeightChangeWithLargeValues() {
        // Given: larger weight values
        let calendar = Calendar.current
        viewModel.weightEntries = [
            WeightDataPoint(date: calendar.date(byAdding: .day, value: -7, to: Date())!, weight: 250.0),
            WeightDataPoint(date: Date(), weight: 245.5)
        ]

        // Then: should calculate correctly
        XCTAssertEqual(viewModel.weightChange, -4.5)
        XCTAssertEqual(viewModel.weightChangeText, "-4.5 lbs")
    }

    func testWeightChangeWithManyEntries() {
        // Given: many entries over 30 days
        let calendar = Calendar.current
        viewModel.weightEntries = (0..<30).map { i in
            let date = calendar.date(byAdding: .day, value: -29 + i, to: Date())!
            return WeightDataPoint(date: date, weight: 180.0 + Double(i) * 0.1)
        }

        // Then: should use first and last entries for change calculation
        XCTAssertEqual(viewModel.startingWeight, 180.0)
        XCTAssertEqual(viewModel.currentWeight, 182.9, accuracy: 0.01)
        XCTAssertEqual(viewModel.daysWithData, 30)
    }
}

// MARK: - WeightDataPoint Tests

final class WeightDataPointTests: XCTestCase {

    func testWeightDataPointInitialization() {
        // Given: date and weight
        let date = Date()
        let weight = 180.5

        // When: creating WeightDataPoint
        let dataPoint = WeightDataPoint(date: date, weight: weight)

        // Then: values should be set correctly
        XCTAssertEqual(dataPoint.date, date)
        XCTAssertEqual(dataPoint.weight, weight)
        XCTAssertNotNil(dataPoint.id)
    }

    func testWeightDataPointHasUniqueIds() {
        // Given: two data points
        let point1 = WeightDataPoint(date: Date(), weight: 180.0)
        let point2 = WeightDataPoint(date: Date(), weight: 180.0)

        // Then: IDs should be unique
        XCTAssertNotEqual(point1.id, point2.id)
    }

    func testWeightDataPointIsIdentifiable() {
        // Given: a data point
        let dataPoint = WeightDataPoint(date: Date(), weight: 180.0)

        // Then: should conform to Identifiable (has id property)
        let _: UUID = dataPoint.id
    }
}
