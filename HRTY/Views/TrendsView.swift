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

                        // Heart rate trends section
                        heartRateSection

                        // Symptom trends section
                        symptomSection
                    }
                }
                .padding()
            }
            .navigationTitle("Trends")
            .task {
                await viewModel.loadAllTrendDataWithHeartRate(context: modelContext)
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

    // MARK: - Heart Rate Section

    @ViewBuilder
    private var heartRateSection: some View {
        // Only show if HealthKit is available
        if viewModel.healthKitAvailable {
            VStack(alignment: .leading, spacing: 16) {
                // Section header
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                    Text("Resting Heart Rate")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .accessibilityAddTraits(.isHeader)

                if viewModel.isLoadingHeartRate {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading heart rate data...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
                } else if viewModel.hasHeartRateData {
                    // Summary card
                    heartRateSummaryCard

                    // Alert legend (if there are alert days)
                    if !viewModel.heartRateAlertDates.isEmpty {
                        heartRateAlertLegend
                    }

                    // Chart
                    HeartRateTrendChart(
                        heartRateEntries: viewModel.heartRateEntries,
                        alertDates: viewModel.heartRateAlertDates
                    )
                    .accessibilityLabel(viewModel.heartRateAccessibilitySummary)

                    // Date range
                    Text(viewModel.dateRangeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    emptyHeartRateStateView
                }
            }
        }
    }

    private var heartRateSummaryCard: some View {
        HStack(spacing: 20) {
            // Current heart rate
            VStack(alignment: .leading, spacing: 4) {
                Text("Latest")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let hr = viewModel.formattedCurrentHeartRate {
                    Text(hr)
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

            // Average
            VStack(alignment: .leading, spacing: 4) {
                Text("30-Day Avg")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let avg = viewModel.formattedAverageHeartRate {
                    Text(avg)
                        .font(.title3)
                        .fontWeight(.semibold)
                } else {
                    Text("--")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)

            Divider()
                .frame(height: 44)

            // Range
            VStack(alignment: .leading, spacing: 4) {
                Text("Range")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let range = viewModel.formattedHeartRateRange {
                    Text(range)
                        .font(.title3)
                        .fontWeight(.semibold)
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

    private var heartRateAlertLegend: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.red.opacity(0.2))
                .frame(width: 16, height: 12)
            Text("Days with heart rate values that may need attention")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Highlighted days show heart rate values that may need attention")
    }

    private var emptyHeartRateStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.slash")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("No Heart Rate Data Yet")
                .font(.headline)

            Text("Heart rate data from Apple Health will appear here when available.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No heart rate data yet. Heart rate data from Apple Health will appear here when available.")
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
                    visibleSymptoms: Set(viewModel.visibleSymptomTypes),
                    alertDates: viewModel.alertDates,
                    colorForSymptom: TrendsViewModel.color
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
