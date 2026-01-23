import SwiftUI

struct SymptomToggleView: View {
    @Binding var toggleStates: [SymptomType: Bool]
    let onToggle: (SymptomType) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SymptomType.allCases, id: \.self) { symptomType in
                    SymptomToggleChip(
                        symptomType: symptomType,
                        isSelected: toggleStates[symptomType] ?? true,
                        onTap: { onToggle(symptomType) }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Symptom filters")
        .accessibilityHint("Toggle symptoms to show or hide them on the chart")
    }
}

struct SymptomToggleChip: View {
    let symptomType: SymptomType
    let isSelected: Bool
    let onTap: () -> Void

    private var shortName: String {
        switch symptomType {
        case .dyspneaAtRest:
            return "Breath at rest"
        case .dyspneaOnExertion:
            return "Breath on activity"
        case .orthopnea:
            return "Lying flat"
        case .pnd:
            return "Night breathing"
        case .chestPain:
            return "Chest"
        case .dizziness:
            return "Dizzy"
        case .syncope:
            return "Fainting"
        case .reducedUrineOutput:
            return "Urine"
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Circle()
                    .fill(TrendsViewModel.color(for: symptomType))
                    .frame(width: 8, height: 8)

                Text(shortName)
                    .font(.caption)
                    .fontWeight(isSelected ? .medium : .regular)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected
                          ? TrendsViewModel.color(for: symptomType).opacity(0.15)
                          : Color(.secondarySystemBackground))
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected
                        ? TrendsViewModel.color(for: symptomType).opacity(0.5)
                        : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .primary : .secondary)
        .accessibilityLabel("\(symptomType.displayName)")
        .accessibilityValue(isSelected ? "showing" : "hidden")
        .accessibilityHint("Double tap to \(isSelected ? "hide" : "show") this symptom on the chart")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var toggleStates: [SymptomType: Bool] = {
            var states: [SymptomType: Bool] = [:]
            for type in SymptomType.allCases {
                states[type] = true
            }
            states[.chestPain] = false
            return states
        }()

        var body: some View {
            VStack {
                SymptomToggleView(
                    toggleStates: $toggleStates,
                    onToggle: { type in
                        toggleStates[type] = !(toggleStates[type] ?? true)
                    }
                )
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
