import SwiftUI
import SwiftData

// MARK: - Medication Category Tabs

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

struct MedicationFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isDosageFieldFocused: Bool
    @State private var selectedTab: MedicationTab = .all

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
            // Category Tab Bar
            Section {
                categoryTabBar
            } header: {
                Text("Category")
            }

            // Medication List
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
                            if viewModel.selectedPresetMedication?.id == medication.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.hrtPinkFallback)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
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

    // MARK: - Category Tab Bar

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
