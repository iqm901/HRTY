import SwiftUI
import SwiftData

struct HeartValveEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: MyHeartViewModel

    private var isEditing: Bool {
        viewModel.selectedHeartValve != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HRTSpacing.lg) {
                        valveTypeSection

                        conditionSection

                        interventionSection

                        notesSection
                    }
                    .padding(.vertical, HRTSpacing.md)
                }
            }
            .navigationTitle(isEditing ? "Edit Valve" : "Add Valve")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveHeartValve(context: modelContext)
                    }
                }
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.validationError != nil },
                set: { if !$0 { viewModel.validationError = nil } }
            )) {
                Button("OK", role: .cancel) {
                    viewModel.validationError = nil
                }
            } message: {
                if let error = viewModel.validationError {
                    Text(error)
                }
            }
        }
    }

    private var valveTypeSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("Valve")
                .font(.headline)

            Picker("Valve Type", selection: $viewModel.valveTypeSelection) {
                ForEach(HeartValveType.allCases) { valveType in
                    Text(valveType.displayName).tag(valveType)
                }
            }
            .pickerStyle(.segmented)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
    }

    private var conditionSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            Text("Condition")
                .font(.headline)

            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Problem Type")
                    .font(.subheadline)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                Picker("Problem Type", selection: $viewModel.problemTypeSelection) {
                    Text("Normal (No problem)").tag(nil as ValveProblemType?)
                    ForEach(ValveProblemType.allCases) { problemType in
                        Text(problemType.displayName).tag(problemType as ValveProblemType?)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color.hrtPinkFallback)
            }

            if viewModel.problemTypeSelection != nil {
                VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                    Text("Severity")
                        .font(.subheadline)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    Picker("Severity", selection: $viewModel.valveSeveritySelection) {
                        Text("Not specified").tag(nil as ValveSeverity?)
                        ForEach(ValveSeverity.allCases) { severity in
                            Text(severity.displayName).tag(severity as ValveSeverity?)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
    }

    private var interventionSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            Toggle("Had Intervention", isOn: $viewModel.hasIntervention)
                .tint(Color.hrtPinkFallback)

            if viewModel.hasIntervention {
                VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                    Text("Intervention Type")
                        .font(.subheadline)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    Picker("Intervention Type", selection: $viewModel.interventionTypeSelection) {
                        Text("Not specified").tag(nil as ValveInterventionType?)
                        ForEach(ValveInterventionType.allCases) { interventionType in
                            Text(interventionType.displayName).tag(interventionType as ValveInterventionType?)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.hrtPinkFallback)
                }

                VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                    Text("Intervention Date")
                        .font(.subheadline)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    DatePicker(
                        "Intervention date",
                        selection: $viewModel.interventionDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("Notes (Optional)")
                .font(.subheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            TextField("Additional notes", text: $viewModel.valveNotes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
    }
}

#Preview {
    HeartValveEditView(viewModel: MyHeartViewModel())
        .modelContainer(for: [ClinicalProfile.self, HeartValveCondition.self])
}
