import Foundation
import SwiftData

// MARK: - Shared Alert Service Protocol

/// Base protocol for alert acknowledgment functionality.
/// Provides default implementation for acknowledging alerts to avoid code duplication.
protocol AlertAcknowledgeable {
    @discardableResult
    func acknowledgeAlert(_ alert: AlertEvent, context: ModelContext) -> Bool
}

/// Default implementation of alert acknowledgment.
/// Both WeightAlertService and SymptomAlertService share this behavior.
extension AlertAcknowledgeable {
    @discardableResult
    func acknowledgeAlert(_ alert: AlertEvent, context: ModelContext) -> Bool {
        alert.isAcknowledged = true

        do {
            try context.save()
            return true
        } catch {
            #if DEBUG
            print("Alert acknowledge error: \(error.localizedDescription)")
            #endif
            return false
        }
    }
}

// MARK: - Weight Alert Service Protocol

/// Protocol defining weight alert service operations.
/// Enables dependency injection and testability for alert checking logic.
protocol WeightAlertServiceProtocol: AlertAcknowledgeable {
    func checkWeightAlerts(
        currentWeight: Double,
        todayEntry: DailyEntry?,
        yesterdayEntry: DailyEntry?,
        context: ModelContext
    )
    func loadUnacknowledgedAlerts(context: ModelContext) -> [AlertEvent]
}

/// Service responsible for checking weight thresholds and managing weight-related alerts.
/// Extracted from TodayViewModel to follow Single Responsibility Principle.
final class WeightAlertService: WeightAlertServiceProtocol {

    // MARK: - Alert Checking

    /// Check weight thresholds and create alerts if needed
    /// - Parameters:
    ///   - currentWeight: The patient's current weight
    ///   - todayEntry: Today's daily entry to link alerts to
    ///   - yesterdayEntry: Yesterday's entry for 24-hour comparison
    ///   - context: SwiftData model context for persistence
    func checkWeightAlerts(
        currentWeight: Double,
        todayEntry: DailyEntry?,
        yesterdayEntry: DailyEntry?,
        context: ModelContext
    ) {
        check24HourAlert(
            currentWeight: currentWeight,
            yesterdayEntry: yesterdayEntry,
            todayEntry: todayEntry,
            context: context
        )

        check7DayAlert(
            currentWeight: currentWeight,
            todayEntry: todayEntry,
            context: context
        )
    }

    // MARK: - Alert Loading

    /// Load unacknowledged weight alerts for display
    /// - Parameter context: SwiftData model context
    /// - Returns: Array of unacknowledged weight-related AlertEvents
    func loadUnacknowledgedAlerts(context: ModelContext) -> [AlertEvent] {
        let predicate = #Predicate<AlertEvent> { alert in
            !alert.isAcknowledged
        }
        let descriptor = FetchDescriptor<AlertEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.triggeredAt, order: .reverse)]
        )

        let allUnacknowledged = (try? context.fetch(descriptor)) ?? []
        // Filter for weight-related alerts in memory
        return allUnacknowledged.filter { alert in
            alert.alertType == .weightGain24h || alert.alertType == .weightGain7d
        }
    }

    // Note: acknowledgeAlert is provided by AlertAcknowledgeable protocol extension

    // MARK: - Private Methods

    private func check24HourAlert(
        currentWeight: Double,
        yesterdayEntry: DailyEntry?,
        todayEntry: DailyEntry?,
        context: ModelContext
    ) {
        guard let previousWeight = yesterdayEntry?.weight else { return }

        let weightChange = currentWeight - previousWeight

        if weightChange >= AlertConstants.weightGain24hThreshold {
            // Check for existing alert of same type today
            if hasAlertToday(ofType: .weightGain24h, context: context) { return }

            let message = format24HourAlertMessage(weightChange: weightChange)
            createAlert(
                type: .weightGain24h,
                message: message,
                todayEntry: todayEntry,
                context: context
            )
        }
    }

    private func check7DayAlert(
        currentWeight: Double,
        todayEntry: DailyEntry?,
        context: ModelContext
    ) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return }
        // Exclude today to ensure we compare against a historical baseline
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return }

        let entries = DailyEntry.fetchForDateRange(from: sevenDaysAgo, to: yesterday, in: context)

        // Find the earliest entry with weight in the historical range (excluding today)
        guard let baselineEntry = entries.first(where: { $0.weight != nil }),
              let baselineWeight = baselineEntry.weight else { return }

        let weightChange = currentWeight - baselineWeight

        if weightChange >= AlertConstants.weightGain7dThreshold {
            // Check for existing alert of same type today
            if hasAlertToday(ofType: .weightGain7d, context: context) { return }

            let message = format7DayAlertMessage(weightChange: weightChange)
            createAlert(
                type: .weightGain7d,
                message: message,
                todayEntry: todayEntry,
                context: context
            )
        }
    }

    private func hasAlertToday(ofType alertType: AlertType, context: ModelContext) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today

        // Use date-based predicate only (enum comparison not supported in #Predicate)
        let predicate = #Predicate<AlertEvent> { alert in
            alert.triggeredAt >= today &&
            alert.triggeredAt < tomorrow
        }
        let descriptor = FetchDescriptor<AlertEvent>(predicate: predicate)

        let todayAlerts = (try? context.fetch(descriptor)) ?? []
        // Filter by alert type in memory
        return todayAlerts.contains { $0.alertType == alertType }
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

        // Note: SwiftData automatically manages the inverse relationship
        // via @Relationship(inverse:) on DailyEntry.alertEvents

        do {
            try context.save()
        } catch {
            #if DEBUG
            print("Alert save error: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Message Formatting

    private func format24HourAlertMessage(weightChange: Double) -> String {
        let formattedChange = String(format: "%.1f", weightChange)
        return "Your weight has increased by \(formattedChange) lbs since yesterday. This is good information to share with your care team. Consider reaching out to discuss."
    }

    private func format7DayAlertMessage(weightChange: Double) -> String {
        let formattedChange = String(format: "%.1f", weightChange)
        return "Over the past week, your weight has increased by \(formattedChange) lbs. Your clinician may want to know about this trend. It might be a good time to check in with them."
    }
}
