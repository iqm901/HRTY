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

    // MARK: - Medication Conflicts

    /// Timestamp when the conflict banner was last dismissed
    static let conflictBannerDismissedAt = "conflictBannerDismissedAt"
}
