import SwiftUI

struct MedicationRowView: View {
    let medication: Medication

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(medication.name)
                        .font(.headline)

                    if medication.isDiuretic {
                        diureticBadge
                    }
                }

                Text(dosageText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !medication.schedule.isEmpty {
                    Text(medication.schedule)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to edit this medication")
    }

    // MARK: - Subviews

    private var diureticBadge: some View {
        Text("Diuretic")
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.15))
            .foregroundStyle(.blue)
            .clipShape(Capsule())
            .accessibilityLabel("This is a diuretic medication")
    }

    // MARK: - Computed Properties

    private var dosageText: String {
        let dosageFormatted: String
        if medication.dosage == floor(medication.dosage) {
            dosageFormatted = String(format: "%.0f", medication.dosage)
        } else {
            dosageFormatted = String(format: "%.1f", medication.dosage)
        }
        return "\(dosageFormatted) \(medication.unit)"
    }

    private var accessibilityLabel: String {
        var label = "\(medication.name), \(dosageText)"
        if medication.isDiuretic {
            label += ", diuretic"
        }
        if !medication.schedule.isEmpty {
            label += ", taken \(medication.schedule)"
        }
        return label
    }
}

#Preview {
    List {
        MedicationRowView(medication: Medication(
            name: "Furosemide",
            dosage: 40,
            unit: "mg",
            schedule: "Morning",
            isDiuretic: true
        ))

        MedicationRowView(medication: Medication(
            name: "Lisinopril",
            dosage: 10,
            unit: "mg",
            schedule: "Morning",
            isDiuretic: false
        ))

        MedicationRowView(medication: Medication(
            name: "Metoprolol",
            dosage: 25,
            unit: "mg",
            schedule: "Twice daily",
            isDiuretic: false
        ))
    }
}
