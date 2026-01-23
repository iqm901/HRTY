import Foundation

// MARK: - Data Types

/// Represents a detected medication conflict.
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
enum ConflictType: Equatable {
    case sameClass(HeartFailureMedication.Category)
    case crossClass(HeartFailureMedication.Category, HeartFailureMedication.Category)
}

// MARK: - Protocol

protocol MedicationConflictServiceProtocol {
    func checkConflicts(
        newCategory: HeartFailureMedication.Category,
        existingMedications: [Medication]
    ) -> [MedicationConflict]

    func findAllConflicts(in medications: [Medication]) -> [MedicationConflict]
}

// MARK: - Implementation

/// Detects medication conflicts based on therapeutic class rules.
final class MedicationConflictService: MedicationConflictServiceProtocol {

    // MARK: - Conflict Rules

    /// Categories that should only have one medication (same-class restriction)
    private static let singleMedicationCategories: Set<HeartFailureMedication.Category> = [
        .loopDiuretic,      // Furosemide, Bumetanide, Torsemide - only one
        .betaBlocker,
        .aceInhibitor,
        .arb,
        .arni,
        .mra,
        .sglt2Inhibitor
    ]

    /// Categories that conflict with each other (cross-class conflicts)
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
                let message = multipleInClassMessage(for: category, medications: medsInCategory)
                conflicts.append(MedicationConflict(
                    type: .sameClass(category),
                    medications: medsInCategory,
                    message: message
                ))
            }
        }

        // Check cross-class conflicts
        for (cat1, cat2) in Self.crossClassConflicts {
            let pairKey = [cat1.rawValue, cat2.rawValue].sorted().joined(separator: "-")
            guard !processedPairs.contains(pairKey) else { continue }
            processedPairs.insert(pairKey)

            let medsInCat1 = activeMedications.filter { $0.category == cat1 }
            let medsInCat2 = activeMedications.filter { $0.category == cat2 }

            if !medsInCat1.isEmpty && !medsInCat2.isEmpty {
                let allConflicting = medsInCat1 + medsInCat2
                let message = existingCrossClassMessage(category1: cat1, category2: cat2)
                conflicts.append(MedicationConflict(
                    type: .crossClass(cat1, cat2),
                    medications: allConflicting,
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
        let existingNames = existingMeds.map { $0.name }.joined(separator: ", ")
        return "You're already taking \(existingNames), which is also a \(category.rawValue.lowercased().dropLast()). It's worth verifying with your care team if you need both."
    }

    private func crossClassMessage(
        newCategory: HeartFailureMedication.Category,
        existingCategory: HeartFailureMedication.Category,
        existingMeds: [Medication]
    ) -> String {
        let existingNames = existingMeds.map { $0.name }.joined(separator: ", ")
        return "You're already taking \(existingNames). \(newCategory.rawValue) and \(existingCategory.rawValue) are usually not taken together. Your care team can help clarify."
    }

    private func multipleInClassMessage(
        for category: HeartFailureMedication.Category,
        medications: [Medication]
    ) -> String {
        let names = medications.map { $0.name }.joined(separator: " and ")
        return "You have \(names) listed, which are both \(category.rawValue.lowercased()). Most patients take only one. Consider verifying with your care team."
    }

    private func existingCrossClassMessage(
        category1: HeartFailureMedication.Category,
        category2: HeartFailureMedication.Category
    ) -> String {
        return "You have both \(category1.rawValue) and \(category2.rawValue) medications listed. These are usually not taken together. Your care team can help clarify."
    }
}
