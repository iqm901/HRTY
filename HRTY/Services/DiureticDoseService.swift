import Foundation
import SwiftData

/// Protocol defining diuretic dose logging operations.
/// Enables dependency injection and testability.
protocol DiureticDoseServiceProtocol {
    func logDose(
        for medication: Medication,
        amount: Double,
        isExtra: Bool,
        timestamp: Date,
        dailyEntry: DailyEntry,
        context: ModelContext
    ) -> DiureticDose?

    func deleteDose(_ dose: DiureticDose, context: ModelContext) -> Bool

    func loadDiuretics(context: ModelContext) -> [Medication]

    func loadTodayDoses(from entry: DailyEntry?) -> [DiureticDose]
}

/// Service responsible for diuretic dose logging operations.
/// Centralizes dose logging logic to avoid duplication across ViewModels.
final class DiureticDoseService: DiureticDoseServiceProtocol {

    /// Log a diuretic dose for a medication
    /// - Parameters:
    ///   - medication: The medication being logged
    ///   - amount: Dose amount in medication's unit
    ///   - isExtra: Whether this is an extra (PRN) dose
    ///   - timestamp: When the dose was taken
    ///   - dailyEntry: The daily entry to associate the dose with
    ///   - context: SwiftData model context
    /// - Returns: The created DiureticDose if successful, nil otherwise
    func logDose(
        for medication: Medication,
        amount: Double,
        isExtra: Bool,
        timestamp: Date,
        dailyEntry: DailyEntry,
        context: ModelContext
    ) -> DiureticDose? {
        let dose = DiureticDose(
            dosageAmount: amount,
            timestamp: timestamp,
            isExtraDose: isExtra,
            medication: medication,
            dailyEntry: dailyEntry
        )

        context.insert(dose)

        // Update the daily entry's doses array
        var doses = dailyEntry.diureticDoses ?? []
        doses.append(dose)
        dailyEntry.diureticDoses = doses
        dailyEntry.updatedAt = Date()

        do {
            try context.save()
            return dose
        } catch {
            #if DEBUG
            print("Diuretic dose save error: \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    /// Delete a logged dose
    /// - Parameters:
    ///   - dose: The dose to delete
    ///   - context: SwiftData model context
    /// - Returns: True if deletion was successful
    func deleteDose(_ dose: DiureticDose, context: ModelContext) -> Bool {
        context.delete(dose)

        do {
            try context.save()
            return true
        } catch {
            #if DEBUG
            print("Diuretic dose delete error: \(error.localizedDescription)")
            #endif
            return false
        }
    }

    /// Load all active diuretic medications
    /// - Parameter context: SwiftData model context
    /// - Returns: Array of active diuretic medications sorted by name
    func loadDiuretics(context: ModelContext) -> [Medication] {
        let predicate = #Predicate<Medication> { medication in
            medication.isDiuretic && medication.isActive
        }
        let descriptor = FetchDescriptor<Medication>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    /// Load today's doses from a daily entry
    /// - Parameter entry: The daily entry to load doses from
    /// - Returns: Array of diuretic doses for today
    func loadTodayDoses(from entry: DailyEntry?) -> [DiureticDose] {
        entry?.diureticDoses ?? []
    }
}
