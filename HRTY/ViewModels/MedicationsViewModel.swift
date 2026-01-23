import Foundation
import SwiftData
import UIKit

@Observable
final class MedicationsViewModel {
    // MARK: - State
    var medications: [Medication] = []
    var priorMedications: [Medication] = []
    var showingAddMedication = false
    var showingEditMedication = false
    var selectedMedication: Medication?
    var showingDeleteConfirmation = false
    var medicationToDelete: Medication?

    // MARK: - Archive State
    var isPriorSectionExpanded = false
    var showingArchivePrompt = false
    var showingArchiveInsteadPrompt = false
    var medicationToArchive: Medication?
    var showingPriorMedicationDetail = false
    var selectedPriorMedication: Medication?

    // MARK: - Reactivation Form Fields
    var reactivateDosageInput: String = ""
    var reactivateSelectedUnit: String = "mg"
    var reactivateScheduleInput: String = ""

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

    // MARK: - Conflict State
    var detectedConflicts: [MedicationConflict] = []
    var showingConflictWarning = false
    var pendingConflictMedication: Medication?
    var conflictWarningMessage: String = ""

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

    // MARK: - Methods
    func loadMedications(context: ModelContext) {
        // Load active medications
        let activeDescriptor = FetchDescriptor<Medication>(
            predicate: #Predicate { $0.isActive == true },
            sortBy: [SortDescriptor(\.name)]
        )

        // Load archived/prior medications
        let priorDescriptor = FetchDescriptor<Medication>(
            predicate: #Predicate { $0.isActive == false },
            sortBy: [SortDescriptor(\.archivedAt, order: .reverse)]
        )

        do {
            medications = try context.fetch(activeDescriptor)
            priorMedications = try context.fetch(priorDescriptor)

            // Ensure all medications have periods (migration)
            for medication in medications + priorMedications {
                medication.createInitialPeriodIfNeeded()
            }

            refreshConflicts()
        } catch {
            medications = []
            priorMedications = []
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

        let medication = Medication(
            name: trimmedName,
            dosage: dosage,
            unit: selectedUnit,
            schedule: trimmedSchedule,
            isDiuretic: isDiuretic,
            categoryRawValue: selectedPresetMedication?.category.rawValue
        )

        // Create initial period for tracking history
        let initialPeriod = MedicationPeriod(
            dosage: dosage,
            unit: selectedUnit,
            schedule: trimmedSchedule,
            startDate: Date()
        )
        medication.periods = [initialPeriod]

        context.insert(medication)

        do {
            try context.save()
            loadMedications(context: context)
            refreshConflicts()
            medicationSavedMessage = "\(trimmedName) added"
            // Don't dismiss or reset here - let the view handle it
            // This allows the form to stay open for adding multiple medications
        } catch {
            validationError = "Could not save medication. Please try again."
        }
    }

    func updateMedication(context: ModelContext) {
        guard validateForm() else { return }
        guard let medication = selectedMedication else { return }
        guard let dosage = parsedDosage else { return }

        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        let trimmedSchedule = scheduleInput.trimmingCharacters(in: .whitespaces)

        medication.name = trimmedName
        medication.isDiuretic = isDiuretic

        // Use updateDosage to track dosage changes as periods
        medication.updateDosage(
            newDosage: dosage,
            newUnit: selectedUnit,
            newSchedule: trimmedSchedule
        )

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

    // MARK: - Archive Methods

    /// Check if we should prompt to archive instead of delete
    func shouldPromptArchiveInsteadOfDelete(_ medication: Medication) -> Bool {
        return medication.canBeArchived
    }

    /// Prepare to archive a medication (shows archive confirmation)
    func prepareForArchive(medication: Medication) {
        medicationToArchive = medication
        showingArchivePrompt = true
    }

    /// Prepare to delete with archive prompt (for medications > 1 day old)
    func prepareForDeleteWithArchiveOption(medication: Medication) {
        medicationToDelete = medication
        showingArchiveInsteadPrompt = true
    }

    /// Archive a medication (move to prior medications)
    func archiveMedication(context: ModelContext) {
        guard let medication = medicationToArchive else { return }

        medication.archive()

        do {
            try context.save()
            loadMedications(context: context)
            medicationToArchive = nil
            showingArchivePrompt = false
        } catch {
            // Revert the archive since save failed
            medication.isActive = true
            medication.archivedAt = nil
            deleteError = "Could not archive medication. Please try again."
        }
    }

    /// Permanently delete a medication (hard delete from database)
    func permanentlyDeleteMedication(context: ModelContext) {
        guard let medication = medicationToDelete else { return }

        context.delete(medication)

        do {
            try context.save()
            loadMedications(context: context)
            medicationToDelete = nil
            showingArchiveInsteadPrompt = false
            deleteError = nil
        } catch {
            deleteError = "Could not delete medication. Please try again."
        }
    }

    /// Archive instead of delete (from delete prompt)
    func archiveInsteadOfDelete(context: ModelContext) {
        guard let medication = medicationToDelete else { return }

        medication.archive()

        do {
            try context.save()
            loadMedications(context: context)
            medicationToDelete = nil
            showingArchiveInsteadPrompt = false
        } catch {
            medication.isActive = true
            medication.archivedAt = nil
            deleteError = "Could not archive medication. Please try again."
        }
    }

    /// Cancel archive or delete prompt
    func cancelArchiveOrDelete() {
        medicationToArchive = nil
        medicationToDelete = nil
        showingArchivePrompt = false
        showingArchiveInsteadPrompt = false
    }

    // MARK: - Prior Medication Methods

    /// Prepare to view a prior medication's detail
    func prepareForPriorDetail(medication: Medication) {
        selectedPriorMedication = medication
        // Pre-fill reactivation form with last known dosage
        reactivateDosageInput = String(format: "%.0f", medication.dosage)
        reactivateSelectedUnit = medication.unit
        reactivateScheduleInput = medication.schedule
        showingPriorMedicationDetail = true
    }

    /// Reactivate a prior medication
    func reactivateMedication(context: ModelContext) {
        guard let medication = selectedPriorMedication else { return }
        guard let dosage = Double(reactivateDosageInput), dosage > 0 else {
            validationError = "Please enter a valid dosage"
            return
        }

        medication.reactivate(
            dosage: dosage,
            unit: reactivateSelectedUnit,
            schedule: reactivateScheduleInput.trimmingCharacters(in: .whitespaces)
        )

        do {
            try context.save()
            loadMedications(context: context)
            refreshConflicts()
            showingPriorMedicationDetail = false
            selectedPriorMedication = nil
            resetReactivationForm()
        } catch {
            validationError = "Could not reactivate medication. Please try again."
        }
    }

    /// Reset reactivation form fields
    func resetReactivationForm() {
        reactivateDosageInput = ""
        reactivateSelectedUnit = "mg"
        reactivateScheduleInput = ""
    }

    /// Toggle the prior medications section expansion
    func togglePriorSection() {
        isPriorSectionExpanded.toggle()
    }

    /// Whether there are any prior medications
    var hasPriorMedications: Bool {
        !priorMedications.isEmpty
    }

    /// Count of prior medications for display
    var priorMedicationsCount: Int {
        priorMedications.count
    }

    // MARK: - Conflict Detection Methods

    /// Check for conflicts before saving. If conflicts exist, show warning; otherwise save directly.
    func checkAndSaveMedication(context: ModelContext) {
        guard validateForm() else { return }
        guard let dosage = parsedDosage else { return }

        // Only check conflicts for preset medications with a known category
        if let category = selectedPresetMedication?.category {
            let conflicts = conflictService.checkConflicts(
                newCategory: category,
                existingMedications: medications
            )

            if !conflicts.isEmpty {
                // Store the pending medication info and show warning
                let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
                let trimmedSchedule = scheduleInput.trimmingCharacters(in: .whitespaces)

                pendingConflictMedication = Medication(
                    name: trimmedName,
                    dosage: dosage,
                    unit: selectedUnit,
                    schedule: trimmedSchedule,
                    isDiuretic: isDiuretic,
                    categoryRawValue: category.rawValue
                )

                conflictWarningMessage = conflicts.first?.message ?? "A potential conflict was detected."
                showingConflictWarning = true
                return
            }
        }

        // No conflicts, save directly
        saveMedication(context: context)
    }

    /// Save medication despite detected conflicts
    func confirmAddDespiteConflict(context: ModelContext) {
        guard let medication = pendingConflictMedication else { return }

        context.insert(medication)

        do {
            try context.save()
            loadMedications(context: context)
            refreshConflicts()
            medicationSavedMessage = "\(medication.name) added"
            pendingConflictMedication = nil
            showingConflictWarning = false
            resetForm()
        } catch {
            validationError = "Could not save medication. Please try again."
        }
    }

    /// Cancel adding the conflicting medication
    func cancelConflictAdd() {
        pendingConflictMedication = nil
        showingConflictWarning = false
    }

    /// Refresh the list of conflicts for display
    func refreshConflicts() {
        detectedConflicts = conflictService.findAllConflicts(in: medications)
    }

    /// Check if a specific medication is part of any conflict
    func isInConflict(_ medication: Medication) -> Bool {
        detectedConflicts.contains { conflict in
            conflict.medications.contains { $0.persistentModelID == medication.persistentModelID }
        }
    }

    /// Whether there are any active conflicts to display
    var hasConflicts: Bool {
        !detectedConflicts.isEmpty
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
