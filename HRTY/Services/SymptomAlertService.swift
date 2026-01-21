import Foundation
import SwiftData

/// Protocol defining symptom alert service operations.
/// Enables dependency injection and testability for symptom alert checking logic.
/// Inherits AlertAcknowledgeable to share the acknowledge implementation with WeightAlertService.
protocol SymptomAlertServiceProtocol: AlertAcknowledgeable {
    func checkSymptomAlerts(
        symptomSeverities: [SymptomType: Int],
        todayEntry: DailyEntry?,
        context: ModelContext
    )
    func loadUnacknowledgedSymptomAlerts(context: ModelContext) -> [AlertEvent]
}

/// Service responsible for checking symptom severities and managing symptom-related alerts.
/// Follows the same pattern as WeightAlertService for consistency.
final class SymptomAlertService: SymptomAlertServiceProtocol {

    // MARK: - Alert Checking

    /// Check symptom severities and create alerts if any are at or above threshold
    /// - Parameters:
    ///   - symptomSeverities: Dictionary mapping symptom types to their severity levels
    ///   - todayEntry: Today's daily entry to link alerts to
    ///   - context: SwiftData model context for persistence
    func checkSymptomAlerts(
        symptomSeverities: [SymptomType: Int],
        todayEntry: DailyEntry?,
        context: ModelContext
    ) {
        // Find symptoms at or above the severe threshold (4 or 5)
        let severeSymptoms = symptomSeverities.filter { _, severity in
            severity >= AlertConstants.severeSymptomThreshold
        }

        guard !severeSymptoms.isEmpty else { return }

        // Check if we already have a symptom alert today for the same symptoms
        if hasMatchingAlertToday(for: severeSymptoms, context: context) {
            return
        }

        let message = formatSymptomAlertMessage(severeSymptoms: severeSymptoms)
        createAlert(
            type: .severeSymptom,
            message: message,
            todayEntry: todayEntry,
            context: context
        )
    }

    // MARK: - Alert Loading

    /// Load unacknowledged symptom alerts for display
    /// - Parameter context: SwiftData model context
    /// - Returns: Array of unacknowledged symptom-related AlertEvents
    func loadUnacknowledgedSymptomAlerts(context: ModelContext) -> [AlertEvent] {
        let predicate = #Predicate<AlertEvent> { alert in
            !alert.isAcknowledged
        }
        let descriptor = FetchDescriptor<AlertEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.triggeredAt, order: .reverse)]
        )

        let allUnacknowledged = (try? context.fetch(descriptor)) ?? []
        // Filter for symptom-related alerts in memory
        return allUnacknowledged.filter { alert in
            alert.alertType == .severeSymptom
        }
    }

    // Note: acknowledgeAlert is provided by AlertAcknowledgeable protocol extension

    // MARK: - Private Methods

    private func hasMatchingAlertToday(for severeSymptoms: [SymptomType: Int], context: ModelContext) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today

        // Use date-based predicate only (enum comparison not supported in #Predicate)
        let predicate = #Predicate<AlertEvent> { alert in
            alert.triggeredAt >= today &&
            alert.triggeredAt < tomorrow
        }
        let descriptor = FetchDescriptor<AlertEvent>(predicate: predicate)

        let todayAlerts = (try? context.fetch(descriptor)) ?? []

        // Filter for symptom alerts in memory
        let todaySymptomAlerts = todayAlerts.filter { $0.alertType == .severeSymptom }

        // Check if any existing alert already covers these symptoms
        // We consider it a match if the alert message contains all the current severe symptoms
        for existingAlert in todaySymptomAlerts {
            let allSymptomsInMessage = severeSymptoms.keys.allSatisfy { symptomType in
                existingAlert.message.contains(symptomType.displayName)
            }
            if allSymptomsInMessage {
                return true
            }
        }

        return false
    }

    private func createAlert(
        type: AlertType,
        message: String,
        todayEntry: DailyEntry?,
        context: ModelContext
    ) {
        let alert = AlertEvent(
            alertType: type,
            message: message,
            triggeredAt: Date(),
            isAcknowledged: false,
            relatedDailyEntry: todayEntry
        )

        context.insert(alert)

        do {
            try context.save()
        } catch {
            #if DEBUG
            print("Alert save error: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Message Formatting

    private func formatSymptomAlertMessage(severeSymptoms: [SymptomType: Int]) -> String {
        let symptomNames = severeSymptoms.keys
            .sorted { $0.displayName < $1.displayName }
            .map { $0.displayName.lowercased() }

        let symptomList: String
        if symptomNames.count == 1 {
            symptomList = symptomNames[0]
        } else if symptomNames.count == 2 {
            symptomList = "\(symptomNames[0]) and \(symptomNames[1])"
        } else {
            let allButLast = symptomNames.dropLast().joined(separator: ", ")
            symptomList = "\(allButLast), and \(symptomNames.last!)"
        }

        // Use correct subject-verb agreement: "is" for singular, "are" for plural
        let verb = symptomNames.count == 1 ? "is" : "are"

        return "You've noted that \(symptomList) \(verb) bothering you more than usual today. This is helpful information to share with your care team when you get a chance."
    }
}
