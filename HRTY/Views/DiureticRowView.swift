import SwiftUI

struct DiureticRowView: View {
    let medication: Medication
    let doses: [DiureticDose]
    let onLogStandardDose: () -> Void
    let onLogCustomDose: () -> Void
    let onDeleteDose: (DiureticDose) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            medicationHeader

            if !doses.isEmpty {
                todaysDoses
            }

            actionButtons
        }
        .padding(.vertical, 8)
    }

    // MARK: - Medication Header

    private var medicationHeader: some View {
        HStack(spacing: 8) {
            Text(medication.name)
                .font(.headline)

            Text(dosageText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(medication.name), \(dosageText)")
    }

    private var dosageText: String {
        let dosageFormatted: String
        if medication.dosage == floor(medication.dosage) {
            dosageFormatted = String(format: "%.0f", medication.dosage)
        } else {
            dosageFormatted = String(format: "%.1f", medication.dosage)
        }
        return "\(dosageFormatted) \(medication.unit)"
    }

    // MARK: - Today's Doses

    private var todaysDoses: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Today:")
                .font(.caption)
                .foregroundStyle(.tertiary)

            FlowLayout(spacing: 8) {
                ForEach(doses, id: \.persistentModelID) { dose in
                    doseChip(dose)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Today's doses")
    }

    private func doseChip(_ dose: DiureticDose) -> some View {
        HStack(spacing: 4) {
            Text(formattedTime(dose.timestamp))
                .font(.caption)

            Text("(\(formattedDosage(dose.dosageAmount)))")
                .font(.caption)
                .foregroundStyle(.secondary)

            if dose.isExtraDose {
                extraBadge
            }

            Button {
                onDeleteDose(dose)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete dose")
            .accessibilityHint("Double tap to remove this dose")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.tertiarySystemBackground))
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(doseAccessibilityLabel(dose))
    }

    private var extraBadge: some View {
        Text("extra")
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(Color.orange.opacity(0.2))
            .foregroundStyle(.orange)
            .clipShape(Capsule())
            .accessibilityHidden(true)
    }

    private func doseAccessibilityLabel(_ dose: DiureticDose) -> String {
        var label = "\(formattedTime(dose.timestamp)), \(formattedDosage(dose.dosageAmount))"
        if dose.isExtraDose {
            label += ", extra dose"
        }
        return label
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                onLogStandardDose()
            } label: {
                Label("Log Standard Dose", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .accessibilityLabel("Log standard dose")
            .accessibilityHint("Double tap to log \(dosageText) now")

            Button {
                onLogCustomDose()
            } label: {
                Text("Custom")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Log custom dose")
            .accessibilityHint("Double tap to log a different amount or extra dose")
        }
    }

    // MARK: - Formatting Helpers

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formattedDosage(_ amount: Double) -> String {
        if amount == floor(amount) {
            return "\(Int(amount)) \(medication.unit)"
        } else {
            return String(format: "%.1f %@", amount, medication.unit)
        }
    }
}

// MARK: - Flow Layout for Dose Chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        let totalHeight = currentY + lineHeight
        let totalWidth = proposal.width ?? currentX

        return (CGSize(width: totalWidth, height: totalHeight), positions)
    }
}

#Preview {
    let medication = Medication(
        name: "Furosemide",
        dosage: 40,
        unit: "mg",
        schedule: "Morning",
        isDiuretic: true
    )

    return VStack(spacing: 24) {
        DiureticRowView(
            medication: medication,
            doses: [],
            onLogStandardDose: {},
            onLogCustomDose: {},
            onDeleteDose: { _ in }
        )

        Divider()

        DiureticRowView(
            medication: medication,
            doses: [
                DiureticDose(dosageAmount: 40, timestamp: Date(), isExtraDose: false),
                DiureticDose(dosageAmount: 40, timestamp: Date().addingTimeInterval(-3600), isExtraDose: true)
            ],
            onLogStandardDose: {},
            onLogCustomDose: {},
            onDeleteDose: { _ in }
        )
    }
    .padding()
}
