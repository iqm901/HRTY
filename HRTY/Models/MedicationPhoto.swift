import Foundation

/// Represents a medication reference photo stored on device.
/// Photos are stored as files in the documents directory, not in SwiftData,
/// since they are for reference only and don't require complex querying.
/// Conforms to Codable to support metadata persistence and potential future export.
struct MedicationPhoto: Identifiable, Equatable, Codable {
    /// Unique identifier for the photo
    let id: UUID

    /// Filename of the full-size photo (e.g., "uuid.jpg")
    let filename: String

    /// Filename of the thumbnail (e.g., "uuid_thumb.jpg")
    let thumbnailFilename: String

    /// When the photo was captured
    let capturedAt: Date

    /// Creates a new MedicationPhoto
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - filename: The photo filename
    ///   - thumbnailFilename: The thumbnail filename
    ///   - capturedAt: Capture timestamp (defaults to now)
    init(
        id: UUID = UUID(),
        filename: String,
        thumbnailFilename: String,
        capturedAt: Date = Date()
    ) {
        self.id = id
        self.filename = filename
        self.thumbnailFilename = thumbnailFilename
        self.capturedAt = capturedAt
    }
}
