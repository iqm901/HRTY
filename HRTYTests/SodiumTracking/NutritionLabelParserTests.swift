import XCTest
@testable import HRTY

final class NutritionLabelParserTests: XCTestCase {

    var parser: NutritionLabelParser!

    override func setUp() {
        super.setUp()
        parser = NutritionLabelParser()
    }

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    // MARK: - Sodium Extraction Tests

    func test_parser_extractsSimpleSodiumValue() {
        // Given
        let text = "Nutrition Facts\nServing Size 1 cup\nSodium 480mg"

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.sodiumMg, 480)
    }

    func test_parser_handlesMgWithSpace() {
        // Given
        let text = "Sodium 480 mg"

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.sodiumMg, 480)
    }

    func test_parser_handlesColonSeparator() {
        // Given
        let text = "Sodium: 350mg"

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.sodiumMg, 350)
    }

    func test_parser_handlesCommasInNumbers() {
        // Given
        let text = "Sodium 1,200mg"

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.sodiumMg, 1200)
    }

    func test_parser_handlesLowercaseSodium() {
        // Given
        let text = "sodium 250mg"

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.sodiumMg, 250)
    }

    func test_parser_returnsNilWhenNoSodiumFound() {
        // Given - text without sodium
        let text = "Nutrition Facts\nCalories 200\nProtein 5g"

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNil(result)
    }

    func test_parser_returnsNilForEmptyText() {
        // Given
        let text = ""

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNil(result)
    }

    func test_parser_handlesMultilineNutritionLabel() {
        // Given - typical multi-line label
        let text = """
        Nutrition Facts
        Serving Size 1 container (227g)
        Calories 150
        Total Fat 2.5g
        Sodium 650mg
        Total Carbohydrate 22g
        Protein 12g
        """

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.sodiumMg, 650)
    }

    // MARK: - Serving Size Extraction Tests

    func test_parser_extractsServingSize() {
        // Given
        let text = "Serving Size 1 cup (240ml)\nSodium 100mg"

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.servingSize)
        XCTAssertTrue(result?.servingSize?.contains("1 cup") ?? false)
    }

    func test_parser_handlesServingSizeWithColon() {
        // Given
        let text = "Serving Size: 2 tablespoons\nSodium 200mg"

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.servingSize)
    }

    // MARK: - Edge Cases

    func test_parser_handlesSmallSodiumValues() {
        // Given
        let text = "Sodium 5mg"

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.sodiumMg, 5)
    }

    func test_parser_handlesFourDigitSodiumValues() {
        // Given
        let text = "Sodium 1850mg"

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.sodiumMg, 1850)
    }

    func test_parser_rawTextIsPreserved() {
        // Given
        let text = "Sodium 300mg"

        // When
        let result = parser.parseText(text)

        // Then
        XCTAssertEqual(result?.rawText, text)
    }
}
