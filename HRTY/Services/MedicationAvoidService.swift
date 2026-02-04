import Foundation

// MARK: - Data Types

/// Represents a medication that heart failure patients should avoid or use with caution.
struct MedicationAvoidWarning: Identifiable, Equatable {
    let id = UUID()
    let category: AvoidCategory
    let matchedKeyword: String
    let message: String

    static func == (lhs: MedicationAvoidWarning, rhs: MedicationAvoidWarning) -> Bool {
        lhs.id == rhs.id
    }
}

/// Categories of medications to avoid for heart failure patients.
enum AvoidCategory: String, CaseIterable {
    case nsaid = "NSAID"
    case coldMedicine = "Cold Medicine"
    case herbalSupplement = "Herbal Supplement"
    case calciumChannelBlocker = "Calcium Channel Blocker"

    var displayName: String {
        switch self {
        case .nsaid:
            return "NSAID (Pain Reliever)"
        case .coldMedicine:
            return "Cold & Cough Medicine"
        case .herbalSupplement:
            return "Herbal Supplement"
        case .calciumChannelBlocker:
            return "Calcium Channel Blocker"
        }
    }

    var warningMessage: String {
        switch self {
        case .nsaid:
            return "NSAIDs can cause fluid retention and may worsen heart failure symptoms. They can also reduce the effectiveness of some heart failure medications. Consider discussing with your care team whether this medication is right for you."
        case .coldMedicine:
            return "Decongestants can raise blood pressure and heart rate, which may worsen heart failure. Ask your pharmacist or care team about heart-safe alternatives."
        case .herbalSupplement:
            return "Some herbal supplements can interact with heart failure medications or affect heart function. Always check with your care team before taking herbal products."
        case .calciumChannelBlocker:
            return "Certain calcium channel blockers may weaken the heart's pumping ability. Your care team can advise if this medication is appropriate for your condition."
        }
    }
}

// MARK: - Protocol

protocol MedicationAvoidServiceProtocol {
    func checkIfShouldAvoid(medicationName: String) -> MedicationAvoidWarning?
    func shouldAvoid(medicationName: String) -> Bool
}

// MARK: - Implementation

/// Service to detect medications that heart failure patients should avoid or use with caution.
final class MedicationAvoidService: MedicationAvoidServiceProtocol {

    // MARK: - Keyword Lists

    /// NSAIDs and their brand names
    private static let nsaidKeywords: Set<String> = [
        // Generic names
        "ibuprofen",
        "naproxen",
        "diclofenac",
        "celecoxib",
        "indomethacin",
        "ketorolac",
        "meloxicam",
        "piroxicam",
        "sulindac",
        "ketoprofen",
        "flurbiprofen",
        "etodolac",
        "nabumetone",
        "oxaprozin",
        // Brand names
        "advil",
        "motrin",
        "aleve",
        "naprosyn",
        "voltaren",
        "celebrex",
        "indocin",
        "toradol",
        "mobic",
        "feldene",
        "clinoril",
        "orudis",
        "ansaid",
        "lodine",
        "relafen",
        "daypro",
        // Note: Low-dose aspirin (81mg) is often prescribed for heart patients,
        // so we don't include "aspirin" here to avoid false positives
    ]

    /// Cold and cough medicines with decongestants
    private static let coldMedicineKeywords: Set<String> = [
        // Active ingredients
        "pseudoephedrine",
        "phenylephrine",
        "ephedrine",
        // Brand names
        "sudafed",
        "dayquil",
        "nyquil",
        "mucinex d",
        "claritin-d",
        "zyrtec-d",
        "allegra-d",
        "advil cold",
        "tylenol cold",
        "theraflu",
        "contac",
        "dimetapp",
        "robitussin cf",
        "alka-seltzer plus",
        "coricidin",
    ]

    /// Herbal supplements that may affect heart function
    private static let herbalKeywords: Set<String> = [
        "ephedra",
        "ma huang",
        "st. john's wort",
        "st john's wort",
        "st johns wort",
        "ginseng",
        "ginkgo",
        "ginkgo biloba",
        "hawthorn",
        "licorice root",
        "bitter orange",
        "guarana",
        "yohimbe",
        "kava",
    ]

    /// Calcium channel blockers that may worsen heart failure
    /// Note: Amlodipine and felodipine are generally safer, so not included
    private static let calciumChannelBlockerKeywords: Set<String> = [
        "diltiazem",
        "verapamil",
        "nifedipine",
        // Brand names
        "cardizem",
        "tiazac",
        "calan",
        "verelan",
        "isoptin",
        "procardia",
        "adalat",
    ]

    // MARK: - Public Methods

    func checkIfShouldAvoid(medicationName: String) -> MedicationAvoidWarning? {
        let lowercaseName = medicationName.lowercased()

        // Check each category
        if let keyword = findMatchingKeyword(in: lowercaseName, keywords: Self.nsaidKeywords) {
            return MedicationAvoidWarning(
                category: .nsaid,
                matchedKeyword: keyword,
                message: AvoidCategory.nsaid.warningMessage
            )
        }

        if let keyword = findMatchingKeyword(in: lowercaseName, keywords: Self.coldMedicineKeywords) {
            return MedicationAvoidWarning(
                category: .coldMedicine,
                matchedKeyword: keyword,
                message: AvoidCategory.coldMedicine.warningMessage
            )
        }

        if let keyword = findMatchingKeyword(in: lowercaseName, keywords: Self.herbalKeywords) {
            return MedicationAvoidWarning(
                category: .herbalSupplement,
                matchedKeyword: keyword,
                message: AvoidCategory.herbalSupplement.warningMessage
            )
        }

        if let keyword = findMatchingKeyword(in: lowercaseName, keywords: Self.calciumChannelBlockerKeywords) {
            return MedicationAvoidWarning(
                category: .calciumChannelBlocker,
                matchedKeyword: keyword,
                message: AvoidCategory.calciumChannelBlocker.warningMessage
            )
        }

        return nil
    }

    func shouldAvoid(medicationName: String) -> Bool {
        checkIfShouldAvoid(medicationName: medicationName) != nil
    }

    // MARK: - Private Methods

    private func findMatchingKeyword(in name: String, keywords: Set<String>) -> String? {
        for keyword in keywords {
            if name.contains(keyword) {
                return keyword
            }
        }
        return nil
    }
}
