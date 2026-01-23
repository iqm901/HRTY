import Foundation
import SwiftData

/// Protocol defining heart rate alert service operations
/// Enables dependency injection and testability for alert checking logic
protocol HeartRateAlertServiceProtocol: AlertAcknowledgeable {
    func checkHeartRateAlerts(
        readings: [HeartRateReading],
        isAbnormal: Bool,
        isLow: Bool,
        todayEntry: DailyEntry?,
        context: ModelContext
    )
    func loadUnacknowledgedHeartRateAlerts(context: ModelContext) -> [AlertEvent]
}

/// Service responsible for checking heart rate thresholds and managing heart rate alerts
/// Follows the same patterns as WeightAlertService and SymptomAlertService
final class HeartRateAlertService: HeartRateAlertServiceProtocol {

    // MARK: - Alert Checking

    /// Check heart rate readings and create alerts if persistent abnormal values are detected
    /// - Parameters:
    ///   - readings: The abnormal heart rate readings
    ///   - isAbnormal: Whether the heart rate is persistently abnormal
    ///   - isLow: True if heart rate is low, false if high
    ///   - todayEntry: Today's daily entry to link alerts to
    ///   - context: SwiftData model context for persistence
    func checkHeartRateAlerts(
        readings: [HeartRateReading],
        isAbnormal: Bool,
        isLow: Bool,
        todayEntry: DailyEntry?,
        context: ModelContext
    ) {
        guard isAbnormal, !readings.isEmpty else { return }

        let alertType: AlertType = isLow ? .heartRateLow : .heartRateHigh

        // Check for existing alert of same type today
        if hasAlertToday(ofType: alertType, context: context) { return }

        let message = formatAlertMessage(readings: readings, isLow: isLow)
        createAlert(
            type: alertType,
            message: message,
            todayEntry: todayEntry,
            context: context
        )
    }

    // MARK: - Alert Loading

    /// Load unacknowledged heart rate alerts for display
    /// - Parameter context: SwiftData model context
    /// - Returns: Array of unacknowledged heart rate AlertEvents
    func loadUnacknowledgedHeartRateAlerts(context: ModelContext) -> [AlertEvent] {
        let predicate = #Predicate<AlertEvent> { alert in
            !alert.isAcknowledged
        }
        let descriptor = FetchDescriptor<AlertEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.triggeredAt, order: .reverse)]
        )

        let allUnacknowledged = (try? context.fetch(descriptor)) ?? []
        // Filter for heart rate alerts in memory
        return allUnacknowledged.filter { alert in
            alert.alertType == .heartRateLow || alert.alertType == .heartRateHigh
        }
    }

    // Note: acknowledgeAlert is provided by AlertAcknowledgeable protocol extension

    // MARK: - Private Methods

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

        do {
            try context.save()
        } catch {
            #if DEBUG
            print("Heart rate alert save error: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Message Formatting

    private func formatAlertMessage(readings: [HeartRateReading], isLow: Bool) -> String {
        guard let latestReading = readings.last else {
            return isLow
                ? "Your resting heart rate has been lower than usual. Consider reaching out to your care team."
                : "Your resting heart rate has been higher than usual. Consider reaching out to your care team."
        }

        let heartRate = latestReading.heartRate

        if isLow {
            return "Your resting heart rate has been around \(heartRate) bpm recently, which is lower than usual. This is good information to share with your care team."
        } else {
            return "Your resting heart rate has been around \(heartRate) bpm recently, which is higher than usual. Your care team can help you understand what this means for you."
        }
    }
}
