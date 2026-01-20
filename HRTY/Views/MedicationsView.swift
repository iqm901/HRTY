import SwiftUI
import SwiftData

struct MedicationsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = MedicationsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasNoMedications {
                    emptyState
                } else {
                    medicationsList
                }
            }
            .navigationTitle("Medications")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.prepareForAdd()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add medication")
                    .accessibilityHint("Opens a form to add a new medication")
                }
            }
            .sheet(isPresented: $viewModel.showingAddMedication) {
                MedicationFormView(viewModel: viewModel, isEditing: false)
            }
            .sheet(isPresented: $viewModel.showingEditMedication) {
                MedicationFormView(viewModel: viewModel, isEditing: true)
            }
            .alert("Delete Medication", isPresented: $viewModel.showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    viewModel.medicationToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    viewModel.deleteMedication(context: modelContext)
                }
            } message: {
                if let medication = viewModel.medicationToDelete {
                    Text("Are you sure you want to remove \(medication.name) from your medications list?")
                }
            }
            .onAppear {
                viewModel.loadMedications(context: modelContext)
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Medications", systemImage: "pills")
        } description: {
            Text("Add your medications to keep track of what you're taking and log your daily diuretic doses.")
        } actions: {
            Button {
                viewModel.prepareForAdd()
            } label: {
                Text("Add Medication")
            }
            .buttonStyle(.borderedProminent)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No medications added yet")
        .accessibilityHint("Tap add medication to get started")
    }

    private var medicationsList: some View {
        List {
            ForEach(viewModel.sortedMedications, id: \.id) { medication in
                MedicationRowView(medication: medication)
                    .onTapGesture {
                        viewModel.prepareForEdit(medication: medication)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.prepareForDelete(medication: medication)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .accessibilityLabel("Delete \(medication.name)")
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    MedicationsView()
        .modelContainer(for: Medication.self, inMemory: true)
}
