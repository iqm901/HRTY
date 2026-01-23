import Foundation
import SwiftData

/// Protocol defining vital signs alert service operations.
/// Handles alerts for blood pressure and oxygen saturation.
protocol VitalSignsAlertServiceProtocol: AlertAcknowledgeable {
    func checkVitalSignsAlerts(
        systolicBP: Int?,
        diastolicBP: Int?,
        oxygenSaturation: Int?,
        todayEntry: DailyEntry?,
        context: ModelContext
    )
    func loadUnacknowledgedVitalSignsAlerts(context: ModelContext) -> [AlertEvent]
}

/// Service responsible for checking vital signs thresholds and managing related alerts.
/// Handles low oxygen saturation, low blood pressure, and low MAP alerts.
final class VitalSignsAlertService: VitalSignsAlertServiceProtocol {

    // MARK: - Alert Checking

    /// Check vital signs thresholds and create alerts if needed
    /// - Parameters:
    ///   - systolicBP: Systolic blood pressure in mmHg
    ///   - diastolicBP: Diastolic blood pressure in mmHg
    ///   - oxygenSaturation: Oxygen saturation percentage
    ///   - todayEntry: Today's daily entry to link alerts to
    ///   - context: SwiftData model context for persistence
    func checkVitalSignsAlerts(
        systolicBP: Int?,
        diastolicBP: Int?,
        oxygenSaturation: Int?,
        todayEntry: DailyEntry?,
        context: ModelContext
    ) {
        // Check oxygen saturation
        if let spo2 = oxygenSaturation {
            checkOxygenSaturationAlert(
                oxygenSaturation: spo2,
                todayEntry: todayEntry,
                context: context
            )
        }

        // Check blood pressure (need both systolic and diastolic)
        if let systolic = systolicBP, let diastolic = diastolicBP {
            checkBloodPressureAlerts(
                systolicBP: systolic,
                diastolicBP: diastolic,
                todayEntry: todayEntry,
                context: context
            )
        }
    }

    // MARK: - Alert Loading

    /// Load unacknowledged vital signs alerts for display
    /// - Parameter context: SwiftData model context
    /// - Returns: Array of unacknowledged vital signs AlertEvents
    func loadUnacknowledgedVitalSignsAlerts(context: ModelContext) -> [AlertEvent] {
        let predicate = #Predicate<AlertEvent> { alert in
            !alert.isAcknowledged
        }
        let descriptor = FetchDescriptor<AlertEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.triggeredAt, order: .reverse)]
        )

        let allUnacknowledged = (try? context.fetch(descriptor)) ?? []
        // Filter for vital signs alerts in memory
        return allUnacknowledged.filter { alert in
            alert.alertType == .lowOxygenSaturation ||
            alert.alertType == .lowBloodPressure ||
            alert.alertType == .lowMAP
        }
    }

    // MARK: - Private Methods

    private func checkOxygenSaturationAlert(
        oxygenSaturation: Int,
        todayEntry: DailyEntry?,
        context: ModelContext
    ) {
        if oxygenSaturation < AlertConstants.oxygenSaturationLowThreshold {
            // Check for existing alert of same type today
            if hasAlertToday(ofType: .lowOxygenSaturation, context: context) { return }

            let message = formatOxygenSaturationAlertMessage(oxygenSaturation: oxygenSaturation)
            createAlert(
                type: .lowOxygenSaturation,
                message: message,
                todayEntry: todayEntry,
                context: context
            )
        }
    }

    private func checkBloodPressureAlerts(
        systolicBP: Int,
        diastolicBP: Int,
        todayEntry: DailyEntry?,
        context: ModelContext
    ) {
        // Defensive check: systolic must be greater than diastolic for valid BP
        guard systolicBP > diastolicBP else { return }

        // Check for low systolic BP
        if systolicBP < AlertConstants.systolicBPLowThreshold {
            if !hasAlertToday(ofType: .lowBloodPressure, context: context) {
                let message = formatLowBPAlertMessage(systolic: systolicBP, diastolic: diastolicBP)
                createAlert(
                    type: .lowBloodPressure,
                    message: message,
                    todayEntry: todayEntry,
                    context: context
                )
            }
        }

        // Check for low MAP (Mean Arterial Pressure)
        // MAP = DBP + (SBP - DBP) / 3
        let map = diastolicBP + (systolicBP - diastolicBP) / 3
        if map < AlertConstants.mapLowThreshold {
            if !hasAlertToday(ofType: .lowMAP, context: context) {
                let message = formatLowMAPAlertMessage(map: map, systolic: systolicBP, diastolic: diastolicBP)
                createAlert(
                    type: .lowMAP,
                    message: message,
                    todayEntry: todayEntry,
                    context: context
                )
            }
        }
    }

    private func hasAlertToday(ofType alertType: AlertType, context: ModelContext) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today

        let predicate = #Predicate<AlertEvent> { alert in
            alert.triggeredAt >= today &&
            alert.triggeredAt < tomorrow
        }
        let descriptor = FetchDescriptor<AlertEvent>(predicate: predicate)

        let todayAlerts = (try? context.fetch(descriptor)) ?? []
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
            print("Vital signs alert save error: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Message Formatting

    private func formatOxygenSaturationAlertMessage(oxygenSaturation: Int) -> String {
        "Your oxygen level is \(oxygenSaturation)%, which is lower than usual. Please contact your care team to discuss this reading."
    }

    private func formatLowBPAlertMessage(systolic: Int, diastolic: Int) -> String {
        "Your blood pressure reading of \(systolic)/\(diastolic) mmHg is lower than usual. Please contact your care team if you're feeling unwell."
    }

    private func formatLowMAPAlertMessage(map: Int, systolic: Int, diastolic: Int) -> String {
        "Your blood pressure reading of \(systolic)/\(diastolic) mmHg indicates your blood pressure may be low. Please contact your care team if you have any symptoms."
    }
}
