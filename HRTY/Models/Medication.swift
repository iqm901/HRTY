import Foundation
import SwiftData

@Model
final class Medication {
    var name: String
    var dosage: Double
    var unit: String
    var schedule: String
    var isDiuretic: Bool
    var isActive: Bool
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \DiureticDose.medication)
    var doses: [DiureticDose]?

    init(
        name: String,
        dosage: Double,
        unit: String = "mg",
        schedule: String = "",
        isDiuretic: Bool = false,
        isActive: Bool = true,
        createdAt: Date = Date()
    ) {
        self.name = name
        self.dosage = dosage
        self.unit = unit
        self.schedule = schedule
        self.isDiuretic = isDiuretic
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
