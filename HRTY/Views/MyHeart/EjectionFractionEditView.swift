import SwiftUI
import SwiftData

struct EjectionFractionEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: MyHeartViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HRTSpacing.lg) {
                        infoSection

                        inputSection

                        if viewModel.profile?.ejectionFraction != nil {
                            clearSection
                        }
                    }
                    .padding(.vertical, HRTSpacing.md)
                }
            }
            .navigationTitle("Ejection Fraction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveEjectionFraction(context: modelContext)
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

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("What is Ejection Fraction?")
                .font(.headline)

            Text("Ejection fraction (EF) measures the percentage of blood pumped out each time your heart beats. This number helps your doctor understand how well your heart is pumping.")
                .font(.subheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                efRangeRow(range: "50-65%", label: "Normal", description: "Heart pumps well")
                efRangeRow(range: "40-49%", label: "Mildly Reduced", description: "Slight decrease")
                efRangeRow(range: "Below 40%", label: "Reduced (HFrEF)", description: "Heart muscle weakened")
            }
            .padding(.top, HRTSpacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
    }

    private func efRangeRow(range: String, label: String, description: String) -> some View {
        HStack(alignment: .top) {
            Text(range)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hrtPinkFallback)
                .frame(width: 70, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
            }
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Ejection Fraction (%)")
                    .font(.subheadline)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                TextField("Enter percentage", text: $viewModel.ejectionFractionInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityLabel("Ejection fraction percentage")
            }

            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Date Measured")
                    .font(.subheadline)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                DatePicker(
                    "Date measured",
                    selection: $viewModel.ejectionFractionDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
    }

    private var clearSection: some View {
        Button(role: .destructive) {
            viewModel.clearEjectionFraction(context: modelContext)
        } label: {
            Text("Clear Ejection Fraction")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .hrtPagePadding()
    }
}

#Preview {
    EjectionFractionEditView(viewModel: MyHeartViewModel())
        .modelContainer(for: [ClinicalProfile.self])
}
