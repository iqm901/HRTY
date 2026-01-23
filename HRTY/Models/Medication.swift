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
    var archivedAt: Date?

    @Relationship(deleteRule: .nullify, inverse: \DiureticDose.medication)
    var doses: [DiureticDose]?

    @Relationship(deleteRule: .cascade)
    var periods: [MedicationPeriod]?

    /// The therapeutic category of this medication, if known
    var category: HeartFailureMedication.Category? {
        guard let rawValue = categoryRawValue else { return nil }
        return HeartFailureMedication.Category(rawValue: rawValue)
    }

    /// Whether this medication can be archived (has been tracked for more than 1 day)
    var canBeArchived: Bool {
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return createdAt < oneDayAgo
    }

    /// The current active period, if any
    var currentPeriod: MedicationPeriod? {
        periods?.first { $0.endDate == nil }
    }

    /// All periods sorted by start date (most recent first)
    var sortedPeriods: [MedicationPeriod] {
        (periods ?? []).sorted { $0.startDate > $1.startDate }
    }

    /// Formatted archived date for display
    var archivedAtDisplay: String? {
        guard let archivedAt = archivedAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: archivedAt)
    }

    init(
        name: String,
        dosage: Double,
        unit: String = "mg",
        schedule: String = "",
        isDiuretic: Bool = false,
        isActive: Bool = true,
        createdAt: Date = Date(),
        categoryRawValue: String? = nil,
        archivedAt: Date? = nil
    ) {
        self.name = name
        self.dosage = dosage
        self.unit = unit
        self.schedule = schedule
        self.isDiuretic = isDiuretic
        self.isActive = isActive
        self.createdAt = createdAt
        self.categoryRawValue = categoryRawValue
        self.archivedAt = archivedAt
    }

    // MARK: - Archive & Reactivate Methods

    /// Archives this medication by ending the current period and marking it inactive
    func archive() {
        // End the current period
        if let currentPeriod = currentPeriod {
            currentPeriod.endDate = Date()
        }

        isActive = false
        archivedAt = Date()
    }

    /// Reactivates this medication with a new dosage period
    func reactivate(dosage newDosage: Double, unit newUnit: String, schedule newSchedule: String) {
        // Create a new period
        let newPeriod = MedicationPeriod(
            dosage: newDosage,
            unit: newUnit,
            schedule: newSchedule,
            startDate: Date()
        )

        if periods == nil {
            periods = []
        }
        periods?.append(newPeriod)

        // Update current medication properties
        self.dosage = newDosage
        self.unit = newUnit
        self.schedule = newSchedule
        self.isActive = true
        self.archivedAt = nil
    }

    /// Updates the dosage, creating a new period if the dosage has changed
    func updateDosage(newDosage: Double, newUnit: String, newSchedule: String) {
        let dosageChanged = dosage != newDosage || unit != newUnit

        if dosageChanged {
            // End the current period
            if let currentPeriod = currentPeriod {
                currentPeriod.endDate = Date()
            }

            // Create a new period with the new dosage
            let newPeriod = MedicationPeriod(
                dosage: newDosage,
                unit: newUnit,
                schedule: newSchedule,
                startDate: Date()
            )

            if periods == nil {
                periods = []
            }
            periods?.append(newPeriod)
        } else if let currentPeriod = currentPeriod {
            // Only schedule changed, update the current period
            currentPeriod.schedule = newSchedule
        }

        // Update medication properties
        self.dosage = newDosage
        self.unit = newUnit
        self.schedule = newSchedule
    }

    /// Creates an initial period for migration from medications without period tracking
    func createInitialPeriodIfNeeded() {
        guard periods == nil || periods?.isEmpty == true else { return }

        let initialPeriod = MedicationPeriod(
            dosage: dosage,
            unit: unit,
            schedule: schedule,
            startDate: createdAt,
            endDate: isActive ? nil : createdAt
        )

        if periods == nil {
            periods = []
        }
        periods?.append(initialPeriod)
    }
}
