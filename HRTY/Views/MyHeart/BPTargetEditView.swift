import SwiftUI
import SwiftData

struct BPTargetEditView: View {
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

                        if viewModel.profile?.targetSystolicBP != nil {
                            clearSection
                        }
                    }
                    .padding(.vertical, HRTSpacing.md)
                }
            }
            .navigationTitle("Blood Pressure Target")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveBPTarget(context: modelContext)
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
            Text("Why Blood Pressure Targets Matter")
                .font(.headline)

            Text("High blood pressure makes your heart work harder than it should. Over time, this extra work can weaken the heart muscle and worsen heart failure.")
                .font(.subheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            Text("Your doctor will set a target based on your specific situation. Many heart failure patients aim for less than 130/80 mmHg, but your target may be different.")
                .font(.subheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .padding(.top, HRTSpacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            Text("Enter your target blood pressure as provided by your doctor.")
                .font(.subheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            HStack(spacing: HRTSpacing.md) {
                VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                    Text("Systolic (top)")
                        .font(.caption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    TextField("120", text: $viewModel.targetSystolicInput)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Target systolic blood pressure")
                }

                Text("/")
                    .font(.title)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                    Text("Diastolic (bottom)")
                        .font(.caption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    TextField("80", text: $viewModel.targetDiastolicInput)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Target diastolic blood pressure")
                }

                Text("mmHg")
                    .font(.subheadline)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
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
            viewModel.clearBPTarget(context: modelContext)
        } label: {
            Text("Clear Blood Pressure Target")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .hrtPagePadding()
    }
}

#Preview {
    BPTargetEditView(viewModel: MyHeartViewModel())
        .modelContainer(for: [ClinicalProfile.self])
}
