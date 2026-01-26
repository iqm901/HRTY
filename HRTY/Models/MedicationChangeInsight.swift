import Foundation

/// Represents a medication dosage change with associated clinical context
struct MedicationChangeInsight: Identifiable {
    let id = UUID()
    let medicationName: String
    let category: HeartFailureMedication.Category?
    let changeDate: Date
    let previousDosage: String?
    let newDosage: String?
    let changeType: ChangeType
    let observations: [ClinicalObservation]
    let contextMessage: String?

    /// Type of medication change detected
    enum ChangeType: String {
        case doseReduction = "Dose reduction"
        case doseIncrease = "Dose increase"
        case discontinued = "Discontinued"
        case started = "Started"
        case scheduleChange = "Schedule change"
    }

    /// Formatted change description for display
    var changeDescription: String {
        switch changeType {
        case .doseReduction, .doseIncrease:
            if let prev = previousDosage, let new = newDosage {
                return "\(prev) \u{2192} \(new)"
            }
            return changeType.rawValue
        case .discontinued:
            if let prev = previousDosage {
                return "\(prev) \u{2192} Discontinued"
            }
            return "Discontinued"
        case .started:
            if let new = newDosage {
                return "Started at \(new)"
            }
            return "Started"
        case .scheduleChange:
            return "Schedule changed"
        }
    }

    /// Formatted date for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: changeDate)
    }

    /// Whether this insight has meaningful observations to share
    var hasObservations: Bool {
        !observations.isEmpty
    }
}

/// A clinical observation that may be relevant to a medication change
struct ClinicalObservation: Identifiable {
    let id = UUID()
    let type: ObservationType
    let description: String
    let severity: Severity

    /// Type of clinical observation
    enum ObservationType: String {
        case lowBloodPressure = "Low blood pressure"
        case lowHeartRate = "Low heart rate"
        case lowMAP = "Low MAP"
        case dizziness = "Dizziness"
        case syncope = "Syncope"
        case reducedUrineOutput = "Reduced urine output"
        case alert = "Alert triggered"
        case averageBP = "Blood pressure average"
        case averageHR = "Heart rate average"
    }

    /// Severity level for visual distinction
    enum Severity: Int {
        case informational = 1
        case notable = 2
        case significant = 3

        var displayColor: String {
            switch self {
            case .informational: return "secondary"
            case .notable: return "orange"
            case .significant: return "red"
            }
        }
    }
}

/// Summary data for vital signs over a lookback period
struct VitalSignsSummary {
    let averageSystolic: Int?
    let averageDiastolic: Int?
    let averageHeartRate: Int?
    let lowBPDays: Int
    let lowHRDays: Int
    let lowMAPDays: Int
    let readingCount: Int

    /// Formatted blood pressure average string
    var formattedAverageBP: String? {
        guard let systolic = averageSystolic, let diastolic = averageDiastolic else {
            return nil
        }
        return "\(systolic)/\(diastolic) mmHg"
    }

    /// Formatted heart rate average string
    var formattedAverageHR: String? {
        guard let hr = averageHeartRate else { return nil }
        return "\(hr) bpm"
    }

    var hasData: Bool {
        readingCount > 0
    }
}

/// Summary data for symptoms over a lookback period
struct SymptomSummary {
    let symptomType: SymptomType
    let daysReported: Int
    let maxSeverity: Int
    let averageSeverity: Double

    /// Whether this symptom was notable (severity >= 3)
    var isNotable: Bool {
        maxSeverity >= 3
    }

    /// Whether this symptom was severe (severity >= 4)
    var isSevere: Bool {
        maxSeverity >= AlertConstants.severeSymptomThreshold
    }
}

/// Summary data for alerts over a lookback period
struct AlertSummary {
    let alertType: AlertType
    let count: Int
    let mostRecentDate: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: mostRecentDate)
    }
}
