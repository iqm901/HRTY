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

    // MARK: - Heart Rate State
    var activeHeartRateAlerts: [AlertEvent] = []
    var latestHeartRate: HeartRateReading?
    var isLoadingHeartRate: Bool = false
    var healthKitAvailable: Bool = false

    // MARK: - HealthKit Weight Import State
    var isLoadingHealthKit: Bool = false
    var showHealthKitTimestamp: Bool = false
    var healthKitTimestampText: String?
    var healthKitError: String?
    var healthKitRecoverySuggestion: String?

    // MARK: - Dizziness BP Alert State
    var activeDizzinessBPAlerts: [AlertEvent] = []
    var hasBPReading: Bool = false

    // MARK: - Vital Signs Alert State
    var activeVitalSignsAlerts: [AlertEvent] = []

    // MARK: - Blood Pressure Input State
    var systolicBPInput: String = ""
    var diastolicBPInput: String = ""
    var bloodPressureValidationError: String?
    var isLoadingBPHealthKit: Bool = false
    var bloodPressureHealthKitTimestamp: String?
    var showBPSaveSuccess: Bool = false

    // MARK: - Oxygen Saturation Input State
    var oxygenSaturationInput: String = ""
    var oxygenSaturationValidationError: String?
    var isLoadingSpO2HealthKit: Bool = false
    var oxygenSaturationHealthKitTimestamp: String?
    var showSpO2SaveSuccess: Bool = false

    // MARK: - Loading State
    var isLoading: Bool = false

    // MARK: - Data State
    var todayEntry: DailyEntry?
    var yesterdayEntry: DailyEntry?

    // MARK: - Services
    private let weightAlertService: WeightAlertServiceProtocol
    private let symptomAlertService: SymptomAlertServiceProtocol
    private let heartRateAlertService: HeartRateAlertServiceProtocol
    private let healthKitService: HealthKitServiceProtocol
    private let dizzinessBPAlertService: DizzinessBPAlertServiceProtocol
    private let vitalSignsAlertService: VitalSignsAlertServiceProtocol
    private let diureticDoseService: DiureticDoseServiceProtocol

    // MARK: - Initialization
    init(
        weightAlertService: WeightAlertServiceProtocol = WeightAlertService(),
        symptomAlertService: SymptomAlertServiceProtocol = SymptomAlertService(),
        heartRateAlertService: HeartRateAlertServiceProtocol = HeartRateAlertService(),
        healthKitService: HealthKitServiceProtocol = HealthKitService(),
        dizzinessBPAlertService: DizzinessBPAlertServiceProtocol = DizzinessBPAlertService(),
        vitalSignsAlertService: VitalSignsAlertServiceProtocol = VitalSignsAlertService(),
        diureticDoseService: DiureticDoseServiceProtocol = DiureticDoseService()
    ) {
        self.weightAlertService = weightAlertService
        self.symptomAlertService = symptomAlertService
        self.heartRateAlertService = heartRateAlertService
        self.healthKitService = healthKitService
        self.dizzinessBPAlertService = dizzinessBPAlertService
        self.vitalSignsAlertService = vitalSignsAlertService
        self.diureticDoseService = diureticDoseService
        self.healthKitAvailable = healthKitService.isAvailable
    }

    // MARK: - Validation Constants (reference AlertConstants for thresholds)

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

    var isHealthKitAvailable: Bool {
        healthKitAvailable
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

    /// Load all data asynchronously to prevent UI freezing
    @MainActor
    func loadAllData(context: ModelContext) async {
        isLoading = true

        // Run fetches - these are sync but wrapped in async context to not block UI
        loadData(context: context)
        loadSymptoms(context: context)
        loadDiuretics(context: context)
        loadVitalSigns(context: context)
        loadWeightAlerts(context: context)
        loadSymptomAlerts(context: context)
        loadHeartRateAlerts(context: context)
        loadDizzinessBPAlerts(context: context)
        loadVitalSignsAlerts(context: context)

        // Load heart rate data asynchronously
        await loadHeartRateData(context: context)

        isLoading = false
    }

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

    // MARK: - HealthKit Weight Import

    /// Import weight from HealthKit
    @MainActor
    func importWeightFromHealthKit() async {
        guard healthKitAvailable else {
            healthKitError = "HealthKit is not available on this device"
            healthKitRecoverySuggestion = "Please ensure Health is enabled in Settings"
            return
        }

        isLoadingHealthKit = true
        healthKitError = nil
        healthKitRecoverySuggestion = nil

        // Request authorization
        let authorized = await healthKitService.requestAuthorization()
        guard authorized else {
            isLoadingHealthKit = false
            healthKitError = "Unable to access Health data"
            healthKitRecoverySuggestion = "Please allow HRTY to read weight data in Settings > Health > Data Access"
            return
        }

        // Fetch latest weight
        if let weight = await healthKitService.fetchLatestWeight() {
            weightInput = String(format: "%.1f", weight.weight)
            showHealthKitTimestamp = true

            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            healthKitTimestampText = "from Health \(formatter.localizedString(for: weight.date, relativeTo: Date()))"
        } else {
            healthKitError = "No recent weight data found"
            healthKitRecoverySuggestion = "Try weighing yourself on a connected scale or enter your weight manually"
        }

        isLoadingHealthKit = false
    }

    /// Clear the HealthKit imported weight indicator and any errors
    func clearHealthKitWeight() {
        showHealthKitTimestamp = false
        healthKitTimestampText = nil
        healthKitError = nil
        healthKitRecoverySuggestion = nil
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
        // Load diuretics using the shared service
        diureticMedications = diureticDoseService.loadDiuretics(context: context)

        // Load today's doses from the daily entry
        todayDiureticDoses = diureticDoseService.loadTodayDoses(from: todayEntry)
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
        }
    }

    /// Delete a logged dose
    func deleteDose(_ dose: DiureticDose, context: ModelContext) {
        if diureticDoseService.deleteDose(dose, context: context) {
            todayDiureticDoses.removeAll { $0.persistentModelID == dose.persistentModelID }
            showDeleteError = false
        } else {
            showDeleteError = true
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

            // Check for dizziness BP prompt if dizziness was updated
            if symptomType == .dizziness {
                Task {
                    await checkDizzinessBPAlert(context: context)
                }
            }
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

    /// Acknowledge (dismiss) an alert (works for weight, symptom, heart rate, dizziness BP, and vital signs alerts)
    func acknowledgeAlert(_ alert: AlertEvent, context: ModelContext) {
        // Use the appropriate service based on alert type
        let success: Bool
        switch alert.alertType {
        case .severeSymptom:
            success = symptomAlertService.acknowledgeAlert(alert, context: context)
        case .heartRateLow, .heartRateHigh:
            success = heartRateAlertService.acknowledgeAlert(alert, context: context)
        case .dizzinessBPCheck:
            success = dizzinessBPAlertService.acknowledgeAlert(alert, context: context)
        case .weightGain24h, .weightGain7d:
            success = weightAlertService.acknowledgeAlert(alert, context: context)
        case .lowOxygenSaturation, .lowBloodPressure, .lowMAP:
            success = vitalSignsAlertService.acknowledgeAlert(alert, context: context)
        }

        if success {
            // Remove from the appropriate list
            switch alert.alertType {
            case .severeSymptom:
                activeSymptomAlerts.removeAll { $0.persistentModelID == alert.persistentModelID }
            case .heartRateLow, .heartRateHigh:
                activeHeartRateAlerts.removeAll { $0.persistentModelID == alert.persistentModelID }
            case .dizzinessBPCheck:
                activeDizzinessBPAlerts.removeAll { $0.persistentModelID == alert.persistentModelID }
            case .weightGain24h, .weightGain7d:
                activeWeightAlerts.removeAll { $0.persistentModelID == alert.persistentModelID }
            case .lowOxygenSaturation, .lowBloodPressure, .lowMAP:
                activeVitalSignsAlerts.removeAll { $0.persistentModelID == alert.persistentModelID }
            }

            // Show brief encouragement message after dismissing alert
            showAlertDismissedEncouragement = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.showAlertDismissedEncouragement = false
            }
        }
    }

    // MARK: - Heart Rate Methods

    /// Formatted heart rate text for display
    var formattedHeartRate: String? {
        guard let reading = latestHeartRate else { return nil }
        return "\(reading.heartRate) bpm"
    }

    /// Formatted timestamp for heart rate reading
    var heartRateTimestamp: String? {
        guard let reading = latestHeartRate else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: reading.date, relativeTo: Date())
    }

    /// Request HealthKit authorization and load heart rate data
    func loadHeartRateData(context: ModelContext) async {
        guard healthKitAvailable else { return }

        isLoadingHeartRate = true

        // Request authorization
        let authorized = await healthKitService.requestAuthorization()
        guard authorized else {
            isLoadingHeartRate = false
            return
        }

        // Fetch latest heart rate
        latestHeartRate = await healthKitService.fetchLatestRestingHeartRate()

        // Check for persistent abnormal heart rate and create alerts if needed
        await checkHeartRateAlerts(context: context)

        isLoadingHeartRate = false
    }

    /// Load unacknowledged heart rate alerts for display
    func loadHeartRateAlerts(context: ModelContext) {
        activeHeartRateAlerts = heartRateAlertService.loadUnacknowledgedHeartRateAlerts(context: context)
    }

    /// Check for persistent abnormal heart rate and create alerts if needed
    func checkHeartRateAlerts(context: ModelContext) async {
        let result = await healthKitService.checkForPersistentAbnormalHeartRate()

        if result.isAbnormal {
            heartRateAlertService.checkHeartRateAlerts(
                readings: result.readings,
                isAbnormal: result.isAbnormal,
                isLow: result.isLow,
                todayEntry: todayEntry,
                context: context
            )
        }

        // Reload alerts to show any new ones
        loadHeartRateAlerts(context: context)
    }

    // MARK: - Dizziness BP Alert Methods

    /// Load unacknowledged dizziness BP alerts for display
    func loadDizzinessBPAlerts(context: ModelContext) {
        activeDizzinessBPAlerts = dizzinessBPAlertService.loadUnacknowledgedDizzinessBPAlerts(context: context)
    }

    /// Check if dizziness warrants a BP check prompt
    @MainActor
    func checkDizzinessBPAlert(context: ModelContext) async {
        let dizzinessSeverity = symptomSeverities[.dizziness] ?? 1

        // Check for recent BP reading from HealthKit
        hasBPReading = await healthKitService.hasRecentBloodPressureReading(
            withinHours: AlertConstants.bloodPressureLookbackHours
        )

        dizzinessBPAlertService.checkDizzinessBPAlert(
            dizzinessSeverity: dizzinessSeverity,
            hasBPReading: hasBPReading,
            todayEntry: todayEntry,
            context: context
        )

        // Reload alerts to show any new ones
        loadDizzinessBPAlerts(context: context)
    }

    // MARK: - Vital Signs Methods

    /// Load vital signs data from today's entry
    func loadVitalSigns(context: ModelContext) {
        guard let entry = todayEntry,
              let vitalSigns = entry.vitalSigns else {
            return
        }

        if let systolic = vitalSigns.systolicBP {
            systolicBPInput = String(systolic)
        }
        if let diastolic = vitalSigns.diastolicBP {
            diastolicBPInput = String(diastolic)
        }
        if let spo2 = vitalSigns.oxygenSaturation {
            oxygenSaturationInput = String(spo2)
        }
    }

    /// Load unacknowledged vital signs alerts for display
    func loadVitalSignsAlerts(context: ModelContext) {
        activeVitalSignsAlerts = vitalSignsAlertService.loadUnacknowledgedVitalSignsAlerts(context: context)
    }

    // MARK: - Blood Pressure Methods

    /// Parsed systolic blood pressure
    var parsedSystolicBP: Int? {
        Int(systolicBPInput)
    }

    /// Parsed diastolic blood pressure
    var parsedDiastolicBP: Int? {
        Int(diastolicBPInput)
    }

    /// Validate blood pressure input
    func validateBloodPressure() -> Bool {
        bloodPressureValidationError = nil

        guard !systolicBPInput.isEmpty, !diastolicBPInput.isEmpty else {
            bloodPressureValidationError = "Please enter both systolic and diastolic values"
            return false
        }

        guard let systolic = parsedSystolicBP else {
            bloodPressureValidationError = "Please enter a valid systolic number"
            return false
        }

        guard let diastolic = parsedDiastolicBP else {
            bloodPressureValidationError = "Please enter a valid diastolic number"
            return false
        }

        guard systolic >= AlertConstants.minimumSystolicBP else {
            bloodPressureValidationError = "Systolic must be at least \(AlertConstants.minimumSystolicBP) mmHg"
            return false
        }

        guard systolic <= AlertConstants.maximumSystolicBP else {
            bloodPressureValidationError = "Systolic must be less than \(AlertConstants.maximumSystolicBP) mmHg"
            return false
        }

        guard diastolic >= AlertConstants.minimumDiastolicBP else {
            bloodPressureValidationError = "Diastolic must be at least \(AlertConstants.minimumDiastolicBP) mmHg"
            return false
        }

        guard diastolic <= AlertConstants.maximumDiastolicBP else {
            bloodPressureValidationError = "Diastolic must be less than \(AlertConstants.maximumDiastolicBP) mmHg"
            return false
        }

        guard systolic > diastolic else {
            bloodPressureValidationError = "Systolic must be greater than diastolic"
            return false
        }

        return true
    }

    /// Save blood pressure to the vital signs entry
    func saveBloodPressure(context: ModelContext) {
        guard validateBloodPressure() else { return }
        guard let systolic = parsedSystolicBP,
              let diastolic = parsedDiastolicBP else { return }

        if todayEntry == nil {
            todayEntry = DailyEntry.getOrCreate(for: Date(), in: context)
        }

        guard let entry = todayEntry else { return }

        // Get or create vital signs entry
        let vitalSigns: VitalSignsEntry
        if let existing = entry.vitalSigns {
            vitalSigns = existing
        } else {
            vitalSigns = VitalSignsEntry(dailyEntry: entry)
            context.insert(vitalSigns)
            entry.vitalSigns = vitalSigns
        }

        vitalSigns.systolicBP = systolic
        vitalSigns.diastolicBP = diastolic
        vitalSigns.bloodPressureTimestamp = Date()
        vitalSigns.updatedAt = Date()
        entry.updatedAt = Date()

        do {
            try context.save()
            showBPSaveSuccess = true

            // Check for vital signs alerts after successful save
            checkVitalSignsAlerts(context: context)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.showBPSaveSuccess = false
            }
        } catch {
            bloodPressureValidationError = "Could not save blood pressure. Please try again."
        }
    }

    /// Import blood pressure from HealthKit
    @MainActor
    func importBloodPressureFromHealthKit() async {
        guard healthKitAvailable else {
            bloodPressureValidationError = "HealthKit is not available on this device"
            return
        }

        isLoadingBPHealthKit = true
        bloodPressureValidationError = nil
        bloodPressureHealthKitTimestamp = nil

        let authorized = await healthKitService.requestAuthorization()
        guard authorized else {
            isLoadingBPHealthKit = false
            bloodPressureValidationError = "Unable to access Health data"
            return
        }

        if let reading = await healthKitService.fetchLatestBloodPressure() {
            systolicBPInput = String(reading.systolic)
            diastolicBPInput = String(reading.diastolic)

            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            bloodPressureHealthKitTimestamp = "from Health \(formatter.localizedString(for: reading.date, relativeTo: Date()))"
        } else {
            bloodPressureValidationError = "No recent blood pressure data found"
        }

        isLoadingBPHealthKit = false
    }

    // MARK: - Oxygen Saturation Methods

    /// Parsed oxygen saturation
    var parsedOxygenSaturation: Int? {
        Int(oxygenSaturationInput)
    }

    /// Validate oxygen saturation input
    func validateOxygenSaturation() -> Bool {
        oxygenSaturationValidationError = nil

        guard !oxygenSaturationInput.isEmpty else {
            oxygenSaturationValidationError = "Please enter your oxygen saturation"
            return false
        }

        guard let spo2 = parsedOxygenSaturation else {
            oxygenSaturationValidationError = "Please enter a valid number"
            return false
        }

        guard spo2 >= AlertConstants.minimumOxygenSaturation else {
            oxygenSaturationValidationError = "Oxygen level must be at least \(AlertConstants.minimumOxygenSaturation)%"
            return false
        }

        guard spo2 <= AlertConstants.maximumOxygenSaturation else {
            oxygenSaturationValidationError = "Oxygen level must be at most \(AlertConstants.maximumOxygenSaturation)%"
            return false
        }

        return true
    }

    /// Save oxygen saturation to the vital signs entry
    func saveOxygenSaturation(context: ModelContext) {
        guard validateOxygenSaturation() else { return }
        guard let spo2 = parsedOxygenSaturation else { return }

        if todayEntry == nil {
            todayEntry = DailyEntry.getOrCreate(for: Date(), in: context)
        }

        guard let entry = todayEntry else { return }

        // Get or create vital signs entry
        let vitalSigns: VitalSignsEntry
        if let existing = entry.vitalSigns {
            vitalSigns = existing
        } else {
            vitalSigns = VitalSignsEntry(dailyEntry: entry)
            context.insert(vitalSigns)
            entry.vitalSigns = vitalSigns
        }

        vitalSigns.oxygenSaturation = spo2
        vitalSigns.oxygenSaturationTimestamp = Date()
        vitalSigns.updatedAt = Date()
        entry.updatedAt = Date()

        do {
            try context.save()
            showSpO2SaveSuccess = true

            // Check for vital signs alerts after successful save
            checkVitalSignsAlerts(context: context)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.showSpO2SaveSuccess = false
            }
        } catch {
            oxygenSaturationValidationError = "Could not save oxygen level. Please try again."
        }
    }

    /// Import oxygen saturation from HealthKit
    @MainActor
    func importOxygenSaturationFromHealthKit() async {
        guard healthKitAvailable else {
            oxygenSaturationValidationError = "HealthKit is not available on this device"
            return
        }

        isLoadingSpO2HealthKit = true
        oxygenSaturationValidationError = nil
        oxygenSaturationHealthKitTimestamp = nil

        let authorized = await healthKitService.requestAuthorization()
        guard authorized else {
            isLoadingSpO2HealthKit = false
            oxygenSaturationValidationError = "Unable to access Health data"
            return
        }

        if let reading = await healthKitService.fetchLatestOxygenSaturation() {
            oxygenSaturationInput = String(reading.percentage)

            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            oxygenSaturationHealthKitTimestamp = "from Health \(formatter.localizedString(for: reading.date, relativeTo: Date()))"
        } else {
            oxygenSaturationValidationError = "No recent oxygen saturation data found"
        }

        isLoadingSpO2HealthKit = false
    }

    // MARK: - Vital Signs Alert Methods

    /// Check vital signs thresholds and create alerts if needed
    func checkVitalSignsAlerts(context: ModelContext) {
        let systolic = todayEntry?.vitalSigns?.systolicBP
        let diastolic = todayEntry?.vitalSigns?.diastolicBP
        let spo2 = todayEntry?.vitalSigns?.oxygenSaturation

        vitalSignsAlertService.checkVitalSignsAlerts(
            systolicBP: systolic,
            diastolicBP: diastolic,
            oxygenSaturation: spo2,
            todayEntry: todayEntry,
            context: context
        )

        // Reload alerts to show any new ones
        loadVitalSignsAlerts(context: context)
    }
}
