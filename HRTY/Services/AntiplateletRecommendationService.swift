import Foundation
import SwiftData

/// Represents the type of antiplatelet therapy recommendation
enum AntiplateletRecommendationType {
    /// Dual antiplatelet therapy (Aspirin + P2Y12 inhibitor)
    case dapt
    /// Single antiplatelet therapy (Aspirin OR P2Y12 inhibitor)
    case singleAntiplatelet
    /// No recommendation (no procedures)
    case none
}

/// Represents the current antiplatelet medication status
struct AntiplateletStatus {
    let hasAspirin: Bool
    let hasP2Y12: Bool

    var hasBothForDAPT: Bool {
        hasAspirin && hasP2Y12
    }

    var hasEitherForSingle: Bool {
        hasAspirin || hasP2Y12
    }
}

/// Represents an antiplatelet recommendation with missing medications
struct AntiplateletRecommendation {
    let recommendationType: AntiplateletRecommendationType
    let currentStatus: AntiplateletStatus
    let missingMedications: [MissingMedication]
    let warningMessage: String?
    let detailMessage: String?

    enum MissingMedication: String {
        case aspirin = "Aspirin"
        case p2y12 = "P2Y12 Inhibitor"

        var suggestionText: String {
            switch self {
            case .aspirin:
                return "Aspirin 81mg"
            case .p2y12:
                return "Clopidogrel or Ticagrelor"
            }
        }
    }

    /// Whether this recommendation should be shown to the user
    var shouldShowWarning: Bool {
        !missingMedications.isEmpty
    }

    static let none = AntiplateletRecommendation(
        recommendationType: .none,
        currentStatus: AntiplateletStatus(hasAspirin: false, hasP2Y12: false),
        missingMedications: [],
        warningMessage: nil,
        detailMessage: nil
    )
}

/// Service for evaluating antiplatelet therapy recommendations based on coronary procedures
struct AntiplateletRecommendationService {

    // MARK: - Medication Keywords

    /// Keywords to identify aspirin medications (case-insensitive)
    static let aspirinKeywords = ["aspirin", "bayer", "ecotrin"]

    /// Keywords to identify P2Y12 inhibitor medications (case-insensitive)
    static let p2y12Keywords = ["clopidogrel", "plavix", "ticagrelor", "brilinta", "prasugrel", "effient"]

    // MARK: - Public Methods

    /// Evaluates antiplatelet recommendation based on procedures and current medications
    /// - Parameters:
    ///   - procedures: The patient's coronary procedures
    ///   - medications: The patient's current active medications
    /// - Returns: An antiplatelet recommendation with missing medications if applicable
    static func evaluate(
        procedures: [CoronaryProcedure],
        medications: [Medication]
    ) -> AntiplateletRecommendation {
        // No recommendation if no procedures
        guard !procedures.isEmpty else {
            return .none
        }

        // Check current medication status
        let status = checkMedicationStatus(medications: medications)

        // Determine recommendation type
        let recommendationType = determineRecommendationType(procedures: procedures)

        // Build recommendation based on type and current status
        return buildRecommendation(
            type: recommendationType,
            status: status
        )
    }

    /// Checks if the medications list contains aspirin
    static func hasAspirin(in medications: [Medication]) -> Bool {
        medications.contains { medication in
            guard medication.isActive else { return false }
            let nameLower = medication.name.lowercased()
            return aspirinKeywords.contains { keyword in
                nameLower.contains(keyword)
            }
        }
    }

    /// Checks if the medications list contains a P2Y12 inhibitor
    static func hasP2Y12Inhibitor(in medications: [Medication]) -> Bool {
        medications.contains { medication in
            guard medication.isActive else { return false }
            let nameLower = medication.name.lowercased()
            return p2y12Keywords.contains { keyword in
                nameLower.contains(keyword)
            }
        }
    }

    // MARK: - Private Methods

    private static func checkMedicationStatus(medications: [Medication]) -> AntiplateletStatus {
        AntiplateletStatus(
            hasAspirin: hasAspirin(in: medications),
            hasP2Y12: hasP2Y12Inhibitor(in: medications)
        )
    }

    private static func determineRecommendationType(procedures: [CoronaryProcedure]) -> AntiplateletRecommendationType {
        // Check for any stent within the last 12 months
        let hasRecentStent = procedures.contains { procedure in
            procedure.procedureType == .stent && procedure.isWithinTwelveMonths
        }

        if hasRecentStent {
            return .dapt
        }

        // Any procedure exists (all >12 months or unknown date) → single antiplatelet
        return .singleAntiplatelet
    }

    private static func buildRecommendation(
        type: AntiplateletRecommendationType,
        status: AntiplateletStatus
    ) -> AntiplateletRecommendation {
        switch type {
        case .none:
            return .none

        case .dapt:
            var missing: [AntiplateletRecommendation.MissingMedication] = []
            if !status.hasAspirin { missing.append(.aspirin) }
            if !status.hasP2Y12 { missing.append(.p2y12) }

            return AntiplateletRecommendation(
                recommendationType: .dapt,
                currentStatus: status,
                missingMedications: missing,
                warningMessage: missing.isEmpty ? nil : "Medication Suggestion",
                detailMessage: missing.isEmpty ? nil :
                    "For stents placed within the last 12 months, guidelines recommend both aspirin and a P2Y12 inhibitor."
            )

        case .singleAntiplatelet:
            let missing: [AntiplateletRecommendation.MissingMedication] = status.hasEitherForSingle ? [] : [.aspirin]

            return AntiplateletRecommendation(
                recommendationType: .singleAntiplatelet,
                currentStatus: status,
                missingMedications: missing,
                warningMessage: missing.isEmpty ? nil : "Medication Suggestion",
                detailMessage: missing.isEmpty ? nil :
                    "After coronary procedures, guidelines recommend taking an antiplatelet medication."
            )
        }
    }
}
