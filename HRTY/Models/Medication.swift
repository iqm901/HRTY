import Foundation
import SwiftData

@Model
final class Medication {
    // MARK: - Available Units (Domain Constant)
    static let availableUnits = ["mg", "mcg", "mL", "g", "units"]

    var name: String
    var dosage: Double
    var unit: String
    var schedule: String
    var isDiuretic: Bool
    var isActive: Bool
    var createdAt: Date
    var categoryRawValue: String?

    @Relationship(deleteRule: .nullify, inverse: \DiureticDose.medication)
    var doses: [DiureticDose]?

    /// The medication category derived from the raw value
    var category: HeartFailureMedication.Category? {
        guard let rawValue = categoryRawValue else { return nil }
        return HeartFailureMedication.Category(rawValue: rawValue)
    }

    init(
        name: String,
        dosage: Double,
        unit: String = "mg",
        schedule: String = "",
        isDiuretic: Bool = false,
        isActive: Bool = true,
        createdAt: Date = Date(),
        categoryRawValue: String? = nil
    ) {
        self.name = name
        self.dosage = dosage
        self.unit = unit
        self.schedule = schedule
        self.isDiuretic = isDiuretic
        self.isActive = isActive
        self.createdAt = createdAt
        self.categoryRawValue = categoryRawValue
    }
}
