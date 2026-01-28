import Foundation
import SwiftData

/// NYHA (New York Heart Association) functional classification for heart failure symptoms
enum NYHAClass: Int, CaseIterable, Identifiable {
    case classI = 1
    case classII = 2
    case classIII = 3
    case classIV = 4

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .classI: return "Class I"
        case .classII: return "Class II"
        case .classIII: return "Class III"
        case .classIV: return "Class IV"
        }
    }

    var description: String {
        switch self {
        case .classI:
            return "No limitation. Ordinary physical activity doesn't cause symptoms."
        case .classII:
            return "Slight limitation. Comfortable at rest, but ordinary activity causes symptoms."
        case .classIII:
            return "Marked limitation. Comfortable only at rest. Less than ordinary activity causes symptoms."
        case .classIV:
            return "Severe limitation. Unable to carry on any physical activity without discomfort."
        }
    }

    var shortDescription: String {
        switch self {
        case .classI: return "No limitation"
        case .classII: return "Slight limitation"
        case .classIII: return "Marked limitation"
        case .classIV: return "Severe limitation"
        }
    }
}

/// Patient's clinical profile containing data from doctor visits
/// Uses singleton pattern - only one profile per patient
@Model
final class ClinicalProfile {
    /// Unique identifier to enforce singleton pattern
    @Attribute(.unique) var profileId: String = "main"

    // MARK: - Ejection Fraction

    /// Ejection fraction percentage (0-100)
    var ejectionFraction: Int?

    /// Date when ejection fraction was measured
    var ejectionFractionDate: Date?

    // MARK: - NYHA Classification

    /// Raw value for NYHA class (1-4)
    var nyhaClassRawValue: Int?

    /// Date when NYHA class was assessed
    var nyhaClassDate: Date?

    /// Computed NYHA class from raw value
    var nyhaClass: NYHAClass? {
        get {
            guard let rawValue = nyhaClassRawValue else { return nil }
            return NYHAClass(rawValue: rawValue)
        }
        set {
            nyhaClassRawValue = newValue?.rawValue
        }
    }

    // MARK: - Blood Pressure Target

    /// Target systolic blood pressure (mmHg)
    var targetSystolicBP: Int?

    /// Target diastolic blood pressure (mmHg)
    var targetDiastolicBP: Int?

    /// Formatted BP target string for display
    var bpTargetDisplay: String? {
        guard let systolic = targetSystolicBP, let diastolic = targetDiastolicBP else {
            return nil
        }
        return "\(systolic)/\(diastolic) mmHg"
    }

    // MARK: - Relationships

    @Relationship(deleteRule: .cascade, inverse: \HeartValveCondition.profile)
    var heartValves: [HeartValveCondition]?

    @Relationship(deleteRule: .cascade, inverse: \CoronaryProcedure.profile)
    var coronaryProcedures: [CoronaryProcedure]?

    // MARK: - Initialization

    init() {
        self.profileId = "main"
    }

    // MARK: - Computed Properties

    /// Returns sorted heart valves by type
    var sortedHeartValves: [HeartValveCondition] {
        (heartValves ?? []).sorted { $0.valveType.sortOrder < $1.valveType.sortOrder }
    }

    /// Returns coronary procedures sorted by date (most recent first)
    var sortedCoronaryProcedures: [CoronaryProcedure] {
        (coronaryProcedures ?? []).sorted { proc1, proc2 in
            // Unknown dates go to the end
            if proc1.dateIsUnknown && !proc2.dateIsUnknown { return false }
            if !proc1.dateIsUnknown && proc2.dateIsUnknown { return true }
            // Both unknown - sort by creation date
            if proc1.dateIsUnknown && proc2.dateIsUnknown {
                return proc1.createdAt > proc2.createdAt
            }
            // Both have dates - sort by year, month, day (most recent first)
            guard let year1 = proc1.procedureYear, let year2 = proc2.procedureYear else {
                return proc1.createdAt > proc2.createdAt
            }
            if year1 != year2 { return year1 > year2 }
            // Same year - compare months (nil goes later)
            let month1 = proc1.procedureMonth ?? 0
            let month2 = proc2.procedureMonth ?? 0
            if month1 != month2 { return month1 > month2 }
            // Same month - compare days (nil goes later)
            let day1 = proc1.procedureDay ?? 0
            let day2 = proc2.procedureDay ?? 0
            return day1 > day2
        }
    }

    /// Returns all stent procedures
    var stentProcedures: [CoronaryProcedure] {
        (coronaryProcedures ?? []).filter { $0.procedureType == .stent }
    }

    /// Returns all CABG procedures
    var cabgProcedures: [CoronaryProcedure] {
        (coronaryProcedures ?? []).filter { $0.procedureType == .cabg }
    }

    /// Whether any stent was placed within the last 12 months
    var hasRecentStent: Bool {
        stentProcedures.contains { $0.isWithinTwelveMonths }
    }

    /// Whether the profile has any clinical data entered
    var hasAnyData: Bool {
        ejectionFraction != nil ||
        nyhaClassRawValue != nil ||
        targetSystolicBP != nil ||
        !(heartValves ?? []).isEmpty ||
        !(coronaryProcedures ?? []).isEmpty
    }

    /// EF category description based on value
    var efCategory: String? {
        guard let ef = ejectionFraction else { return nil }
        if ef >= 50 {
            return "Preserved (HFpEF)"
        } else if ef >= 40 {
            return "Mildly Reduced"
        } else {
            return "Reduced (HFrEF)"
        }
    }

    // MARK: - Static Methods

    /// Gets the existing profile or creates a new one if none exists
    @MainActor
    static func getOrCreate(in context: ModelContext) -> ClinicalProfile {
        let descriptor = FetchDescriptor<ClinicalProfile>(
            predicate: #Predicate { $0.profileId == "main" }
        )

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let newProfile = ClinicalProfile()
        context.insert(newProfile)
        return newProfile
    }
}
