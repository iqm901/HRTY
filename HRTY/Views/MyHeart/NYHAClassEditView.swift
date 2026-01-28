import SwiftUI
import SwiftData

struct NYHAClassEditView: View {
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

                        selectionSection

                        if viewModel.profile?.nyhaClass != nil {
                            clearSection
                        }
                    }
                    .padding(.vertical, HRTSpacing.md)
                }
            }
            .navigationTitle("NYHA Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveNYHAClass(context: modelContext)
                    }
                    .disabled(viewModel.selectedNYHAClass == nil)
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
            Text("What is NYHA Class?")
                .font(.headline)

            Text("The New York Heart Association (NYHA) classification describes how heart failure affects your daily activities. Your class can change over time with treatment.")
                .font(.subheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
    }

    private var selectionSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            Text("Select Your NYHA Class")
                .font(.subheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            ForEach(NYHAClass.allCases) { nyhaClass in
                nyhaClassRow(nyhaClass)
            }

            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Date Assessed")
                    .font(.subheadline)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .padding(.top, HRTSpacing.sm)

                DatePicker(
                    "Date assessed",
                    selection: $viewModel.nyhaClassDate,
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

    private func nyhaClassRow(_ nyhaClass: NYHAClass) -> some View {
        Button {
            viewModel.selectedNYHAClass = nyhaClass
        } label: {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(nyhaClass.displayName)
                        .font(.headline)
                        .foregroundStyle(Color.hrtTextFallback)

                    Text(nyhaClass.description)
                        .font(.caption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if viewModel.selectedNYHAClass == nyhaClass {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.hrtPinkFallback)
                        .font(.title2)
                }
            }
            .padding(HRTSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: HRTRadius.small)
                    .fill(viewModel.selectedNYHAClass == nyhaClass ?
                          Color.hrtPinkLightFallback : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: HRTRadius.small)
                    .stroke(viewModel.selectedNYHAClass == nyhaClass ?
                            Color.hrtPinkFallback : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(nyhaClass.displayName)
        .accessibilityHint(nyhaClass.description)
        .accessibilityAddTraits(viewModel.selectedNYHAClass == nyhaClass ? .isSelected : [])
    }

    private var clearSection: some View {
        Button(role: .destructive) {
            viewModel.clearNYHAClass(context: modelContext)
        } label: {
            Text("Clear NYHA Class")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .hrtPagePadding()
    }
}

#Preview {
    NYHAClassEditView(viewModel: MyHeartViewModel())
        .modelContainer(for: [ClinicalProfile.self])
}
