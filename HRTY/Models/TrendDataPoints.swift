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
