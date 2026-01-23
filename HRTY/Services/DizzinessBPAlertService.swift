import Foundation
import SwiftData

/// Protocol defining dizziness BP check alert service operations.
/// Enables dependency injection and testability for dizziness-related BP check prompts.
protocol DizzinessBPAlertServiceProtocol: AlertAcknowledgeable {
    func checkDizzinessBPAlert(
        dizzinessSeverity: Int,
        hasBPReading: Bool,
        todayEntry: DailyEntry?,
        context: ModelContext
    )
    func loadUnacknowledgedDizzinessBPAlerts(context: ModelContext) -> [AlertEvent]
}

/// Service responsible for prompting users to check blood pressure when dizziness is reported
/// and no recent BP data is available from HealthKit.
final class DizzinessBPAlertService: DizzinessBPAlertServiceProtocol {

    // MARK: - Alert Checking

    /// Check if dizziness severity triggers a BP check prompt
    /// - Parameters:
    ///   - dizzinessSeverity: Current dizziness severity (1-5)
    ///   - hasBPReading: Whether recent BP data exists in HealthKit
    ///   - todayEntry: Today's daily entry to link alerts to
    ///   - context: SwiftData model context for persistence
    func checkDizzinessBPAlert(
        dizzinessSeverity: Int,
        hasBPReading: Bool,
        todayEntry: DailyEntry?,
        context: ModelContext
    ) {
        // Only trigger if dizziness is at or above threshold
        guard dizzinessSeverity >= AlertConstants.dizzinessBPPromptThreshold else { return }

        // Don't show prompt if BP data is available
        guard !hasBPReading else { return }

        // Check if we already have a dizziness BP alert today
        if hasAlertToday(context: context) {
            return
        }

        let message = formatDizzinessBPMessage()
        createAlert(
            message: message,
            todayEntry: todayEntry,
            context: context
        )
    }

    // MARK: - Alert Loading

    /// Load unacknowledged dizziness BP check alerts for display
    /// - Parameter context: SwiftData model context
    /// - Returns: Array of unacknowledged dizziness BP AlertEvents
    func loadUnacknowledgedDizzinessBPAlerts(context: ModelContext) -> [AlertEvent] {
        let predicate = #Predicate<AlertEvent> { alert in
            !alert.isAcknowledged
        }
        let descriptor = FetchDescriptor<AlertEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.triggeredAt, order: .reverse)]
        )

        let allUnacknowledged = (try? context.fetch(descriptor)) ?? []
        return allUnacknowledged.filter { alert in
            alert.alertType == .dizzinessBPCheck
        }
    }

    // MARK: - Private Methods

    private func hasAlertToday(context: ModelContext) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today

        let predicate = #Predicate<AlertEvent> { alert in
            alert.triggeredAt >= today &&
            alert.triggeredAt < tomorrow
        }
        let descriptor = FetchDescriptor<AlertEvent>(predicate: predicate)

        let todayAlerts = (try? context.fetch(descriptor)) ?? []
        return todayAlerts.contains { $0.alertType == .dizzinessBPCheck }
    }

    private func createAlert(
        message: String,
        todayEntry: DailyEntry?,
        context: ModelContext
    ) {
        let alert = AlertEvent(
            alertType: .dizzinessBPCheck,
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
            print("Dizziness BP alert save error: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Message Formatting

    private func formatDizzinessBPMessage() -> String {
        "You mentioned feeling dizzy today. If you have a blood pressure cuff, it might be helpful to take a reading. Remember to stand up slowly. If you're concerned or symptoms persist, consider reaching out to your care team."
    }
}
