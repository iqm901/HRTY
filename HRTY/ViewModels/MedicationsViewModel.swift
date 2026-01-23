import Foundation
import SwiftData
import UIKit

@Observable
final class MedicationsViewModel {
    // MARK: - State
    var medications: [Medication] = []
    var showingAddMedication = false
    var showingEditMedication = false
    var selectedMedication: Medication?
    var showingDeleteConfirmation = false
    var medicationToDelete: Medication?

    // MARK: - Conflict State
    var detectedConflicts: [MedicationConflict] = []
    var showingConflictWarning = false
    var pendingConflictMedication: PendingMedication?
    @ObservationIgnored
    private var conflictBannerDismissedAt: Date? {
        get {
            UserDefaults.standard.object(forKey: AppStorageKeys.conflictBannerDismissedAt) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppStorageKeys.conflictBannerDismissedAt)
        }
    }
    @ObservationIgnored
    private var lastConflictMedicationIds: Set<String> = []

    /// Pending medication data when conflict is detected
    struct PendingMedication {
        let name: String
        let dosage: Double
        let unit: String
        let schedule: String
        let isDiuretic: Bool
        let categoryRawValue: String?
    }

    // MARK: - Photo State
    var photos: [MedicationPhoto] = []
    var showingPhotoCaptureView = false
    var selectedPhoto: MedicationPhoto?
    var showingPhotoViewer = false
    var capturedImage: UIImage?
    var photoError: String?
    var photoSavedMessage: String?

    // MARK: - Form Fields
    var nameInput: String = ""
    var dosageInput: String = ""
    var selectedUnit: String = "mg"
    var scheduleInput: String = ""
    var isDiuretic: Bool = false

    // MARK: - Preset Medication Selection
    var usePresetMedication: Bool = true
    var selectedPresetMedication: HeartFailureMedication?
    var selectedDosageOption: String = ""
    var selectedFrequency: String = ""

    /// Available dosages for the currently selected preset medication
    var availableDosages: [String] {
        selectedPresetMedication?.availableDosages ?? []
    }

    /// Select a preset medication and auto-populate form fields
    func selectPresetMedication(_ medication: HeartFailureMedication?) {
        selectedPresetMedication = medication
        if let med = medication {
            nameInput = med.displayName
            selectedUnit = med.unit
            isDiuretic = med.isDiuretic
            selectedFrequency = med.defaultFrequency
            scheduleInput = med.defaultFrequency
            // Reset dosage selection
            selectedDosageOption = ""
            dosageInput = ""
        }
    }

    /// Select a dosage from the preset options
    func selectDosage(_ dosage: String) {
        selectedDosageOption = dosage
        dosageInput = dosage
    }

    // MARK: - Validation & Errors
    var validationError: String?
    var deleteError: String?
    var medicationSavedMessage: String?

    // MARK: - Services
    private let photoService = PhotoService.shared
    private let diureticDoseService: DiureticDoseServiceProtocol
    private let conflictService: MedicationConflictServiceProtocol

    // MARK: - Initialization
    init(
        diureticDoseService: DiureticDoseServiceProtocol = DiureticDoseService(),
        conflictService: MedicationConflictServiceProtocol = MedicationConflictService()
    ) {
        self.diureticDoseService = diureticDoseService
        self.conflictService = conflictService
    }

    // MARK: - Computed Properties
    var sortedMedications: [Medication] {
        medications
            .filter { $0.isActive }
            .sorted { lhs, rhs in
                // Diuretics first
                if lhs.isDiuretic != rhs.isDiuretic {
                    return lhs.isDiuretic
                }
                // Then alphabetically
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
    }

    var hasNoMedications: Bool {
        sortedMedications.isEmpty
    }

    var parsedDosage: Double? {
        Double(dosageInput)
    }

    var isFormValid: Bool {
        guard let dosage = parsedDosage else { return false }
        return !nameInput.trimmingCharacters(in: .whitespaces).isEmpty && dosage > 0
    }

    /// Whether to show the conflict banner
    var showConflictBanner: Bool {
        guard !detectedConflicts.isEmpty else { return false }

        // Get current conflict medication IDs
        let currentConflictMedIds = Set(detectedConflicts.flatMap { $0.medications.map { $0.name } })

        // If banner was dismissed, only show again if conflicts changed
        if let dismissedAt = conflictBannerDismissedAt {
            // Check if any medication was created after dismissal
            let hasNewConflicts = medications.contains { med in
                med.createdAt > dismissedAt && currentConflictMedIds.contains(med.name)
            }
            return hasNewConflicts
        }

        return true
    }

    /// Message to display in the conflict warning alert
    var conflictWarningMessage: String {
        guard let pending = pendingConflictMedication else { return "" }

        // Find conflicts for the pending medication
        let category = pending.categoryRawValue.flatMap { HeartFailureMedication.Category(rawValue: $0) }
        guard let cat = category else { return "" }

        let conflicts = conflictService.checkConflicts(newCategory: cat, existingMedications: medications)
        return conflicts.first?.message ?? "This medication may overlap with one you already have listed."
    }

    // MARK: - Methods
    func loadMedications(context: ModelContext) {
        let descriptor = FetchDescriptor<Medication>(
            predicate: #Predicate { $0.isActive == true },
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            medications = try context.fetch(descriptor)
            // Check for conflicts after loading
            detectedConflicts = conflictService.findAllConflicts(in: medications)
        } catch {
            medications = []
            detectedConflicts = []
        }
    }

    func resetForm() {
        nameInput = ""
        dosageInput = ""
        selectedUnit = "mg"
        scheduleInput = ""
        isDiuretic = false
        validationError = nil
        selectedMedication = nil
        // Reset preset medication fields
        selectedPresetMedication = nil
        selectedDosageOption = ""
        selectedFrequency = ""
        usePresetMedication = true
        // Don't clear medicationSavedMessage here - let it show briefly
    }

    func clearSavedMessage() {
        medicationSavedMessage = nil
    }

    func prepareForAdd() {
        resetForm()
        showingAddMedication = true
    }

    func prepareForEdit(medication: Medication) {
        selectedMedication = medication
        nameInput = medication.name
        dosageInput = String(format: "%.0f", medication.dosage)
        selectedUnit = medication.unit
        scheduleInput = medication.schedule
        isDiuretic = medication.isDiuretic
        validationError = nil
        showingEditMedication = true
    }

    func prepareForDelete(medication: Medication) {
        medicationToDelete = medication
        showingDeleteConfirmation = true
    }

    func validateForm() -> Bool {
        validationError = nil

        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            validationError = "Please enter a medication name"
            return false
        }

        guard !dosageInput.isEmpty else {
            validationError = "Please enter a dosage"
            return false
        }

        guard let dosage = parsedDosage, dosage > 0 else {
            validationError = "Please enter a valid dosage amount"
            return false
        }

        return true
    }

    func saveMedication(context: ModelContext) {
        guard validateForm() else { return }
        guard let dosage = parsedDosage else { return }

        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        let trimmedSchedule = scheduleInput.trimmingCharacters(in: .whitespaces)
        let categoryRaw = selectedPresetMedication?.category.rawValue

        let medication = Medication(
            name: trimmedName,
            dosage: dosage,
            unit: selectedUnit,
            schedule: trimmedSchedule,
            isDiuretic: isDiuretic,
            categoryRawValue: categoryRaw
        )

        context.insert(medication)

        do {
            try context.save()
            loadMedications(context: context)
            medicationSavedMessage = "\(trimmedName) added"
            // Don't dismiss or reset here - let the view handle it
            // This allows the form to stay open for adding multiple medications
        } catch {
            validationError = "Could not save medication. Please try again."
        }
    }

    /// Check for conflicts before saving, showing alert if conflicts found
    func checkAndSaveMedication(context: ModelContext) {
        guard validateForm() else { return }
        guard let dosage = parsedDosage else { return }

        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        let trimmedSchedule = scheduleInput.trimmingCharacters(in: .whitespaces)
        let categoryRaw = selectedPresetMedication?.category.rawValue

        // Check for conflicts if we have a category
        if let category = selectedPresetMedication?.category {
            let conflicts = conflictService.checkConflicts(
                newCategory: category,
                existingMedications: medications
            )

            if !conflicts.isEmpty {
                // Store pending medication and show warning
                pendingConflictMedication = PendingMedication(
                    name: trimmedName,
                    dosage: dosage,
                    unit: selectedUnit,
                    schedule: trimmedSchedule,
                    isDiuretic: isDiuretic,
                    categoryRawValue: categoryRaw
                )
                showingConflictWarning = true
                return
            }
        }

        // No conflicts - save directly
        saveMedication(context: context)
    }

    /// Confirm adding medication despite detected conflicts
    func confirmAddDespiteConflict(context: ModelContext) {
        guard let pending = pendingConflictMedication else { return }

        let medication = Medication(
            name: pending.name,
            dosage: pending.dosage,
            unit: pending.unit,
            schedule: pending.schedule,
            isDiuretic: pending.isDiuretic,
            categoryRawValue: pending.categoryRawValue
        )

        context.insert(medication)

        do {
            try context.save()
            loadMedications(context: context)
            medicationSavedMessage = "\(pending.name) added"
            pendingConflictMedication = nil
            showingConflictWarning = false
        } catch {
            validationError = "Could not save medication. Please try again."
        }
    }

    /// Cancel adding medication with conflicts
    func cancelConflictAdd() {
        pendingConflictMedication = nil
        showingConflictWarning = false
    }

    /// Dismiss the conflict banner
    func dismissConflictBanner() {
        conflictBannerDismissedAt = Date()
    }

    /// Check if a medication is part of a detected conflict
    func isInConflict(_ medication: Medication) -> Bool {
        detectedConflicts.contains { conflict in
            conflict.medications.contains { $0.persistentModelID == medication.persistentModelID }
        }
    }

    func updateMedication(context: ModelContext) {
        guard validateForm() else { return }
        guard let medication = selectedMedication else { return }
        guard let dosage = parsedDosage else { return }

        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        let trimmedSchedule = scheduleInput.trimmingCharacters(in: .whitespaces)

        medication.name = trimmedName
        medication.dosage = dosage
        medication.unit = selectedUnit
        medication.schedule = trimmedSchedule
        medication.isDiuretic = isDiuretic

        do {
            try context.save()
            loadMedications(context: context)
            showingEditMedication = false
            resetForm()
        } catch {
            validationError = "Could not update medication. Please try again."
        }
    }

    func deleteMedication(context: ModelContext) {
        guard let medication = medicationToDelete else { return }

        // Soft delete - set isActive to false
        medication.isActive = false

        do {
            try context.save()
            loadMedications(context: context)
            medicationToDelete = nil
            deleteError = nil
        } catch {
            // Revert the soft delete since save failed
            medication.isActive = true
            deleteError = "Could not remove medication. Please try again."
        }
    }

    func clearDeleteError() {
        deleteError = nil
    }

    // MARK: - Photo Methods

    func loadPhotos() {
        photos = photoService.loadPhotos()
    }

    func prepareForPhotoCapture() {
        capturedImage = nil
        photoError = nil
        showingPhotoCaptureView = true
    }

    func savePhoto() async {
        guard let image = capturedImage else { return }

        do {
            let photo = try await photoService.savePhoto(image)
            await MainActor.run {
                photos.insert(photo, at: 0)
                capturedImage = nil
                showingPhotoCaptureView = false
                photoSavedMessage = "Photo saved"
            }
        } catch {
            await MainActor.run {
                photoError = "Unable to save photo. Please try again."
            }
        }
    }

    func viewPhoto(_ photo: MedicationPhoto) {
        selectedPhoto = photo
        showingPhotoViewer = true
    }

    @MainActor
    func deletePhoto(_ photo: MedicationPhoto) {
        do {
            try photoService.deletePhoto(photo)
            photos.removeAll { $0.id == photo.id }
            if selectedPhoto?.id == photo.id {
                selectedPhoto = nil
                showingPhotoViewer = false
            }
        } catch {
            photoError = "Unable to delete photo. Please try again."
        }
    }

    func clearPhotoError() {
        photoError = nil
    }

    func clearPhotoSavedMessage() {
        photoSavedMessage = nil
    }

    var hasNoPhotos: Bool {
        photos.isEmpty
    }

    // MARK: - Diuretic Dose Logging

    var diureticMedications: [Medication] = []
    var todayDiureticDoses: [DiureticDose] = []
    var showDoseDeleteError: Bool = false
    var todayEntry: DailyEntry?

    /// Returns doses for a specific medication logged today
    func doses(for medication: Medication) -> [DiureticDose] {
        todayDiureticDoses.filter { $0.medication?.persistentModelID == medication.persistentModelID }
            .sorted { $0.timestamp < $1.timestamp }
    }

    func loadDiuretics(context: ModelContext) {
        // Get today's entry
        todayEntry = DailyEntry.getOrCreate(for: Date(), in: context)

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
            showDoseDeleteError = false
        } else {
            showDoseDeleteError = true
        }
    }

    var hasDiuretics: Bool {
        !diureticMedications.isEmpty
    }
}
