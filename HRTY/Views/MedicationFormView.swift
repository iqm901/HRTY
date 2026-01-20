import SwiftUI
import SwiftData

struct MedicationFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isDosageFieldFocused: Bool

    @Bindable var viewModel: MedicationsViewModel
    let isEditing: Bool

    var body: some View {
        NavigationStack {
            Form {
                medicationDetailsSection
                scheduleSection
                diureticSection

                if let error = viewModel.validationError {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.callout)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Medication" : "Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                        viewModel.resetForm()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if isEditing {
                            viewModel.updateMedication(context: modelContext)
                        } else {
                            viewModel.saveMedication(context: modelContext)
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Sections

    private var medicationDetailsSection: some View {
        Section {
            TextField("Medication name", text: $viewModel.nameInput)
                .textContentType(.none)
                .autocorrectionDisabled()
                .accessibilityLabel("Medication name")
                .accessibilityHint("Enter the name of the medication")

            HStack {
                TextField("Dosage", text: $viewModel.dosageInput)
                    .keyboardType(.decimalPad)
                    .focused($isDosageFieldFocused)
                    .accessibilityLabel("Dosage amount")
                    .accessibilityHint("Enter the dosage number")
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isDosageFieldFocused = false
                            }
                        }
                    }

                Picker("Unit", selection: $viewModel.selectedUnit) {
                    ForEach(Medication.availableUnits, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .labelsHidden()
                .accessibilityLabel("Dosage unit")
                .accessibilityHint("Select the unit of measurement")
            }
        } header: {
            Text("Medication Details")
        } footer: {
            Text("Enter the medication name and dosage as shown on your prescription.")
        }
    }

    private var scheduleSection: some View {
        Section {
            TextField("e.g., Morning, Twice daily", text: $viewModel.scheduleInput)
                .textContentType(.none)
                .accessibilityLabel("Schedule")
                .accessibilityHint("Enter when you take this medication, this is optional")
        } header: {
            Text("Schedule (Optional)")
        } footer: {
            Text("When do you typically take this medication?")
        }
    }

    private var diureticSection: some View {
        Section {
            Toggle(isOn: $viewModel.isDiuretic) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This is a diuretic")
                        .font(.body)
                    Text("Water pills that help remove extra fluid")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityLabel("Diuretic medication toggle")
            .accessibilityHint("Turn on if this is a diuretic, also known as a water pill")
        } footer: {
            Text("Diuretics are tracked separately to help monitor your daily fluid management.")
        }
    }
}

#Preview("Add Medication") {
    MedicationFormView(
        viewModel: MedicationsViewModel(),
        isEditing: false
    )
    .modelContainer(for: Medication.self, inMemory: true)
}

#Preview("Edit Medication") {
    let viewModel = MedicationsViewModel()
    viewModel.nameInput = "Furosemide"
    viewModel.dosageInput = "40"
    viewModel.selectedUnit = "mg"
    viewModel.scheduleInput = "Morning"
    viewModel.isDiuretic = true

    return MedicationFormView(
        viewModel: viewModel,
        isEditing: true
    )
    .modelContainer(for: Medication.self, inMemory: true)
}
