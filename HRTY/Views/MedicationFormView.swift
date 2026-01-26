import SwiftUI
import SwiftData

// MARK: - Heart Failure Medication Category Tabs

enum MedicationTab: String, CaseIterable {
    case all = "All"
    case betaBlocker = "Beta Blockers"
    case raasInhibitor = "RAAS Inhibitors"
    case mra = "MRA"
    case sglt2 = "SGLT2 Inhibitors"
    case diuretic = "Diuretics"
    case other = "Other"

    /// Returns the HeartFailureMedication.Category values that belong to this tab
    var includedCategories: [HeartFailureMedication.Category] {
        switch self {
        case .all:
            return HeartFailureMedication.Category.allCases
        case .betaBlocker:
            return [.betaBlocker]
        case .raasInhibitor:
            return [.aceInhibitor, .arb, .arni]
        case .mra:
            return [.mra]
        case .sglt2:
            return [.sglt2Inhibitor]
        case .diuretic:
            return [.loopDiuretic, .thiazideDiuretic]
        case .other:
            return [.other]
        }
    }
}

// MARK: - Other Medication Category Tabs

enum OtherMedicationTab: String, CaseIterable {
    case all = "All"
    case statins = "Statins"
    case anticoagulants = "Anticoag"
    case antiplatelets = "Antiplatelets"
    case ccb = "CCBs"
    case antiarrhythmics = "Antiarrhythm"
    case nitrates = "Nitrates"
    case betaBlockers = "Beta Block"
    case aceArb = "ACE-I/ARBs"
    case diuretics = "Diuretics"
    case diabetes = "Diabetes"
    case other = "Other"

    /// Returns the OtherMedicationCategory values that belong to this tab
    var includedCategories: [OtherMedicationCategory] {
        switch self {
        case .all:
            return OtherMedicationCategory.allCases
        case .statins:
            return [.statin]
        case .anticoagulants:
            return [.anticoagulant]
        case .antiplatelets:
            return [.antiplatelet]
        case .ccb:
            return [.calciumChannelBlockerDHP, .calciumChannelBlockerNonDHP]
        case .antiarrhythmics:
            return [.antiarrhythmic]
        case .nitrates:
            return [.nitrate]
        case .betaBlockers:
            return [.additionalBetaBlocker]
        case .aceArb:
            return [.additionalAceInhibitor, .additionalArb]
        case .diuretics:
            return [.additionalDiuretic, .potassiumSupplement]
        case .diabetes:
            return [.glp1Agonist, .diabetesMed]
        case .other:
            return [.alphaBlocker, .centralAgent, .thyroid, .pulmonaryHTN, .other]
        }
    }
}

struct MedicationFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isDosageFieldFocused: Bool
    @FocusState private var isSearchFieldFocused: Bool
    @State private var selectedTab: MedicationTab = .all
    @State private var selectedOtherTab: OtherMedicationTab = .all

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

                // Show search results when searching, otherwise show regular content
                if viewModel.isSearchActive && !isEditing {
                    searchResultsSection
                } else {
                    // Entry mode toggle (only when not editing)
                    if !isEditing {
                        medicationTypeSection
                    }

                    // Show appropriate section based on entry mode
                    if !isEditing {
                        switch viewModel.entryMode {
                        case .heartFailure:
                            presetMedicationSection
                        case .other:
                            otherMedicationSection
                        case .custom:
                            customMedicationSection
                        }
                    } else {
                        customMedicationSection
                    }
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
                TextField("Search all medications...", text: $viewModel.searchText)
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
        }
    }

    // MARK: - Search Results Section

    private var searchResultsSection: some View {
        Group {
            if viewModel.hasSearchResults {
                // Heart Failure Medications results
                if !viewModel.heartFailureSearchResults.isEmpty {
                    Section {
                        ForEach(viewModel.heartFailureSearchResults) { medication in
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

                // Other Medications results
                if !viewModel.otherMedicationSearchResults.isEmpty {
                    Section {
                        ForEach(viewModel.otherMedicationSearchResults) { medication in
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

    // MARK: - Medication Type Toggle

    private var medicationTypeSection: some View {
        Section {
            Picker("Entry Type", selection: $viewModel.entryMode) {
                ForEach(MedicationEntryMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.entryMode) { _, _ in
                // Clear selection when switching modes
                clearMedicationSelection()
            }
        } footer: {
            Text(entryModeFooterText)
        }
    }

    private var entryModeFooterText: String {
        switch viewModel.entryMode {
        case .heartFailure:
            return "Select from common heart failure medications"
        case .other:
            return "Select from other cardiac medications"
        case .custom:
            return "Enter any medication manually"
        }
    }

    // MARK: - Preset Medication Selection

    /// Medications filtered by the currently selected tab, sorted alphabetically
    private var filteredMedications: [HeartFailureMedication] {
        HeartFailureMedication.allMedications
            .filter { medication in
                selectedTab.includedCategories.contains(medication.category)
            }
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }

    private var presetMedicationSection: some View {
        Group {
            if let selectedMed = viewModel.selectedPresetMedication {
                // SELECTED STATE: Show selected medication and dosage/frequency options
                Section {
                    Text(selectedMed.displayName)
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtTextFallback)
                } header: {
                    Text("Medication")
                }

                // Dosage Picker
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
                }
            } else {
                // UNSELECTED STATE: Show category tabs and medication list
                Section {
                    categoryTabBar
                } header: {
                    Text("Category")
                }

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
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Medication")
                }
            }
        }
    }

    // MARK: - Other Medication Selection

    /// Other medications filtered by the currently selected tab, sorted alphabetically
    private var filteredOtherMedications: [OtherMedication] {
        OtherMedication.allMedications
            .filter { medication in
                selectedOtherTab.includedCategories.contains(medication.category)
            }
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }

    private var otherMedicationSection: some View {
        Group {
            if let selectedMed = viewModel.selectedOtherMedication {
                // SELECTED STATE: Show selected medication and dosage/frequency options
                Section {
                    Text(selectedMed.displayName)
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtTextFallback)
                } header: {
                    Text("Medication")
                }

                // Dosage Picker
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

                // Frequency Picker
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
            } else {
                // UNSELECTED STATE: Show category tabs and medication list
                Section {
                    otherCategoryTabBar
                } header: {
                    Text("Category")
                }

                Section {
                    ForEach(filteredOtherMedications) { medication in
                        Button {
                            viewModel.selectOtherMedication(medication)
                        } label: {
                            HStack {
                                Text(medication.displayName)
                                    .font(.hrtBody)
                                    .foregroundStyle(Color.hrtTextFallback)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Medication")
                }
            }
        }
    }

    // MARK: - Category Tab Bar (Heart Failure)

    private var categoryTabBar: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80, maximum: 120), spacing: HRTSpacing.sm)
        ]

        return LazyVGrid(columns: columns, spacing: HRTSpacing.sm) {
            ForEach(MedicationTab.allCases, id: \.self) { tab in
                MedicationTabPill(
                    title: tab.rawValue,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                        // Clear selection when changing tabs
                        if viewModel.selectedPresetMedication != nil {
                            let currentCategory = viewModel.selectedPresetMedication?.category
                            if let category = currentCategory,
                               !tab.includedCategories.contains(category) {
                                viewModel.selectPresetMedication(nil)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, HRTSpacing.xs)
    }

    // MARK: - Category Tab Bar (Other Medications)

    private var otherCategoryTabBar: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80, maximum: 120), spacing: HRTSpacing.sm)
        ]

        return LazyVGrid(columns: columns, spacing: HRTSpacing.sm) {
            ForEach(OtherMedicationTab.allCases, id: \.self) { tab in
                MedicationTabPill(
                    title: tab.rawValue,
                    isSelected: selectedOtherTab == tab
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedOtherTab = tab
                        // Clear selection when changing tabs
                        if viewModel.selectedOtherMedication != nil {
                            let currentCategory = viewModel.selectedOtherMedication?.category
                            if let category = currentCategory,
                               !tab.includedCategories.contains(category) {
                                viewModel.selectOtherMedication(nil)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, HRTSpacing.xs)
    }

    // MARK: - Tab Pill Component

    private struct MedicationTabPill: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.hrtCallout)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, HRTSpacing.md)
                    .padding(.vertical, HRTSpacing.sm)
                    .background(isSelected ? Color.hrtPinkFallback : Color.hrtPinkLightFallback)
                    .foregroundStyle(isSelected ? .white : Color.hrtTextFallback)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(title) medications")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
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
