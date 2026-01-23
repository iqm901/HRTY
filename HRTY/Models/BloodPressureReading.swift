import Foundation

/// Data point for blood pressure readings from HealthKit
/// Used to represent individual blood pressure samples fetched from Apple Health
struct BloodPressureReading: Identifiable, Equatable {
    let id: UUID
    let systolic: Int
    let diastolic: Int
    let date: Date

    init(systolic: Int, diastolic: Int, date: Date) {
        self.id = UUID()
        self.systolic = systolic
        self.diastolic = diastolic
        self.date = date
    }

    /// Mean Arterial Pressure: MAP = DBP + (SBP - DBP) / 3
    var meanArterialPressure: Int {
        diastolic + (systolic - diastolic) / 3
    }

    /// Formatted blood pressure string (e.g., "120/80")
    var formatted: String {
        "\(systolic)/\(diastolic)"
    }
}
