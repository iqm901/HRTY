import Foundation

/// Data point for heart rate readings from HealthKit
/// Used to represent individual heart rate samples fetched from Apple Health
struct HeartRateReading: Identifiable, Equatable, HealthKitReading {
    let id: UUID
    let heartRate: Int
    let date: Date

    init(heartRate: Int, date: Date) {
        self.id = UUID()
        self.heartRate = heartRate
        self.date = date
    }
}
