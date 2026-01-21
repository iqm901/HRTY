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
    var showAlertDismissedEncouragement: Bool = false

    // MARK: - Symptom Alert State
    var activeSymptomAlerts: [AlertEvent] = []

    // MARK: - Data State
    var todayEntry: DailyEntry?
    var yesterdayEntry: DailyEntry?

    // MARK: - HealthKit State
    var healthKitWeight: HealthKitWeight?
    var isLoadingHealthKit: Bool = false
    var healthKitError: String?
    var showHealthKitTimestamp: Bool = false

    // MARK: - Services
    private let weightAlertService: WeightAlertServiceProtocol
    private let symptomAlertService: SymptomAlertServiceProtocol
    private let healthKitService: HealthKitServiceProtocol

    // MARK: - Initialization
    init(
        weightAlertService: WeightAlertServiceProtocol = WeightAlertService(),
        symptomAlertService: SymptomAlertServiceProtocol = SymptomAlertService(),
        healthKitService: HealthKitServiceProtocol = HealthKitService()
    ) {
        self.weightAlertService = weightAlertService
        self.symptomAlertService = symptomAlertService
        self.healthKitService = healthKitService
    }

    // MARK: - Validation Constants (reference AlertConstants for thresholds)

    // MARK: - HealthKit Computed Properties

    /// Whether HealthKit is available on this device
    var isHealthKitAvailable: Bool {
        healthKitService.isHealthKitAvailable
    }

    /// Whether HealthKit authorization has been denied (for showing settings hint)
    var isHealthKitAuthorizationDenied: Bool {
        healthKitService.authorizationStatus == .denied
    }

    /// Formatted text for the imported weight timestamp
    var healthKitTimestampText: String? {
        guard let healthKitWeight = healthKitWeight else { return nil }
        return "From Health: \(healthKitWeight.formattedTimestamp)"
    }

    // MARK: - Computed Properties
    var parsedWeight: Double? {
        Double(weightInput)
    }

    var isValidWeight: Bool {
        guard let weight = parsedWeight else { return false }
        return weight >= AlertConstants.minimumWeight && weight <= AlertConstants.maximumWeight
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

        if change > AlertConstants.weightStabilityThreshold {
            return "Your weight is up \(formattedChange) lbs from yesterday"
        } else if change < -AlertConstants.weightStabilityThreshold {
            return "Your weight is down \(formattedChange) lbs from yesterday"
        } else {
            return "Your weight is stable from yesterday"
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

        guard weight >= AlertConstants.minimumWeight else {
            validationError = "Weight must be at least \(Int(AlertConstants.minimumWeight)) lbs"
            return false
        }

        guard weight <= AlertConstants.maximumWeight else {
            validationError = "Weight must be less than \(Int(AlertConstants.maximumWeight)) lbs"
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

            // Check for symptom alerts after successful save
            checkSymptomAlerts(context: context)
        } catch {
            // Track error state for potential UI indication
            // Auto-save errors are non-blocking but trackable
            symptomSaveError = true
            #if DEBUG
            print("Symptom save error: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Symptom Alert Methods

    /// Load unacknowledged symptom alerts for display
    func loadSymptomAlerts(context: ModelContext) {
        activeSymptomAlerts = symptomAlertService.loadUnacknowledgedSymptomAlerts(context: context)
    }

    /// Check symptom severities and create alerts if any are severe
    func checkSymptomAlerts(context: ModelContext) {
        symptomAlertService.checkSymptomAlerts(
            symptomSeverities: symptomSeverities,
            todayEntry: todayEntry,
            context: context
        )

        // Reload alerts to show any new ones
        loadSymptomAlerts(context: context)
    }

    // MARK: - Weight Alert Methods

    /// Load unacknowledged weight alerts for display
    func loadWeightAlerts(context: ModelContext) {
        activeWeightAlerts = weightAlertService.loadUnacknowledgedAlerts(context: context)
    }

    /// Check weight thresholds after weight is saved and create alerts if needed
    func checkWeightAlerts(context: ModelContext) {
        guard let currentWeight = todayEntry?.weight else { return }

        weightAlertService.checkWeightAlerts(
            currentWeight: currentWeight,
            todayEntry: todayEntry,
            yesterdayEntry: yesterdayEntry,
            context: context
        )

        // Reload alerts to show any new ones
        loadWeightAlerts(context: context)
    }

    /// Acknowledge (dismiss) an alert (works for both weight and symptom alerts)
    func acknowledgeAlert(_ alert: AlertEvent, context: ModelContext) {
        // Use the appropriate service based on alert type
        let success: Bool
        if alert.alertType == .severeSymptom {
            success = symptomAlertService.acknowledgeAlert(alert, context: context)
        } else {
            success = weightAlertService.acknowledgeAlert(alert, context: context)
        }

        if success {
            // Remove from the appropriate list
            if alert.alertType == .severeSymptom {
                activeSymptomAlerts.removeAll { $0.persistentModelID == alert.persistentModelID }
            } else {
                activeWeightAlerts.removeAll { $0.persistentModelID == alert.persistentModelID }
            }

            // Show brief encouragement message after dismissing alert
            showAlertDismissedEncouragement = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.showAlertDismissedEncouragement = false
            }
        }
    }

    // MARK: - HealthKit Methods

    /// Import weight from HealthKit
    /// Requests authorization if needed, then fetches the latest weight
    func importWeightFromHealthKit() async {
        guard isHealthKitAvailable else {
            healthKitError = "Health data is not available on this device"
            return
        }

        isLoadingHealthKit = true
        healthKitError = nil

        do {
            // Request authorization if not already granted
            try await healthKitService.requestAuthorization()

            // Fetch the latest weight
            if let weight = try await healthKitService.fetchLatestWeight() {
                await MainActor.run {
                    healthKitWeight = weight
                    weightInput = weight.formattedWeight
                    showHealthKitTimestamp = true
                    isLoadingHealthKit = false
                }
            } else {
                await MainActor.run {
                    healthKitError = "No weight data found in Health. Make sure you have recorded your weight in the Health app."
                    isLoadingHealthKit = false
                }
            }
        } catch let error as HealthKitError {
            await MainActor.run {
                healthKitError = error.errorDescription
                isLoadingHealthKit = false
            }
        } catch {
            await MainActor.run {
                healthKitError = "Could not import weight: \(error.localizedDescription)"
                isLoadingHealthKit = false
            }
        }
    }

    /// Clear the HealthKit imported weight state (when user edits manually)
    func clearHealthKitWeight() {
        healthKitWeight = nil
        showHealthKitTimestamp = false
    }
}
