import Foundation
import SwiftData

/// Stores daily vital sign readings including blood pressure and oxygen saturation.
/// One VitalSignsEntry per day, linked to DailyEntry.
@Model
final class VitalSignsEntry {
    /// Systolic blood pressure in mmHg (the top number)
    var systolicBP: Int?

    /// Diastolic blood pressure in mmHg (the bottom number)
    var diastolicBP: Int?

    /// Timestamp of the blood pressure reading
    var bloodPressureTimestamp: Date?

    /// Oxygen saturation percentage (SpO2), typically 95-100%
    var oxygenSaturation: Int?

    /// Timestamp of the oxygen saturation reading
    var oxygenSaturationTimestamp: Date?

    /// Reference to the daily entry this vital signs record belongs to
    @Relationship
    var dailyEntry: DailyEntry?

    /// When this record was created
    var createdAt: Date

    /// When this record was last updated
    var updatedAt: Date

    init(
        systolicBP: Int? = nil,
        diastolicBP: Int? = nil,
        bloodPressureTimestamp: Date? = nil,
        oxygenSaturation: Int? = nil,
        oxygenSaturationTimestamp: Date? = nil,
        dailyEntry: DailyEntry? = nil
    ) {
        self.systolicBP = systolicBP
        self.diastolicBP = diastolicBP
        self.bloodPressureTimestamp = bloodPressureTimestamp
        self.oxygenSaturation = oxygenSaturation
        self.oxygenSaturationTimestamp = oxygenSaturationTimestamp
        self.dailyEntry = dailyEntry
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// Mean Arterial Pressure (MAP) calculated from systolic and diastolic
    /// Formula: MAP = DBP + (SBP - DBP) / 3
    var meanArterialPressure: Int? {
        guard let systolic = systolicBP, let diastolic = diastolicBP else {
            return nil
        }
        return diastolic + (systolic - diastolic) / 3
    }

    /// Formatted blood pressure string (e.g., "120/80")
    var formattedBloodPressure: String? {
        guard let systolic = systolicBP, let diastolic = diastolicBP else {
            return nil
        }
        return "\(systolic)/\(diastolic)"
    }

    /// Whether blood pressure has been recorded
    var hasBloodPressure: Bool {
        systolicBP != nil && diastolicBP != nil
    }

    /// Whether oxygen saturation has been recorded
    var hasOxygenSaturation: Bool {
        oxygenSaturation != nil
    }
}
