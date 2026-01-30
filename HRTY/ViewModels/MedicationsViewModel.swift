import Foundation
import SwiftData
import UIKit

/// Entry mode for adding medications
enum MedicationEntryMode: String, CaseIterable {
    case heartFailure = "Heart Failure Meds"
    case other = "Other Medications"
    case custom = "Custom Entry"
}

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

    // MARK: - History State
    var isHistorySectionExpanded = false
    var timelineEvents: [MedicationHistoryService.TimelineEvent] = []
    var selectedSnapshotDate: Date = Date()
    var snapshotRegimen: MedicationHistoryService.RegimenSnapshot?
    var showingHistoryView = false

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

    // MARK: - Entry Mode and Preset Medication Selection
    var entryMode: MedicationEntryMode = .heartFailure
    var selectedPresetMedication: HeartFailureMedication?
    var selectedDosageOption: String = ""
    var selectedFrequency: String = ""

    // MARK: - Other Medication Selection
    var selectedOtherMedication: OtherMedication?
    var otherMedicationSelectedDosageOption: String = ""
    var otherMedicationSelectedFrequency: String = ""

    // MARK: - Search State
    var searchText: String = ""

    /// Whether search is active (non-empty search text)
    var isSearchActive: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Search results from Heart Failure Medications
    var heartFailureSearchResults: [HeartFailureMedication] {
        guard isSearchActive else { return [] }
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        return HeartFailureMedication.allMedications.filter { medication in
            medication.genericName.lowercased().contains(query) ||
            (medication.brandName?.lowercased().contains(query) ?? false)
        }.sorted { med1, med2 in
            // Prioritize medications that start with the query
            let med1StartsWithQuery = med1.genericName.lowercased().hasPrefix(query) ||
                                      (med1.brandName?.lowercased().hasPrefix(query) ?? false)
            let med2StartsWithQuery = med2.genericName.lowercased().hasPrefix(query) ||
                                      (med2.brandName?.lowercased().hasPrefix(query) ?? false)
            if med1StartsWithQuery != med2StartsWithQuery {
                return med1StartsWithQuery
            }
            return med1.displayName.localizedCaseInsensitiveCompare(med2.displayName) == .orderedAscending
        }
    }

    /// Search results from Other Medications
    var otherMedicationSearchResults: [OtherMedication] {
        guard isSearchActive else { return [] }
        return OtherMedication.search(query: searchText)
    }

    /// Whether there are any search results
    var hasSearchResults: Bool {
        !heartFailureSearchResults.isEmpty || !otherMedicationSearchResults.isEmpty
    }

    /// Clear search and reset to default state
    func clearSearch() {
        searchText = ""
    }

    /// Available dosages for the currently selected preset medication
    var availableDosages: [String] {
        selectedPresetMedication?.availableDosages ?? []
    }

    /// Available dosages for the currently selected other medication
    var availableOtherDosages: [String] {
        selectedOtherMedication?.availableDosages ?? []
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

    /// Select an Other Medication and auto-populate form fields
    func selectOtherMedication(_ medication: OtherMedication?) {
        selectedOtherMedication = medication
        if let med = medication {
            nameInput = med.displayName
            selectedUnit = med.unit
            isDiuretic = med.isDiuretic
            otherMedicationSelectedFrequency = med.defaultFrequency
            scheduleInput = med.defaultFrequency
            // Reset dosage selection
            otherMedicationSelectedDosageOption = ""
            dosageInput = ""
        }
    }

    /// Select a dosage from the preset options
    func selectDosage(_ dosage: String) {
        selectedDosageOption = dosage
        dosageInput = dosage
    }

    /// Select a dosage from the other medication options
    func selectOtherMedicationDosage(_ dosage: String) {
        otherMedicationSelectedDosageOption = dosage
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

    // MARK: - Avoid Warning State
    var showingAvoidWarning = false
    var pendingAvoidMedication: Medication?
    var avoidWarningMessage: String = ""
    var avoidWarningCategory: String = ""

    // MARK: - Services
    private let photoService = PhotoService.shared
    private let conflictService: MedicationConflictServiceProtocol
    private let avoidService: MedicationAvoidServiceProtocol
    private let historyService = MedicationHistoryService()

    // MARK: - Initialization
    init(
        conflictService: MedicationConflictServiceProtocol = MedicationConflictService(),
        avoidService: MedicationAvoidServiceProtocol = MedicationAvoidService()
    ) {
        self.conflictService = conflictService
        self.avoidService = avoidService
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

    /// Validates if dosageInput is a valid dosage (numeric or combination like "49/51")
    var isValidDosage: Bool {
        let trimmed = dosageInput.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return false }

        // Check for combination dosage (e.g., "49/51")
        if trimmed.contains("/") {
            let parts = trimmed.split(separator: "/")
            return parts.count == 2 &&
                   parts.allSatisfy { Double($0) != nil && Double($0)! > 0 }
        }

        // Check for simple numeric dosage
        if let value = Double(trimmed) {
            return value > 0
        }

        return false
    }

    var isFormValid: Bool {
        !nameInput.trimmingCharacters(in: .whitespaces).isEmpty && isValidDosage
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
        // Reset other medication fields
        selectedOtherMedication = nil
        otherMedicationSelectedDosageOption = ""
        otherMedicationSelectedFrequency = ""
        // Reset entry mode and search
        entryMode = .heartFailure
        searchText = ""
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
        dosageInput = medication.dosage
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

        guard isValidDosage else {
            validationError = "Please enter a valid dosage (e.g., 50 or 49/51)"
            return false
        }

        return true
    }

    func saveMedication(context: ModelContext) {
        guard validateForm() else { return }

        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        let trimmedSchedule = scheduleInput.trimmingCharacters(in: .whitespaces)
        let trimmedDosage = dosageInput.trimmingCharacters(in: .whitespaces)

        // Auto-detect if medication is a diuretic
        // Use preset's isDiuretic if available, then other medication's, otherwise detect from name
        let detectedDiuretic = selectedPresetMedication?.isDiuretic
            ?? selectedOtherMedication?.isDiuretic
            ?? HeartFailureMedication.isDiuretic(medicationName: trimmedName)
            || OtherMedication.knownDiureticNames.contains(trimmedName.lowercased())

        // Get category from HF medication (Other medications don't have HF categories)
        let categoryRawValue = selectedPresetMedication?.category.rawValue

        let medication = Medication(
            name: trimmedName,
            dosage: trimmedDosage,
            unit: selectedUnit,
            schedule: trimmedSchedule,
            isDiuretic: detectedDiuretic,
            categoryRawValue: categoryRawValue
        )

        // Create initial period for tracking history
        let initialPeriod = MedicationPeriod(
            dosage: trimmedDosage,
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

        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        let trimmedSchedule = scheduleInput.trimmingCharacters(in: .whitespaces)
        let trimmedDosage = dosageInput.trimmingCharacters(in: .whitespaces)

        medication.name = trimmedName
        medication.isDiuretic = isDiuretic

        // Use updateDosage to track dosage changes as periods
        medication.updateDosage(
            newDosage: trimmedDosage,
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
        reactivateDosageInput = medication.dosage
        reactivateSelectedUnit = medication.unit
        reactivateScheduleInput = medication.schedule
        showingPriorMedicationDetail = true
    }

    /// Reactivate a prior medication
    func reactivateMedication(context: ModelContext) {
        guard let medication = selectedPriorMedication else { return }

        let trimmedDosage = reactivateDosageInput.trimmingCharacters(in: .whitespaces)
        guard isValidReactivationDosage else {
            validationError = "Please enter a valid dosage (e.g., 50 or 49/51)"
            return
        }

        medication.reactivate(
            dosage: trimmedDosage,
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

    /// Validates if reactivateDosageInput is a valid dosage
    private var isValidReactivationDosage: Bool {
        let trimmed = reactivateDosageInput.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return false }

        // Check for combination dosage (e.g., "49/51")
        if trimmed.contains("/") {
            let parts = trimmed.split(separator: "/")
            return parts.count == 2 &&
                   parts.allSatisfy { Double($0) != nil && Double($0)! > 0 }
        }

        // Check for simple numeric dosage
        if let value = Double(trimmed) {
            return value > 0
        }

        return false
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

    /// Check for conflicts and avoid warnings before saving.
    /// Priority: 1) Drug conflicts, 2) Avoid warnings, 3) Save directly
    func checkAndSaveMedication(context: ModelContext) {
        guard validateForm() else { return }

        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        let trimmedDosage = dosageInput.trimmingCharacters(in: .whitespaces)
        let trimmedSchedule = scheduleInput.trimmingCharacters(in: .whitespaces)

        // Auto-detect if medication is a diuretic
        let detectedDiuretic = selectedPresetMedication?.isDiuretic
            ?? selectedOtherMedication?.isDiuretic
            ?? HeartFailureMedication.isDiuretic(medicationName: trimmedName)
            || OtherMedication.knownDiureticNames.contains(trimmedName.lowercased())

        let categoryRawValue = selectedPresetMedication?.category.rawValue

        // 1) Check for drug-drug conflicts (only for HF medications with known category)
        if let category = selectedPresetMedication?.category {
            let conflicts = conflictService.checkConflicts(
                newCategory: category,
                existingMedications: medications
            )

            if !conflicts.isEmpty {
                pendingConflictMedication = Medication(
                    name: trimmedName,
                    dosage: trimmedDosage,
                    unit: selectedUnit,
                    schedule: trimmedSchedule,
                    isDiuretic: detectedDiuretic,
                    categoryRawValue: categoryRawValue
                )

                conflictWarningMessage = conflicts.first?.message ?? "A potential conflict was detected."
                showingConflictWarning = true
                return
            }
        }

        // 2) Check if medication is on the "avoid" list for heart failure patients
        if let avoidWarning = avoidService.checkIfShouldAvoid(medicationName: trimmedName) {
            pendingAvoidMedication = Medication(
                name: trimmedName,
                dosage: trimmedDosage,
                unit: selectedUnit,
                schedule: trimmedSchedule,
                isDiuretic: detectedDiuretic,
                categoryRawValue: categoryRawValue
            )

            avoidWarningMessage = avoidWarning.message
            avoidWarningCategory = avoidWarning.category.displayName
            showingAvoidWarning = true
            return
        }

        // 3) No warnings, save directly
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

    // MARK: - Avoid Warning Methods

    /// Save medication despite it being on the "avoid" list
    func confirmAddDespiteAvoidWarning(context: ModelContext) {
        guard let medication = pendingAvoidMedication else { return }

        // Create initial period for tracking history
        let initialPeriod = MedicationPeriod(
            dosage: medication.dosage,
            unit: medication.unit,
            schedule: medication.schedule,
            startDate: Date()
        )
        medication.periods = [initialPeriod]

        context.insert(medication)

        do {
            try context.save()
            loadMedications(context: context)
            refreshConflicts()
            medicationSavedMessage = "\(medication.name) added"
            pendingAvoidMedication = nil
            showingAvoidWarning = false
            resetForm()
        } catch {
            validationError = "Could not save medication. Please try again."
        }
    }

    /// Cancel adding the avoid-list medication
    func cancelAvoidAdd() {
        pendingAvoidMedication = nil
        showingAvoidWarning = false
        avoidWarningMessage = ""
        avoidWarningCategory = ""
    }

    /// Check if a specific medication is on the "avoid" list (for showing caution badge)
    func shouldShowCaution(_ medication: Medication) -> Bool {
        avoidService.shouldAvoid(medicationName: medication.name)
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

    // MARK: - Medication History Methods

    /// Load the complete medication timeline
    func loadTimeline(context: ModelContext) {
        timelineEvents = historyService.getMedicationTimeline(context: context)
    }

    /// Load regimen for the selected snapshot date
    func loadRegimenForDate(_ date: Date, context: ModelContext) {
        selectedSnapshotDate = date
        snapshotRegimen = historyService.getMedicationRegimen(asOf: date, context: context)
    }

    /// Toggle the history section expansion
    func toggleHistorySection() {
        isHistorySectionExpanded.toggle()
    }

    /// Whether there are any timeline events to show
    var hasTimelineEvents: Bool {
        !timelineEvents.isEmpty
    }

    /// Count of timeline events
    var timelineEventsCount: Int {
        timelineEvents.count
    }

    /// Prepare to show the full history view
    func prepareForHistoryView() {
        showingHistoryView = true
    }
}
