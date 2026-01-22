import XCTest
@testable import HRTY

// MARK: - MedicationPhoto Model Tests

final class MedicationPhotoTests: XCTestCase {

    // MARK: - Initialization Tests

    func testMedicationPhotoInitializationWithDefaults() {
        // When: creating a photo with minimal parameters
        let photo = MedicationPhoto(
            filename: "test.jpg",
            thumbnailFilename: "test_thumb.jpg"
        )

        // Then: defaults should be set correctly
        XCTAssertNotNil(photo.id, "Photo should have a UUID")
        XCTAssertEqual(photo.filename, "test.jpg")
        XCTAssertEqual(photo.thumbnailFilename, "test_thumb.jpg")
        XCTAssertNotNil(photo.capturedAt, "Photo should have a capture date")
    }

    func testMedicationPhotoInitializationWithCustomValues() {
        // Given: custom values
        let customId = UUID()
        let customDate = Date(timeIntervalSince1970: 1000000)

        // When: creating a photo with custom values
        let photo = MedicationPhoto(
            id: customId,
            filename: "custom.jpg",
            thumbnailFilename: "custom_thumb.jpg",
            capturedAt: customDate
        )

        // Then: custom values should be used
        XCTAssertEqual(photo.id, customId)
        XCTAssertEqual(photo.filename, "custom.jpg")
        XCTAssertEqual(photo.thumbnailFilename, "custom_thumb.jpg")
        XCTAssertEqual(photo.capturedAt, customDate)
    }

    // MARK: - Identifiable Conformance Tests

    func testMedicationPhotoIsIdentifiable() {
        // Given: two photos with different IDs
        let photo1 = MedicationPhoto(filename: "a.jpg", thumbnailFilename: "a_thumb.jpg")
        let photo2 = MedicationPhoto(filename: "b.jpg", thumbnailFilename: "b_thumb.jpg")

        // Then: they should have unique identifiers
        XCTAssertNotEqual(photo1.id, photo2.id, "Different photos should have unique IDs")
    }

    func testMedicationPhotoIdIsStable() {
        // Given: a photo
        let id = UUID()
        let photo = MedicationPhoto(
            id: id,
            filename: "test.jpg",
            thumbnailFilename: "test_thumb.jpg"
        )

        // Then: ID should remain stable
        XCTAssertEqual(photo.id, id)
        XCTAssertEqual(photo.id, id)
    }

    // MARK: - Equatable Conformance Tests

    func testMedicationPhotoEquatableSameValues() {
        // Given: same ID and values
        let id = UUID()
        let date = Date()
        let photo1 = MedicationPhoto(id: id, filename: "test.jpg", thumbnailFilename: "thumb.jpg", capturedAt: date)
        let photo2 = MedicationPhoto(id: id, filename: "test.jpg", thumbnailFilename: "thumb.jpg", capturedAt: date)

        // Then: they should be equal
        XCTAssertEqual(photo1, photo2)
    }

    func testMedicationPhotoEquatableDifferentIds() {
        // Given: different IDs but same other values
        let photo1 = MedicationPhoto(id: UUID(), filename: "test.jpg", thumbnailFilename: "thumb.jpg")
        let photo2 = MedicationPhoto(id: UUID(), filename: "test.jpg", thumbnailFilename: "thumb.jpg")

        // Then: they should not be equal
        XCTAssertNotEqual(photo1, photo2)
    }

    func testMedicationPhotoEquatableDifferentFilenames() {
        // Given: same ID but different filename
        let id = UUID()
        let photo1 = MedicationPhoto(id: id, filename: "a.jpg", thumbnailFilename: "thumb.jpg")
        let photo2 = MedicationPhoto(id: id, filename: "b.jpg", thumbnailFilename: "thumb.jpg")

        // Then: they should not be equal
        XCTAssertNotEqual(photo1, photo2)
    }

    // MARK: - Filename Convention Tests

    func testFilenameFollowsExpectedFormat() {
        // Given: a UUID
        let id = UUID()
        let expectedFilename = "\(id.uuidString).jpg"
        let expectedThumbnail = "\(id.uuidString)_thumb.jpg"

        // When: creating a photo following the convention
        let photo = MedicationPhoto(
            id: id,
            filename: expectedFilename,
            thumbnailFilename: expectedThumbnail
        )

        // Then: filenames should match expected format
        XCTAssertTrue(photo.filename.hasSuffix(".jpg"))
        XCTAssertTrue(photo.thumbnailFilename.contains("_thumb"))
        XCTAssertTrue(photo.thumbnailFilename.hasSuffix(".jpg"))
    }
}

// MARK: - PhotoServiceError Tests

final class PhotoServiceErrorTests: XCTestCase {

    func testSaveFailedErrorDescription() {
        // Given: a save failed error
        let error = PhotoServiceError.saveFailed

        // Then: description should be user-friendly
        XCTAssertEqual(error.errorDescription, "Unable to save photo. Please try again.")
    }

    func testThumbnailGenerationFailedErrorDescription() {
        // Given: a thumbnail generation failed error
        let error = PhotoServiceError.thumbnailGenerationFailed

        // Then: description should be user-friendly
        XCTAssertEqual(error.errorDescription, "Unable to create thumbnail.")
    }

    func testPhotoNotFoundErrorDescription() {
        // Given: a photo not found error
        let error = PhotoServiceError.photoNotFound

        // Then: description should be user-friendly
        XCTAssertEqual(error.errorDescription, "Photo not found.")
    }

    func testDeleteFailedErrorDescription() {
        // Given: a delete failed error
        let error = PhotoServiceError.deleteFailed

        // Then: description should be user-friendly
        XCTAssertEqual(error.errorDescription, "Unable to delete photo. Please try again.")
    }

    func testErrorMessagesArePatientFriendly() {
        // Given: all error types
        let errors: [PhotoServiceError] = [.saveFailed, .thumbnailGenerationFailed, .photoNotFound, .deleteFailed]

        // Then: none should contain technical jargon
        let technicalTerms = ["exception", "null", "nil", "crash", "fatal", "error code"]

        for error in errors {
            guard let description = error.errorDescription else {
                XCTFail("Error should have a description")
                continue
            }

            for term in technicalTerms {
                XCTAssertFalse(
                    description.lowercased().contains(term),
                    "Error message '\(description)' should not contain technical term '\(term)'"
                )
            }
        }
    }

    func testErrorMessagesAreNotAlarmist() {
        // Given: all error types
        let errors: [PhotoServiceError] = [.saveFailed, .thumbnailGenerationFailed, .photoNotFound, .deleteFailed]

        // Then: none should use alarming language
        let alarmingTerms = ["critical", "urgent", "immediately", "danger", "warning", "severe"]

        for error in errors {
            guard let description = error.errorDescription else {
                XCTFail("Error should have a description")
                continue
            }

            for term in alarmingTerms {
                XCTAssertFalse(
                    description.lowercased().contains(term),
                    "Error message '\(description)' should not contain alarming term '\(term)'"
                )
            }
        }
    }
}

// MARK: - PhotoServiceProtocol Tests

final class PhotoServiceProtocolTests: XCTestCase {

    func testPhotoServiceSharedInstanceExists() {
        // Given: the shared instance
        let service = PhotoService.shared

        // Then: it should exist
        XCTAssertNotNil(service)
    }

    func testPhotoServiceConformsToProtocol() {
        // Given: the shared instance
        let service = PhotoService.shared

        // Then: it should conform to PhotoServiceProtocol
        XCTAssertTrue(service is PhotoServiceProtocol)
    }

    func testLoadPhotosReturnsArray() {
        // Given: the photo service
        let service = PhotoService.shared

        // When: loading photos
        let photos = service.loadPhotos()

        // Then: should return an array (may be empty)
        XCTAssertNotNil(photos)
    }

    func testLoadThumbnailReturnsNilForNonexistentPhoto() {
        // Given: a photo that doesn't exist
        let nonexistentPhoto = MedicationPhoto(
            id: UUID(),
            filename: "nonexistent_\(UUID().uuidString).jpg",
            thumbnailFilename: "nonexistent_\(UUID().uuidString)_thumb.jpg"
        )

        // When: trying to load its thumbnail
        let thumbnail = PhotoService.shared.loadThumbnail(for: nonexistentPhoto)

        // Then: should return nil
        XCTAssertNil(thumbnail)
    }

    func testLoadFullImageReturnsNilForNonexistentPhoto() {
        // Given: a photo that doesn't exist
        let nonexistentPhoto = MedicationPhoto(
            id: UUID(),
            filename: "nonexistent_\(UUID().uuidString).jpg",
            thumbnailFilename: "nonexistent_\(UUID().uuidString)_thumb.jpg"
        )

        // When: trying to load its full image
        let fullImage = PhotoService.shared.loadFullImage(for: nonexistentPhoto)

        // Then: should return nil
        XCTAssertNil(fullImage)
    }
}

// MARK: - Photo Gallery Accessibility Tests

final class PhotoGalleryAccessibilityTests: XCTestCase {

    func testPhotoDateFormattingIsAccessible() {
        // Given: a photo with a recent date
        let date = Date() // Use current date to avoid locale-specific year formatting issues
        let photo = MedicationPhoto(
            filename: "test.jpg",
            thumbnailFilename: "test_thumb.jpg",
            capturedAt: date
        )

        // When: formatting for accessibility
        let formattedDate = photo.capturedAt.formatted(date: .abbreviated, time: .shortened)

        // Then: should produce a readable string
        XCTAssertFalse(formattedDate.isEmpty, "Formatted date should not be empty")
        // The formatted string should contain some recognizable date components
        XCTAssertGreaterThan(formattedDate.count, 5, "Formatted date should have meaningful content")
    }

    func testPhotosSortedByDateDescending() {
        // Given: photos with different dates
        let oldDate = Date(timeIntervalSince1970: 1000000)
        let newDate = Date(timeIntervalSince1970: 2000000)

        let oldPhoto = MedicationPhoto(filename: "old.jpg", thumbnailFilename: "old_thumb.jpg", capturedAt: oldDate)
        let newPhoto = MedicationPhoto(filename: "new.jpg", thumbnailFilename: "new_thumb.jpg", capturedAt: newDate)

        // When: sorting by date descending (newest first)
        let sorted = [oldPhoto, newPhoto].sorted { $0.capturedAt > $1.capturedAt }

        // Then: newer photo should be first
        XCTAssertEqual(sorted.first?.filename, "new.jpg")
        XCTAssertEqual(sorted.last?.filename, "old.jpg")
    }
}
