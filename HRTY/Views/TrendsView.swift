import SwiftUI
import SwiftData

struct TrendsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TrendsViewModel()
    @State private var showingWeightInfo = false
    @State private var showingHeartRateInfo = false
    @State private var showingBloodPressureInfo = false
    @State private var showingOxygenSaturationInfo = false
    @State private var showingSymptomsInfo = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero image extending to top
                    Image("TrendsHero")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 280)
                        .containerRelativeFrame(.horizontal)
                        .clipped()
                        .overlay(alignment: .top) {
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.12), location: 0),
                                    .init(color: Color.white.opacity(0), location: 0.7)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                        .overlay(alignment: .topLeading) {
                            Text("Trends")
                                .font(.custom("Nunito-SemiBold", size: 34))
                                .foregroundStyle(Color.hrtHeroTitle)
                                .shadow(color: Color.hrtHeroTitleShadow, radius: 8, x: 0, y: 2)
                                .padding(.top, 60)
                                .padding(.leading, HRTSpacing.md)
                        }

                    // Main content with rounded top corners, pulled up to overlap image
                    mainContent
                        .background(
                            Color.hrtBackgroundFallback
                                .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                        )
                        .offset(y: -40)
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(Color.hrtBackgroundFallback)
            .toolbarBackground(Color.hrtBackgroundFallback.opacity(0), for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadAllTrendDataWithHeartRate(context: modelContext)
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.lg) {
            if viewModel.isLoading {
                HRTLoadingView("Loading trends...")
                    .frame(height: 200)
            } else {
                // 1. Vitals section (top)
                vitalsSection

                // 2. Symptoms section
                symptomSection
            }
        }
        .padding(HRTSpacing.md)
        .padding(.top, HRTSpacing.sm)
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
            // Section header with info button
            HStack {
                Text("Weight")
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)

                Spacer()

                Button {
                    showingWeightInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
                .accessibilityLabel("Learn about weight tracking")
            }

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
        .sheet(isPresented: $showingWeightInfo) {
            TrendEducationSheet(education: EducationContent.Trends.weightEducation)
        }
    }

    // MARK: - Blood Pressure Content Section

    private var bloodPressureContentSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            // Section header with info button
            HStack {
                Text("Blood Pressure")
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)

                Spacer()

                Button {
                    showingBloodPressureInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
                .accessibilityLabel("Learn about blood pressure tracking")
            }

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
        .sheet(isPresented: $showingBloodPressureInfo) {
            TrendEducationSheet(education: EducationContent.Trends.bloodPressureEducation)
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
            // Section header with info button
            HStack {
                Text("Heart Rate")
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)

                Spacer()

                Button {
                    showingHeartRateInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
                .accessibilityLabel("Learn about heart rate tracking")
            }

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
        .sheet(isPresented: $showingHeartRateInfo) {
            TrendEducationSheet(education: EducationContent.Trends.heartRateEducation)
        }
    }

    // MARK: - Oxygen Saturation Content Section

    private var oxygenSaturationContentSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            // Section header with info button
            HStack {
                Text("Oxygen Saturation")
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)

                Spacer()

                Button {
                    showingOxygenSaturationInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
                .accessibilityLabel("Learn about oxygen saturation tracking")
            }

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
        .sheet(isPresented: $showingOxygenSaturationInfo) {
            TrendEducationSheet(education: EducationContent.Trends.oxygenSaturationEducation)
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
            message: "Enter your heart rate on the Today tab or sync from Apple Health."
        )
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .accessibilityLabel("No heart rate data yet. Enter your heart rate on the Today tab or sync from Apple Health.")
    }

    // MARK: - Symptom Section

    private var symptomSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            // Section header with info button
            HStack {
                HStack(spacing: HRTSpacing.sm) {
                    Image(systemName: "heart.text.square.fill")
                        .foregroundStyle(Color.hrtPinkFallback)
                    Text("Symptoms")
                        .font(.hrtTitle2)
                        .foregroundStyle(Color.hrtTextFallback)
                }

                Spacer()

                Button {
                    showingSymptomsInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
                .accessibilityLabel("Learn about symptom tracking")
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
        .sheet(isPresented: $showingSymptomsInfo) {
            TrendEducationSheet(education: EducationContent.Trends.symptomsEducation)
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

// MARK: - Trend Education Sheet

/// Sheet displaying educational content about a trend metric
struct TrendEducationSheet: View {
    let education: TrendEducation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: HRTSpacing.lg) {
                    // What it means section
                    educationSection(
                        title: "What It Means",
                        icon: "info.circle.fill",
                        content: education.whatItMeans,
                        accentColor: Color.hrtPinkFallback
                    )

                    // Patterns to watch section
                    educationSection(
                        title: "Patterns to Watch",
                        icon: "eye.fill",
                        content: education.patternsToWatch,
                        accentColor: Color.hrtCautionFallback
                    )

                    // Normal range section
                    VStack(alignment: .leading, spacing: HRTSpacing.sm) {
                        Label("Normal Range", systemImage: "checkmark.circle.fill")
                            .font(.hrtHeadline)
                            .foregroundStyle(Color.hrtGoodFallback)

                        Text(education.normalRange)
                            .font(.hrtBody)
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(HRTSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.hrtGoodFallback.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))

                    // Source
                    HStack {
                        Image(systemName: "book.closed.fill")
                            .font(.caption)
                        Text("Source: \(education.source)")
                            .font(.hrtCaption)
                    }
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, HRTSpacing.sm)
                }
                .padding(HRTSpacing.lg)
            }
            .background(Color.hrtBackgroundFallback)
            .navigationTitle(education.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func educationSection(title: String, icon: String, content: String, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Label(title, systemImage: icon)
                .font(.hrtHeadline)
                .foregroundStyle(accentColor)

            Text(content)
                .font(.hrtBody)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HRTSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
    }
}

#Preview {
    TrendsView()
        .modelContainer(for: DailyEntry.self, inMemory: true)
}
