import Foundation

/// Centralized location for all clinical alert thresholds.
/// These values are used across the app for triggering patient alerts.
/// Per CLAUDE.md: "All clinical thresholds defined as constants in a single location"
enum AlertConstants {
    // MARK: - Weight Alert Thresholds

    /// Weight gain threshold for 24-hour alert (in lbs)
    /// Triggers when: current weight - yesterday's weight >= this value
    static let weightGain24hThreshold: Double = 2.0

    /// Weight gain threshold for 7-day alert (in lbs)
    /// Triggers when: current weight - baseline weight (7 days ago) >= this value
    static let weightGain7dThreshold: Double = 5.0

    // MARK: - Weight Validation Bounds

    /// Minimum valid weight entry (in lbs)
    static let minimumWeight: Double = 50.0

    /// Maximum valid weight entry (in lbs)
    static let maximumWeight: Double = 500.0

    // MARK: - Heart Rate Alert Thresholds (for future use)

    /// Heart rate below this value triggers low heart rate alert (bpm)
    static let heartRateLowThreshold: Int = 40

    /// Heart rate above this value triggers high heart rate alert (bpm)
    static let heartRateHighThreshold: Int = 120

    // MARK: - Symptom Alert Thresholds

    /// Symptom severity at or above this level triggers severe symptom alert
    static let severeSymptomThreshold: Int = 4

    // MARK: - Weight Display Thresholds

    /// Minimum weight change (in lbs) to be considered "up" or "down" rather than "stable"
    /// Changes smaller than this are treated as normal daily fluctuation
    static let weightStabilityThreshold: Double = 0.05
}
