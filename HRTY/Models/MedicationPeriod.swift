import Foundation
import SwiftData

/// Represents a specific dosage period for a medication.
/// Tracks when a medication was taken at a specific dosage, allowing for
/// complete medication history even when dosages change or medications are archived/reactivated.
@Model
final class MedicationPeriod {
    var dosage: String
    var unit: String
    var schedule: String
    var startDate: Date
    var endDate: Date?  // nil = currently active

    @Relationship(inverse: \Medication.periods)
    var medication: Medication?

    init(
        dosage: String,
        unit: String,
        schedule: String,
        startDate: Date = Date(),
        endDate: Date? = nil
    ) {
        self.dosage = dosage
        self.unit = unit
        self.schedule = schedule
        self.startDate = startDate
        self.endDate = endDate
    }

    /// Formatted date range for display, e.g., "Jan 15, 2024 - Mar 1, 2024" or "Jan 15, 2024 - Present"
    var dateRangeDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let startString = formatter.string(from: startDate)

        if let endDate = endDate {
            let endString = formatter.string(from: endDate)
            return "\(startString) – \(endString)"
        } else {
            return "\(startString) – Present"
        }
    }

    /// Formatted dosage for display, e.g., "40 mg" or "49/51 mg"
    var dosageDisplay: String {
        "\(dosage) \(unit)"
    }

    /// Whether this period is currently active (no end date)
    var isCurrentPeriod: Bool {
        endDate == nil
    }
}
