import Foundation
import SwiftData

/// Protocol defining sodium repository operations for testability
protocol SodiumRepositoryProtocol {
    func addEntry(
        name: String,
        sodiumMg: Int,
        servingSize: String?,
        source: SodiumEntrySource,
        barcode: String?,
        templateId: UUID?,
        context: ModelContext
    ) -> SodiumEntry?

    func deleteEntry(_ entry: SodiumEntry, context: ModelContext) -> Bool
    func fetchTodayEntries(context: ModelContext) -> [SodiumEntry]
    func getTodayTotal(context: ModelContext) -> Int
    func fetchEntriesForDate(_ date: Date, context: ModelContext) -> [SodiumEntry]

    func saveAsTemplate(
        name: String,
        sodiumMg: Int,
        servingSize: String?,
        category: TemplateCategory,
        barcode: String?,
        context: ModelContext
    ) -> SodiumTemplate?

    func fetchTemplates(context: ModelContext) -> [SodiumTemplate]
    func fetchFrequentTemplates(limit: Int, context: ModelContext) -> [SodiumTemplate]
    func deleteTemplate(_ template: SodiumTemplate, context: ModelContext) -> Bool
    func archiveTemplate(_ template: SodiumTemplate, context: ModelContext) -> Bool

    func addEntryFromTemplate(_ template: SodiumTemplate, context: ModelContext) -> SodiumEntry?
}

/// Repository for managing sodium entries and templates
final class SodiumRepository: SodiumRepositoryProtocol {

    // MARK: - Entry Operations

    @discardableResult
    func addEntry(
        name: String,
        sodiumMg: Int,
        servingSize: String?,
        source: SodiumEntrySource,
        barcode: String?,
        templateId: UUID?,
        context: ModelContext
    ) -> SodiumEntry? {
        let entry = SodiumEntry(
            name: name,
            sodiumMg: sodiumMg,
            servingSize: servingSize,
            source: source,
            barcode: barcode,
            templateId: templateId
        )

        context.insert(entry)

        do {
            try context.save()
            return entry
        } catch {
            #if DEBUG
            print("SodiumRepository: Failed to save entry - \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    @discardableResult
    func deleteEntry(_ entry: SodiumEntry, context: ModelContext) -> Bool {
        context.delete(entry)

        do {
            try context.save()
            return true
        } catch {
            #if DEBUG
            print("SodiumRepository: Failed to delete entry - \(error.localizedDescription)")
            #endif
            return false
        }
    }

    func fetchTodayEntries(context: ModelContext) -> [SodiumEntry] {
        return SodiumEntry.fetchForDate(Date(), in: context)
    }

    func getTodayTotal(context: ModelContext) -> Int {
        return SodiumEntry.totalSodiumForDate(Date(), in: context)
    }

    func fetchEntriesForDate(_ date: Date, context: ModelContext) -> [SodiumEntry] {
        return SodiumEntry.fetchForDate(date, in: context)
    }

    // MARK: - Template Operations

    @discardableResult
    func saveAsTemplate(
        name: String,
        sodiumMg: Int,
        servingSize: String?,
        category: TemplateCategory,
        barcode: String?,
        context: ModelContext
    ) -> SodiumTemplate? {
        let template = SodiumTemplate(
            name: name,
            sodiumMg: sodiumMg,
            servingSize: servingSize,
            category: category,
            barcode: barcode
        )

        context.insert(template)

        do {
            try context.save()
            return template
        } catch {
            #if DEBUG
            print("SodiumRepository: Failed to save template - \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    func fetchTemplates(context: ModelContext) -> [SodiumTemplate] {
        return SodiumTemplate.fetchAll(in: context)
    }

    func fetchFrequentTemplates(limit: Int, context: ModelContext) -> [SodiumTemplate] {
        return SodiumTemplate.fetchFrequentlyUsed(limit: limit, in: context)
    }

    @discardableResult
    func deleteTemplate(_ template: SodiumTemplate, context: ModelContext) -> Bool {
        context.delete(template)

        do {
            try context.save()
            return true
        } catch {
            #if DEBUG
            print("SodiumRepository: Failed to delete template - \(error.localizedDescription)")
            #endif
            return false
        }
    }

    @discardableResult
    func archiveTemplate(_ template: SodiumTemplate, context: ModelContext) -> Bool {
        template.isArchived = true

        do {
            try context.save()
            return true
        } catch {
            template.isArchived = false
            #if DEBUG
            print("SodiumRepository: Failed to archive template - \(error.localizedDescription)")
            #endif
            return false
        }
    }

    // MARK: - Template Usage

    @discardableResult
    func addEntryFromTemplate(_ template: SodiumTemplate, context: ModelContext) -> SodiumEntry? {
        // Record template usage
        template.recordUsage()

        // Create entry from template
        let entry = SodiumEntry(
            name: template.name,
            sodiumMg: template.sodiumMg,
            servingSize: template.servingSize,
            source: .template,
            barcode: template.barcode,
            templateId: template.id
        )

        context.insert(entry)

        do {
            try context.save()
            return entry
        } catch {
            #if DEBUG
            print("SodiumRepository: Failed to add entry from template - \(error.localizedDescription)")
            #endif
            return nil
        }
    }
}
