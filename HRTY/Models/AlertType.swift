import Foundation

enum AlertType: String, Codable, CaseIterable {
    case weightGain24h
    case weightGain7d
    case heartRateLow
    case heartRateHigh
    case severeSymptom
    case dizzinessBPCheck
    case lowOxygenSaturation
    case lowBloodPressure
    case lowMAP

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
        case .dizzinessBPCheck:
            return "Blood pressure check suggested"
        case .lowOxygenSaturation:
            return "Low oxygen level"
        case .lowBloodPressure:
            return "Low blood pressure"
        case .lowMAP:
            return "Low blood pressure"
        }
    }

    /// A patient-friendly description explaining the alert for accessibility and UI display.
    /// These descriptions are warm and reassuring, guiding the patient to contact their care team.
    var accessibilityDescription: String {
        switch self {
        case .weightGain24h:
            return "Your weight has changed noticeably since yesterday. It's a good idea to check in with your care team."
        case .weightGain7d:
            return "Your weight has shifted over the past week. Your care team can help you understand what this means."
        case .heartRateLow:
            return "Your heart rate seems lower than usual. Consider reaching out to your care team."
        case .heartRateHigh:
            return "Your heart rate seems higher than usual. Your care team can help you figure out next steps."
        case .severeSymptom:
            return "You've noted a symptom that may need attention. Please consider contacting your care team."
        case .dizzinessBPCheck:
            return "You mentioned feeling dizzy. Checking your blood pressure may be helpful."
        case .lowOxygenSaturation:
            return "Your oxygen level seems lower than usual. It's a good idea to check in with your care team to discuss this reading."
        case .lowBloodPressure:
            return "Your blood pressure seems lower than usual. Consider reaching out to your care team, especially if you're feeling unwell."
        case .lowMAP:
            return "Your blood pressure reading may be on the low side. Your care team can help you understand what this means for you."
        }
    }
}
