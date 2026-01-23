import Foundation

// MARK: - Data Types
// Note: These types are used by MedicationsViewModel and Views for conflict display.
// They are co-located with the service for cohesion, as the service owns conflict detection logic.

/// Represents a detected medication conflict.
/// Used to communicate conflict information between the service, view model, and views.
struct MedicationConflict: Identifiable, Equatable {
    let id = UUID()
    let type: ConflictType
    let medications: [Medication]
    let message: String

    static func == (lhs: MedicationConflict, rhs: MedicationConflict) -> Bool {
        lhs.id == rhs.id
    }
}

/// The type of medication conflict detected.
/// - sameClass: Multiple medications from the same therapeutic class (e.g., two beta-blockers)
/// - crossClass: Medications from mutually exclusive classes (e.g., ACE inhibitor with ARB)
enum ConflictType: Equatable {
    case sameClass(HeartFailureMedication.Category)
    case crossClass(HeartFailureMedication.Category, HeartFailureMedication.Category)
}

// MARK: - Protocol

protocol MedicationConflictServiceProtocol {
    /// Check if adding a medication with the given category would conflict with existing medications
    func checkConflicts(
        newCategory: HeartFailureMedication.Category,
        existingMedications: [Medication]
    ) -> [MedicationConflict]

    /// Find all conflicts among the given medications
    func findAllConflicts(in medications: [Medication]) -> [MedicationConflict]
}

// MARK: - Implementation

/// Stateless service that detects medication conflicts based on therapeutic class rules.
/// This service is pure computation with no side effects, making it thread-safe and testable.
final class MedicationConflictService: MedicationConflictServiceProtocol {

    // MARK: - Conflict Rules (Static)
    // These rules are defined as static constants since they represent domain knowledge
    // that doesn't change at runtime. This makes the service instance effectively stateless.

    /// Categories that should only have one medication (same-class restriction)
    private static let singleMedicationCategories: Set<HeartFailureMedication.Category> = [
        .betaBlocker,
        .aceInhibitor,
        .arb,
        .arni,
        .mra,
        .sglt2Inhibitor
    ]

    /// Categories that conflict with each other (cross-class conflicts)
    /// ACEi, ARB, and ARNI are mutually exclusive per clinical guidelines
    private static let crossClassConflicts: [(HeartFailureMedication.Category, HeartFailureMedication.Category)] = [
        (.aceInhibitor, .arb),
        (.aceInhibitor, .arni),
        (.arb, .arni)
    ]

    // MARK: - Public Methods

    func checkConflicts(
        newCategory: HeartFailureMedication.Category,
        existingMedications: [Medication]
    ) -> [MedicationConflict] {
        let activeMedications = existingMedications.filter { $0.isActive }
        var conflicts: [MedicationConflict] = []

        // Check same-class conflicts
        if Self.singleMedicationCategories.contains(newCategory) {
            let sameClassMeds = activeMedications.filter { $0.category == newCategory }
            if !sameClassMeds.isEmpty {
                let message = sameClassMessage(for: newCategory, existingMeds: sameClassMeds)
                conflicts.append(MedicationConflict(
                    type: .sameClass(newCategory),
                    medications: sameClassMeds,
                    message: message
                ))
            }
        }

        // Check cross-class conflicts
        for (cat1, cat2) in Self.crossClassConflicts {
            if newCategory == cat1 {
                let conflictingMeds = activeMedications.filter { $0.category == cat2 }
                if !conflictingMeds.isEmpty {
                    let message = crossClassMessage(
                        newCategory: newCategory,
                        existingCategory: cat2,
                        existingMeds: conflictingMeds
                    )
                    conflicts.append(MedicationConflict(
                        type: .crossClass(cat1, cat2),
                        medications: conflictingMeds,
                        message: message
                    ))
                }
            } else if newCategory == cat2 {
                let conflictingMeds = activeMedications.filter { $0.category == cat1 }
                if !conflictingMeds.isEmpty {
                    let message = crossClassMessage(
                        newCategory: newCategory,
                        existingCategory: cat1,
                        existingMeds: conflictingMeds
                    )
                    conflicts.append(MedicationConflict(
                        type: .crossClass(cat1, cat2),
                        medications: conflictingMeds,
                        message: message
                    ))
                }
            }
        }

        return conflicts
    }

    func findAllConflicts(in medications: [Medication]) -> [MedicationConflict] {
        let activeMedications = medications.filter { $0.isActive }
        var conflicts: [MedicationConflict] = []
        var processedPairs: Set<String> = []

        // Check same-class conflicts
        for category in Self.singleMedicationCategories {
            let medsInCategory = activeMedications.filter { $0.category == category }
            if medsInCategory.count > 1 {
                let message = multipleSameClassMessage(for: category, meds: medsInCategory)
                conflicts.append(MedicationConflict(
                    type: .sameClass(category),
                    medications: medsInCategory,
                    message: message
                ))
            }
        }

        // Check cross-class conflicts
        for (cat1, cat2) in Self.crossClassConflicts {
            let medsInCat1 = activeMedications.filter { $0.category == cat1 }
            let medsInCat2 = activeMedications.filter { $0.category == cat2 }

            if !medsInCat1.isEmpty && !medsInCat2.isEmpty {
                // Create a unique key for this pair to avoid duplicates
                let pairKey = [cat1.rawValue, cat2.rawValue].sorted().joined(separator: "-")
                guard !processedPairs.contains(pairKey) else { continue }
                processedPairs.insert(pairKey)

                let allMeds = medsInCat1 + medsInCat2
                let message = existingCrossClassMessage(cat1: cat1, cat2: cat2, meds: allMeds)
                conflicts.append(MedicationConflict(
                    type: .crossClass(cat1, cat2),
                    medications: allMeds,
                    message: message
                ))
            }
        }

        return conflicts
    }

    // MARK: - Message Generation

    private func sameClassMessage(
        for category: HeartFailureMedication.Category,
        existingMeds: [Medication]
    ) -> String {
        let medNames = existingMeds.map { $0.name }.joined(separator: ", ")
        let categoryName = friendlyCategoryName(category)
        return "You already have \(medNames) listed, which is also a \(categoryName.lowercased()). Most people take only one \(categoryName.lowercased()) at a time. You may want to verify this with your care team."
    }

    private func multipleSameClassMessage(
        for category: HeartFailureMedication.Category,
        meds: [Medication]
    ) -> String {
        let medNames = meds.map { $0.name }.joined(separator: ", ")
        let categoryName = friendlyCategoryName(category)
        return "You have multiple \(categoryName.lowercased())s listed: \(medNames). Most people take only one at a time. You may want to verify this with your care team."
    }

    private func crossClassMessage(
        newCategory: HeartFailureMedication.Category,
        existingCategory: HeartFailureMedication.Category,
        existingMeds: [Medication]
    ) -> String {
        let medNames = existingMeds.map { $0.name }.joined(separator: ", ")
        let newCategoryName = friendlyCategoryName(newCategory)
        let existingCategoryName = friendlyCategoryName(existingCategory)
        let article = articleFor(existingCategoryName)
        return "You already have \(medNames) listed, which is \(article) \(existingCategoryName). \(newCategoryName)s and \(existingCategoryName)s are typically not taken together. You may want to verify this with your care team."
    }

    private func articleFor(_ word: String) -> String {
        // Use "an" before vowel sounds. Note: acronyms like "ACE", "ARB", "ARNI", "MRA"
        // start with vowel sounds (ay-ce, ar, ar-nee, em-ar-ay), while "SGLT2" starts
        // with "ess" (consonant sound)
        let vowelSoundPrefixes = ["ACE", "ARB", "ARNI", "MRA"]
        let uppercased = word.uppercased()
        for prefix in vowelSoundPrefixes {
            if uppercased.hasPrefix(prefix) {
                return "an"
            }
        }
        // Standard vowel check for other words
        let firstChar = word.lowercased().first ?? "x"
        return "aeiou".contains(firstChar) ? "an" : "a"
    }

    private func existingCrossClassMessage(
        cat1: HeartFailureMedication.Category,
        cat2: HeartFailureMedication.Category,
        meds: [Medication]
    ) -> String {
        let medNames = meds.map { $0.name }.joined(separator: ", ")
        let cat1Name = friendlyCategoryName(cat1)
        let cat2Name = friendlyCategoryName(cat2)
        return "You have both \(cat1Name.lowercased())s and \(cat2Name.lowercased())s listed: \(medNames). These are typically not taken together. You may want to verify this with your care team."
    }

    private func friendlyCategoryName(_ category: HeartFailureMedication.Category) -> String {
        switch category {
        case .betaBlocker:
            return "Beta Blocker"
        case .aceInhibitor:
            return "ACE Inhibitor"
        case .arb:
            return "ARB"
        case .arni:
            return "ARNI"
        case .mra:
            return "MRA"
        case .sglt2Inhibitor:
            return "SGLT2 Inhibitor"
        case .loopDiuretic:
            return "Loop Diuretic"
        case .thiazideDiuretic:
            return "Thiazide Diuretic"
        case .other:
            return "Other"
        }
    }
}
