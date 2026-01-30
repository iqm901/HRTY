import XCTest
import SwiftData
@testable import HRTY

final class LocalProductDatabaseTests: XCTestCase {

    var database: LocalProductDatabase!
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() {
        super.setUp()
        database = LocalProductDatabase()

        let schema = Schema([SodiumEntry.self, SodiumTemplate.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    override func tearDown() {
        database = nil
        context = nil
        container = nil
        super.tearDown()
    }

    // MARK: - Product Lookup Tests

    func test_database_returnsNilForUnknownBarcode() {
        // Given - no templates in database
        let barcode = "1234567890123"

        // When
        let product = database.findProduct(barcode: barcode, context: context)

        // Then
        XCTAssertNil(product)
    }

    func test_database_findsExistingProduct() {
        // Given - create a template with barcode
        let template = SodiumTemplate(
            name: "Test Product",
            sodiumMg: 450,
            servingSize: "1 can",
            category: .beverage,
            barcode: "1234567890123"
        )
        context.insert(template)
        try? context.save()

        // When
        let product = database.findProduct(barcode: "1234567890123", context: context)

        // Then
        XCTAssertNotNil(product)
        XCTAssertEqual(product?.name, "Test Product")
        XCTAssertEqual(product?.sodiumMg, 450)
        XCTAssertEqual(product?.servingSize, "1 can")
        XCTAssertEqual(product?.barcode, "1234567890123")
    }

    func test_database_customProductPersists() {
        // Given
        let product = ProductInfo(
            barcode: "9876543210987",
            name: "Custom Product",
            sodiumMg: 320,
            servingSize: "2 oz",
            brand: "Test Brand"
        )

        // When
        let saved = database.saveCustomProduct(product, context: context)

        // Then
        XCTAssertTrue(saved)

        // Verify it can be found
        let foundProduct = database.findProduct(barcode: "9876543210987", context: context)
        XCTAssertNotNil(foundProduct)
        XCTAssertEqual(foundProduct?.name, "Custom Product")
        XCTAssertEqual(foundProduct?.sodiumMg, 320)
    }

    func test_database_doesNotFindArchivedTemplate() {
        // Given - create an archived template with barcode
        let template = SodiumTemplate(
            name: "Archived Product",
            sodiumMg: 200,
            category: .snack,
            barcode: "1111111111111",
            isArchived: true
        )
        context.insert(template)
        try? context.save()

        // When
        let product = database.findProduct(barcode: "1111111111111", context: context)

        // Then
        XCTAssertNil(product)
    }

    func test_database_productInfoEquality() {
        // Given
        let product1 = ProductInfo(barcode: "123", name: "Test", sodiumMg: 100, servingSize: nil, brand: nil)
        let product2 = ProductInfo(barcode: "123", name: "Test", sodiumMg: 100, servingSize: nil, brand: nil)
        let product3 = ProductInfo(barcode: "456", name: "Test", sodiumMg: 100, servingSize: nil, brand: nil)

        // Then
        XCTAssertEqual(product1, product2)
        XCTAssertNotEqual(product1, product3)
    }

    func test_database_saveMultipleCustomProducts() {
        // Given
        let product1 = ProductInfo(barcode: "111", name: "Product 1", sodiumMg: 100, servingSize: nil, brand: nil)
        let product2 = ProductInfo(barcode: "222", name: "Product 2", sodiumMg: 200, servingSize: nil, brand: nil)

        // When
        database.saveCustomProduct(product1, context: context)
        database.saveCustomProduct(product2, context: context)

        // Then
        let found1 = database.findProduct(barcode: "111", context: context)
        let found2 = database.findProduct(barcode: "222", context: context)

        XCTAssertNotNil(found1)
        XCTAssertNotNil(found2)
        XCTAssertEqual(found1?.name, "Product 1")
        XCTAssertEqual(found2?.name, "Product 2")
    }
}
