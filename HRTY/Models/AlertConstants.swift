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

    // MARK: - Heart Rate Alert Thresholds

    /// Heart rate below this value triggers low heart rate alert (bpm)
    static let heartRateLowThreshold: Int = 40

    /// Heart rate above this value triggers high heart rate alert (bpm)
    static let heartRateHighThreshold: Int = 120

    // MARK: - Heart Rate Validation Bounds

    /// Minimum valid heart rate entry (bpm)
    static let minimumHeartRate: Int = 30

    /// Maximum valid heart rate entry (bpm)
    static let maximumHeartRate: Int = 250

    // MARK: - Symptom Alert Thresholds

    /// Symptom severity at or above this level triggers severe symptom alert
    static let severeSymptomThreshold: Int = 4

    /// Dizziness severity at or above this level triggers BP check prompt
    static let dizzinessBPPromptThreshold: Int = 3

    /// Hours to look back for recent blood pressure readings
    static let bloodPressureLookbackHours: Int = 24

    // MARK: - Weight Display Thresholds

    /// Minimum weight change (in lbs) to be considered "up" or "down" rather than "stable"
    /// Changes smaller than this are treated as normal daily fluctuation
    static let weightStabilityThreshold: Double = 0.05

    // MARK: - Display Thresholds (for visual indicators)
    // These define when values should show caution (yellow) or critical (red) styling

    // Oxygen Saturation Display Thresholds
    /// SpO2 above this is normal (no styling change)
    static let oxygenSaturationNormalThreshold: Int = 92
    /// SpO2 below this is critical (red + bold); between this and normal is caution
    static let oxygenSaturationCriticalThreshold: Int = 88

    // Heart Rate Display Thresholds
    /// Heart rate at or above this is normal (no styling change)
    static let heartRateNormalLow: Int = 60
    /// Heart rate at or below this is normal (no styling change)
    static let heartRateNormalHigh: Int = 100
    /// Heart rate below this is critical (red + bold); between this and normalLow is caution
    static let heartRateCriticalLow: Int = 40
    /// Heart rate above this is critical (red + bold); between normalHigh and this is caution
    static let heartRateCriticalHigh: Int = 120

    // Systolic Blood Pressure Display Thresholds
    /// Systolic at or above this is normal (no styling change)
    static let systolicBPNormalLow: Int = 90
    /// Systolic at or below this is normal (no styling change)
    static let systolicBPNormalHigh: Int = 139
    /// Systolic below this is critical (red + bold); between this and normalLow is caution
    static let systolicBPCriticalLow: Int = 80
    /// Systolic at or above this is critical (red + bold); between normalHigh and this is caution
    static let systolicBPCriticalHigh: Int = 160

    // Diastolic Blood Pressure Display Thresholds
    /// Diastolic at or above this is normal (no styling change)
    static let diastolicBPNormalLow: Int = 60
    /// Diastolic at or below this is normal (no styling change)
    static let diastolicBPNormalHigh: Int = 89
    /// Diastolic below this is critical (red + bold); between this and normalLow is caution
    static let diastolicBPCriticalLow: Int = 50
    /// Diastolic at or above this is critical (red + bold); between normalHigh and this is caution
    static let diastolicBPCriticalHigh: Int = 100

    // Weight Gain Display Thresholds (uses existing weightGain24hThreshold and weightGain7dThreshold)
    // 2-4.9 lbs gain = caution, ≥5 lbs gain = critical

    // MARK: - Vital Signs Alert Thresholds

    /// Oxygen saturation below this value triggers low SpO2 alert (%)
    static let oxygenSaturationLowThreshold: Int = 90

    /// Systolic blood pressure below this value triggers low BP alert (mmHg)
    static let systolicBPLowThreshold: Int = 90

    /// Mean Arterial Pressure below this value triggers low MAP alert (mmHg)
    static let mapLowThreshold: Int = 60

    // MARK: - Vital Signs Validation Bounds

    /// Minimum valid oxygen saturation (%)
    static let minimumOxygenSaturation: Int = 70

    /// Maximum valid oxygen saturation (%)
    static let maximumOxygenSaturation: Int = 100

    /// Minimum valid systolic blood pressure (mmHg)
    static let minimumSystolicBP: Int = 60

    /// Maximum valid systolic blood pressure (mmHg)
    static let maximumSystolicBP: Int = 250

    /// Minimum valid diastolic blood pressure (mmHg)
    static let minimumDiastolicBP: Int = 40

    /// Maximum valid diastolic blood pressure (mmHg)
    static let maximumDiastolicBP: Int = 150
}
