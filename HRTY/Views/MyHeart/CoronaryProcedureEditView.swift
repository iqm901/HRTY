import SwiftUI
import SwiftData

struct CoronaryProcedureEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: MyHeartViewModel

    private var isEditing: Bool {
        viewModel.selectedCoronaryProcedure != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HRTSpacing.lg) {
                        procedureTypeSection

                        dateSection

                        vesselsSection

                        if viewModel.procedureTypeSelection == .cabg {
                            graftTypesSection
                        }

                        notesSection
                    }
                    .padding(.vertical, HRTSpacing.md)
                }
            }
            .navigationTitle(isEditing ? "Edit Procedure" : "Add Procedure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveCoronaryProcedure(context: modelContext)
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

    // MARK: - Procedure Type Section

    private var procedureTypeSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("Type of Procedure")
                .font(.headline)

            VStack(spacing: HRTSpacing.sm) {
                ForEach(CoronaryProcedureType.allCases) { procedureType in
                    Button {
                        viewModel.procedureTypeSelection = procedureType
                    } label: {
                        HStack {
                            Image(systemName: procedureType.icon)
                                .font(.title3)
                                .foregroundStyle(viewModel.procedureTypeSelection == procedureType ? Color.hrtPinkFallback : Color.hrtTextSecondaryFallback)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(procedureType.displayName)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color.hrtTextFallback)
                            }

                            Spacer()

                            if viewModel.procedureTypeSelection == procedureType {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.hrtPinkFallback)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(Color.hrtTextTertiaryFallback)
                            }
                        }
                        .padding(HRTSpacing.sm)
                        .background(
                            viewModel.procedureTypeSelection == procedureType
                                ? Color.hrtPinkFallback.opacity(0.1)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.small))
                    }
                    .buttonStyle(.plain)
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

    // MARK: - Date Section

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            Text("When was this done?")
                .font(.headline)

            if !viewModel.procedureDateIsUnknown {
                FlexibleDatePicker(
                    year: $viewModel.procedureYear,
                    month: $viewModel.procedureMonth,
                    day: $viewModel.procedureDay
                )
            }

            Toggle("I don't know the date", isOn: $viewModel.procedureDateIsUnknown)
                .tint(Color.hrtPinkFallback)
                .font(.subheadline)
                .onChange(of: viewModel.procedureDateIsUnknown) { _, isUnknown in
                    if isUnknown {
                        viewModel.procedureYear = nil
                        viewModel.procedureMonth = nil
                        viewModel.procedureDay = nil
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

    // MARK: - Vessels Section

    private var vesselsSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Which vessels? (optional)")
                    .font(.headline)

                Text("Select any arteries involved in this procedure")
                    .font(.caption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }

            if !viewModel.procedureVesselsUnknown {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HRTSpacing.sm) {
                    ForEach(CoronaryArteryType.allCases) { arteryType in
                        Button {
                            if viewModel.procedureVesselsSelection.contains(arteryType) {
                                viewModel.procedureVesselsSelection.remove(arteryType)
                            } else {
                                viewModel.procedureVesselsSelection.insert(arteryType)
                            }
                        } label: {
                            HStack {
                                Image(systemName: viewModel.procedureVesselsSelection.contains(arteryType) ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(viewModel.procedureVesselsSelection.contains(arteryType) ? Color.hrtPinkFallback : Color.hrtTextTertiaryFallback)

                                Text(arteryType.shortName)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.hrtTextFallback)

                                Spacer()
                            }
                            .padding(.vertical, HRTSpacing.xs)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Toggle("I don't know", isOn: $viewModel.procedureVesselsUnknown)
                .tint(Color.hrtPinkFallback)
                .font(.subheadline)
                .onChange(of: viewModel.procedureVesselsUnknown) { _, isUnknown in
                    if isUnknown {
                        viewModel.procedureVesselsSelection = []
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

    // MARK: - Graft Types Section (CABG only)

    private var graftTypesSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Graft types used? (optional)")
                    .font(.headline)

                Text("Select the types of grafts used in your bypass surgery")
                    .font(.caption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }

            if !viewModel.procedureGraftTypesUnknown {
                VStack(spacing: HRTSpacing.sm) {
                    ForEach(CABGGraftType.allCases) { graftType in
                        Button {
                            if viewModel.procedureGraftTypesSelection.contains(graftType) {
                                viewModel.procedureGraftTypesSelection.remove(graftType)
                            } else {
                                viewModel.procedureGraftTypesSelection.insert(graftType)
                            }
                        } label: {
                            HStack {
                                Image(systemName: viewModel.procedureGraftTypesSelection.contains(graftType) ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(viewModel.procedureGraftTypesSelection.contains(graftType) ? Color.hrtPinkFallback : Color.hrtTextTertiaryFallback)

                                Text(graftType.displayName)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.hrtTextFallback)

                                Spacer()
                            }
                            .padding(.vertical, HRTSpacing.xs)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Toggle("I don't know", isOn: $viewModel.procedureGraftTypesUnknown)
                .tint(Color.hrtPinkFallback)
                .font(.subheadline)
                .onChange(of: viewModel.procedureGraftTypesUnknown) { _, isUnknown in
                    if isUnknown {
                        viewModel.procedureGraftTypesSelection = []
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

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("Notes (Optional)")
                .font(.subheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            TextField("Additional notes about this procedure", text: $viewModel.procedureNotes, axis: .vertical)
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
    CoronaryProcedureEditView(viewModel: MyHeartViewModel())
        .modelContainer(for: [ClinicalProfile.self, CoronaryProcedure.self])
}
