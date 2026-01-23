import Foundation
import UIKit
import AVFoundation

/// Protocol for photo service operations - enables dependency injection and testing
protocol PhotoServiceProtocol {
    var authorizationStatus: AVAuthorizationStatus { get }
    func requestCameraPermission() async -> Bool
    func savePhoto(_ image: UIImage) async throws -> MedicationPhoto
    func loadPhotos() -> [MedicationPhoto]
    func loadThumbnail(for photo: MedicationPhoto) -> UIImage?
    func loadFullImage(for photo: MedicationPhoto) -> UIImage?
    func deletePhoto(_ photo: MedicationPhoto) throws
}

/// Errors that can occur during photo operations
enum PhotoServiceError: LocalizedError {
    case saveFailed
    case thumbnailGenerationFailed
    case photoNotFound
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Unable to save photo. Please try again."
        case .thumbnailGenerationFailed:
            return "Unable to create thumbnail."
        case .photoNotFound:
            return "Photo not found."
        case .deleteFailed:
            return "Unable to delete photo. Please try again."
        }
    }
}

/// Service for managing medication reference photos.
/// Handles camera permissions, photo storage, and thumbnail generation.
@Observable
final class PhotoService: PhotoServiceProtocol {

    // MARK: - Singleton

    static let shared = PhotoService()

    // MARK: - Properties

    /// Current camera authorization status
    private(set) var authorizationStatus: AVAuthorizationStatus = .notDetermined

    /// Directory for storing photos
    private let photosDirectoryName = "MedicationPhotos"
    private let thumbnailsDirectoryName = "Thumbnails"

    /// Thumbnail size
    private let thumbnailSize = CGSize(width: 150, height: 150)

    // MARK: - Initialization

    private init() {
        refreshAuthorizationStatus()
        createDirectoriesIfNeeded()
    }

    // MARK: - Permission Management

    /// Refreshes the current camera authorization status
    private func refreshAuthorizationStatus() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    /// Requests camera permission from the user.
    /// - Returns: `true` if permission was granted, `false` otherwise.
    @MainActor
    func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            authorizationStatus = .authorized
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            refreshAuthorizationStatus()
            return granted
        case .denied, .restricted:
            authorizationStatus = status
            return false
        @unknown default:
            return false
        }
    }

    /// Whether camera access is authorized
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    /// Whether permission has been determined
    var isPermissionDetermined: Bool {
        authorizationStatus != .notDetermined
    }

    // MARK: - Directory Management

    private var photosDirectory: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent(photosDirectoryName)
    }

    private var thumbnailsDirectory: URL {
        return photosDirectory.appendingPathComponent(thumbnailsDirectoryName)
    }

    private func createDirectoriesIfNeeded() {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: photosDirectory.path) {
            try? fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        }

        if !fileManager.fileExists(atPath: thumbnailsDirectory.path) {
            try? fileManager.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Photo Storage

    /// Saves a photo to the documents directory with thumbnail.
    /// - Parameter image: The image to save
    /// - Returns: The saved MedicationPhoto
    func savePhoto(_ image: UIImage) async throws -> MedicationPhoto {
        let photoId = UUID()
        let filename = "\(photoId.uuidString).jpg"
        let thumbnailFilename = "\(photoId.uuidString)_thumb.jpg"

        let photoURL = photosDirectory.appendingPathComponent(filename)
        let thumbnailURL = thumbnailsDirectory.appendingPathComponent(thumbnailFilename)

        // Save full-size image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw PhotoServiceError.saveFailed
        }

        do {
            try imageData.write(to: photoURL)
        } catch {
            throw PhotoServiceError.saveFailed
        }

        // Generate and save thumbnail
        if let thumbnail = generateThumbnail(from: image),
           let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) {
            try? thumbnailData.write(to: thumbnailURL)
        }

        return MedicationPhoto(
            id: photoId,
            filename: filename,
            thumbnailFilename: thumbnailFilename,
            capturedAt: Date()
        )
    }

    /// Loads all saved medication photos
    /// - Returns: Array of MedicationPhoto objects
    func loadPhotos() -> [MedicationPhoto] {
        let fileManager = FileManager.default

        guard let contents = try? fileManager.contentsOfDirectory(
            at: photosDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else {
            return []
        }

        return contents
            .filter { $0.pathExtension == "jpg" && !$0.lastPathComponent.contains("_thumb") }
            .compactMap { url -> MedicationPhoto? in
                let filename = url.lastPathComponent
                let idString = filename.replacingOccurrences(of: ".jpg", with: "")
                guard let id = UUID(uuidString: idString) else { return nil }

                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let creationDate = attributes?[.creationDate] as? Date ?? Date()

                return MedicationPhoto(
                    id: id,
                    filename: filename,
                    thumbnailFilename: "\(idString)_thumb.jpg",
                    capturedAt: creationDate
                )
            }
            .sorted { $0.capturedAt > $1.capturedAt }
    }

    /// Loads the thumbnail image for a photo
    /// - Parameter photo: The MedicationPhoto
    /// - Returns: The thumbnail UIImage or nil
    func loadThumbnail(for photo: MedicationPhoto) -> UIImage? {
        let thumbnailURL = thumbnailsDirectory.appendingPathComponent(photo.thumbnailFilename)

        if let data = try? Data(contentsOf: thumbnailURL),
           let image = UIImage(data: data) {
            return image
        }

        // Fallback to full image if thumbnail doesn't exist
        return loadFullImage(for: photo)
    }

    /// Loads the full-size image for a photo
    /// - Parameter photo: The MedicationPhoto
    /// - Returns: The full-size UIImage or nil
    func loadFullImage(for photo: MedicationPhoto) -> UIImage? {
        let photoURL = photosDirectory.appendingPathComponent(photo.filename)

        guard let data = try? Data(contentsOf: photoURL),
              let image = UIImage(data: data) else {
            return nil
        }

        return image
    }

    /// Deletes a photo and its thumbnail
    /// - Parameter photo: The MedicationPhoto to delete
    func deletePhoto(_ photo: MedicationPhoto) throws {
        let fileManager = FileManager.default
        let photoURL = photosDirectory.appendingPathComponent(photo.filename)
        let thumbnailURL = thumbnailsDirectory.appendingPathComponent(photo.thumbnailFilename)

        do {
            if fileManager.fileExists(atPath: photoURL.path) {
                try fileManager.removeItem(at: photoURL)
            }
            if fileManager.fileExists(atPath: thumbnailURL.path) {
                try fileManager.removeItem(at: thumbnailURL)
            }
        } catch {
            throw PhotoServiceError.deleteFailed
        }
    }

    // MARK: - Thumbnail Generation

    private func generateThumbnail(from image: UIImage) -> UIImage? {
        // Guard against invalid image dimensions to prevent division by zero
        guard image.size.width > 0, image.size.height > 0 else {
            return nil
        }

        let aspectRatio = image.size.width / image.size.height
        var newSize: CGSize

        if aspectRatio > 1 {
            // Landscape
            newSize = CGSize(width: thumbnailSize.width, height: thumbnailSize.width / aspectRatio)
        } else {
            // Portrait or square
            newSize = CGSize(width: thumbnailSize.height * aspectRatio, height: thumbnailSize.height)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
