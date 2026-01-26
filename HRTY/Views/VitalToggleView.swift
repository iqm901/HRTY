import SwiftUI

/// Horizontal scrolling pill button selector for vital sign types in the Trends view
struct VitalToggleView: View {
    @Binding var selectedVital: VitalType

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(VitalType.allCases, id: \.self) { vitalType in
                    VitalToggleChip(
                        vitalType: vitalType,
                        isSelected: selectedVital == vitalType,
                        onTap: { selectedVital = vitalType }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Vital sign filters")
        .accessibilityHint("Select which vital sign to view")
    }
}

/// Individual pill button for a vital sign type
struct VitalToggleChip: View {
    let vitalType: VitalType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: vitalType.icon)
                    .font(.caption)

                Text(vitalType.label)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected
                          ? vitalType.color.opacity(0.15)
                          : Color(.secondarySystemBackground))
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected
                        ? vitalType.color.opacity(0.5)
                        : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? vitalType.color : .secondary)
        .accessibilityLabel(vitalType.label)
        .accessibilityValue(isSelected ? "selected" : "not selected")
        .accessibilityHint("Double tap to view \(vitalType.label) chart")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedVital: VitalType = .overview

        var body: some View {
            VStack(spacing: 20) {
                VitalToggleView(selectedVital: $selectedVital)

                Text("Selected: \(selectedVital.label)")
                    .font(.headline)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
