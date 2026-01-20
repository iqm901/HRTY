import Foundation

enum AlertType: String, Codable, CaseIterable {
    case weightGain24h
    case weightGain7d
    case heartRateLow
    case heartRateHigh
    case severeSymptom

    var displayName: String {
        switch self {
        case .weightGain24h:
            return "Weight change in 24 hours"
        case .weightGain7d:
            return "Weight change over 7 days"
        case .heartRateLow:
            return "Low heart rate"
        case .heartRateHigh:
            return "High heart rate"
        case .severeSymptom:
            return "Symptom needs attention"
        }
    }
}
