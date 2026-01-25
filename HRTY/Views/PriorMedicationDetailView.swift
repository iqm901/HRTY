import SwiftUI
import SwiftData

/// Detail view for a prior (archived) medication.
/// Shows dosage history and allows reactivation.
struct PriorMedicationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isDosageFieldFocused: Bool

    @Bindable var viewModel: MedicationsViewModel
    let medication: Medication

    var body: some View {
        NavigationStack {
            Form {
                medicationInfoSection

                dosageHistorySection

                reactivationSection

                if let error = viewModel.validationError {
                    Section {
                        Text(error)
                            .foregroundStyle(Color.hrtAlertFallback)
                            .font(.hrtCallout)
                    }
                }
            }
            .navigationTitle(medication.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                        viewModel.selectedPriorMedication = nil
                        viewModel.resetReactivationForm()
                    }
                }
            }
        }
    }

    // MARK: - Medication Info Section

    private var medicationInfoSection: some View {
        Section {
            HStack {
                Text("Status")
                Spacer()
                Text("Archived")
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }

            if let archivedDate = medication.archivedAtDisplay {
                HStack {
                    Text("Archived On")
                    Spacer()
                    Text(archivedDate)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }
            }
        }
    }

    // MARK: - Dosage History Section

    private var dosageHistorySection: some View {
        Section {
            if medication.sortedPeriods.isEmpty {
                Text("No dosage history available")
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .font(.hrtCallout)
            } else {
                ForEach(medication.sortedPeriods, id: \.id) { period in
                    VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                        Text(period.dosageDisplay)
                            .font(.hrtBody)
                            .foregroundStyle(Color.hrtTextFallback)

                        if !period.schedule.isEmpty {
                            Text(period.schedule)
                                .font(.hrtCallout)
                                .foregroundStyle(Color.hrtTextSecondaryFallback)
                        }

                        Text(period.dateRangeDisplay)
                            .font(.hrtCaption)
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                    }
                    .padding(.vertical, HRTSpacing.xs)
                }
            }
        } header: {
            Text("Dosage History")
        } footer: {
            Text("All previous dosages for this medication are shown above.")
        }
    }

    // MARK: - Reactivation Section

    private var reactivationSection: some View {
        Section {
            HStack {
                TextField("Dosage", text: $viewModel.reactivateDosageInput)
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

                Picker("Unit", selection: $viewModel.reactivateSelectedUnit) {
                    ForEach(Medication.availableUnits, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .labelsHidden()
                .accessibilityLabel("Dosage unit")
            }

            TextField("Schedule (e.g., Once daily)", text: $viewModel.reactivateScheduleInput)
                .textContentType(.none)
                .accessibilityLabel("Schedule")
                .accessibilityHint("Enter when you take this medication")

            Button {
                viewModel.reactivateMedication(context: modelContext)
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                    Text("Reactivate Medication")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .disabled(!isReactivationFormValid)
            .foregroundStyle(isReactivationFormValid ? Color.hrtPinkFallback : Color.hrtTextSecondaryFallback)
        } header: {
            Text("Reactivate")
        } footer: {
            Text("Enter the dosage to restart this medication. A new dosage period will begin today.")
        }
    }

    // MARK: - Validation

    private var isReactivationFormValid: Bool {
        let trimmed = viewModel.reactivateDosageInput.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return false }

        // Check for combination dosage (e.g., "49/51")
        if trimmed.contains("/") {
            let parts = trimmed.split(separator: "/")
            return parts.count == 2 &&
                   parts.allSatisfy { Double($0) != nil && Double($0)! > 0 }
        }

        // Check for simple numeric dosage
        if let value = Double(trimmed) {
            return value > 0
        }

        return false
    }
}

#Preview {
    let viewModel = MedicationsViewModel()
    viewModel.reactivateDosageInput = "40"
    viewModel.reactivateSelectedUnit = "mg"
    viewModel.reactivateScheduleInput = "Once daily"

    let medication = Medication(
        name: "Furosemide",
        dosage: "40",
        unit: "mg",
        schedule: "Once daily",
        isDiuretic: true,
        isActive: false,
        archivedAt: Date()
    )

    return PriorMedicationDetailView(viewModel: viewModel, medication: medication)
        .modelContainer(for: Medication.self, inMemory: true)
}
