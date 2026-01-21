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
                        }

                        if viewModel.hasSymptomData {
                            symptomSection
                        }

                        if !viewModel.hasWeightData && !viewModel.hasSymptomData {
                            emptyStateView
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Trends")
            .onAppear {
                viewModel.loadAllData(context: modelContext)
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

            // Toggle chips
            SymptomToggleChips(
                symptoms: SymptomType.allCases,
                isVisible: { viewModel.isSymptomVisible($0) },
                colorForSymptom: { viewModel.colorForSymptom($0) },
                onToggle: { viewModel.toggleSymptom($0) }
            )

            // Chart
            SymptomTrendChart(
                symptomEntries: viewModel.symptomEntries,
                visibleSymptoms: Set(SymptomType.allCases.filter { viewModel.isSymptomVisible($0) }),
                alertDates: viewModel.alertDates,
                colorForSymptom: { viewModel.colorForSymptom($0) }
            )
            .accessibilityLabel(viewModel.symptomAccessibilitySummary)

            // Legend hint
            if !viewModel.alertDates.isEmpty {
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(Color.orange.opacity(0.3))
                        .frame(width: 16, height: 2)

                    Text("Days with alerts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Date range
            Text(viewModel.dateRangeText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Data Yet")
                .font(.title3)
                .fontWeight(.medium)

            Text("Start logging your daily check-ins on the Today tab to see your trends here.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No data yet. Start logging your daily check-ins on the Today tab to see your trends here.")
    }
}

#Preview {
    TrendsView()
        .modelContainer(for: DailyEntry.self, inMemory: true)
}
