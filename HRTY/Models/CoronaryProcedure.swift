import Foundation
import SwiftData

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

    /// Date when the procedure was performed
    var procedureDate: Date?

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
        guard let date = procedureDate, !dateIsUnknown else { return false }
        let twelveMonthsAgo = Calendar.current.date(byAdding: .month, value: -12, to: Date()) ?? Date()
        return date >= twelveMonthsAgo
    }

    /// Formatted procedure date for display
    var procedureDateDisplay: String? {
        if dateIsUnknown {
            return "Date unknown"
        }
        guard let date = procedureDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
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
        procedureDate: Date? = nil,
        dateIsUnknown: Bool = false,
        vesselsInvolved: [CoronaryArteryType] = [],
        graftTypes: [CABGGraftType] = [],
        notes: String? = nil
    ) {
        self.procedureTypeRawValue = procedureType.rawValue
        self.procedureDate = procedureDate
        self.dateIsUnknown = dateIsUnknown
        self.vesselsInvolvedRawValues = vesselsInvolved.isEmpty ? nil : vesselsInvolved.map(\.rawValue).joined(separator: ",")
        self.graftTypesRawValues = graftTypes.isEmpty ? nil : graftTypes.map(\.rawValue).joined(separator: ",")
        self.notes = notes
        self.createdAt = Date()
    }
}
