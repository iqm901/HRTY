import SwiftUI
import SwiftData

struct TrendsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TrendsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: HRTSpacing.lg) {
                        if viewModel.isLoading {
                            HRTLoadingView("Loading trends...")
                                .frame(height: 200)
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
                    .padding(HRTSpacing.md)
                }
                .scrollContentBackground(.hidden)
            }
            .toolbarBackground(Color.hrtBackgroundFallback, for: .navigationBar)
            .navigationTitle("Trends")
            .task {
                await viewModel.loadAllTrendDataWithHeartRate(context: modelContext)
            }
        }
    }

    // MARK: - Weight Section

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            // Section header
            HStack(spacing: HRTSpacing.sm) {
                Image(systemName: "scalemass.fill")
                    .foregroundStyle(Color.hrtPinkFallback)
                Text("Weight")
                    .font(.hrtTitle2)
                    .foregroundStyle(Color.hrtTextFallback)
            }
            .accessibilityAddTraits(.isHeader)

            // Summary card
            weightSummaryCard

            // Chart
            WeightChartView(weightEntries: viewModel.weightEntries)
                .accessibilityLabel(viewModel.accessibilitySummary)

            // Date range
            Text(viewModel.dateRangeText)
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var weightSummaryCard: some View {
        HStack(spacing: HRTSpacing.lg) {
            // Current weight
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Current")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                if let weight = viewModel.formattedCurrentWeight {
                    Text(weight)
                        .font(.hrtTitle)
                        .foregroundStyle(Color.hrtTextFallback)
                } else {
                    Text("--")
                        .font(.hrtTitle)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }
            .accessibilityElement(children: .combine)

            HRTDivider(direction: .vertical)
                .frame(height: 44)

            // 30-day change
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("30-Day Change")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                if let changeText = viewModel.weightChangeText {
                    HStack(spacing: HRTSpacing.xs) {
                        changeIndicator
                        Text(changeText)
                            .font(.hrtTitle3)
                            .foregroundStyle(Color.hrtTextFallback)
                    }
                } else {
                    Text("--")
                        .font(.hrtTitle3)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }
            .accessibilityElement(children: .combine)

            Spacer()
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
    }

    @ViewBuilder
    private var changeIndicator: some View {
        if let change = viewModel.weightChange {
            if change > 0.1 {
                Image(systemName: "arrow.up")
                    .foregroundStyle(Color.hrtCautionFallback)
                    .accessibilityLabel("increased")
            } else if change < -0.1 {
                Image(systemName: "arrow.down")
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .accessibilityLabel("decreased")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.hrtGoodFallback)
                    .accessibilityLabel("stable")
            }
        }
    }

    // MARK: - Heart Rate Section

    @ViewBuilder
    private var heartRateSection: some View {
        // Only show if HealthKit is available
        if viewModel.healthKitAvailable {
            VStack(alignment: .leading, spacing: HRTSpacing.md) {
                // Section header
                HStack(spacing: HRTSpacing.sm) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(Color.hrtPinkFallback)
                    Text("Resting Heart Rate")
                        .font(.hrtTitle2)
                        .foregroundStyle(Color.hrtTextFallback)
                }
                .accessibilityAddTraits(.isHeader)

                if viewModel.isLoadingHeartRate {
                    HStack(spacing: HRTSpacing.sm) {
                        ProgressView()
                            .tint(Color.hrtPinkFallback)
                            .scaleEffect(0.8)
                        Text("Loading heart rate data...")
                            .font(.hrtCallout)
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, HRTSpacing.sm)
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
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    emptyHeartRateStateView
                }
            }
        }
    }

    private var heartRateSummaryCard: some View {
        HStack(spacing: HRTSpacing.md) {
            // Current heart rate
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Latest")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                if let hr = viewModel.formattedCurrentHeartRate {
                    Text(hr)
                        .font(.hrtTitle)
                        .foregroundStyle(Color.hrtTextFallback)
                } else {
                    Text("--")
                        .font(.hrtTitle)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }
            .accessibilityElement(children: .combine)

            HRTDivider(direction: .vertical)
                .frame(height: 44)

            // Average
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("30-Day Avg")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                if let avg = viewModel.formattedAverageHeartRate {
                    Text(avg)
                        .font(.hrtTitle3)
                        .foregroundStyle(Color.hrtTextFallback)
                } else {
                    Text("--")
                        .font(.hrtTitle3)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }
            .accessibilityElement(children: .combine)

            HRTDivider(direction: .vertical)
                .frame(height: 44)

            // Range
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Range")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                if let range = viewModel.formattedHeartRateRange {
                    Text(range)
                        .font(.hrtTitle3)
                        .foregroundStyle(Color.hrtTextFallback)
                } else {
                    Text("--")
                        .font(.hrtTitle3)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }
            .accessibilityElement(children: .combine)

            Spacer()
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
    }

    private var heartRateAlertLegend: some View {
        HStack(spacing: HRTSpacing.xs) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.hrtAlertFallback.opacity(0.2))
                .frame(width: 16, height: 12)
            Text("Days with heart rate values that may need attention")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Highlighted days show heart rate values that may need attention")
    }

    private var emptyHeartRateStateView: some View {
        HRTEmptyState(
            icon: "heart.slash",
            title: "No Heart Rate Data Yet",
            message: "Heart rate data from Apple Health will appear here when available."
        )
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .accessibilityLabel("No heart rate data yet. Heart rate data from Apple Health will appear here when available.")
    }

    // MARK: - Symptom Section

    private var symptomSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            // Section header
            HStack(spacing: HRTSpacing.sm) {
                Image(systemName: "heart.text.square.fill")
                    .foregroundStyle(Color.hrtPinkFallback)
                Text("Symptoms")
                    .font(.hrtTitle2)
                    .foregroundStyle(Color.hrtTextFallback)
            }
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
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                emptySymptomStateView
            }
        }
    }

    private var alertLegend: some View {
        HStack(spacing: HRTSpacing.xs) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.hrtAlertFallback.opacity(0.2))
                .frame(width: 16, height: 12)
            Text("Days with symptoms that may need attention")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Highlighted days show symptoms that may need attention")
    }

    // MARK: - Empty States

    private var emptyWeightStateView: some View {
        HRTEmptyState(
            icon: "scalemass",
            title: "No Weight Data Yet",
            message: "Start logging your daily weight on the Today tab to see your trends here."
        )
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .accessibilityLabel("No weight data yet. Start logging your daily weight on the Today tab to see your trends here.")
    }

    private var emptySymptomStateView: some View {
        HRTEmptyState(
            icon: "waveform.path.ecg",
            title: "No Symptom Data Yet",
            message: "Log how you're feeling on the Today tab to track your symptoms over time."
        )
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .accessibilityLabel("No symptom data yet. Log how you're feeling on the Today tab to track your symptoms over time.")
    }
}

#Preview {
    TrendsView()
        .modelContainer(for: DailyEntry.self, inMemory: true)
}
