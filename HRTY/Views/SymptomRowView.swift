import SwiftUI

struct SymptomRowView: View {
    let symptomType: SymptomType
    let severity: Int
    let onSeverityChange: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(symptomType.displayName)
                .font(.subheadline)
                .foregroundStyle(.primary)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { level in
                    severityButton(level: level)
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(symptomType.displayName)
    }

    private func severityButton(level: Int) -> some View {
        Button {
            onSeverityChange(level)
        } label: {
            Text("\(level)")
                .font(.system(size: 16, weight: severity == level ? .bold : .regular))
                .frame(width: 44, height: 44)
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
        if severity == level {
            return severityColor(for: level)
        }
        return Color(.secondarySystemBackground)
    }

    private func buttonForeground(for level: Int) -> Color {
        if severity == level {
            return .white
        }
        return .primary
    }

    private func buttonBorder(for level: Int) -> Color {
        if severity == level {
            return severityColor(for: level)
        }
        return Color(.separator)
    }

    private func severityColor(for level: Int) -> Color {
        switch level {
        case 1:
            return .green
        case 2:
            return Color(red: 0.6, green: 0.8, blue: 0.2)
        case 3:
            return .yellow
        case 4:
            return .orange
        case 5:
            return .red
        default:
            return .gray
        }
    }

    // MARK: - Accessibility

    private func severityAccessibilityLabel(for level: Int) -> String {
        let description: String
        switch level {
        case 1:
            description = "None"
        case 2:
            description = "Mild"
        case 3:
            description = "Moderate"
        case 4:
            description = "Significant"
        case 5:
            description = "Severe"
        default:
            description = "Unknown"
        }
        return "Severity \(level): \(description)"
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
