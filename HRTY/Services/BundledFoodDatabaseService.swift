import Foundation

/// Service for loading and searching the bundled food database
final class BundledFoodDatabaseService {

    static let shared = BundledFoodDatabaseService()

    private var foods: [BundledFoodItem] = []
    private var isLoaded = false

    private init() {
        loadDatabase()
    }

    // MARK: - Loading

    private func loadDatabase() {
        guard !isLoaded else { return }

        guard let url = Bundle.main.url(forResource: "BundledFoods", withExtension: "json") else {
            print("BundledFoodDatabaseService: Could not find BundledFoods.json in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let database = try decoder.decode(BundledFoodDatabase.self, from: data)
            foods = database.foods
            isLoaded = true
            print("BundledFoodDatabaseService: Loaded \(foods.count) foods")
        } catch {
            print("BundledFoodDatabaseService: Failed to load database - \(error)")
        }
    }

    // MARK: - Search

    /// Search foods by name (case-insensitive, supports partial matching)
    func searchFoods(query: String) -> [BundledFoodItem] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces).lowercased()

        guard !trimmedQuery.isEmpty else {
            return []
        }

        // Split query into words for better matching
        let queryWords = trimmedQuery.split(separator: " ").map { String($0) }

        return foods.filter { food in
            let searchText = "\(food.displayName) \(food.category.displayName)".lowercased()

            // Check if all query words are found in the search text
            return queryWords.allSatisfy { word in
                searchText.contains(word)
            }
        }
        .sorted { food1, food2 in
            // Prioritize exact matches and matches at the start of the name
            let name1 = food1.name.lowercased()
            let name2 = food2.name.lowercased()

            let startsWithQuery1 = name1.hasPrefix(trimmedQuery)
            let startsWithQuery2 = name2.hasPrefix(trimmedQuery)

            if startsWithQuery1 != startsWithQuery2 {
                return startsWithQuery1
            }

            // Then sort alphabetically
            return food1.displayName < food2.displayName
        }
    }

    /// Get foods by category
    func foodsByCategory(_ category: BundledFoodCategory) -> [BundledFoodItem] {
        foods.filter { $0.category == category }
            .sorted { $0.displayName < $1.displayName }
    }

    /// Get all categories that have foods
    func availableCategories() -> [BundledFoodCategory] {
        let usedCategories = Set(foods.map { $0.category })
        return BundledFoodCategory.allCases.filter { usedCategories.contains($0) }
    }

    /// Get all foods (for browsing)
    func allFoods() -> [BundledFoodItem] {
        foods.sorted { $0.displayName < $1.displayName }
    }

    /// Get featured/popular foods (high-sodium items users should be aware of)
    func featuredFoods(limit: Int = 10) -> [BundledFoodItem] {
        foods.sorted { $0.sodiumMg > $1.sodiumMg }
            .prefix(limit)
            .map { $0 }
    }

    /// Get foods by brand
    func foodsByBrand(_ brand: String) -> [BundledFoodItem] {
        let brandLower = brand.lowercased()
        return foods.filter { $0.brand?.lowercased() == brandLower }
            .sorted { $0.displayName < $1.displayName }
    }

    /// Get unique brands
    func availableBrands() -> [String] {
        Array(Set(foods.compactMap { $0.brand })).sorted()
    }

    // MARK: - Convenience

    /// Get total count of foods in database
    var totalFoodCount: Int {
        foods.count
    }
}
