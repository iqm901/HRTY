import Foundation

/// Predefined heart failure medications with common dosages and frequencies
/// Based on 2022 AHA/ACC/HFSA Guidelines and 2024 ACC Expert Consensus
struct HeartFailureMedication: Identifiable, Hashable {
    let id = UUID()
    let genericName: String
    let brandName: String?
    let category: Category
    let availableDosages: [String]
    let defaultFrequency: String
    let isDiuretic: Bool
    let unit: String

    var displayName: String {
        if let brand = brandName {
            return "\(genericName) (\(brand))"
        }
        return genericName
    }

    enum Category: String, CaseIterable {
        case loopDiuretic = "Loop Diuretics"
        case thiazideDiuretic = "Thiazide-like Diuretics"
        case betaBlocker = "Beta Blockers"
        case aceInhibitor = "ACE Inhibitors"
        case arb = "ARBs"
        case arni = "ARNI"
        case mra = "MRAs"
        case sglt2Inhibitor = "SGLT2 Inhibitors"
        case other = "Other"
    }
}

// MARK: - Predefined Heart Failure Medications

extension HeartFailureMedication {

    /// All predefined heart failure medications organized by category
    static let allMedications: [HeartFailureMedication] = [
        // MARK: - Loop Diuretics
        HeartFailureMedication(
            genericName: "Furosemide",
            brandName: "Lasix",
            category: .loopDiuretic,
            availableDosages: ["20", "40", "80", "120", "160"],
            defaultFrequency: "Twice daily",
            isDiuretic: true,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Torsemide",
            brandName: "Demadex",
            category: .loopDiuretic,
            availableDosages: ["10", "20", "40", "60", "100"],
            defaultFrequency: "Once daily",
            isDiuretic: true,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Bumetanide",
            brandName: "Bumex",
            category: .loopDiuretic,
            availableDosages: ["0.5", "1", "2", "4"],
            defaultFrequency: "Twice daily",
            isDiuretic: true,
            unit: "mg"
        ),

        // MARK: - Thiazide-like Diuretics
        HeartFailureMedication(
            genericName: "Metolazone",
            brandName: "Zaroxolyn",
            category: .thiazideDiuretic,
            availableDosages: ["2.5", "5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: true,
            unit: "mg"
        ),

        // MARK: - Beta Blockers
        HeartFailureMedication(
            genericName: "Carvedilol",
            brandName: "Coreg",
            category: .betaBlocker,
            availableDosages: ["3.125", "6.25", "12.5", "25"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Metoprolol Succinate",
            brandName: "Toprol-XL",
            category: .betaBlocker,
            availableDosages: ["12.5", "25", "50", "100", "200"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Bisoprolol",
            brandName: "Zebeta",
            category: .betaBlocker,
            availableDosages: ["1.25", "2.5", "5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - ACE Inhibitors
        HeartFailureMedication(
            genericName: "Lisinopril",
            brandName: "Zestril",
            category: .aceInhibitor,
            availableDosages: ["2.5", "5", "10", "20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Enalapril",
            brandName: "Vasotec",
            category: .aceInhibitor,
            availableDosages: ["2.5", "5", "10", "20"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Ramipril",
            brandName: "Altace",
            category: .aceInhibitor,
            availableDosages: ["1.25", "2.5", "5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Captopril",
            brandName: "Capoten",
            category: .aceInhibitor,
            availableDosages: ["6.25", "12.5", "25", "50"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - ARBs
        HeartFailureMedication(
            genericName: "Losartan",
            brandName: "Cozaar",
            category: .arb,
            availableDosages: ["25", "50", "100", "150"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Valsartan",
            brandName: "Diovan",
            category: .arb,
            availableDosages: ["40", "80", "160", "320"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Candesartan",
            brandName: "Atacand",
            category: .arb,
            availableDosages: ["4", "8", "16", "32"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - ARNI
        HeartFailureMedication(
            genericName: "Sacubitril/Valsartan",
            brandName: "Entresto",
            category: .arni,
            availableDosages: ["24/26", "49/51", "97/103"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - MRAs
        HeartFailureMedication(
            genericName: "Spironolactone",
            brandName: "Aldactone",
            category: .mra,
            availableDosages: ["12.5", "25", "50"],
            defaultFrequency: "Once daily",
            isDiuretic: true,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Eplerenone",
            brandName: "Inspra",
            category: .mra,
            availableDosages: ["25", "50"],
            defaultFrequency: "Once daily",
            isDiuretic: true,
            unit: "mg"
        ),

        // MARK: - SGLT2 Inhibitors
        HeartFailureMedication(
            genericName: "Dapagliflozin",
            brandName: "Farxiga",
            category: .sglt2Inhibitor,
            availableDosages: ["5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Empagliflozin",
            brandName: "Jardiance",
            category: .sglt2Inhibitor,
            availableDosages: ["10", "25"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Sotagliflozin",
            brandName: "Inpefa",
            category: .sglt2Inhibitor,
            availableDosages: ["200", "400"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Other
        HeartFailureMedication(
            genericName: "Digoxin",
            brandName: "Lanoxin",
            category: .other,
            availableDosages: ["0.0625", "0.125", "0.25"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Hydralazine",
            brandName: nil,
            category: .other,
            availableDosages: ["10", "25", "37.5", "50", "75", "100"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Isosorbide Dinitrate",
            brandName: "Isordil",
            category: .other,
            availableDosages: ["10", "20", "40"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Hydralazine/Isosorbide Dinitrate",
            brandName: "BiDil",
            category: .other,
            availableDosages: ["37.5/20"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        HeartFailureMedication(
            genericName: "Ivabradine",
            brandName: "Corlanor",
            category: .other,
            availableDosages: ["2.5", "5", "7.5"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
    ]

    /// Medications grouped by category for display
    static var medicationsByCategory: [(category: Category, medications: [HeartFailureMedication])] {
        Category.allCases.compactMap { category in
            let meds = allMedications.filter { $0.category == category }
            return meds.isEmpty ? nil : (category, meds)
        }
    }

    /// Common frequency options
    static let frequencyOptions = [
        "Once daily",
        "Twice daily",
        "Three times daily",
        "Four times daily",
        "Every other day",
        "As needed"
    ]

    /// All known diuretic medications (generic and brand names)
    static let knownDiureticNames: Set<String> = {
        var names = Set<String>()
        for med in allMedications where med.isDiuretic {
            names.insert(med.genericName.lowercased())
            if let brand = med.brandName {
                names.insert(brand.lowercased())
            }
        }
        return names
    }()

    /// Checks if a medication name matches a known diuretic
    /// - Parameter name: The medication name to check (case-insensitive)
    /// - Returns: true if the medication is a known diuretic
    static func isDiuretic(medicationName name: String) -> Bool {
        let normalizedName = name.lowercased().trimmingCharacters(in: .whitespaces)

        // Check for exact match
        if knownDiureticNames.contains(normalizedName) {
            return true
        }

        // Check if name contains any known diuretic name (for partial matches like "Furosemide 40mg")
        for diureticName in knownDiureticNames {
            if normalizedName.contains(diureticName) {
                return true
            }
        }

        return false
    }
}
