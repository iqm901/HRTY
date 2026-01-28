import SwiftUI
import SwiftData

/// View that allows users to see what medications they were taking on any specific date.
/// Provides a date picker and displays the regimen snapshot for that date.
struct MedicationHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var regimen: MedicationHistoryService.RegimenSnapshot?

    private let historyService = MedicationHistoryService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HRTSpacing.lg) {
                        datePickerSection

                        if let regimen = regimen {
                            regimenSection(regimen)
                        }
                    }
                    .padding(.vertical, HRTSpacing.md)
                }
            }
            .navigationTitle("Medication History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadRegimen()
            }
            .onChange(of: selectedDate) { _, _ in
                loadRegimen()
            }
        }
    }

    // MARK: - Subviews

    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack(spacing: HRTSpacing.sm) {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.hrtPinkFallback)
                Text("Select Date")
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)
            }
            .padding(.horizontal, HRTSpacing.md)

            VStack(spacing: HRTSpacing.sm) {
                DatePicker(
                    "Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(Color.hrtPinkFallback)

                // Quick select buttons
                HStack(spacing: HRTSpacing.sm) {
                    quickSelectButton("Today", date: Date())
                    quickSelectButton("1 Week Ago", date: Date().addingTimeInterval(-7 * 24 * 60 * 60))
                    quickSelectButton("1 Month Ago", date: Date().addingTimeInterval(-30 * 24 * 60 * 60))
                }
            }
            .padding(HRTSpacing.md)
            .background(Color.hrtCardFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
            .padding(.horizontal, HRTSpacing.md)
        }
    }

    private func quickSelectButton(_ title: String, date: Date) -> some View {
        Button {
            withAnimation {
                selectedDate = date
            }
        } label: {
            Text(title)
                .font(.hrtCaption)
                .foregroundStyle(isDateSelected(date) ? Color.white : Color.hrtPinkFallback)
                .padding(.horizontal, HRTSpacing.sm)
                .padding(.vertical, HRTSpacing.xs)
                .background(isDateSelected(date) ? Color.hrtPinkFallback : Color.hrtPinkFallback.opacity(0.15))
                .clipShape(Capsule())
        }
    }

    private func isDateSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: date)
    }

    private func regimenSection(_ regimen: MedicationHistoryService.RegimenSnapshot) -> some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack(spacing: HRTSpacing.sm) {
                Image(systemName: "pills")
                    .foregroundStyle(Color.hrtPinkFallback)
                Text("Medications on \(regimen.formattedDate)")
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)
            }
            .padding(.horizontal, HRTSpacing.md)

            if regimen.isEmpty {
                emptyRegimenState
            } else {
                medicationsList(regimen.medications)
            }
        }
    }

    private var emptyRegimenState: some View {
        VStack(spacing: HRTSpacing.md) {
            Image(systemName: "pills")
                .font(.system(size: 40))
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            Text("No medications on this date")
                .font(.hrtBody)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            Text("Either no medications had been added yet, or all medications were discontinued before this date.")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HRTSpacing.xl)
        .padding(.horizontal, HRTSpacing.lg)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .padding(.horizontal, HRTSpacing.md)
    }

    private func medicationsList(_ medications: [MedicationHistoryService.MedicationSnapshot]) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(medications) { medication in
                medicationRow(medication)

                if medication.id != medications.last?.id {
                    HRTDivider()
                        .padding(.horizontal, HRTSpacing.md)
                }
            }
        }
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .padding(.horizontal, HRTSpacing.md)
    }

    private func medicationRow(_ medication: MedicationHistoryService.MedicationSnapshot) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                HStack(spacing: HRTSpacing.sm) {
                    Text(medication.medicationName)
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtTextFallback)

                    if medication.isDiuretic {
                        Text("DIURETIC")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Color.hrtPinkFallback)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.hrtPinkFallback.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                Text(medication.dosageDisplay)
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                if let category = medication.category {
                    Text(category.rawValue)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback.opacity(0.7))
                }
            }

            Spacer()
        }
        .padding(.horizontal, HRTSpacing.md)
        .padding(.vertical, HRTSpacing.sm)
    }

    // MARK: - Methods

    private func loadRegimen() {
        regimen = historyService.getMedicationRegimen(asOf: selectedDate, context: modelContext)
    }
}

#Preview {
    MedicationHistoryView()
        .modelContainer(for: Medication.self, inMemory: true)
}
