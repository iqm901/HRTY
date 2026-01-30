import Foundation
import SwiftData

/// Model for storing user's favorite bundled foods
@Model
final class FoodFavorite {
    var id: UUID
    var bundledFoodId: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        bundledFoodId: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.bundledFoodId = bundledFoodId
        self.createdAt = createdAt
    }
}

// MARK: - Static Methods

extension FoodFavorite {

    /// Check if a bundled food is favorited
    static func isFavorite(bundledFoodId: String, in context: ModelContext) -> Bool {
        let predicate = #Predicate<FoodFavorite> { favorite in
            favorite.bundledFoodId == bundledFoodId
        }
        let descriptor = FetchDescriptor<FoodFavorite>(predicate: predicate)

        guard let results = try? context.fetch(descriptor) else {
            return false
        }
        return !results.isEmpty
    }

    /// Get all favorite bundled food IDs
    static func allFavoriteIds(in context: ModelContext) -> [String] {
        let descriptor = FetchDescriptor<FoodFavorite>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        guard let favorites = try? context.fetch(descriptor) else {
            return []
        }

        return favorites.map { $0.bundledFoodId }
    }

    /// Toggle favorite status for a bundled food
    /// Returns true if the food is now favorited, false if unfavorited
    @discardableResult
    static func toggle(bundledFoodId: String, in context: ModelContext) -> Bool {
        let predicate = #Predicate<FoodFavorite> { favorite in
            favorite.bundledFoodId == bundledFoodId
        }
        let descriptor = FetchDescriptor<FoodFavorite>(predicate: predicate)

        guard let existing = try? context.fetch(descriptor) else {
            // Error fetching, try to add as new favorite
            let favorite = FoodFavorite(bundledFoodId: bundledFoodId)
            context.insert(favorite)
            try? context.save()
            return true
        }

        if let favoriteToRemove = existing.first {
            // Already favorited, remove it
            context.delete(favoriteToRemove)
            try? context.save()
            return false
        } else {
            // Not favorited, add it
            let favorite = FoodFavorite(bundledFoodId: bundledFoodId)
            context.insert(favorite)
            try? context.save()
            return true
        }
    }
}
