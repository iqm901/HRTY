import Foundation
import SwiftData

/// Category for organizing sodium templates
enum TemplateCategory: String, Codable, CaseIterable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"
    case beverage = "beverage"
    case condiment = "condiment"
    case other = "other"

    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        case .beverage: return "Beverage"
        case .condiment: return "Condiment"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sun.horizon"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .snack: return "leaf"
        case .beverage: return "cup.and.saucer"
        case .condiment: return "drop"
        case .other: return "ellipsis.circle"
        }
    }
}

@Model
final class SodiumTemplate {
    var id: UUID
    var name: String
    var sodiumMg: Int
    var servingSize: String?
    var categoryRawValue: String
    var usageCount: Int
    var lastUsedAt: Date?
    var barcode: String?
    var createdAt: Date
    var isArchived: Bool

    var category: TemplateCategory {
        get { TemplateCategory(rawValue: categoryRawValue) ?? .other }
        set { categoryRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        sodiumMg: Int,
        servingSize: String? = nil,
        category: TemplateCategory = .other,
        usageCount: Int = 0,
        lastUsedAt: Date? = nil,
        barcode: String? = nil,
        createdAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.sodiumMg = sodiumMg
        self.servingSize = servingSize
        self.categoryRawValue = category.rawValue
        self.usageCount = usageCount
        self.lastUsedAt = lastUsedAt
        self.barcode = barcode
        self.createdAt = createdAt
        self.isArchived = isArchived
    }

    /// Increment usage count and update last used timestamp
    func recordUsage() {
        usageCount += 1
        lastUsedAt = Date()
    }
}

// MARK: - Fetch Methods

extension SodiumTemplate {

    /// Fetch all active templates
    static func fetchAll(in context: ModelContext) -> [SodiumTemplate] {
        let predicate = #Predicate<SodiumTemplate> { template in
            template.isArchived == false
        }
        let descriptor = FetchDescriptor<SodiumTemplate>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    /// Fetch frequently used templates (sorted by usage count, limited)
    static func fetchFrequentlyUsed(limit: Int = 8, in context: ModelContext) -> [SodiumTemplate] {
        let predicate = #Predicate<SodiumTemplate> { template in
            template.isArchived == false && template.usageCount > 0
        }
        var descriptor = FetchDescriptor<SodiumTemplate>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.usageCount, order: .reverse)]
        )
        descriptor.fetchLimit = limit

        return (try? context.fetch(descriptor)) ?? []
    }

    /// Fetch recently used templates
    static func fetchRecentlyUsed(limit: Int = 8, in context: ModelContext) -> [SodiumTemplate] {
        let predicate = #Predicate<SodiumTemplate> { template in
            template.isArchived == false && template.lastUsedAt != nil
        }
        var descriptor = FetchDescriptor<SodiumTemplate>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.lastUsedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit

        return (try? context.fetch(descriptor)) ?? []
    }

    /// Fetch templates by category
    static func fetchByCategory(_ category: TemplateCategory, in context: ModelContext) -> [SodiumTemplate] {
        let categoryValue = category.rawValue
        let predicate = #Predicate<SodiumTemplate> { template in
            template.isArchived == false && template.categoryRawValue == categoryValue
        }
        let descriptor = FetchDescriptor<SodiumTemplate>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    /// Find template by barcode
    static func findByBarcode(_ barcode: String, in context: ModelContext) -> SodiumTemplate? {
        let predicate = #Predicate<SodiumTemplate> { template in
            template.barcode == barcode && template.isArchived == false
        }
        var descriptor = FetchDescriptor<SodiumTemplate>(predicate: predicate)
        descriptor.fetchLimit = 1

        return try? context.fetch(descriptor).first
    }
}
