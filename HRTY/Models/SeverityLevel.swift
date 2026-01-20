import SwiftUI

/// Represents the severity level of a symptom on a 1-5 scale.
/// Used throughout the app for consistent severity representation.
enum SeverityLevel: Int, CaseIterable {
    case none = 1
    case mild = 2
    case moderate = 3
    case significant = 4
    case severe = 5

    var label: String {
        switch self {
        case .none: return "None"
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .significant: return "Significant"
        case .severe: return "Severe"
        }
    }

    var color: Color {
        switch self {
        case .none: return .green
        case .mild: return Color(red: 0.6, green: 0.8, blue: 0.2)
        case .moderate: return .yellow
        case .significant: return .orange
        case .severe: return .red
        }
    }

    /// Returns true if this severity level should trigger an alert consideration
    var triggersAlertConsideration: Bool {
        self == .significant || self == .severe
    }

    init?(rawValue: Int) {
        switch rawValue {
        case 1: self = .none
        case 2: self = .mild
        case 3: self = .moderate
        case 4: self = .significant
        case 5: self = .severe
        default: return nil
        }
    }
}
