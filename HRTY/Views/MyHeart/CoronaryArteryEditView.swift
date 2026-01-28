import SwiftUI
import SwiftData

struct CoronaryArteryEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: MyHeartViewModel

    private var isEditing: Bool {
        viewModel.selectedCoronaryArtery != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HRTSpacing.lg) {
                        arteryTypeSection

                        blockageSection

                        stentSection

                        notesSection
                    }
                    .padding(.vertical, HRTSpacing.md)
                }
            }
            .navigationTitle(isEditing ? "Edit Artery" : "Add Artery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveCoronaryArtery(context: modelContext)
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

    private var arteryTypeSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("Artery")
                .font(.headline)

            Picker("Artery Type", selection: $viewModel.arteryTypeSelection) {
                ForEach(CoronaryArteryType.allCases) { arteryType in
                    Text(arteryType.displayName).tag(arteryType)
                }
            }
            .pickerStyle(.menu)
            .tint(Color.hrtPinkFallback)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
    }

    private var blockageSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            Toggle("Has Blockage", isOn: $viewModel.hasBlockage)
                .tint(Color.hrtPinkFallback)

            if viewModel.hasBlockage {
                VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                    Text("Blockage Severity")
                        .font(.subheadline)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    Picker("Severity", selection: $viewModel.blockageSeveritySelection) {
                        Text("Not specified").tag(nil as BlockageSeverity?)
                        ForEach(BlockageSeverity.allCases) { severity in
                            Text("\(severity.displayName) (\(severity.percentageRange))").tag(severity as BlockageSeverity?)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.hrtPinkFallback)
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

    private var stentSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            Toggle("Stent Placed", isOn: $viewModel.hasStent)
                .tint(Color.hrtPinkFallback)

            if viewModel.hasStent {
                VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                    Text("Stent Date")
                        .font(.subheadline)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    DatePicker(
                        "Stent date",
                        selection: $viewModel.stentDate,
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

            TextField("Additional notes", text: $viewModel.arteryNotes, axis: .vertical)
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
    CoronaryArteryEditView(viewModel: MyHeartViewModel())
        .modelContainer(for: [ClinicalProfile.self, CoronaryArtery.self])
}
