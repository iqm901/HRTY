import Foundation
import SwiftData

@Observable
final class TodayViewModel {
    // MARK: - Weight Input
    var weightInput: String = ""
    var validationError: String?
    var showSaveSuccess: Bool = false

    // MARK: - Symptom Input
    var symptomSeverities: [SymptomType: Int] = [:]
    var symptomSaveError: Bool = false

    // MARK: - Weight Alert State
    var activeWeightAlerts: [AlertEvent] = []

    // MARK: - Data State
    var todayEntry: DailyEntry?
    var yesterdayEntry: DailyEntry?

    // MARK: - Validation Constants
    static let minimumWeight: Double = 50.0
    static let maximumWeight: Double = 500.0

    // MARK: - Weight Alert Constants
    static let weightGain24hThreshold: Double = 2.0  // lbs
    static let weightGain7dThreshold: Double = 5.0   // lbs

    // MARK: - Computed Properties
    var parsedWeight: Double? {
        Double(weightInput)
    }

    var isValidWeight: Bool {
        guard let weight = parsedWeight else { return false }
        return weight >= Self.minimumWeight && weight <= Self.maximumWeight
    }

    var previousWeight: Double? {
        yesterdayEntry?.weight
    }

    var weightChange: Double? {
        guard let current = todayEntry?.weight,
              let previous = previousWeight else {
            return nil
        }
        return current - previous
    }

    var weightChangeText: String? {
        guard let change = weightChange else { return nil }
        let absChange = abs(change)
        let formattedChange = String(format: "%.1f", absChange)

        if change > 0.05 {
            return "You're \(formattedChange) lbs heavier than yesterday"
        } else if change < -0.05 {
            return "You're \(formattedChange) lbs lighter than yesterday"
        } else {
            return "Your weight is the same as yesterday"
        }
    }

    var hasNoPreviousData: Bool {
        previousWeight == nil
    }

    var yesterdayDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return formatter.string(from: yesterday)
    }

    /// Returns true when the patient has actively engaged with symptom logging
    /// (any symptom rated above 1, indicating intentional input rather than defaults)
    var hasLoggedSymptoms: Bool {
        symptomSeverities.values.contains { $0 > 1 }
    }

    // MARK: - Methods
    func loadData(context: ModelContext) {
        let today = Date()
        todayEntry = DailyEntry.getOrCreate(for: today, in: context)

        if let existingWeight = todayEntry?.weight {
            weightInput = String(format: "%.1f", existingWeight)
        }

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        yesterdayEntry = DailyEntry.fetchForDate(yesterday, in: context)
    }

    func validateWeight() -> Bool {
        validationError = nil

        guard !weightInput.isEmpty else {
            validationError = "Please enter your weight"
            return false
        }

        guard let weight = parsedWeight else {
            validationError = "Please enter a valid number"
            return false
        }

        guard weight >= Self.minimumWeight else {
            validationError = "Weight must be at least \(Int(Self.minimumWeight)) lbs"
            return false
        }

        guard weight <= Self.maximumWeight else {
            validationError = "Weight must be less than \(Int(Self.maximumWeight)) lbs"
            return false
        }

        return true
    }

    func saveWeight(context: ModelContext) {
        guard validateWeight() else { return }
        guard let weight = parsedWeight else { return }

        if todayEntry == nil {
            todayEntry = DailyEntry.getOrCreate(for: Date(), in: context)
        }

        todayEntry?.weight = weight
        todayEntry?.updatedAt = Date()

        do {
            try context.save()
            showSaveSuccess = true

            // Check for weight alerts after successful save
            checkWeightAlerts(context: context)

            // Auto-dismiss success message after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.showSaveSuccess = false
            }
        } catch {
            validationError = "Could not save weight. Please try again."
        }
    }

    // MARK: - Diuretic State
    var diureticMedications: [Medication] = []
    var todayDiureticDoses: [DiureticDose] = []
    var showDeleteError: Bool = false

    // MARK: - Diuretic Computed Properties

    /// Returns doses for a specific medication logged today
    func doses(for medication: Medication) -> [DiureticDose] {
        todayDiureticDoses.filter { $0.medication?.persistentModelID == medication.persistentModelID }
            .sorted { $0.timestamp < $1.timestamp }
    }

    // MARK: - Diuretic Methods

    func loadDiuretics(context: ModelContext) {
        // Fetch all active diuretic medications
        let predicate = #Predicate<Medication> { medication in
            medication.isDiuretic && medication.isActive
        }
        let descriptor = FetchDescriptor<Medication>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )

        diureticMedications = (try? context.fetch(descriptor)) ?? []

        // Load today's doses from the daily entry
        todayDiureticDoses = todayEntry?.diureticDoses ?? []
    }

    /// Log a standard dose (quick entry with medication's default dosage)
    func logStandardDose(for medication: Medication, context: ModelContext) {
        logDose(
            for: medication,
            amount: medication.dosage,
            isExtra: false,
            timestamp: Date(),
            context: context
        )
    }

    /// Log a custom dose with specific amount, extra flag, and timestamp
    func logCustomDose(
        for medication: Medication,
        amount: Double,
        isExtra: Bool,
        timestamp: Date,
        context: ModelContext
    ) {
        logDose(for: medication, amount: amount, isExtra: isExtra, timestamp: timestamp, context: context)
    }

    private func logDose(
        for medication: Medication,
        amount: Double,
        isExtra: Bool,
        timestamp: Date,
        context: ModelContext
    ) {
        // Ensure we have a daily entry
        if todayEntry == nil {
            todayEntry = DailyEntry.getOrCreate(for: Date(), in: context)
        }

        guard let entry = todayEntry else { return }

        let dose = DiureticDose(
            dosageAmount: amount,
            timestamp: timestamp,
            isExtraDose: isExtra,
            medication: medication,
            dailyEntry: entry
        )

        context.insert(dose)

        // Update local state
        var doses = entry.diureticDoses ?? []
        doses.append(dose)
        entry.diureticDoses = doses
        entry.updatedAt = Date()

        do {
            try context.save()
            todayDiureticDoses = entry.diureticDoses ?? []
        } catch {
            #if DEBUG
            print("Diuretic dose save error: \(error.localizedDescription)")
            #endif
        }
    }

    /// Delete a logged dose
    func deleteDose(_ dose: DiureticDose, context: ModelContext) {
        context.delete(dose)

        do {
            try context.save()
            todayDiureticDoses.removeAll { $0.persistentModelID == dose.persistentModelID }
            showDeleteError = false
        } catch {
            showDeleteError = true
            #if DEBUG
            print("Diuretic dose delete error: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Symptom Methods

    func loadSymptoms(context: ModelContext) {
        // Initialize all symptoms with default severity of 1
        for symptomType in SymptomType.allCases {
            symptomSeverities[symptomType] = 1
        }

        // Load existing symptoms from today's entry
        guard let entry = todayEntry,
              let existingSymptoms = entry.symptoms else {
            return
        }

        for symptom in existingSymptoms {
            symptomSeverities[symptom.symptomType] = symptom.severity
        }
    }

    func severity(for symptomType: SymptomType) -> Int {
        symptomSeverities[symptomType] ?? 1
    }

    func updateSeverity(_ severity: Int, for symptomType: SymptomType, context: ModelContext) {
        let clampedSeverity = min(max(severity, 1), 5)
        symptomSeverities[symptomType] = clampedSeverity

        // Ensure we have a daily entry
        if todayEntry == nil {
            todayEntry = DailyEntry.getOrCreate(for: Date(), in: context)
        }

        guard let entry = todayEntry else { return }

        // Find or create the symptom entry
        var symptoms = entry.symptoms ?? []
        if let existingIndex = symptoms.firstIndex(where: { $0.symptomType == symptomType }) {
            symptoms[existingIndex].severity = clampedSeverity
        } else {
            let newSymptom = SymptomEntry(symptomType: symptomType, severity: clampedSeverity, dailyEntry: entry)
            context.insert(newSymptom)
            symptoms.append(newSymptom)
        }

        entry.symptoms = symptoms
        entry.updatedAt = Date()

        do {
            try context.save()
            symptomSaveError = false
        } catch {
            // Track error state for potential UI indication
            // Auto-save errors are non-blocking but trackable
            symptomSaveError = true
            #if DEBUG
            print("Symptom save error: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Weight Alert Methods

    /// Load unacknowledged weight alerts for display
    func loadWeightAlerts(context: ModelContext) {
        let predicate = #Predicate<AlertEvent> { alert in
            !alert.isAcknowledged
        }
        var descriptor = FetchDescriptor<AlertEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.triggeredAt, order: .reverse)]
        )

        let allUnacknowledged = (try? context.fetch(descriptor)) ?? []
        // Filter for weight-related alerts in memory
        activeWeightAlerts = allUnacknowledged.filter { alert in
            alert.alertType == .weightGain24h || alert.alertType == .weightGain7d
        }
    }

    /// Check weight thresholds after weight is saved and create alerts if needed
    func checkWeightAlerts(context: ModelContext) {
        guard let currentWeight = todayEntry?.weight else { return }

        // Check 24-hour threshold
        check24HourAlert(currentWeight: currentWeight, context: context)

        // Check 7-day threshold
        check7DayAlert(currentWeight: currentWeight, context: context)

        // Reload alerts to show any new ones
        loadWeightAlerts(context: context)
    }

    private func check24HourAlert(currentWeight: Double, context: ModelContext) {
        guard let previousWeight = yesterdayEntry?.weight else { return }

        let weightChange = currentWeight - previousWeight

        if weightChange >= Self.weightGain24hThreshold {
            // Check for existing alert of same type today
            if hasAlertToday(ofType: .weightGain24h, context: context) { return }

            let message = format24HourAlertMessage(weightChange: weightChange)
            createAlert(type: .weightGain24h, message: message, context: context)
        }
    }

    private func check7DayAlert(currentWeight: Double, context: ModelContext) {
        let calendar = Calendar.current
        let today = Date()
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return }

        let entries = DailyEntry.fetchForDateRange(from: sevenDaysAgo, to: today, in: context)

        // Find the earliest entry with weight in the range
        guard let earliestWeight = entries.first(where: { $0.weight != nil })?.weight else { return }

        let weightChange = currentWeight - earliestWeight

        if weightChange >= Self.weightGain7dThreshold {
            // Check for existing alert of same type today
            if hasAlertToday(ofType: .weightGain7d, context: context) { return }

            let message = format7DayAlertMessage(weightChange: weightChange)
            createAlert(type: .weightGain7d, message: message, context: context)
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

    private func createAlert(type: AlertType, message: String, context: ModelContext) {
        let alert = AlertEvent(
            alertType: type,
            message: message,
            triggeredAt: Date(),
            isAcknowledged: false,
            relatedDailyEntry: todayEntry
        )

        context.insert(alert)

        // Link to daily entry
        if var alerts = todayEntry?.alertEvents {
            alerts.append(alert)
            todayEntry?.alertEvents = alerts
        } else {
            todayEntry?.alertEvents = [alert]
        }

        do {
            try context.save()
        } catch {
            #if DEBUG
            print("Alert save error: \(error.localizedDescription)")
            #endif
        }
    }

    private func format24HourAlertMessage(weightChange: Double) -> String {
        let formattedChange = String(format: "%.1f", weightChange)
        return "Your weight has increased by \(formattedChange) lbs since yesterday. This is good information to share with your care team. Consider reaching out to discuss."
    }

    private func format7DayAlertMessage(weightChange: Double) -> String {
        let formattedChange = String(format: "%.1f", weightChange)
        return "Over the past week, your weight has increased by \(formattedChange) lbs. Your clinician may want to know about this trend. It might be a good time to check in with them."
    }

    /// Acknowledge (dismiss) an alert
    func acknowledgeAlert(_ alert: AlertEvent, context: ModelContext) {
        alert.isAcknowledged = true

        do {
            try context.save()
            activeWeightAlerts.removeAll { $0.persistentModelID == alert.persistentModelID }
        } catch {
            #if DEBUG
            print("Alert acknowledge error: \(error.localizedDescription)")
            #endif
        }
    }
}
