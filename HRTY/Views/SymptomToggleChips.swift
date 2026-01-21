import SwiftUI

struct SymptomToggleChips: View {
    let symptoms: [SymptomType]
    let isVisible: (SymptomType) -> Bool
    let colorForSymptom: (SymptomType) -> Color
    let onToggle: (SymptomType) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(symptoms, id: \.self) { symptom in
                    SymptomChip(
                        symptom: symptom,
                        isSelected: isVisible(symptom),
                        color: colorForSymptom(symptom),
                        onTap: { onToggle(symptom) }
                    )
                }
            }
            .padding(.horizontal, 1) // Prevent clipping
        }
    }
}

struct SymptomChip: View {
    let symptom: SymptomType
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)

                Text(shortName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color.opacity(0.15) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? color : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(symptom.displayName), \(isSelected ? "showing" : "hidden")")
        .accessibilityHint("Double tap to \(isSelected ? "hide" : "show") this symptom on the chart")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var shortName: String {
        switch symptom {
        case .dyspneaAtRest:
            return "Rest"
        case .dyspneaOnExertion:
            return "Activity"
        case .orthopnea:
            return "Lying flat"
        case .pnd:
            return "Night"
        case .chestPain:
            return "Chest"
        case .dizziness:
            return "Dizzy"
        case .syncope:
            return "Faint"
        case .reducedUrineOutput:
            return "Urine"
        }
    }
}

#Preview {
    SymptomToggleChips(
        symptoms: SymptomType.allCases,
        isVisible: { $0 == .dyspneaAtRest || $0 == .dizziness },
        colorForSymptom: { type in
            switch type {
            case .dyspneaAtRest: return .blue
            case .dyspneaOnExertion: return .cyan
            case .orthopnea: return .purple
            case .pnd: return .indigo
            case .chestPain: return .red
            case .dizziness: return .orange
            case .syncope: return .pink
            case .reducedUrineOutput: return .brown
            }
        },
        onToggle: { _ in }
    )
    .padding()
}
