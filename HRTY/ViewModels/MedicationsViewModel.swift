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

    // MARK: - Validation & Errors
    var validationError: String?
    var deleteError: String?

    // MARK: - Services
    private let photoService = PhotoService.shared

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
        let descriptor = FetchDescriptor<Medication>(
            predicate: #Predicate { $0.isActive == true },
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            medications = try context.fetch(descriptor)
        } catch {
            medications = []
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
            isDiuretic: isDiuretic
        )

        context.insert(medication)

        do {
            try context.save()
            loadMedications(context: context)
            showingAddMedication = false
            resetForm()
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
}
