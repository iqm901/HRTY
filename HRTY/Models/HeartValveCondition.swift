import Foundation
import SwiftData

/// Types of heart valves
enum HeartValveType: String, CaseIterable, Identifiable {
    case mitral = "Mitral"
    case aortic = "Aortic"
    case tricuspid = "Tricuspid"
    case pulmonary = "Pulmonary"

    var id: String { rawValue }

    var displayName: String { rawValue }

    /// Sort order for display
    var sortOrder: Int {
        switch self {
        case .mitral: return 0
        case .aortic: return 1
        case .tricuspid: return 2
        case .pulmonary: return 3
        }
    }
}

/// Types of valve problems
enum ValveProblemType: String, CaseIterable, Identifiable {
    case stenosis = "Stenosis"
    case regurgitation = "Regurgitation"
    case mixed = "Mixed"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var description: String {
        switch self {
        case .stenosis:
            return "Valve doesn't open fully, restricting blood flow"
        case .regurgitation:
            return "Valve doesn't close completely, allowing blood to leak backward"
        case .mixed:
            return "Both stenosis and regurgitation present"
        }
    }
}

/// Severity levels for valve conditions
enum ValveSeverity: String, CaseIterable, Identifiable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"

    var id: String { rawValue }

    var displayName: String { rawValue }
}

/// Types of valve interventions
enum ValveInterventionType: String, CaseIterable, Identifiable {
    case repair = "Repair"
    case mechanicalReplacement = "Mechanical Replacement"
    case biologicalReplacement = "Biological Replacement"
    case tavi = "TAVI/TAVR"
    case mitraClip = "MitraClip"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .repair: return "Valve Repair"
        case .mechanicalReplacement: return "Mechanical Valve Replacement"
        case .biologicalReplacement: return "Biological Valve Replacement"
        case .tavi: return "TAVI/TAVR (Transcatheter)"
        case .mitraClip: return "MitraClip"
        }
    }

    var shortName: String { rawValue }
}

/// Record of a heart valve's condition
@Model
final class HeartValveCondition {
    /// Raw value for valve type
    var valveTypeRawValue: String

    /// Raw value for problem type (stenosis, regurgitation, mixed)
    var problemTypeRawValue: String?

    /// Raw value for severity
    var severityRawValue: String?

    /// Whether an intervention has been performed
    var hasIntervention: Bool

    /// Raw value for intervention type
    var interventionTypeRawValue: String?

    /// Date when intervention was performed
    var interventionDate: Date?

    /// Additional notes about this valve
    var notes: String?

    /// Reference to the clinical profile
    var profile: ClinicalProfile?

    // MARK: - Computed Properties

    /// The type of heart valve
    var valveType: HeartValveType {
        get {
            HeartValveType(rawValue: valveTypeRawValue) ?? .mitral
        }
        set {
            valveTypeRawValue = newValue.rawValue
        }
    }

    /// The type of problem with the valve
    var problemType: ValveProblemType? {
        get {
            guard let rawValue = problemTypeRawValue else { return nil }
            return ValveProblemType(rawValue: rawValue)
        }
        set {
            problemTypeRawValue = newValue?.rawValue
        }
    }

    /// The severity of the condition
    var severity: ValveSeverity? {
        get {
            guard let rawValue = severityRawValue else { return nil }
            return ValveSeverity(rawValue: rawValue)
        }
        set {
            severityRawValue = newValue?.rawValue
        }
    }

    /// The type of intervention performed
    var interventionType: ValveInterventionType? {
        get {
            guard let rawValue = interventionTypeRawValue else { return nil }
            return ValveInterventionType(rawValue: rawValue)
        }
        set {
            interventionTypeRawValue = newValue?.rawValue
        }
    }

    /// Summary text for display in lists
    var statusSummary: String {
        var parts: [String] = []

        if let problem = problemType {
            if let sev = severity {
                parts.append("\(sev.displayName) \(problem.displayName.lowercased())")
            } else {
                parts.append(problem.displayName)
            }
        } else {
            parts.append("Normal")
        }

        if hasIntervention, let intervention = interventionType {
            parts.append(intervention.shortName)
        }

        return parts.joined(separator: " • ")
    }

    /// Formatted intervention date for display
    var interventionDateDisplay: String? {
        guard let date = interventionDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Whether this valve has any recorded condition
    var hasCondition: Bool {
        problemType != nil
    }

    // MARK: - Initialization

    init(
        valveType: HeartValveType,
        problemType: ValveProblemType? = nil,
        severity: ValveSeverity? = nil,
        hasIntervention: Bool = false,
        interventionType: ValveInterventionType? = nil,
        interventionDate: Date? = nil,
        notes: String? = nil
    ) {
        self.valveTypeRawValue = valveType.rawValue
        self.problemTypeRawValue = problemType?.rawValue
        self.severityRawValue = severity?.rawValue
        self.hasIntervention = hasIntervention
        self.interventionTypeRawValue = interventionType?.rawValue
        self.interventionDate = interventionDate
        self.notes = notes
    }
}
