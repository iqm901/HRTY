import Foundation
import SwiftData

/// Protocol defining diuretic dose management operations.
/// Enables dependency injection and testability.
protocol DiureticDoseManagerProtocol: AnyObject {
    var diureticMedications: [Medication] { get }
    var todayDiureticDoses: [DiureticDose] { get }
    var showDeleteError: Bool { get set }

    func loadDiuretics(context: ModelContext, dailyEntry: DailyEntry?)
    func doses(for medication: Medication) -> [DiureticDose]
    func logStandardDose(for medication: Medication, context: ModelContext, dailyEntry: inout DailyEntry?) -> Bool
    func logCustomDose(for medication: Medication, amount: Double, isExtra: Bool, timestamp: Date, context: ModelContext, dailyEntry: inout DailyEntry?) -> Bool
    func deleteDose(_ dose: DiureticDose, context: ModelContext) -> Bool
}

/// Manager responsible for diuretic dose state and operations.
/// Consolidates diuretic logic that was duplicated across view models.
@Observable
final class DiureticDoseManager: DiureticDoseManagerProtocol {

    // MARK: - State

    private(set) var diureticMedications: [Medication] = []
    private(set) var todayDiureticDoses: [DiureticDose] = []
    var showDeleteError: Bool = false

    // MARK: - Dependencies

    private let diureticDoseService: DiureticDoseServiceProtocol

    // MARK: - Initialization

    init(diureticDoseService: DiureticDoseServiceProtocol = DiureticDoseService()) {
        self.diureticDoseService = diureticDoseService
    }

    // MARK: - Loading Methods

    /// Load diuretic medications and today's doses
    /// - Parameters:
    ///   - context: SwiftData model context
    ///   - dailyEntry: Today's daily entry to load doses from
    func loadDiuretics(context: ModelContext, dailyEntry: DailyEntry?) {
        diureticMedications = diureticDoseService.loadDiuretics(context: context)
        todayDiureticDoses = diureticDoseService.loadTodayDoses(from: dailyEntry)
    }

    /// Returns doses for a specific medication logged today
    /// - Parameter medication: The medication to filter doses for
    /// - Returns: Array of doses for that medication, sorted by timestamp
    func doses(for medication: Medication) -> [DiureticDose] {
        todayDiureticDoses
            .filter { $0.medication?.persistentModelID == medication.persistentModelID }
            .sorted { $0.timestamp < $1.timestamp }
    }

    // MARK: - Dose Logging Methods

    /// Log a standard dose (quick entry with medication's default dosage)
    /// - Parameters:
    ///   - medication: The medication to log a dose for
    ///   - context: SwiftData model context
    ///   - dailyEntry: Reference to today's entry (will be created if nil)
    /// - Returns: True if the dose was logged successfully
    @discardableResult
    func logStandardDose(for medication: Medication, context: ModelContext, dailyEntry: inout DailyEntry?) -> Bool {
        guard let dosageAmount = Double(medication.dosage) else { return false }

        return logDose(
            for: medication,
            amount: dosageAmount,
            isExtra: false,
            timestamp: Date(),
            context: context,
            dailyEntry: &dailyEntry
        )
    }

    /// Log a custom dose with specific amount, extra flag, and timestamp
    /// - Parameters:
    ///   - medication: The medication to log a dose for
    ///   - amount: The dose amount
    ///   - isExtra: Whether this is an extra (PRN) dose
    ///   - timestamp: When the dose was taken
    ///   - context: SwiftData model context
    ///   - dailyEntry: Reference to today's entry (will be created if nil)
    /// - Returns: True if the dose was logged successfully
    @discardableResult
    func logCustomDose(
        for medication: Medication,
        amount: Double,
        isExtra: Bool,
        timestamp: Date,
        context: ModelContext,
        dailyEntry: inout DailyEntry?
    ) -> Bool {
        return logDose(
            for: medication,
            amount: amount,
            isExtra: isExtra,
            timestamp: timestamp,
            context: context,
            dailyEntry: &dailyEntry
        )
    }

    /// Delete a logged dose
    /// - Parameters:
    ///   - dose: The dose to delete
    ///   - context: SwiftData model context
    /// - Returns: True if deletion was successful
    @discardableResult
    func deleteDose(_ dose: DiureticDose, context: ModelContext) -> Bool {
        if diureticDoseService.deleteDose(dose, context: context) {
            todayDiureticDoses.removeAll { $0.persistentModelID == dose.persistentModelID }
            showDeleteError = false
            return true
        } else {
            showDeleteError = true
            return false
        }
    }

    // MARK: - Private Methods

    private func logDose(
        for medication: Medication,
        amount: Double,
        isExtra: Bool,
        timestamp: Date,
        context: ModelContext,
        dailyEntry: inout DailyEntry?
    ) -> Bool {
        // Ensure we have a daily entry
        if dailyEntry == nil {
            dailyEntry = DailyEntry.getOrCreate(for: Date(), in: context)
        }

        guard let entry = dailyEntry else { return false }

        if let dose = diureticDoseService.logDose(
            for: medication,
            amount: amount,
            isExtra: isExtra,
            timestamp: timestamp,
            dailyEntry: entry,
            context: context
        ) {
            // Update local state for immediate UI feedback
            if !todayDiureticDoses.contains(where: { $0.persistentModelID == dose.persistentModelID }) {
                todayDiureticDoses.append(dose)
            }
            return true
        }
        return false
    }
}
