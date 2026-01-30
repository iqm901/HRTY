import SwiftUI
import SwiftData

struct TemplateEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SodiumViewModel

    private var isEditing: Bool {
        viewModel.editingTemplate != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                // Name Section
                Section {
                    TextField("Template name", text: $viewModel.nameInput)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Name")
                }

                // Sodium Section
                Section {
                    HStack {
                        TextField("Amount", text: $viewModel.sodiumInput)
                            .keyboardType(.numberPad)

                        Text("mg")
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                    }
                } header: {
                    Text("Sodium")
                }

                // Serving Size Section
                Section {
                    TextField("e.g., 1 cup, 2 slices", text: $viewModel.servingInput)
                } header: {
                    Text("Serving Size (Optional)")
                }

                // Category Section
                Section {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(TemplateCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Category")
                }

                // Delete Section (only when editing)
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            if let template = viewModel.editingTemplate {
                                viewModel.deleteTemplate(template, context: modelContext)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Template")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Template" : "New Template")
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
                        viewModel.saveTemplate(context: modelContext)
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
}

#Preview("New Template") {
    TemplateEditorSheet(viewModel: SodiumViewModel())
        .modelContainer(for: [SodiumTemplate.self], inMemory: true)
}

#Preview("Edit Template") {
    let viewModel = SodiumViewModel()
    viewModel.nameInput = "Morning Coffee"
    viewModel.sodiumInput = "50"
    viewModel.servingInput = "1 cup"
    viewModel.selectedCategory = .beverage

    return TemplateEditorSheet(viewModel: viewModel)
        .modelContainer(for: [SodiumTemplate.self], inMemory: true)
}
