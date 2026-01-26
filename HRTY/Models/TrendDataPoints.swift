import Foundation

/// Data point for weight chart visualization and export
struct WeightDataPoint: Identifiable, Equatable {
    let date: Date
    let weight: Double

    var id: Date { date }
}

/// Data point for symptom trend chart visualization and export
struct SymptomDataPoint: Identifiable, Equatable {
    let date: Date
    let symptomType: SymptomType
    let severity: Int
    let hasAlert: Bool

    var id: String { "\(date.timeIntervalSince1970)-\(symptomType.rawValue)" }
}

/// Data point for heart rate trend chart visualization and export
struct HeartRateDataPoint: Identifiable, Equatable {
    let date: Date
    let heartRate: Int
    let hasAlert: Bool

    var id: Date { date }
}

/// Data point for blood pressure trend chart visualization and export
struct BloodPressureDataPoint: Identifiable, Equatable {
    let date: Date
    let systolic: Int
    let diastolic: Int
    let hasAlert: Bool

    var id: Date { date }
}

/// Data point for oxygen saturation trend chart visualization and export
struct OxygenSaturationDataPoint: Identifiable, Equatable {
    let date: Date
    let percentage: Int
    let hasAlert: Bool

    var id: Date { date }
}
