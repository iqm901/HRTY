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

/// Severity levels for coronary artery blockages
enum BlockageSeverity: String, CaseIterable, Identifiable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    case totalOcclusion = "Total Occlusion"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var percentageRange: String {
        switch self {
        case .mild: return "1-49%"
        case .moderate: return "50-69%"
        case .severe: return "70-99%"
        case .totalOcclusion: return "100%"
        }
    }
}

/// Record of a coronary artery's condition
@Model
final class CoronaryArtery {
    /// Raw value for artery type
    var arteryTypeRawValue: String

    /// Whether the artery has a blockage
    var hasBlockage: Bool

    /// Severity of the blockage (if present)
    var blockageSeverityRawValue: String?

    /// Whether a stent has been placed
    var hasStent: Bool

    /// Date when stent was placed
    var stentDate: Date?

    /// Additional notes about this artery
    var notes: String?

    /// Reference to the clinical profile
    var profile: ClinicalProfile?

    // MARK: - Computed Properties

    /// The type of coronary artery
    var arteryType: CoronaryArteryType {
        get {
            CoronaryArteryType(rawValue: arteryTypeRawValue) ?? .lad
        }
        set {
            arteryTypeRawValue = newValue.rawValue
        }
    }

    /// The severity of blockage
    var blockageSeverity: BlockageSeverity? {
        get {
            guard let rawValue = blockageSeverityRawValue else { return nil }
            return BlockageSeverity(rawValue: rawValue)
        }
        set {
            blockageSeverityRawValue = newValue?.rawValue
        }
    }

    /// Summary text for display in lists
    var statusSummary: String {
        var parts: [String] = []

        if hasBlockage {
            if let severity = blockageSeverity {
                parts.append("\(severity.displayName) blockage")
            } else {
                parts.append("Blockage")
            }
        } else {
            parts.append("No significant blockage")
        }

        if hasStent {
            parts.append("Stent placed")
        }

        return parts.joined(separator: " • ")
    }

    /// Formatted stent date for display
    var stentDateDisplay: String? {
        guard let date = stentDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // MARK: - Initialization

    init(
        arteryType: CoronaryArteryType,
        hasBlockage: Bool = false,
        blockageSeverity: BlockageSeverity? = nil,
        hasStent: Bool = false,
        stentDate: Date? = nil,
        notes: String? = nil
    ) {
        self.arteryTypeRawValue = arteryType.rawValue
        self.hasBlockage = hasBlockage
        self.blockageSeverityRawValue = blockageSeverity?.rawValue
        self.hasStent = hasStent
        self.stentDate = stentDate
        self.notes = notes
    }
}
