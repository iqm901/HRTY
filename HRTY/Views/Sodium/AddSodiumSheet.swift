import SwiftUI
import SwiftData

struct AddSodiumSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SodiumViewModel

    var body: some View {
        NavigationStack {
            Form {
                // Name Section
                Section {
                    TextField("Food or drink name", text: $viewModel.nameInput)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Item")
                }

                // Sodium Section
                Section {
                    HStack {
                        TextField("Amount", text: $viewModel.sodiumInput)
                            .keyboardType(.numberPad)

                        Text("mg")
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                    }

                    // Quick Add Chips
                    quickAddChips
                } header: {
                    Text("Sodium")
                } footer: {
                    Text("Enter the sodium content from the nutrition label")
                }

                // Serving Size Section (Optional)
                Section {
                    TextField("e.g., 1 cup, 2 slices", text: $viewModel.servingInput)
                } header: {
                    Text("Serving Size (Optional)")
                }
            }
            .navigationTitle("Add Sodium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.resetForm()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addEntry(context: modelContext)
                        if viewModel.errorMessage == nil {
                            viewModel.resetForm()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                    .fontWeight(.semibold)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearErrorMessage()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    // MARK: - Quick Add Chips

    private var quickAddChips: some View {
        HStack(spacing: HRTSpacing.sm) {
            ForEach(SodiumConstants.quickAddValues, id: \.self) { value in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        // Add to current value or set if empty
                        if let current = Int(viewModel.sodiumInput) {
                            viewModel.sodiumInput = String(current + value)
                        } else {
                            viewModel.sodiumInput = String(value)
                        }
                    }
                } label: {
                    Text("+\(value)")
                        .font(.hrtCaption)
                        .fontWeight(.medium)
                        .padding(.horizontal, HRTSpacing.sm)
                        .padding(.vertical, HRTSpacing.xs)
                        .background(Color.hrtPinkLightFallback)
                        .foregroundStyle(Color.hrtPinkFallback)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }
}

#Preview {
    AddSodiumSheet(viewModel: SodiumViewModel())
        .modelContainer(for: [SodiumEntry.self], inMemory: true)
}
