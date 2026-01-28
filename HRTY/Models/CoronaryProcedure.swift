import Foundation
import SwiftData

/// Types of coronary arteries that can be tracked
enum CoronaryArteryType: String, CaseIterable, Identifiable {
    case lm = "LM"      // Left Main
    case lad = "LAD"    // Left Anterior Descending
    case lcx = "LCx"    // Left Circumflex
    case rca = "RCA"    // Right Coronary Artery
    case diagonal = "Diagonal"
    case om = "OM"      // Obtuse Marginal
    case pda = "PDA"    // Posterior Descending Artery

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lm: return "Left Main (LM)"
        case .lad: return "Left Anterior Descending (LAD)"
        case .lcx: return "Left Circumflex (LCx)"
        case .rca: return "Right Coronary Artery (RCA)"
        case .diagonal: return "Diagonal Branch"
        case .om: return "Obtuse Marginal (OM)"
        case .pda: return "Posterior Descending (PDA)"
        }
    }

    var shortName: String { rawValue }

    /// Sort order for display (major arteries first)
    var sortOrder: Int {
        switch self {
        case .lm: return 0
        case .lad: return 1
        case .lcx: return 2
        case .rca: return 3
        case .diagonal: return 4
        case .om: return 5
        case .pda: return 6
        }
    }
}

/// Types of coronary procedures
enum CoronaryProcedureType: String, CaseIterable, Identifiable {
    case stent = "Stent"
    case cabg = "CABG"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .stent: return "Stent (PCI)"
        case .cabg: return "Bypass Surgery (CABG)"
        }
    }

    var shortName: String {
        switch self {
        case .stent: return "Stent"
        case .cabg: return "CABG"
        }
    }

    var icon: String {
        switch self {
        case .stent: return "circle.circle"
        case .cabg: return "arrow.triangle.branch"
        }
    }
}

/// Types of grafts used in CABG surgery
enum CABGGraftType: String, CaseIterable, Identifiable {
    case lima = "LIMA"
    case rima = "RIMA"
    case saphenousVein = "Saphenous Vein"
    case radialArtery = "Radial Artery"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lima: return "LIMA (Left Internal Mammary)"
        case .rima: return "RIMA (Right Internal Mammary)"
        case .saphenousVein: return "Saphenous Vein Graft"
        case .radialArtery: return "Radial Artery Graft"
        }
    }

    var shortName: String { rawValue }
}

/// Record of a coronary procedure (Stent or CABG)
@Model
final class CoronaryProcedure {
    /// Raw value for procedure type ("Stent" or "CABG")
    var procedureTypeRawValue: String

    /// Year component of procedure date (e.g., 2024)
    var procedureYear: Int?

    /// Month component of procedure date (1-12)
    var procedureMonth: Int?

    /// Day component of procedure date (1-31)
    var procedureDay: Int?

    /// Explicit flag for "I don't know the date"
    var dateIsUnknown: Bool

    /// Comma-separated raw values for vessels involved
    var vesselsInvolvedRawValues: String?

    /// Comma-separated raw values for graft types (CABG only)
    var graftTypesRawValues: String?

    /// Additional notes about the procedure
    var notes: String?

    /// Reference to the clinical profile
    var profile: ClinicalProfile?

    /// When this record was created
    var createdAt: Date

    // MARK: - Computed Properties

    /// The type of procedure
    var procedureType: CoronaryProcedureType {
        get {
            CoronaryProcedureType(rawValue: procedureTypeRawValue) ?? .stent
        }
        set {
            procedureTypeRawValue = newValue.rawValue
        }
    }

    /// The vessels involved in this procedure
    var vesselsInvolved: [CoronaryArteryType] {
        get {
            guard let rawValues = vesselsInvolvedRawValues else { return [] }
            return rawValues.split(separator: ",")
                .compactMap { CoronaryArteryType(rawValue: String($0)) }
        }
        set {
            if newValue.isEmpty {
                vesselsInvolvedRawValues = nil
            } else {
                vesselsInvolvedRawValues = newValue.map(\.rawValue).joined(separator: ",")
            }
        }
    }

    /// The graft types used (for CABG only)
    var graftTypes: [CABGGraftType] {
        get {
            guard let rawValues = graftTypesRawValues else { return [] }
            return rawValues.split(separator: ",")
                .compactMap { CABGGraftType(rawValue: String($0)) }
        }
        set {
            if newValue.isEmpty {
                graftTypesRawValues = nil
            } else {
                graftTypesRawValues = newValue.map(\.rawValue).joined(separator: ",")
            }
        }
    }

    /// Whether the procedure date is within the last 12 months
    var isWithinTwelveMonths: Bool {
        guard let year = procedureYear, !dateIsUnknown else { return false }

        // Build a date from available components
        // Use Jan 1 if month unknown, use 1st if day unknown (conservative estimate)
        var components = DateComponents()
        components.year = year
        components.month = procedureMonth ?? 1
        components.day = procedureDay ?? 1

        guard let procedureDate = Calendar.current.date(from: components) else { return false }
        let twelveMonthsAgo = Calendar.current.date(byAdding: .month, value: -12, to: Date()) ?? Date()
        return procedureDate >= twelveMonthsAgo
    }

    /// Formatted procedure date for display
    /// Returns "Jan 15, 2024", "Jan 2024", "2024", or "Date unknown" based on available components
    var procedureDateDisplay: String? {
        if dateIsUnknown {
            return "Date unknown"
        }

        guard let year = procedureYear else { return nil }

        if let month = procedureMonth {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = procedureDay ?? 1

            guard let date = Calendar.current.date(from: components) else {
                return String(year)
            }

            let formatter = DateFormatter()
            if procedureDay != nil {
                formatter.dateFormat = "MMM d, yyyy"  // "Jan 15, 2024"
            } else {
                formatter.dateFormat = "MMM yyyy"      // "Jan 2024"
            }
            return formatter.string(from: date)
        }

        return String(year)  // Just the year
    }

    /// Summary text for display in lists
    var summary: String {
        var parts: [String] = [procedureType.shortName]

        if let dateDisplay = procedureDateDisplay {
            parts.append(dateDisplay)
        }

        return parts.joined(separator: " - ")
    }

    /// Detailed summary including vessels
    var detailedSummary: String {
        var parts: [String] = []

        if !vesselsInvolved.isEmpty {
            let vesselNames = vesselsInvolved.map(\.shortName).joined(separator: ", ")
            parts.append("Vessels: \(vesselNames)")
        }

        if procedureType == .cabg && !graftTypes.isEmpty {
            let graftNames = graftTypes.map(\.shortName).joined(separator: ", ")
            parts.append("Grafts: \(graftNames)")
        }

        return parts.joined(separator: "\n")
    }

    // MARK: - Initialization

    init(
        procedureType: CoronaryProcedureType,
        procedureYear: Int? = nil,
        procedureMonth: Int? = nil,
        procedureDay: Int? = nil,
        dateIsUnknown: Bool = false,
        vesselsInvolved: [CoronaryArteryType] = [],
        graftTypes: [CABGGraftType] = [],
        notes: String? = nil
    ) {
        self.procedureTypeRawValue = procedureType.rawValue
        self.procedureYear = procedureYear
        self.procedureMonth = procedureMonth
        self.procedureDay = procedureDay
        self.dateIsUnknown = dateIsUnknown
        self.vesselsInvolvedRawValues = vesselsInvolved.isEmpty ? nil : vesselsInvolved.map(\.rawValue).joined(separator: ",")
        self.graftTypesRawValues = graftTypes.isEmpty ? nil : graftTypes.map(\.rawValue).joined(separator: ",")
        self.notes = notes
        self.createdAt = Date()
    }
}
