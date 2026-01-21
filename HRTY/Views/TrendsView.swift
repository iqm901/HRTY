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
                    } else if viewModel.hasWeightData {
                        weightSection
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Trends")
            .onAppear {
                viewModel.loadWeightData(context: modelContext)
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
                    .foregroundStyle(.orange)
                    .accessibilityLabel("increased")
            } else if change < -0.1 {
                Image(systemName: "arrow.down")
                    .foregroundStyle(.green)
                    .accessibilityLabel("decreased")
            } else {
                Image(systemName: "equal")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("stable")
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Weight Data Yet")
                .font(.title3)
                .fontWeight(.medium)

            Text("Start logging your daily weight on the Today tab to see your trends here.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No weight data yet. Start logging your daily weight on the Today tab to see your trends here.")
    }
}

#Preview {
    TrendsView()
        .modelContainer(for: DailyEntry.self, inMemory: true)
}
