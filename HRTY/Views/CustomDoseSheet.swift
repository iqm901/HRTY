import SwiftUI

struct CustomDoseSheet: View {
    let medication: Medication
    let onSave: (Double, Bool, Date) -> Void
    let onCancel: () -> Void

    @State private var dosageText: String = ""
    @State private var isExtraDose: Bool = false
    @State private var timestamp: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                medicationSection
                dosageSection
                extraDoseSection
                timeSection
            }
            .navigationTitle("Log Dose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                dosageText = formatDosage(medication.dosage)
            }
        }
    }

    // MARK: - Sections

    private var medicationSection: some View {
        Section {
            HStack {
                Text(medication.name)
                    .font(.headline)
                Spacer()
                Text("Standard: \(formatDosage(medication.dosage)) \(medication.unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(medication.name), standard dose \(formatDosage(medication.dosage)) \(medication.unit)")
        }
    }

    private var dosageSection: some View {
        Section {
            HStack {
                TextField("Amount", text: $dosageText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("Dosage amount")
                    .accessibilityHint("Enter the amount in \(medication.unit)")

                Text(medication.unit)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Dosage")
        } footer: {
            if !isValidDosage && !dosageText.isEmpty {
                Text("Please enter a valid amount")
                    .foregroundStyle(.red)
            }
        }
    }

    private var extraDoseSection: some View {
        Section {
            Toggle(isOn: $isExtraDose) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Extra Dose")
                    Text("Mark if this is outside your normal schedule")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityLabel("Extra dose toggle")
            .accessibilityHint("Turn on if this dose is outside your normal schedule")
            .accessibilityValue(isExtraDose ? "On" : "Off")
        }
    }

    private var timeSection: some View {
        Section {
            DatePicker(
                "Time",
                selection: $timestamp,
                in: ...Date(),
                displayedComponents: .hourAndMinute
            )
            .accessibilityLabel("Dose time")
            .accessibilityHint("Select when you took this dose")
        } header: {
            Text("When did you take it?")
        }
    }

    // MARK: - Validation

    private var parsedDosage: Double? {
        Double(dosageText)
    }

    private var isValidDosage: Bool {
        guard let dosage = parsedDosage else { return false }
        return dosage > 0 && dosage <= 1000
    }

    private var isFormValid: Bool {
        isValidDosage
    }

    // MARK: - Actions

    private func save() {
        guard let dosage = parsedDosage, isFormValid else { return }
        onSave(dosage, isExtraDose, timestamp)
    }

    // MARK: - Helpers

    private func formatDosage(_ value: Double) -> String {
        if value == floor(value) {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

#Preview {
    CustomDoseSheet(
        medication: Medication(
            name: "Furosemide",
            dosage: 40,
            unit: "mg",
            schedule: "Morning",
            isDiuretic: true
        ),
        onSave: { amount, isExtra, time in
            print("Save: \(amount), extra: \(isExtra), time: \(time)")
        },
        onCancel: {
            print("Cancel")
        }
    )
}
