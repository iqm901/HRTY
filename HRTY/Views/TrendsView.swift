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
                            // 1. Symptoms section (moved to top)
                            symptomSection

                            // 2. Vitals section (new)
                            vitalsSection
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

    // MARK: - Vitals Section

    private var vitalsSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            // Section header
            HStack(spacing: HRTSpacing.sm) {
                Image(systemName: "chart.line.text.clipboard")
                    .foregroundStyle(Color.hrtPinkFallback)
                Text("Vitals")
                    .font(.hrtTitle2)
                    .foregroundStyle(Color.hrtTextFallback)
            }
            .accessibilityAddTraits(.isHeader)

            // Toggle pills
            VitalToggleView(selectedVital: $viewModel.selectedVital)

            // Selected content based on toggle
            switch viewModel.selectedVital {
            case .overview:
                VitalsOverviewView(viewModel: viewModel, selectedVital: $viewModel.selectedVital)
            case .weight:
                weightContentSection
            case .bloodPressure:
                bloodPressureContentSection
            case .heartRate:
                heartRateContentSection
            case .oxygenSaturation:
                oxygenSaturationContentSection
            }
        }
    }

    // MARK: - Weight Content Section (for Vitals toggle)

    private var weightContentSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            if viewModel.hasWeightData {
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
            } else {
                emptyWeightStateView
            }
        }
    }

    // MARK: - Blood Pressure Content Section

    private var bloodPressureContentSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            if viewModel.hasBloodPressureData {
                // Summary card
                bloodPressureSummaryCard

                // Alert legend (if there are alert days)
                if !viewModel.bloodPressureAlertDates.isEmpty {
                    bloodPressureAlertLegend
                }

                // Chart
                BloodPressureTrendChart(
                    bloodPressureEntries: viewModel.bloodPressureEntries,
                    alertDates: viewModel.bloodPressureAlertDates
                )
                .accessibilityLabel(viewModel.bloodPressureAccessibilitySummary)

                // Date range
                Text(viewModel.dateRangeText)
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                emptyBloodPressureStateView
            }
        }
    }

    private var bloodPressureSummaryCard: some View {
        HStack(spacing: HRTSpacing.md) {
            // Current BP
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Latest")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                if let bp = viewModel.formattedCurrentBP {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(bp)
                            .font(.hrtTitle)
                            .foregroundStyle(Color.hrtTextFallback)
                        Text("mmHg")
                            .font(.hrtCaption)
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                    }
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

                if let avg = viewModel.formattedAverageBP {
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

            Spacer()
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
    }

    private var bloodPressureAlertLegend: some View {
        HStack(spacing: HRTSpacing.xs) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.hrtAlertFallback.opacity(0.2))
                .frame(width: 16, height: 12)
            Text("Days with blood pressure values that may need attention")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Highlighted days show blood pressure values that may need attention")
    }

    private var emptyBloodPressureStateView: some View {
        HRTEmptyState(
            icon: "heart.text.clipboard",
            title: "No Blood Pressure Data Yet",
            message: "Log your blood pressure on the Today tab to see your trends here."
        )
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .accessibilityLabel("No blood pressure data yet. Log your blood pressure on the Today tab to see your trends here.")
    }

    // MARK: - Heart Rate Content Section (for Vitals toggle)

    private var heartRateContentSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
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

    // MARK: - Oxygen Saturation Content Section

    private var oxygenSaturationContentSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            if viewModel.hasOxygenSaturationData {
                // Summary card
                oxygenSaturationSummaryCard

                // Alert legend (if there are alert days)
                if !viewModel.oxygenSaturationAlertDates.isEmpty {
                    oxygenSaturationAlertLegend
                }

                // Chart
                OxygenSaturationTrendChart(
                    oxygenSaturationEntries: viewModel.oxygenSaturationEntries,
                    alertDates: viewModel.oxygenSaturationAlertDates
                )
                .accessibilityLabel(viewModel.oxygenSaturationAccessibilitySummary)

                // Date range
                Text(viewModel.dateRangeText)
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                emptyOxygenSaturationStateView
            }
        }
    }

    private var oxygenSaturationSummaryCard: some View {
        HStack(spacing: HRTSpacing.md) {
            // Current O2
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Latest")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                if let o2 = viewModel.formattedCurrentO2 {
                    Text(o2)
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

                if let avg = viewModel.formattedAverageO2 {
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

                if let range = viewModel.formattedO2Range {
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

    private var oxygenSaturationAlertLegend: some View {
        HStack(spacing: HRTSpacing.xs) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.hrtAlertFallback.opacity(0.2))
                .frame(width: 16, height: 12)
            Text("Days with oxygen saturation values that may need attention")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Highlighted days show oxygen saturation values that may need attention")
    }

    private var emptyOxygenSaturationStateView: some View {
        HRTEmptyState(
            icon: "lungs",
            title: "No Oxygen Saturation Data Yet",
            message: "Log your oxygen saturation on the Today tab to see your trends here."
        )
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .accessibilityLabel("No oxygen saturation data yet. Log your oxygen saturation on the Today tab to see your trends here.")
    }

    // MARK: - Weight Summary Card

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

    // MARK: - Heart Rate Summary Card

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
