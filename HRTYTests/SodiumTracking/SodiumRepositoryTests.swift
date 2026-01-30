import XCTest
import SwiftData
@testable import HRTY

final class SodiumRepositoryTests: XCTestCase {

    var repository: SodiumRepository!
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() {
        super.setUp()
        repository = SodiumRepository()

        let schema = Schema([SodiumEntry.self, SodiumTemplate.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    override func tearDown() {
        repository = nil
        context = nil
        container = nil
        super.tearDown()
    }

    // MARK: - Entry Tests

    func test_addEntry_persistsAndReturnsEntry() {
        // When
        let entry = repository.addEntry(
            name: "Test Food",
            sodiumMg: 500,
            servingSize: "1 cup",
            source: .manual,
            barcode: nil,
            templateId: nil,
            context: context
        )

        // Then
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.name, "Test Food")
        XCTAssertEqual(entry?.sodiumMg, 500)
        XCTAssertEqual(entry?.servingSize, "1 cup")
        XCTAssertEqual(entry?.source, .manual)
    }

    func test_todayTotal_sumsOnlyTodayEntries() {
        // Given - add entries for today
        repository.addEntry(name: "Food 1", sodiumMg: 300, servingSize: nil, source: .manual, barcode: nil, templateId: nil, context: context)
        repository.addEntry(name: "Food 2", sodiumMg: 200, servingSize: nil, source: .manual, barcode: nil, templateId: nil, context: context)

        // When
        let total = repository.getTodayTotal(context: context)

        // Then
        XCTAssertEqual(total, 500)
    }

    func test_todayTotal_excludesYesterdayEntries() {
        // Given - add today's entry
        repository.addEntry(name: "Today Food", sodiumMg: 300, servingSize: nil, source: .manual, barcode: nil, templateId: nil, context: context)

        // Add yesterday's entry manually with backdated timestamp
        let yesterdayEntry = SodiumEntry(
            name: "Yesterday Food",
            sodiumMg: 1000,
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            source: .manual
        )
        context.insert(yesterdayEntry)
        try? context.save()

        // When
        let total = repository.getTodayTotal(context: context)

        // Then - should only include today's entry
        XCTAssertEqual(total, 300)
    }

    func test_deleteEntry_removesFromStore() {
        // Given
        let entry = repository.addEntry(
            name: "To Delete",
            sodiumMg: 100,
            servingSize: nil,
            source: .manual,
            barcode: nil,
            templateId: nil,
            context: context
        )!

        // When
        let deleted = repository.deleteEntry(entry, context: context)

        // Then
        XCTAssertTrue(deleted)
        let entries = repository.fetchTodayEntries(context: context)
        XCTAssertTrue(entries.isEmpty)
    }

    // MARK: - Template Tests

    func test_createTemplate_persistsTemplate() {
        // When
        let template = repository.saveAsTemplate(
            name: "Morning Coffee",
            sodiumMg: 50,
            servingSize: "1 cup",
            category: .beverage,
            barcode: nil,
            context: context
        )

        // Then
        XCTAssertNotNil(template)
        XCTAssertEqual(template?.name, "Morning Coffee")
        XCTAssertEqual(template?.sodiumMg, 50)
        XCTAssertEqual(template?.category, .beverage)
    }

    func test_fetchTemplates_returnsAllActive() {
        // Given
        repository.saveAsTemplate(name: "Template 1", sodiumMg: 100, servingSize: nil, category: .breakfast, barcode: nil, context: context)
        repository.saveAsTemplate(name: "Template 2", sodiumMg: 200, servingSize: nil, category: .lunch, barcode: nil, context: context)

        // When
        let templates = repository.fetchTemplates(context: context)

        // Then
        XCTAssertEqual(templates.count, 2)
    }

    func test_archiveTemplate_removesFromActiveList() {
        // Given
        let template = repository.saveAsTemplate(
            name: "To Archive",
            sodiumMg: 100,
            servingSize: nil,
            category: .snack,
            barcode: nil,
            context: context
        )!

        // When
        let archived = repository.archiveTemplate(template, context: context)

        // Then
        XCTAssertTrue(archived)
        let templates = repository.fetchTemplates(context: context)
        XCTAssertTrue(templates.isEmpty)
    }

    func test_addEntryFromTemplate_createsEntryAndIncrementsUsage() {
        // Given
        let template = repository.saveAsTemplate(
            name: "Quick Add",
            sodiumMg: 250,
            servingSize: "1 serving",
            category: .snack,
            barcode: nil,
            context: context
        )!
        let initialUsageCount = template.usageCount

        // When
        let entry = repository.addEntryFromTemplate(template, context: context)

        // Then
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.name, "Quick Add")
        XCTAssertEqual(entry?.sodiumMg, 250)
        XCTAssertEqual(entry?.source, .template)
        XCTAssertEqual(entry?.templateId, template.id)
        XCTAssertEqual(template.usageCount, initialUsageCount + 1)
        XCTAssertNotNil(template.lastUsedAt)
    }

    func test_deleteTemplate_removesFromStore() {
        // Given
        let template = repository.saveAsTemplate(
            name: "To Delete",
            sodiumMg: 100,
            servingSize: nil,
            category: .other,
            barcode: nil,
            context: context
        )!

        // When
        let deleted = repository.deleteTemplate(template, context: context)

        // Then
        XCTAssertTrue(deleted)
        let templates = repository.fetchTemplates(context: context)
        XCTAssertTrue(templates.isEmpty)
    }
}
