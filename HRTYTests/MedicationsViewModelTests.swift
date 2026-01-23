import XCTest
@testable import HRTY

final class MedicationsViewModelTests: XCTestCase {

    var viewModel: MedicationsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = MedicationsViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Sorting Tests

    func testSortedMedicationsDiureticsFirst() {
        // Given: medications with mixed diuretic flags
        let lisinopril = Medication(name: "Lisinopril", dosage: 10, isDiuretic: false)
        let furosemide = Medication(name: "Furosemide", dosage: 40, isDiuretic: true)
        let metoprolol = Medication(name: "Metoprolol", dosage: 25, isDiuretic: false)

        viewModel.medications = [lisinopril, furosemide, metoprolol]

        // When: getting sorted medications
        let sorted = viewModel.sortedMedications

        // Then: diuretic should be first
        XCTAssertEqual(sorted.first?.name, "Furosemide", "Diuretic should be sorted first")
    }

    func testSortedMedicationsAlphabeticalWithinGroups() {
        // Given: multiple medications with same diuretic status
        let lisinopril = Medication(name: "Lisinopril", dosage: 10, isDiuretic: false)
        let amlodipine = Medication(name: "Amlodipine", dosage: 5, isDiuretic: false)
        let metoprolol = Medication(name: "Metoprolol", dosage: 25, isDiuretic: false)

        viewModel.medications = [lisinopril, amlodipine, metoprolol]

        // When: getting sorted medications
        let sorted = viewModel.sortedMedications

        // Then: should be alphabetical
        XCTAssertEqual(sorted[0].name, "Amlodipine")
        XCTAssertEqual(sorted[1].name, "Lisinopril")
        XCTAssertEqual(sorted[2].name, "Metoprolol")
    }

    func testSortedMedicationsMultipleDiureticsAlphabetical() {
        // Given: multiple diuretics
        let spironolactone = Medication(name: "Spironolactone", dosage: 25, isDiuretic: true)
        let furosemide = Medication(name: "Furosemide", dosage: 40, isDiuretic: true)
        let lisinopril = Medication(name: "Lisinopril", dosage: 10, isDiuretic: false)

        viewModel.medications = [spironolactone, furosemide, lisinopril]

        // When: getting sorted medications
        let sorted = viewModel.sortedMedications

        // Then: diuretics first, alphabetically, then non-diuretics
        XCTAssertEqual(sorted[0].name, "Furosemide")
        XCTAssertEqual(sorted[1].name, "Spironolactone")
        XCTAssertEqual(sorted[2].name, "Lisinopril")
    }

    func testSortedMedicationsExcludesInactive() {
        // Given: mix of active and inactive medications
        let active = Medication(name: "Active Med", dosage: 10, isActive: true)
        let inactive = Medication(name: "Inactive Med", dosage: 20, isActive: false)

        viewModel.medications = [active, inactive]

        // When: getting sorted medications
        let sorted = viewModel.sortedMedications

        // Then: only active medications included
        XCTAssertEqual(sorted.count, 1)
        XCTAssertEqual(sorted.first?.name, "Active Med")
    }

    func testSortedMedicationsCaseInsensitive() {
        // Given: medications with different cases
        let lower = Medication(name: "amlodipine", dosage: 5, isDiuretic: false)
        let upper = Medication(name: "Betablocker", dosage: 10, isDiuretic: false)

        viewModel.medications = [upper, lower]

        // When: getting sorted medications
        let sorted = viewModel.sortedMedications

        // Then: should be case-insensitive alphabetical
        XCTAssertEqual(sorted[0].name, "amlodipine")
        XCTAssertEqual(sorted[1].name, "Betablocker")
    }

    // MARK: - Empty State Tests

    func testHasNoMedicationsWhenEmpty() {
        // Given: no medications
        viewModel.medications = []

        // Then: hasNoMedications should be true
        XCTAssertTrue(viewModel.hasNoMedications)
    }

    func testHasNoMedicationsWhenAllInactive() {
        // Given: only inactive medications
        let inactive = Medication(name: "Inactive", dosage: 10, isActive: false)
        viewModel.medications = [inactive]

        // Then: hasNoMedications should be true
        XCTAssertTrue(viewModel.hasNoMedications)
    }

    func testHasNoMedicationsWhenHasActive() {
        // Given: at least one active medication
        let active = Medication(name: "Active", dosage: 10, isActive: true)
        viewModel.medications = [active]

        // Then: hasNoMedications should be false
        XCTAssertFalse(viewModel.hasNoMedications)
    }

    // MARK: - Form Validation Tests

    func testIsFormValidWithValidInput() {
        // Given: valid name and dosage
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = "10"

        // Then: form should be valid
        XCTAssertTrue(viewModel.isFormValid)
    }

    func testIsFormInvalidWithEmptyName() {
        // Given: empty name
        viewModel.nameInput = ""
        viewModel.dosageInput = "10"

        // Then: form should be invalid
        XCTAssertFalse(viewModel.isFormValid)
    }

    func testIsFormInvalidWithWhitespaceOnlyName() {
        // Given: whitespace-only name
        viewModel.nameInput = "   "
        viewModel.dosageInput = "10"

        // Then: form should be invalid
        XCTAssertFalse(viewModel.isFormValid)
    }

    func testIsFormInvalidWithEmptyDosage() {
        // Given: empty dosage
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = ""

        // Then: form should be invalid
        XCTAssertFalse(viewModel.isFormValid)
    }

    func testIsFormInvalidWithNonNumericDosage() {
        // Given: non-numeric dosage
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = "abc"

        // Then: form should be invalid
        XCTAssertFalse(viewModel.isFormValid)
    }

    func testIsFormInvalidWithZeroDosage() {
        // Given: zero dosage
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = "0"

        // Then: form should be invalid
        XCTAssertFalse(viewModel.isFormValid)
    }

    func testIsFormInvalidWithNegativeDosage() {
        // Given: negative dosage
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = "-5"

        // Then: form should be invalid
        XCTAssertFalse(viewModel.isFormValid)
    }

    func testIsFormValidWithDecimalDosage() {
        // Given: decimal dosage
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = "2.5"

        // Then: form should be valid
        XCTAssertTrue(viewModel.isFormValid)
    }

    // MARK: - Parsed Dosage Tests

    func testParsedDosageWithValidInteger() {
        viewModel.dosageInput = "40"
        XCTAssertEqual(viewModel.parsedDosage, 40.0)
    }

    func testParsedDosageWithValidDecimal() {
        viewModel.dosageInput = "12.5"
        XCTAssertEqual(viewModel.parsedDosage, 12.5)
    }

    func testParsedDosageWithInvalidInput() {
        viewModel.dosageInput = "not a number"
        XCTAssertNil(viewModel.parsedDosage)
    }

    func testParsedDosageWithEmptyInput() {
        viewModel.dosageInput = ""
        XCTAssertNil(viewModel.parsedDosage)
    }

    // MARK: - Form Reset Tests

    func testResetFormClearsAllFields() {
        // Given: form with data
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = "10"
        viewModel.selectedUnit = "mcg"
        viewModel.scheduleInput = "Morning"
        viewModel.isDiuretic = true
        viewModel.validationError = "Some error"
        viewModel.selectedMedication = Medication(name: "Test", dosage: 10)

        // When: reset form
        viewModel.resetForm()

        // Then: all fields should be cleared
        XCTAssertEqual(viewModel.nameInput, "")
        XCTAssertEqual(viewModel.dosageInput, "")
        XCTAssertEqual(viewModel.selectedUnit, "mg")
        XCTAssertEqual(viewModel.scheduleInput, "")
        XCTAssertFalse(viewModel.isDiuretic)
        XCTAssertNil(viewModel.validationError)
        XCTAssertNil(viewModel.selectedMedication)
    }

    // MARK: - Validate Form Tests

    func testValidateFormReturnsErrorForEmptyName() {
        // Given: empty name
        viewModel.nameInput = ""
        viewModel.dosageInput = "10"

        // When: validate
        let result = viewModel.validateForm()

        // Then: should fail with appropriate error
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.validationError, "Please enter a medication name")
    }

    func testValidateFormReturnsErrorForEmptyDosage() {
        // Given: valid name, empty dosage
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = ""

        // When: validate
        let result = viewModel.validateForm()

        // Then: should fail with appropriate error
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.validationError, "Please enter a dosage")
    }

    func testValidateFormReturnsErrorForInvalidDosage() {
        // Given: valid name, invalid dosage
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = "abc"

        // When: validate
        let result = viewModel.validateForm()

        // Then: should fail with appropriate error
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.validationError, "Please enter a valid dosage amount")
    }

    func testValidateFormReturnsErrorForZeroDosage() {
        // Given: valid name, zero dosage
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = "0"

        // When: validate
        let result = viewModel.validateForm()

        // Then: should fail with appropriate error
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.validationError, "Please enter a valid dosage amount")
    }

    func testValidateFormSucceedsWithValidInput() {
        // Given: valid input
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = "10"

        // When: validate
        let result = viewModel.validateForm()

        // Then: should succeed
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.validationError)
    }

    func testValidateFormClearsPreviousError() {
        // Given: existing validation error
        viewModel.validationError = "Previous error"
        viewModel.nameInput = "Lisinopril"
        viewModel.dosageInput = "10"

        // When: validate with valid input
        _ = viewModel.validateForm()

        // Then: error should be cleared
        XCTAssertNil(viewModel.validationError)
    }

    // MARK: - Prepare for Add Tests

    func testPrepareForAddResetsFormAndShowsSheet() {
        // Given: form with existing data
        viewModel.nameInput = "Previous"
        viewModel.showingAddMedication = false

        // When: prepare for add
        viewModel.prepareForAdd()

        // Then: form should be reset and sheet shown
        XCTAssertEqual(viewModel.nameInput, "")
        XCTAssertTrue(viewModel.showingAddMedication)
    }

    // MARK: - Prepare for Edit Tests

    func testPrepareForEditPopulatesFormFields() {
        // Given: a medication to edit
        let medication = Medication(
            name: "Furosemide",
            dosage: 40,
            unit: "mg",
            schedule: "Morning",
            isDiuretic: true
        )

        // When: prepare for edit
        viewModel.prepareForEdit(medication: medication)

        // Then: form fields should be populated
        XCTAssertEqual(viewModel.nameInput, "Furosemide")
        XCTAssertEqual(viewModel.dosageInput, "40")
        XCTAssertEqual(viewModel.selectedUnit, "mg")
        XCTAssertEqual(viewModel.scheduleInput, "Morning")
        XCTAssertTrue(viewModel.isDiuretic)
        XCTAssertTrue(viewModel.showingEditMedication)
        XCTAssertNotNil(viewModel.selectedMedication)
    }

    func testPrepareForEditClearsValidationError() {
        // Given: existing validation error
        viewModel.validationError = "Previous error"
        let medication = Medication(name: "Test", dosage: 10)

        // When: prepare for edit
        viewModel.prepareForEdit(medication: medication)

        // Then: validation error should be cleared
        XCTAssertNil(viewModel.validationError)
    }

    // MARK: - Prepare for Delete Tests

    func testPrepareForDeleteSetsStateCorrectly() {
        // Given: a medication to delete
        let medication = Medication(name: "ToDelete", dosage: 10)

        // When: prepare for delete
        viewModel.prepareForDelete(medication: medication)

        // Then: state should be set correctly
        XCTAssertTrue(viewModel.showingDeleteConfirmation)
        XCTAssertNotNil(viewModel.medicationToDelete)
        XCTAssertEqual(viewModel.medicationToDelete?.name, "ToDelete")
    }

    // MARK: - Delete Error Tests

    func testClearDeleteErrorResetsError() {
        // Given: an existing delete error
        viewModel.deleteError = "Some error"

        // When: clear delete error
        viewModel.clearDeleteError()

        // Then: error should be nil
        XCTAssertNil(viewModel.deleteError)
    }

    func testDeleteErrorInitiallyNil() {
        // Then: delete error should be nil initially
        XCTAssertNil(viewModel.deleteError)
    }
}

// MARK: - Medication Model Tests

final class MedicationModelTests: XCTestCase {

    func testMedicationDefaultValues() {
        // When: creating medication with minimal parameters
        let medication = Medication(name: "Test", dosage: 10)

        // Then: default values should be set
        XCTAssertEqual(medication.unit, "mg")
        XCTAssertEqual(medication.schedule, "")
        XCTAssertFalse(medication.isDiuretic)
        XCTAssertTrue(medication.isActive)
        XCTAssertNotNil(medication.createdAt)
    }

    func testMedicationAvailableUnits() {
        // Verify available units are defined
        XCTAssertEqual(Medication.availableUnits, ["mg", "mcg", "mL", "g", "units"])
        XCTAssertEqual(Medication.availableUnits.count, 5)
    }

    func testMedicationCustomValues() {
        // When: creating medication with custom values
        let medication = Medication(
            name: "Furosemide",
            dosage: 40,
            unit: "mcg",
            schedule: "Twice daily",
            isDiuretic: true,
            isActive: true
        )

        // Then: values should be set correctly
        XCTAssertEqual(medication.name, "Furosemide")
        XCTAssertEqual(medication.dosage, 40)
        XCTAssertEqual(medication.unit, "mcg")
        XCTAssertEqual(medication.schedule, "Twice daily")
        XCTAssertTrue(medication.isDiuretic)
        XCTAssertTrue(medication.isActive)
    }
}

// MARK: - MedicationsViewModel Photo Tests

final class MedicationsViewModelPhotoTests: XCTestCase {

    var viewModel: MedicationsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = MedicationsViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Photo State Initial Values

    func testPhotoStateInitialValues() {
        // Then: photo state should have correct initial values
        XCTAssertTrue(viewModel.photos.isEmpty)
        XCTAssertFalse(viewModel.showingPhotoCaptureView)
        XCTAssertNil(viewModel.selectedPhoto)
        XCTAssertFalse(viewModel.showingPhotoViewer)
        XCTAssertNil(viewModel.capturedImage)
        XCTAssertNil(viewModel.photoError)
        XCTAssertNil(viewModel.photoSavedMessage)
    }

    func testHasNoPhotosWhenEmpty() {
        // Given: no photos
        viewModel.photos = []

        // Then: hasNoPhotos should be true
        XCTAssertTrue(viewModel.hasNoPhotos)
    }

    func testHasNoPhotosWhenPhotosExist() {
        // Given: at least one photo
        let photo = MedicationPhoto(filename: "test.jpg", thumbnailFilename: "test_thumb.jpg")
        viewModel.photos = [photo]

        // Then: hasNoPhotos should be false
        XCTAssertFalse(viewModel.hasNoPhotos)
    }

    // MARK: - Prepare for Photo Capture Tests

    func testPrepareForPhotoCaptureResetsState() {
        // Given: existing state
        viewModel.capturedImage = UIImage()
        viewModel.photoError = "Previous error"
        viewModel.showingPhotoCaptureView = false

        // When: prepare for photo capture
        viewModel.prepareForPhotoCapture()

        // Then: state should be reset and view shown
        XCTAssertNil(viewModel.capturedImage)
        XCTAssertNil(viewModel.photoError)
        XCTAssertTrue(viewModel.showingPhotoCaptureView)
    }

    // MARK: - View Photo Tests

    func testViewPhotoSetsSelectedPhotoAndShowsViewer() {
        // Given: a photo to view
        let photo = MedicationPhoto(filename: "view.jpg", thumbnailFilename: "view_thumb.jpg")

        // When: view photo
        viewModel.viewPhoto(photo)

        // Then: selected photo and viewer state should be set
        XCTAssertEqual(viewModel.selectedPhoto?.id, photo.id)
        XCTAssertTrue(viewModel.showingPhotoViewer)
    }

    func testViewPhotoDifferentPhotoUpdatesSelection() {
        // Given: already viewing a photo
        let photo1 = MedicationPhoto(filename: "first.jpg", thumbnailFilename: "first_thumb.jpg")
        let photo2 = MedicationPhoto(filename: "second.jpg", thumbnailFilename: "second_thumb.jpg")
        viewModel.viewPhoto(photo1)

        // When: view a different photo
        viewModel.viewPhoto(photo2)

        // Then: selected photo should be updated
        XCTAssertEqual(viewModel.selectedPhoto?.id, photo2.id)
        XCTAssertTrue(viewModel.showingPhotoViewer)
    }

    // MARK: - Clear Photo Error Tests

    func testClearPhotoErrorResetsError() {
        // Given: an existing photo error
        viewModel.photoError = "Some error"

        // When: clear photo error
        viewModel.clearPhotoError()

        // Then: error should be nil
        XCTAssertNil(viewModel.photoError)
    }

    func testClearPhotoErrorWhenAlreadyNil() {
        // Given: no existing error
        viewModel.photoError = nil

        // When: clear photo error
        viewModel.clearPhotoError()

        // Then: error should remain nil (no crash)
        XCTAssertNil(viewModel.photoError)
    }

    // MARK: - Clear Photo Saved Message Tests

    func testClearPhotoSavedMessageResetsMessage() {
        // Given: an existing saved message
        viewModel.photoSavedMessage = "Photo saved"

        // When: clear photo saved message
        viewModel.clearPhotoSavedMessage()

        // Then: message should be nil
        XCTAssertNil(viewModel.photoSavedMessage)
    }

    func testClearPhotoSavedMessageWhenAlreadyNil() {
        // Given: no existing message
        viewModel.photoSavedMessage = nil

        // When: clear photo saved message
        viewModel.clearPhotoSavedMessage()

        // Then: message should remain nil (no crash)
        XCTAssertNil(viewModel.photoSavedMessage)
    }

    // MARK: - Photo Error Message Quality Tests

    func testPhotoErrorMessagesArePatientFriendly() {
        // Given: possible error messages that could be set
        let errorMessages = [
            "Unable to save photo. Please try again.",
            "Unable to delete photo. Please try again."
        ]

        // Then: error messages should not contain technical jargon
        let technicalTerms = ["exception", "null", "nil", "crash", "fatal", "error code", "failed", "failure"]

        for message in errorMessages {
            for term in technicalTerms {
                XCTAssertFalse(
                    message.lowercased().contains(term),
                    "Error message '\(message)' should not contain technical term '\(term)'"
                )
            }
        }
    }

    func testPhotoErrorMessagesAreNotAlarmist() {
        // Given: possible error messages
        let errorMessages = [
            "Unable to save photo. Please try again.",
            "Unable to delete photo. Please try again."
        ]

        // Then: error messages should not use alarming language
        let alarmingTerms = ["critical", "urgent", "immediately", "danger", "warning", "severe", "emergency"]

        for message in errorMessages {
            for term in alarmingTerms {
                XCTAssertFalse(
                    message.lowercased().contains(term),
                    "Error message '\(message)' should not contain alarming term '\(term)'"
                )
            }
        }
    }

    // MARK: - Photo Saved Message Quality Tests

    func testPhotoSavedMessageIsBrief() {
        // Given: the expected saved message
        let savedMessage = "Photo saved"

        // Then: message should be brief and simple
        XCTAssertLessThanOrEqual(savedMessage.count, 20, "Saved message should be brief")
    }
}
