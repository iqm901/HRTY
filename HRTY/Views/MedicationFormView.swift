import SwiftUI
import SwiftData

struct MedicationFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isDosageFieldFocused: Bool
    @FocusState private var isSearchFieldFocused: Bool
    @State private var limitToHeartFailure: Bool = true

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

                // Global search bar (only when not editing and not showing selected medication)
                if !isEditing && !hasMedicationSelected {
                    searchSection
                }

                // Show appropriate content based on state
                if isEditing {
                    customMedicationSection
                } else if viewModel.entryMode == .custom {
                    customMedicationSection
                } else if viewModel.isSearchActive {
                    searchResultsSection
                } else {
                    // Show all medications when not searching
                    allMedicationsSection
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
                    if !isEditing && hasMedicationSelected {
                        // Back button when a medication is selected
                        Button("Back") {
                            clearMedicationSelection()
                        }
                    } else {
                        // Done button to dismiss the form
                        Button("Done") {
                            dismiss()
                            viewModel.resetForm()
                        }
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
                            viewModel.checkAndSaveMedication(context: modelContext)
                            // Reset form for next medication (don't dismiss) if no conflict warning
                            if viewModel.validationError == nil && !viewModel.showingConflictWarning {
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

    /// Whether any medication (preset or other) is currently selected
    private var hasMedicationSelected: Bool {
        viewModel.selectedPresetMedication != nil || viewModel.selectedOtherMedication != nil
    }

    /// Clear any medication selection
    private func clearMedicationSelection() {
        viewModel.selectPresetMedication(nil)
        viewModel.selectOtherMedication(nil)
    }

    // MARK: - Search Section

    private var searchSection: some View {
        Section {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.secondary)
                TextField("Search medications...", text: $viewModel.searchText)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .focused($isSearchFieldFocused)
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            Toggle("Limit to heart failure medications", isOn: $limitToHeartFailure)
                .font(.hrtCallout)
        }
    }

    // MARK: - Search Results Section

    /// Filtered search results based on the limitToHeartFailure toggle
    private var filteredSearchResults: (heartFailure: [HeartFailureMedication], other: [OtherMedication]) {
        if limitToHeartFailure {
            return (viewModel.heartFailureSearchResults, [])
        } else {
            return (viewModel.heartFailureSearchResults, viewModel.otherMedicationSearchResults)
        }
    }

    /// Whether there are any search results after applying the filter
    private var hasFilteredResults: Bool {
        !filteredSearchResults.heartFailure.isEmpty || !filteredSearchResults.other.isEmpty
    }

    private var searchResultsSection: some View {
        Group {
            if hasFilteredResults {
                // Heart Failure Medications results
                if !filteredSearchResults.heartFailure.isEmpty {
                    Section {
                        ForEach(filteredSearchResults.heartFailure) { medication in
                            Button {
                                selectFromSearch(heartFailureMedication: medication)
                            } label: {
                                HStack {
                                    Text(medication.displayName)
                                        .font(.hrtBody)
                                        .foregroundStyle(Color.hrtTextFallback)
                                    Spacer()
                                    Text("HF")
                                        .font(.hrtCaption2)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, HRTSpacing.sm)
                                        .padding(.vertical, HRTSpacing.xs)
                                        .background(Color.hrtPinkFallback.opacity(0.2))
                                        .foregroundStyle(Color.hrtPinkFallback)
                                        .clipShape(Capsule())
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text("Heart Failure Medications")
                    }
                }

                // Other Medications results (only shown when not limited to HF)
                if !filteredSearchResults.other.isEmpty {
                    Section {
                        ForEach(filteredSearchResults.other) { medication in
                            Button {
                                selectFromSearch(otherMedication: medication)
                            } label: {
                                HStack {
                                    Text(medication.displayName)
                                        .font(.hrtBody)
                                        .foregroundStyle(Color.hrtTextFallback)
                                    Spacer()
                                    Text("Other")
                                        .font(.hrtCaption2)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, HRTSpacing.sm)
                                        .padding(.vertical, HRTSpacing.xs)
                                        .background(Color.secondary.opacity(0.2))
                                        .foregroundStyle(Color.secondary)
                                        .clipShape(Capsule())
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text("Other Medications")
                    }
                }
            } else {
                Section {
                    Text("No medications found for \"\(viewModel.searchText)\"")
                        .foregroundStyle(Color.secondary)
                        .font(.hrtCallout)

                    Button {
                        viewModel.entryMode = .custom
                        viewModel.nameInput = viewModel.searchText
                        viewModel.clearSearch()
                        isSearchFieldFocused = false
                    } label: {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text("Manually enter Medication")
                        }
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtPinkFallback)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    /// Select a Heart Failure medication from search results
    private func selectFromSearch(heartFailureMedication medication: HeartFailureMedication) {
        viewModel.clearSearch()
        viewModel.entryMode = .heartFailure
        viewModel.selectPresetMedication(medication)
        isSearchFieldFocused = false
    }

    /// Select an Other medication from search results
    private func selectFromSearch(otherMedication medication: OtherMedication) {
        viewModel.clearSearch()
        viewModel.entryMode = .other
        viewModel.selectOtherMedication(medication)
        isSearchFieldFocused = false
    }

    // MARK: - All Medications Section (when not searching)

    private var allMedicationsSection: some View {
        Group {
            // Check if a medication is selected (either HF or Other)
            if let selectedMed = viewModel.selectedPresetMedication {
                selectedHeartFailureMedicationSection(selectedMed)
            } else if let selectedMed = viewModel.selectedOtherMedication {
                selectedOtherMedicationSection(selectedMed)
            } else {
                // Show all medications filtered by checkbox
                Section {
                    ForEach(filteredMedications) { medication in
                        Button {
                            viewModel.selectPresetMedication(medication)
                        } label: {
                            HStack {
                                Text(medication.displayName)
                                    .font(.hrtBody)
                                    .foregroundStyle(Color.hrtTextFallback)
                                Spacer()
                                Text("HF")
                                    .font(.hrtCaption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, HRTSpacing.sm)
                                    .padding(.vertical, HRTSpacing.xs)
                                    .background(Color.hrtPinkFallback.opacity(0.2))
                                    .foregroundStyle(Color.hrtPinkFallback)
                                    .clipShape(Capsule())
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // Show other medications if not limited to HF
                    if !limitToHeartFailure {
                        ForEach(filteredOtherMedications) { medication in
                            Button {
                                viewModel.selectOtherMedication(medication)
                            } label: {
                                HStack {
                                    Text(medication.displayName)
                                        .font(.hrtBody)
                                        .foregroundStyle(Color.hrtTextFallback)
                                    Spacer()
                                    Text("Other")
                                        .font(.hrtCaption2)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, HRTSpacing.sm)
                                        .padding(.vertical, HRTSpacing.xs)
                                        .background(Color.secondary.opacity(0.2))
                                        .foregroundStyle(Color.secondary)
                                        .clipShape(Capsule())
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Medications")
                }
            }
        }
    }

    /// Section shown when a heart failure medication is selected
    private func selectedHeartFailureMedicationSection(_ selectedMed: HeartFailureMedication) -> some View {
        Group {
            Section {
                Text(selectedMed.displayName)
                    .font(.hrtBody)
                    .foregroundStyle(Color.hrtTextFallback)
            } header: {
                Text("Medication")
            }

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
            }
        }
    }

    /// Section shown when an other medication is selected
    private func selectedOtherMedicationSection(_ selectedMed: OtherMedication) -> some View {
        Group {
            Section {
                Text(selectedMed.displayName)
                    .font(.hrtBody)
                    .foregroundStyle(Color.hrtTextFallback)
            } header: {
                Text("Medication")
            }

            Section {
                Picker("Dosage", selection: Binding(
                    get: { viewModel.otherMedicationSelectedDosageOption },
                    set: { viewModel.selectOtherMedicationDosage($0) }
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

            Section {
                Picker("Frequency", selection: $viewModel.otherMedicationSelectedFrequency) {
                    ForEach(HeartFailureMedication.frequencyOptions, id: \.self) { frequency in
                        Text(frequency).tag(frequency)
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: viewModel.otherMedicationSelectedFrequency) { _, newValue in
                    viewModel.scheduleInput = newValue
                }
            } header: {
                Text("Frequency")
            }
        }
    }

    /// All heart failure medications sorted alphabetically
    private var filteredMedications: [HeartFailureMedication] {
        HeartFailureMedication.allMedications
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }

    /// All other medications sorted alphabetically
    private var filteredOtherMedications: [OtherMedication] {
        OtherMedication.allMedications
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
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
                        .keyboardType(.numbersAndPunctuation)
                        .focused($isDosageFieldFocused)
                        .accessibilityLabel("Dosage amount")
                        .accessibilityHint("Enter the dosage number or combination like 49/51")
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
                if !viewModel.dosageInput.isEmpty && !viewModel.isValidDosage {
                    Text("Please enter a valid dosage (e.g., 50 or 49/51)")
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

    return MedicationFormView(
        viewModel: viewModel,
        isEditing: true
    )
    .modelContainer(for: Medication.self, inMemory: true)
}
