import Foundation
import SwiftData

/// Source of sodium entry data
enum SodiumEntrySource: String, Codable, CaseIterable {
    case manual = "manual"
    case barcode = "barcode"
    case ocr = "ocr"
    case template = "template"

    var icon: String {
        switch self {
        case .manual: return "pencil"
        case .barcode: return "barcode.viewfinder"
        case .ocr: return "camera"
        case .template: return "star"
        }
    }

    var displayName: String {
        switch self {
        case .manual: return "Manual Entry"
        case .barcode: return "Barcode Scan"
        case .ocr: return "Label Scan"
        case .template: return "Quick Add"
        }
    }
}

@Model
final class SodiumEntry {
    var id: UUID
    var name: String
    var sodiumMg: Int
    var servingSize: String?
    var timestamp: Date
    var sourceRawValue: String
    var barcode: String?
    var templateId: UUID?
    var bundledFoodId: String?

    var source: SodiumEntrySource {
        get { SodiumEntrySource(rawValue: sourceRawValue) ?? .manual }
        set { sourceRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        sodiumMg: Int,
        servingSize: String? = nil,
        timestamp: Date = Date(),
        source: SodiumEntrySource = .manual,
        barcode: String? = nil,
        templateId: UUID? = nil,
        bundledFoodId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.sodiumMg = sodiumMg
        self.servingSize = servingSize
        self.timestamp = timestamp
        self.sourceRawValue = source.rawValue
        self.barcode = barcode
        self.templateId = templateId
        self.bundledFoodId = bundledFoodId
    }
}

// MARK: - Fetch Methods

extension SodiumEntry {

    /// Fetch all entries for a specific date
    static func fetchForDate(_ date: Date, in context: ModelContext) -> [SodiumEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let predicate = #Predicate<SodiumEntry> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }
        let descriptor = FetchDescriptor<SodiumEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    /// Fetch entries within a date range
    static func fetchForDateRange(from startDate: Date, to endDate: Date, in context: ModelContext) -> [SodiumEntry] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        guard let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) else {
            return []
        }

        let predicate = #Predicate<SodiumEntry> { entry in
            entry.timestamp >= start && entry.timestamp < end
        }
        let descriptor = FetchDescriptor<SodiumEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    /// Calculate total sodium for a specific date
    static func totalSodiumForDate(_ date: Date, in context: ModelContext) -> Int {
        let entries = fetchForDate(date, in: context)
        return entries.reduce(0) { $0 + $1.sodiumMg }
    }

    /// Calculate daily totals for a date range (for charts)
    static func dailyTotals(from startDate: Date, to endDate: Date, in context: ModelContext) -> [(date: Date, totalMg: Int)] {
        let entries = fetchForDateRange(from: startDate, to: endDate, in: context)
        let calendar = Calendar.current

        var dailyTotals: [Date: Int] = [:]

        for entry in entries {
            let day = calendar.startOfDay(for: entry.timestamp)
            dailyTotals[day, default: 0] += entry.sodiumMg
        }

        return dailyTotals
            .map { (date: $0.key, totalMg: $0.value) }
            .sorted { $0.date < $1.date }
    }

    /// Fetch recent bundled food IDs (for "Recent Foods" feature)
    static func fetchRecentBundledFoodIds(limit: Int = 10, in context: ModelContext) -> [String] {
        let descriptor = FetchDescriptor<SodiumEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        guard let entries = try? context.fetch(descriptor) else {
            return []
        }

        // Get unique bundled food IDs, maintaining order by most recent
        var seenIds = Set<String>()
        var recentIds: [String] = []

        for entry in entries {
            guard let foodId = entry.bundledFoodId, !seenIds.contains(foodId) else {
                continue
            }
            seenIds.insert(foodId)
            recentIds.append(foodId)
            if recentIds.count >= limit {
                break
            }
        }

        return recentIds
    }
}
