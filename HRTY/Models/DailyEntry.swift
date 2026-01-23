import Foundation
import SwiftData

@Model
final class DailyEntry {
    @Attribute(.unique) var date: Date
    var weight: Double?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \SymptomEntry.dailyEntry)
    var symptoms: [SymptomEntry]?

    @Relationship(deleteRule: .cascade, inverse: \DiureticDose.dailyEntry)
    var diureticDoses: [DiureticDose]?

    @Relationship(inverse: \AlertEvent.relatedDailyEntry)
    var alertEvents: [AlertEvent]?

    @Relationship(deleteRule: .cascade, inverse: \VitalSignsEntry.dailyEntry)
    var vitalSigns: VitalSignsEntry?

    init(
        date: Date = Date(),
        weight: Double? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.date = Calendar.current.startOfDay(for: date)
        self.weight = weight
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension DailyEntry {
    static func fetchForDate(_ date: Date, in context: ModelContext) -> DailyEntry? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = #Predicate<DailyEntry> { entry in
            entry.date == startOfDay
        }
        var descriptor = FetchDescriptor<DailyEntry>(predicate: predicate)
        descriptor.fetchLimit = 1

        return try? context.fetch(descriptor).first
    }

    static func getOrCreate(for date: Date, in context: ModelContext) -> DailyEntry {
        if let existing = fetchForDate(date, in: context) {
            return existing
        }

        let newEntry = DailyEntry(date: date)
        context.insert(newEntry)
        return newEntry
    }

    static func fetchForDateRange(from startDate: Date, to endDate: Date, in context: ModelContext) -> [DailyEntry] {
        let start = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.startOfDay(for: endDate)

        let predicate = #Predicate<DailyEntry> { entry in
            entry.date >= start && entry.date <= end
        }
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }
}
