import Foundation

/// Data point for oxygen saturation (SpO2) readings from HealthKit
/// Used to represent individual SpO2 samples fetched from Apple Health
struct OxygenSaturationReading: Identifiable, Equatable {
    let id: UUID
    let percentage: Int
    let date: Date

    init(percentage: Int, date: Date) {
        self.id = UUID()
        self.percentage = percentage
        self.date = date
    }

    /// Formatted SpO2 string (e.g., "98%")
    var formatted: String {
        "\(percentage)%"
    }
}
