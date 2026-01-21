import SwiftUI
import SwiftData

struct TrendsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TrendsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Loading trends...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    } else {
                        if viewModel.hasWeightData {
                            weightSection
                        } else {
                            emptyWeightStateView
                        }

                        // Symptom trends section
                        symptomSection
                    }
                }
                .padding()
            }
            .navigationTitle("Trends")
            .onAppear {
                viewModel.loadAllTrendData(context: modelContext)
            }
        }
    }

    // MARK: - Weight Section

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("Weight")
                .font(.title2)
                .fontWeight(.semibold)
                .accessibilityAddTraits(.isHeader)

            // Summary card
            weightSummaryCard

            // Chart
            WeightChartView(weightEntries: viewModel.weightEntries)
                .accessibilityLabel(viewModel.accessibilitySummary)

            // Date range
            Text(viewModel.dateRangeText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var weightSummaryCard: some View {
        HStack(spacing: 20) {
            // Current weight
            VStack(alignment: .leading, spacing: 4) {
                Text("Current")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let weight = viewModel.formattedCurrentWeight {
                    Text(weight)
                        .font(.title)
                        .fontWeight(.bold)
                } else {
                    Text("--")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)

            Divider()
                .frame(height: 44)

            // 30-day change
            VStack(alignment: .leading, spacing: 4) {
                Text("30-Day Change")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let changeText = viewModel.weightChangeText {
                    HStack(spacing: 4) {
                        changeIndicator
                        Text(changeText)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                } else {
                    Text("--")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var changeIndicator: some View {
        if let change = viewModel.weightChange {
            if change > 0.1 {
                Image(systemName: "arrow.up")
                    .foregroundStyle(.blue)
                    .accessibilityLabel("increased")
            } else if change < -0.1 {
                Image(systemName: "arrow.down")
                    .foregroundStyle(.blue)
                    .accessibilityLabel("decreased")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
                    .accessibilityLabel("stable")
            }
        }
    }

    // MARK: - Symptom Section

    private var symptomSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("Symptoms")
                .font(.title2)
                .fontWeight(.semibold)
                .accessibilityAddTraits(.isHeader)

            if viewModel.hasSymptomData {
                // Toggle controls
                SymptomToggleView(
                    toggleStates: Binding(
                        get: { viewModel.symptomToggleStates },
                        set: { viewModel.symptomToggleStates = $0 }
                    ),
                    onToggle: { symptomType in
                        viewModel.toggleSymptom(symptomType)
                    }
                )

                // Alert legend (if there are alert days)
                if !viewModel.alertDates.isEmpty {
                    alertLegend
                }

                // Chart
                SymptomTrendChart(
                    symptomEntries: viewModel.symptomEntries,
                    visibleSymptomTypes: viewModel.visibleSymptomTypes,
                    alertDates: viewModel.alertDates
                )
                .accessibilityLabel(viewModel.symptomAccessibilitySummary)

                // Date range
                Text(viewModel.dateRangeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                emptySymptomStateView
            }
        }
    }

    private var alertLegend: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.red.opacity(0.2))
                .frame(width: 16, height: 12)
            Text("Days with symptoms that may need attention")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Highlighted days show symptoms that may need attention")
    }

    // MARK: - Empty States

    private var emptyWeightStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "scalemass")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("No Weight Data Yet")
                .font(.headline)

            Text("Start logging your daily weight on the Today tab to see your trends here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No weight data yet. Start logging your daily weight on the Today tab to see your trends here.")
    }

    private var emptySymptomStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("No Symptom Data Yet")
                .font(.headline)

            Text("Log how you're feeling on the Today tab to track your symptoms over time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No symptom data yet. Log how you're feeling on the Today tab to track your symptoms over time.")
    }
}

#Preview {
    TrendsView()
        .modelContainer(for: DailyEntry.self, inMemory: true)
}
