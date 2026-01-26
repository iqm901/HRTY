import SwiftUI

struct MedicationRowView: View {
    let medication: Medication
    var isInConflict: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: HRTSpacing.sm) {
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                HStack(spacing: HRTSpacing.sm) {
                    Text(medication.name)
                        .font(.hrtBodySemibold)
                        .foregroundStyle(Color.hrtTextFallback)

                    if isInConflict {
                        reviewBadge
                    }
                }

                Text(dosageText)
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                if !medication.schedule.isEmpty {
                    Text(medication.schedule)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, HRTSpacing.xs)
        .padding(.horizontal, isInConflict ? HRTSpacing.sm : 0)
        .background(isInConflict ? Color.conflictBackground : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: isInConflict ? HRTRadius.small : 0))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to edit this medication")
    }

    // MARK: - Subviews

    private var diureticBadge: some View {
        Text("Diuretic")
            .font(.hrtSmall)
            .fontWeight(.medium)
            .padding(.horizontal, HRTSpacing.sm)
            .padding(.vertical, 2)
            .background(Color.hrtPinkLightFallback)
            .foregroundStyle(Color.hrtPinkFallback)
            .clipShape(Capsule())
            .accessibilityLabel("This is a diuretic medication")
    }

    private var reviewBadge: some View {
        Text("Review")
            .font(.hrtSmall)
            .fontWeight(.medium)
            .padding(.horizontal, HRTSpacing.sm)
            .padding(.vertical, 2)
            .background(Color.conflictBadgeBackground)
            .foregroundStyle(Color.conflictBadgeText)
            .clipShape(Capsule())
            .accessibilityLabel("This medication may need review")
    }

    // MARK: - Computed Properties

    private var dosageText: String {
        "\(medication.dosage) \(medication.unit)"
    }

    private var accessibilityLabel: String {
        var label = "\(medication.name), \(dosageText)"
        if medication.isDiuretic {
            label += ", diuretic"
        }
        if isInConflict {
            label += ", needs review with care team"
        }
        if !medication.schedule.isEmpty {
            label += ", taken \(medication.schedule)"
        }
        return label
    }
}

// MARK: - Conflict Colors

private extension Color {
    /// Warm amber/yellow background for medications in conflict
    static let conflictBackground = Color.adaptive(
        light: Color(red: 255/255, green: 251/255, blue: 235/255),
        dark: Color(red: 60/255, green: 50/255, blue: 30/255)
    )

    /// Background for the "Review" badge
    static let conflictBadgeBackground = Color.adaptive(
        light: Color(red: 254/255, green: 243/255, blue: 199/255),
        dark: Color(red: 80/255, green: 65/255, blue: 30/255)
    )

    /// Text color for the "Review" badge
    static let conflictBadgeText = Color.adaptive(
        light: Color(red: 180/255, green: 130/255, blue: 20/255),
        dark: Color(red: 250/255, green: 200/255, blue: 80/255)
    )
}

#Preview {
    List {
        MedicationRowView(medication: Medication(
            name: "Furosemide",
            dosage: "40",
            unit: "mg",
            schedule: "Morning",
            isDiuretic: true
        ), isInConflict: true)

        MedicationRowView(medication: Medication(
            name: "Bumetanide",
            dosage: "1",
            unit: "mg",
            schedule: "Morning",
            isDiuretic: true
        ), isInConflict: true)

        MedicationRowView(medication: Medication(
            name: "Lisinopril",
            dosage: "10",
            unit: "mg",
            schedule: "Morning",
            isDiuretic: false
        ))

        MedicationRowView(medication: Medication(
            name: "Metoprolol",
            dosage: "25",
            unit: "mg",
            schedule: "Twice daily",
            isDiuretic: false
        ))
    }
}
