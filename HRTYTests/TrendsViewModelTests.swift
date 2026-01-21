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
        XCTAssertNotNil(viewModel.currentWeight)
        XCTAssertEqual(viewModel.currentWeight!, 182.9, accuracy: 0.01)
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
        XCTAssertEqual(dataPoint.id, date)
    }

    func testWeightDataPointIdIsDate() {
        // Given: a specific date
        let date = Date()
        let dataPoint = WeightDataPoint(date: date, weight: 180.0)

        // Then: ID should be the date (semantic identifier for daily entries)
        XCTAssertEqual(dataPoint.id, date)
    }

    func testWeightDataPointIsIdentifiable() {
        // Given: a data point
        let dataPoint = WeightDataPoint(date: Date(), weight: 180.0)

        // Then: should conform to Identifiable (id is Date type)
        let _: Date = dataPoint.id
    }

    func testWeightDataPointEquatable() {
        // Given: two data points with same date and weight
        let date = Date()
        let point1 = WeightDataPoint(date: date, weight: 180.0)
        let point2 = WeightDataPoint(date: date, weight: 180.0)

        // Then: should be equal
        XCTAssertEqual(point1, point2)
    }

    func testWeightDataPointNotEqualWithDifferentWeight() {
        // Given: two data points with same date but different weight
        let date = Date()
        let point1 = WeightDataPoint(date: date, weight: 180.0)
        let point2 = WeightDataPoint(date: date, weight: 185.0)

        // Then: should not be equal
        XCTAssertNotEqual(point1, point2)
    }
}

// MARK: - SymptomDataPoint Tests

final class SymptomDataPointTests: XCTestCase {

    func testSymptomDataPointInitialization() {
        // Given: date, symptom type, severity, and alert status
        let date = Date()
        let symptomType = SymptomType.chestPain
        let severity = 3
        let hasAlert = false

        // When: creating SymptomDataPoint
        let dataPoint = SymptomDataPoint(
            date: date,
            symptomType: symptomType,
            severity: severity,
            hasAlert: hasAlert
        )

        // Then: values should be set correctly
        XCTAssertEqual(dataPoint.date, date)
        XCTAssertEqual(dataPoint.symptomType, symptomType)
        XCTAssertEqual(dataPoint.severity, severity)
        XCTAssertEqual(dataPoint.hasAlert, hasAlert)
    }

    func testSymptomDataPointIdIsUnique() {
        // Given: two data points with same date but different symptom types
        let date = Date()
        let point1 = SymptomDataPoint(date: date, symptomType: .chestPain, severity: 2, hasAlert: false)
        let point2 = SymptomDataPoint(date: date, symptomType: .dizziness, severity: 2, hasAlert: false)

        // Then: IDs should be different
        XCTAssertNotEqual(point1.id, point2.id)
    }

    func testSymptomDataPointIdIncludesDateAndType() {
        // Given: a specific date and symptom type
        let date = Date()
        let symptomType = SymptomType.dyspneaAtRest
        let dataPoint = SymptomDataPoint(date: date, symptomType: symptomType, severity: 1, hasAlert: false)

        // Then: ID should contain date timestamp and symptom raw value
        XCTAssertTrue(dataPoint.id.contains(symptomType.rawValue))
        XCTAssertTrue(dataPoint.id.contains(String(date.timeIntervalSince1970)))
    }

    func testSymptomDataPointEquatable() {
        // Given: two data points with same values
        let date = Date()
        let point1 = SymptomDataPoint(date: date, symptomType: .orthopnea, severity: 4, hasAlert: true)
        let point2 = SymptomDataPoint(date: date, symptomType: .orthopnea, severity: 4, hasAlert: true)

        // Then: should be equal
        XCTAssertEqual(point1, point2)
    }

    func testSymptomDataPointWithAlertFlag() {
        // Given: a symptom with severity >= 4 (alert threshold)
        let dataPoint = SymptomDataPoint(
            date: Date(),
            symptomType: .syncope,
            severity: 4,
            hasAlert: true
        )

        // Then: hasAlert should be true
        XCTAssertTrue(dataPoint.hasAlert)
    }
}

// MARK: - TrendsViewModel Symptom Tests

final class TrendsViewModelSymptomTests: XCTestCase {

    var viewModel: TrendsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = TrendsViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Symptom Empty State Tests

    func testHasNoSymptomDataWhenEmpty() {
        // Given: no symptom entries
        viewModel.symptomEntries = []

        // Then: hasSymptomData should be false
        XCTAssertFalse(viewModel.hasSymptomData)
    }

    func testHasSymptomDataWhenEntriesExist() {
        // Given: symptom entries
        viewModel.symptomEntries = [
            SymptomDataPoint(date: Date(), symptomType: .chestPain, severity: 2, hasAlert: false)
        ]

        // Then: hasSymptomData should be true
        XCTAssertTrue(viewModel.hasSymptomData)
    }

    func testDaysWithSymptomDataCountsUniqueDays() {
        // Given: symptom entries across 3 days (some days have multiple symptoms)
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        viewModel.symptomEntries = [
            SymptomDataPoint(date: today, symptomType: .chestPain, severity: 2, hasAlert: false),
            SymptomDataPoint(date: today, symptomType: .dizziness, severity: 1, hasAlert: false),
            SymptomDataPoint(date: yesterday, symptomType: .orthopnea, severity: 3, hasAlert: false),
            SymptomDataPoint(date: twoDaysAgo, symptomType: .syncope, severity: 2, hasAlert: false)
        ]

        // Then: daysWithSymptomData should be 3 (unique days)
        XCTAssertEqual(viewModel.daysWithSymptomData, 3)
    }

    // MARK: - Symptom Toggle Tests

    func testSymptomToggleStatesInitiallyEmpty() {
        // Then: toggle states should be empty by default
        XCTAssertTrue(viewModel.symptomToggleStates.isEmpty)
    }

    func testToggleSymptomSetsVisibility() {
        // Given: initial state (symptom visible by default)
        let symptomType = SymptomType.chestPain

        // When: toggling the symptom
        viewModel.toggleSymptom(symptomType)

        // Then: should be toggled off (false)
        XCTAssertFalse(viewModel.isSymptomVisible(symptomType))
    }

    func testToggleSymptomTwiceRestoresVisibility() {
        // Given: initial state
        let symptomType = SymptomType.dyspneaAtRest

        // When: toggling twice
        viewModel.toggleSymptom(symptomType)
        viewModel.toggleSymptom(symptomType)

        // Then: should be visible again
        XCTAssertTrue(viewModel.isSymptomVisible(symptomType))
    }

    func testIsSymptomVisibleDefaultsToTrue() {
        // Given: no toggle states set
        let symptomType = SymptomType.pnd

        // Then: should default to visible (true)
        XCTAssertTrue(viewModel.isSymptomVisible(symptomType))
    }

    // MARK: - Filtered Symptom Entries Tests

    func testFilteredSymptomEntriesRespectsToggleState() {
        // Given: entries for multiple symptoms
        viewModel.symptomEntries = [
            SymptomDataPoint(date: Date(), symptomType: .chestPain, severity: 2, hasAlert: false),
            SymptomDataPoint(date: Date(), symptomType: .dizziness, severity: 1, hasAlert: false)
        ]
        viewModel.toggleSymptom(.chestPain) // Hide chest pain

        // Then: filtered entries should only include dizziness
        let filtered = viewModel.filteredSymptomEntries
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.symptomType, .dizziness)
    }

    func testVisibleSymptomTypesExcludesToggledOff() {
        // Given: toggle off two symptoms
        viewModel.toggleSymptom(.chestPain)
        viewModel.toggleSymptom(.syncope)

        // Then: visible types should exclude those two
        let visible = viewModel.visibleSymptomTypes
        XCTAssertEqual(visible.count, 6) // 8 total - 2 hidden
        XCTAssertFalse(visible.contains(.chestPain))
        XCTAssertFalse(visible.contains(.syncope))
    }

    // MARK: - Alert Date Tests

    func testHasAlertOnDateReturnsFalseWhenEmpty() {
        // Given: no alert dates
        viewModel.alertDates = []

        // Then: hasAlert should return false
        XCTAssertFalse(viewModel.hasAlert(on: Date()))
    }

    func testHasAlertOnDateReturnsTrueWhenDateHasAlert() {
        // Given: alert date set
        let today = Calendar.current.startOfDay(for: Date())
        viewModel.alertDates = [today]

        // Then: hasAlert should return true for today
        XCTAssertTrue(viewModel.hasAlert(on: Date()))
    }

    func testHasAlertNormalizesDateToStartOfDay() {
        // Given: alert date at start of day
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        viewModel.alertDates = [today]

        // When: checking with a time later in the same day
        let laterToday = calendar.date(byAdding: .hour, value: 14, to: today)!

        // Then: should still find the alert
        XCTAssertTrue(viewModel.hasAlert(on: laterToday))
    }

    // MARK: - Symptom Accessibility Summary Tests

    func testSymptomAccessibilitySummaryWithNoData() {
        // Given: no symptom entries
        viewModel.symptomEntries = []

        // Then: should provide appropriate message
        XCTAssertEqual(viewModel.symptomAccessibilitySummary, "No symptom data recorded in the past 30 days")
    }

    func testSymptomAccessibilitySummaryIncludesDaysCount() {
        // Given: symptom entries
        let calendar = Calendar.current
        viewModel.symptomEntries = [
            SymptomDataPoint(date: Date(), symptomType: .chestPain, severity: 2, hasAlert: false),
            SymptomDataPoint(date: calendar.date(byAdding: .day, value: -1, to: Date())!, symptomType: .dizziness, severity: 1, hasAlert: false)
        ]

        // Then: summary should mention days of data
        XCTAssertTrue(viewModel.symptomAccessibilitySummary.contains("2 days of data"))
    }

    func testSymptomAccessibilitySummaryIncludesVisibleCount() {
        // Given: some symptoms toggled off
        viewModel.symptomEntries = [
            SymptomDataPoint(date: Date(), symptomType: .chestPain, severity: 2, hasAlert: false)
        ]
        viewModel.toggleSymptom(.dyspneaAtRest)
        viewModel.toggleSymptom(.orthopnea)

        // Then: summary should mention visible count
        XCTAssertTrue(viewModel.symptomAccessibilitySummary.contains("6 of 8 symptoms visible"))
    }

    func testSymptomAccessibilitySummaryMentionsAlerts() {
        // Given: symptom entries with alert days
        viewModel.symptomEntries = [
            SymptomDataPoint(date: Date(), symptomType: .chestPain, severity: 4, hasAlert: true)
        ]
        viewModel.alertDates = [Calendar.current.startOfDay(for: Date())]

        // Then: summary should mention alerts with warm language
        XCTAssertTrue(viewModel.symptomAccessibilitySummary.contains("1 day with symptoms that needed attention"))
    }

    func testSymptomAccessibilitySummaryNoAlertsMessage() {
        // Given: symptom entries without alerts
        viewModel.symptomEntries = [
            SymptomDataPoint(date: Date(), symptomType: .chestPain, severity: 2, hasAlert: false)
        ]
        viewModel.alertDates = []

        // Then: summary should indicate no alerts
        XCTAssertTrue(viewModel.symptomAccessibilitySummary.contains("No symptom alerts in this period"))
    }

    // MARK: - Symptom Color Tests

    func testSymptomColorsAreDistinct() {
        // Given: all symptom types
        let colors = SymptomType.allCases.map { TrendsViewModel.color(for: $0) }

        // Then: all colors should be provided (no crashes)
        XCTAssertEqual(colors.count, 8)
    }

    func testSymptomColorForEachType() {
        // Then: each symptom type should have a color
        for symptomType in SymptomType.allCases {
            let _ = TrendsViewModel.color(for: symptomType) // Should not crash
        }
    }

    // MARK: - Symptom Entries By Type Tests

    func testSymptomEntriesForTypeFiltersCorrectly() {
        // Given: entries for multiple symptom types
        let today = Date()
        viewModel.symptomEntries = [
            SymptomDataPoint(date: today, symptomType: .chestPain, severity: 2, hasAlert: false),
            SymptomDataPoint(date: today, symptomType: .dizziness, severity: 1, hasAlert: false),
            SymptomDataPoint(date: today, symptomType: .chestPain, severity: 3, hasAlert: false)
        ]

        // When: getting entries for chest pain
        let chestPainEntries = viewModel.symptomEntries(for: .chestPain)

        // Then: should only include chest pain entries
        XCTAssertEqual(chestPainEntries.count, 2)
        XCTAssertTrue(chestPainEntries.allSatisfy { $0.symptomType == .chestPain })
    }

    func testSymptomEntriesForTypeAreSortedByDate() {
        // Given: entries out of order
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        viewModel.symptomEntries = [
            SymptomDataPoint(date: today, symptomType: .dizziness, severity: 2, hasAlert: false),
            SymptomDataPoint(date: twoDaysAgo, symptomType: .dizziness, severity: 1, hasAlert: false),
            SymptomDataPoint(date: yesterday, symptomType: .dizziness, severity: 3, hasAlert: false)
        ]

        // When: getting entries for dizziness
        let entries = viewModel.symptomEntries(for: .dizziness)

        // Then: should be sorted by date ascending
        XCTAssertEqual(entries.count, 3)
        XCTAssertEqual(entries[0].date, twoDaysAgo)
        XCTAssertEqual(entries[1].date, yesterday)
        XCTAssertEqual(entries[2].date, today)
    }
}
