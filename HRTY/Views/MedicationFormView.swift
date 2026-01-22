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
                // Success message when medication is saved
                if let message = viewModel.medicationSavedMessage {
                    Section {
                        HStack(spacing: HRTSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.hrtGoodFallback)
                            Text(message)
                                .foregroundStyle(Color.hrtGoodFallback)
                        }
                        .font(.hrtCallout)
                    }
                }

                if !isEditing {
                    medicationTypeSection
                }

                if viewModel.usePresetMedication && !isEditing {
                    presetMedicationSection
                } else {
                    customMedicationSection
                }

                if let error = viewModel.validationError {
                    Section {
                        Text(error)
                            .foregroundStyle(Color.hrtAlertFallback)
                            .font(.hrtCallout)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Medication" : "Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                        viewModel.resetForm()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        if isEditing {
                            viewModel.updateMedication(context: modelContext)
                            // Dismiss after editing
                            if viewModel.validationError == nil {
                                dismiss()
                            }
                        } else {
                            viewModel.saveMedication(context: modelContext)
                            // Reset form for next medication (don't dismiss)
                            if viewModel.validationError == nil {
                                viewModel.resetForm()
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isFormValid)
                }
            }
            .onChange(of: viewModel.nameInput) { _, _ in
                viewModel.clearSavedMessage()
            }
        }
    }

    // MARK: - Medication Type Toggle

    private var medicationTypeSection: some View {
        Section {
            Picker("Entry Type", selection: $viewModel.usePresetMedication) {
                Text("Heart Failure Meds").tag(true)
                Text("Custom Entry").tag(false)
            }
            .pickerStyle(.segmented)
        } footer: {
            Text(viewModel.usePresetMedication
                 ? "Select from common heart failure medications"
                 : "Enter any medication manually")
        }
    }

    // MARK: - Preset Medication Selection

    private var presetMedicationSection: some View {
        Group {
            // Medication Picker
            Section {
                Picker("Medication", selection: Binding(
                    get: { viewModel.selectedPresetMedication },
                    set: { viewModel.selectPresetMedication($0) }
                )) {
                    Text("Select a medication").tag(nil as HeartFailureMedication?)

                    ForEach(HeartFailureMedication.medicationsByCategory, id: \.category) { category, medications in
                        Section(header: Text(category.rawValue)) {
                            ForEach(medications) { medication in
                                Text(medication.displayName).tag(medication as HeartFailureMedication?)
                            }
                        }
                    }
                }
                .pickerStyle(.navigationLink)
            } header: {
                Text("Medication")
            }

            // Dosage Picker (only shown when medication is selected)
            if let selectedMed = viewModel.selectedPresetMedication {
                Section {
                    Picker("Dosage", selection: Binding(
                        get: { viewModel.selectedDosageOption },
                        set: { viewModel.selectDosage($0) }
                    )) {
                        Text("Select dosage").tag("")
                        ForEach(selectedMed.availableDosages, id: \.self) { dosage in
                            Text("\(dosage) \(selectedMed.unit)").tag(dosage)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("Dosage")
                }

                // Frequency Picker
                Section {
                    Picker("Frequency", selection: $viewModel.selectedFrequency) {
                        ForEach(HeartFailureMedication.frequencyOptions, id: \.self) { frequency in
                            Text(frequency).tag(frequency)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: viewModel.selectedFrequency) { _, newValue in
                        viewModel.scheduleInput = newValue
                    }
                } header: {
                    Text("Frequency")
                } footer: {
                    if selectedMed.isDiuretic {
                        Label("This is a diuretic - doses will be tracked on the Today screen", systemImage: "drop.fill")
                            .font(.hrtCaption)
                            .foregroundStyle(Color.hrtPinkFallback)
                    }
                }
            }
        }
    }

    // MARK: - Custom Medication Entry

    private var customMedicationSection: some View {
        Group {
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
                if !viewModel.dosageInput.isEmpty && viewModel.parsedDosage == nil {
                    Text("Please enter a valid number for dosage")
                        .foregroundStyle(Color.hrtAlertFallback)
                } else {
                    Text("Enter the medication name and dosage as shown on your prescription.")
                }
            }

            Section {
                TextField("e.g., Once daily, Twice daily", text: $viewModel.scheduleInput)
                    .textContentType(.none)
                    .accessibilityLabel("Schedule")
                    .accessibilityHint("Enter when you take this medication, this is optional")
            } header: {
                Text("Schedule (Optional)")
            } footer: {
                Text("When do you typically take this medication?")
            }

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
