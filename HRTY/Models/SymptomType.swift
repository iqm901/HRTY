import Foundation

enum SymptomType: String, Codable, CaseIterable {
    case dyspneaAtRest
    case dyspneaOnExertion
    case orthopnea
    case pnd
    case chestPain
    case dizziness
    case syncope
    case reducedUrineOutput

    var displayName: String {
        switch self {
        case .dyspneaAtRest:
            return "Shortness of breath at rest"
        case .dyspneaOnExertion:
            return "Shortness of breath with activity"
        case .orthopnea:
            return "Difficulty breathing lying flat"
        case .pnd:
            return "Waking up short of breath"
        case .chestPain:
            return "Chest discomfort"
        case .dizziness:
            return "Feeling dizzy or lightheaded"
        case .syncope:
            return "Fainting or near-fainting"
        case .reducedUrineOutput:
            return "Less urine than usual"
        }
    }
}
