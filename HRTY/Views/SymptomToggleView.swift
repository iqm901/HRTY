import SwiftUI

struct SymptomToggleView: View {
    @Binding var toggleStates: [SymptomType: Bool]
    let onToggle: (SymptomType) -> Void
    @State private var isExpanded = false

    private var selectedCount: Int {
        toggleStates.values.filter { $0 }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header row (tappable)
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Select symptoms")
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtTextFallback)
                    Spacer()
                    Text("\(selectedCount) of 8")
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }
                .padding(HRTSpacing.md)
                .background(Color.hrtCardFallback)
                .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Select symptoms")
            .accessibilityValue("\(selectedCount) of 8 selected")
            .accessibilityHint("Double tap to \(isExpanded ? "collapse" : "expand") symptom list")

            // Expandable list
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(SymptomType.allCases, id: \.self) { symptomType in
                        SymptomToggleRow(
                            symptomType: symptomType,
                            isSelected: toggleStates[symptomType] ?? true,
                            onTap: { onToggle(symptomType) }
                        )
                        if symptomType != SymptomType.allCases.last {
                            Divider().padding(.leading, HRTSpacing.md)
                        }
                    }
                }
                .background(Color.hrtCardFallback)
                .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
                .padding(.top, HRTSpacing.xs)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

struct SymptomToggleRow: View {
    let symptomType: SymptomType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(TrendsViewModel.color(for: symptomType))
                    .frame(width: 10, height: 10)
                Text(symptomType.displayName)
                    .font(.hrtBody)
                    .foregroundStyle(Color.hrtTextFallback)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.hrtPinkFallback : Color.hrtTextTertiaryFallback)
            }
            .padding(HRTSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(symptomType.displayName)
        .accessibilityValue(isSelected ? "selected" : "not selected")
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
            .background(Color.hrtBackgroundFallback)
        }
    }

    return PreviewWrapper()
}
