import Foundation

/// Centralized location for all @AppStorage keys.
/// Prevents typos and ensures consistency across ViewModels.
enum AppStorageKeys {
    // MARK: - Onboarding

    /// Whether the user has completed onboarding
    static let hasCompletedOnboarding = "hasCompletedOnboarding"

    // MARK: - Settings

    /// Daily reminder toggle state
    static let reminderEnabled = "reminderEnabled"

    /// Hour component of reminder time (0-23)
    static let reminderHour = "reminderHour"

    /// Minute component of reminder time (0-59)
    static let reminderMinute = "reminderMinute"

    /// Optional patient name/ID for PDF exports
    static let patientIdentifier = "patientIdentifier"

    // MARK: - Units

    /// Weight unit preference ("lbs" or "kg")
    static let weightUnit = "weightUnit"

    // MARK: - Educational Messages

    /// Whether the user has dismissed the vitals educational message
    static let hasSeenVitalsEducationalMessage = "hasSeenVitalsEducationalMessage"
}
