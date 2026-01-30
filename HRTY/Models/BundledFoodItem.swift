import Foundation

/// Category for organizing bundled food items in the database
enum BundledFoodCategory: String, Codable, CaseIterable {
    case cannedSoups = "canned_soups"
    case frozenMeals = "frozen_meals"
    case chips = "chips"
    case bread = "bread"
    case deliMeats = "deli_meats"
    case cheese = "cheese"
    case condiments = "condiments"
    case cannedVegetables = "canned_vegetables"
    case breakfast = "breakfast"
    case snacks = "snacks"
    case fastFood = "fast_food"
    case pizza = "pizza"
    case chinese = "chinese"
    case mexican = "mexican"
    case beverages = "beverages"
    case sauces = "sauces"
    case pickled = "pickled"
    case instantNoodles = "instant_noodles"
    case other = "other"

    var displayName: String {
        switch self {
        case .cannedSoups: return "Canned Soups"
        case .frozenMeals: return "Frozen Meals"
        case .chips: return "Chips & Crackers"
        case .bread: return "Bread & Bakery"
        case .deliMeats: return "Deli Meats"
        case .cheese: return "Cheese"
        case .condiments: return "Condiments"
        case .cannedVegetables: return "Canned Vegetables"
        case .breakfast: return "Breakfast"
        case .snacks: return "Snacks"
        case .fastFood: return "Fast Food"
        case .pizza: return "Pizza"
        case .chinese: return "Chinese"
        case .mexican: return "Mexican"
        case .beverages: return "Beverages"
        case .sauces: return "Sauces & Marinades"
        case .pickled: return "Pickled Foods"
        case .instantNoodles: return "Instant Noodles"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .cannedSoups: return "flame"
        case .frozenMeals: return "snowflake"
        case .chips: return "leaf"
        case .bread: return "rectangle.split.3x1"
        case .deliMeats: return "fork.knife"
        case .cheese: return "square.stack.3d.up"
        case .condiments: return "drop"
        case .cannedVegetables: return "carrot"
        case .breakfast: return "sun.horizon"
        case .snacks: return "popcorn"
        case .fastFood: return "bag"
        case .pizza: return "circle.grid.2x2"
        case .chinese: return "takeoutbag.and.cup.and.straw"
        case .mexican: return "flame"
        case .beverages: return "cup.and.saucer"
        case .sauces: return "drop.circle"
        case .pickled: return "seal"
        case .instantNoodles: return "flame.circle"
        case .other: return "ellipsis.circle"
        }
    }
}

/// A pre-populated food item from the bundled database
struct BundledFoodItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let sodiumMg: Int
    let servingSize: String
    let category: BundledFoodCategory
    let brand: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case sodiumMg = "sodium_mg"
        case servingSize = "serving_size"
        case category
        case brand
    }

    /// Display name with brand if available
    var displayName: String {
        if let brand = brand {
            return "\(brand) \(name)"
        }
        return name
    }
}

/// Container for the JSON structure
struct BundledFoodDatabase: Codable {
    let foods: [BundledFoodItem]
}
