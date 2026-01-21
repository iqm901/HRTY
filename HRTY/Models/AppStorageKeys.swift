import Foundation

/// Centralized location for all @AppStorage keys.
/// Prevents typos and ensures consistency across ViewModels.
enum AppStorageKeys {
    // MARK: - Settings

    /// Daily reminder toggle state
    static let reminderEnabled = "reminderEnabled"

    /// Hour component of reminder time (0-23)
    static let reminderHour = "reminderHour"

    /// Minute component of reminder time (0-59)
    static let reminderMinute = "reminderMinute"

    /// Optional patient name/ID for PDF exports
    static let patientIdentifier = "patientIdentifier"
}
