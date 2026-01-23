import SwiftUI
import SwiftData

struct DiureticSectionView: View {
    @Bindable var viewModel: TodayViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var showCustomDoseSheet: Bool = false
    @State private var selectedMedication: Medication?

    var body: some View {
        VStack(spacing: 16) {
            sectionHeader

            if viewModel.diureticMedications.isEmpty {
                emptyState
            } else {
                diureticsList
            }

            if viewModel.showDeleteError {
                deleteErrorView
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showCustomDoseSheet) {
            if let medication = selectedMedication {
                CustomDoseSheet(
                    medication: medication,
                    onSave: { amount, isExtra, timestamp in
                        viewModel.logCustomDose(
                            for: medication,
                            amount: amount,
                            isExtra: isExtra,
                            timestamp: timestamp,
                            context: modelContext
                        )
                        showCustomDoseSheet = false
                        selectedMedication = nil
                    },
                    onCancel: {
                        showCustomDoseSheet = false
                        selectedMedication = nil
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        HStack {
            Image(systemName: "pills.fill")
                .foregroundStyle(.cyan)
            Text("Diuretics")
                .font(.headline)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Diuretics section")
        .accessibilityHint("Log your diuretic medications here")
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("No diuretics configured")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            NavigationLink(value: "medications") {
                Label("Add in Medications", systemImage: "arrow.right.circle")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            .accessibilityLabel("Go to Medications to add diuretics")
            .accessibilityHint("Double tap to open the Medications tab")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    // MARK: - Diuretics List

    private var diureticsList: some View {
        VStack(spacing: 4) {
            ForEach(viewModel.diureticMedications, id: \.persistentModelID) { medication in
                DiureticRowView(
                    medication: medication,
                    doses: viewModel.doses(for: medication),
                    onLogStandardDose: {
                        viewModel.logStandardDose(for: medication, context: modelContext)
                    },
                    onLogCustomDose: {
                        selectedMedication = medication
                        showCustomDoseSheet = true
                    },
                    onDeleteDose: { dose in
                        viewModel.deleteDose(dose, context: modelContext)
                    }
                )

                if medication.persistentModelID != viewModel.diureticMedications.last?.persistentModelID {
                    Divider()
                }
            }
        }
    }

    // MARK: - Delete Error

    private var deleteErrorView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text("Could not delete dose. Please try again.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: Could not delete dose")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DailyEntry.self, Medication.self, DiureticDose.self, configurations: config)

    // Add sample medication
    let medication = Medication(
        name: "Furosemide",
        dosage: 40,
        unit: "mg",
        schedule: "Morning",
        isDiuretic: true
    )
    container.mainContext.insert(medication)

    let viewModel = TodayViewModel()

    return NavigationStack {
        ScrollView {
            DiureticSectionView(viewModel: viewModel)
                .padding()
        }
    }
    .modelContainer(container)
    .onAppear {
        viewModel.loadData(context: container.mainContext)
        viewModel.loadDiuretics(context: container.mainContext)
    }
}
