import SwiftUI

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

struct SymptomRowView: View {
    let symptomType: SymptomType
    let severity: Int
    let onSeverityChange: (Int) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(symptomType.displayName)
                .font(.subheadline)
                .foregroundStyle(.primary)

            HStack(spacing: buttonSpacing) {
                ForEach(1...5, id: \.self) { level in
                    severityButton(level: level)
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(symptomType.displayName)
    }

    // MARK: - Dynamic Type Adaptive Sizing

    private var buttonSize: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return 40
        case .large, .xLarge:
            return 44
        case .xxLarge, .xxxLarge:
            return 52
        case .accessibility1, .accessibility2:
            return 60
        case .accessibility3, .accessibility4, .accessibility5:
            return 72
        @unknown default:
            return 44
        }
    }

    private var buttonSpacing: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 4 : 8
    }

    private var buttonFontSize: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return 14
        case .large, .xLarge:
            return 16
        case .xxLarge, .xxxLarge:
            return 20
        case .accessibility1, .accessibility2:
            return 24
        case .accessibility3, .accessibility4, .accessibility5:
            return 28
        @unknown default:
            return 16
        }
    }

    private func severityButton(level: Int) -> some View {
        Button {
            onSeverityChange(level)
        } label: {
            Text("\(level)")
                .font(.system(size: buttonFontSize, weight: severity == level ? .bold : .regular))
                .frame(minWidth: buttonSize, minHeight: buttonSize)
                .background(buttonBackground(for: level))
                .foregroundStyle(buttonForeground(for: level))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(buttonBorder(for: level), lineWidth: severity == level ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(severityAccessibilityLabel(for: level))
        .accessibilityHint(severityAccessibilityHint(for: level))
        .accessibilityAddTraits(severity == level ? .isSelected : [])
    }

    // MARK: - Styling

    private func buttonBackground(for level: Int) -> Color {
        guard severity == level, let severityLevel = SeverityLevel(rawValue: level) else {
            return Color(.secondarySystemBackground)
        }
        return severityLevel.color
    }

    private func buttonForeground(for level: Int) -> Color {
        severity == level ? .white : .primary
    }

    private func buttonBorder(for level: Int) -> Color {
        guard severity == level, let severityLevel = SeverityLevel(rawValue: level) else {
            return Color(.separator)
        }
        return severityLevel.color
    }

    // MARK: - Accessibility

    private func severityAccessibilityLabel(for level: Int) -> String {
        let label = SeverityLevel(rawValue: level)?.label ?? "Unknown"
        return "Severity \(level): \(label)"
    }

    private func severityAccessibilityHint(for level: Int) -> String {
        if severity == level {
            return "Currently selected"
        }
        return "Double tap to select"
    }
}

#Preview {
    VStack(spacing: 16) {
        SymptomRowView(
            symptomType: .dyspneaAtRest,
            severity: 1,
            onSeverityChange: { _ in }
        )
        SymptomRowView(
            symptomType: .chestPain,
            severity: 3,
            onSeverityChange: { _ in }
        )
        SymptomRowView(
            symptomType: .dizziness,
            severity: 5,
            onSeverityChange: { _ in }
        )
    }
    .padding()
}
