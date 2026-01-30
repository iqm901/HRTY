import XCTest
import SwiftData
@testable import HRTY

final class SodiumViewModelTests: XCTestCase {

    var viewModel: SodiumViewModel!

    override func setUp() {
        super.setUp()
        viewModel = SodiumViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Progress Color Tests

    func test_progressColor_greenUnder75Percent() {
        // Given - under 75% of limit (2000mg)
        viewModel.todayTotalMg = 1000 // 50%

        // Then
        XCTAssertEqual(viewModel.progressColor, .hrtGoodFallback)
    }

    func test_progressColor_yellowAt75to90Percent() {
        // Given - 75-90% of limit
        viewModel.todayTotalMg = 1600 // 80%

        // Then
        XCTAssertEqual(viewModel.progressColor, .hrtCautionFallback)
    }

    func test_progressColor_yellowAtExactly75Percent() {
        // Given - exactly 75% of limit
        viewModel.todayTotalMg = 1500

        // Then
        XCTAssertEqual(viewModel.progressColor, .hrtCautionFallback)
    }

    func test_progressColor_redAbove90Percent() {
        // Given - over 90% of limit
        viewModel.todayTotalMg = 1900 // 95%

        // Then
        XCTAssertEqual(viewModel.progressColor, .hrtAlertFallback)
    }

    func test_progressColor_redAtExactly90Percent() {
        // Given - exactly 90% of limit
        viewModel.todayTotalMg = 1800

        // Then
        XCTAssertEqual(viewModel.progressColor, .hrtAlertFallback)
    }

    func test_progressColor_redWhenOverLimit() {
        // Given - over limit
        viewModel.todayTotalMg = 2500

        // Then
        XCTAssertEqual(viewModel.progressColor, .hrtAlertFallback)
    }

    // MARK: - Remaining Calculation Tests

    func test_remainingMg_calculatesCorrectly() {
        // Given
        viewModel.todayTotalMg = 1200

        // Then
        XCTAssertEqual(viewModel.remainingMg, 800) // 2000 - 1200
    }

    func test_remainingMg_neverNegative() {
        // Given - over limit
        viewModel.todayTotalMg = 2500

        // Then
        XCTAssertEqual(viewModel.remainingMg, 0)
    }

    func test_isOverLimit_falseWhenUnder() {
        // Given
        viewModel.todayTotalMg = 1999

        // Then
        XCTAssertFalse(viewModel.isOverLimit)
    }

    func test_isOverLimit_trueAtLimit() {
        // Given
        viewModel.todayTotalMg = 2000

        // Then
        XCTAssertTrue(viewModel.isOverLimit)
    }

    // MARK: - Form Validation Tests

    func test_formValidation_requiresNameAndSodium() {
        // Given - empty form
        viewModel.nameInput = ""
        viewModel.sodiumInput = ""

        // Then
        XCTAssertFalse(viewModel.isFormValid)
    }

    func test_formValidation_invalidWithOnlyName() {
        // Given
        viewModel.nameInput = "Test Food"
        viewModel.sodiumInput = ""

        // Then
        XCTAssertFalse(viewModel.isFormValid)
    }

    func test_formValidation_invalidWithOnlySodium() {
        // Given
        viewModel.nameInput = ""
        viewModel.sodiumInput = "500"

        // Then
        XCTAssertFalse(viewModel.isFormValid)
    }

    func test_formValidation_validWithNameAndSodium() {
        // Given
        viewModel.nameInput = "Test Food"
        viewModel.sodiumInput = "500"

        // Then
        XCTAssertTrue(viewModel.isFormValid)
    }

    func test_formValidation_invalidWithWhitespaceOnlyName() {
        // Given
        viewModel.nameInput = "   "
        viewModel.sodiumInput = "500"

        // Then
        XCTAssertFalse(viewModel.isFormValid)
    }

    func test_formValidation_invalidWithZeroSodium() {
        // Given
        viewModel.nameInput = "Test Food"
        viewModel.sodiumInput = "0"

        // Then
        XCTAssertFalse(viewModel.isFormValid)
    }

    func test_formValidation_invalidWithNegativeSodium() {
        // Given
        viewModel.nameInput = "Test Food"
        viewModel.sodiumInput = "-100"

        // Then
        XCTAssertFalse(viewModel.isFormValid)
    }

    func test_formValidation_invalidWithNonNumericSodium() {
        // Given
        viewModel.nameInput = "Test Food"
        viewModel.sodiumInput = "abc"

        // Then
        XCTAssertFalse(viewModel.isFormValid)
    }

    // MARK: - Form Reset Tests

    func test_resetForm_clearsAllFields() {
        // Given - form with data
        viewModel.nameInput = "Test Food"
        viewModel.sodiumInput = "500"
        viewModel.servingInput = "1 cup"
        viewModel.selectedCategory = .breakfast
        viewModel.errorMessage = "Some error"

        // When
        viewModel.resetForm()

        // Then
        XCTAssertEqual(viewModel.nameInput, "")
        XCTAssertEqual(viewModel.sodiumInput, "")
        XCTAssertEqual(viewModel.servingInput, "")
        XCTAssertEqual(viewModel.selectedCategory, .other)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.editingTemplate)
    }

    // MARK: - Progress Percent Tests

    func test_progressPercent_calculatesCorrectly() {
        // Given
        viewModel.todayTotalMg = 1000

        // Then
        XCTAssertEqual(viewModel.progressPercent, 0.5, accuracy: 0.001)
    }

    func test_progressPercent_canExceed100() {
        // Given - over limit
        viewModel.todayTotalMg = 2500

        // Then
        XCTAssertEqual(viewModel.progressPercent, 1.25, accuracy: 0.001)
    }

    // MARK: - Formatted Values Tests

    func test_formattedTotal_displaysCorrectly() {
        // Given
        viewModel.todayTotalMg = 1240

        // Then
        XCTAssertEqual(viewModel.formattedTotal, "1,240 / 2,000 mg")
    }

    func test_formattedRemaining_displaysCorrectly() {
        // Given
        viewModel.todayTotalMg = 1240

        // Then
        XCTAssertEqual(viewModel.formattedRemaining, "760 mg remaining")
    }

    func test_formattedRemaining_showsLimitReachedWhenOver() {
        // Given
        viewModel.todayTotalMg = 2500

        // Then
        XCTAssertEqual(viewModel.formattedRemaining, "Daily limit reached")
    }
}
