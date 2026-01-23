import SwiftUI
import SwiftData

/// Tab view containing all vital signs entry sections
struct VitalSignsTabView: View {
    @Bindable var viewModel: TodayViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var isWeightFieldFocused: Bool

    var body: some View {
        VStack(spacing: HRTSpacing.lg) {
            timingRecommendation

            heartRateSection

            weightEntrySection

            BloodPressureEntryView(
                systolicInput: $viewModel.systolicBPInput,
                diastolicInput: $viewModel.diastolicBPInput,
                isHealthKitAvailable: viewModel.isHealthKitAvailable,
                isLoadingHealthKit: viewModel.isLoadingBPHealthKit,
                healthKitTimestamp: viewModel.bloodPressureHealthKitTimestamp,
                validationError: viewModel.bloodPressureValidationError,
                showSaveSuccess: viewModel.showBPSaveSuccess,
                onImportFromHealthKit: {
                    Task {
                        await viewModel.importBloodPressureFromHealthKit()
                    }
                },
                onSave: {
                    viewModel.saveBloodPressure(context: modelContext)
                }
            )

            OxygenSaturationEntryView(
                oxygenInput: $viewModel.oxygenSaturationInput,
                isHealthKitAvailable: viewModel.isHealthKitAvailable,
                isLoadingHealthKit: viewModel.isLoadingSpO2HealthKit,
                healthKitTimestamp: viewModel.oxygenSaturationHealthKitTimestamp,
                validationError: viewModel.oxygenSaturationValidationError,
                showSaveSuccess: viewModel.showSpO2SaveSuccess,
                onImportFromHealthKit: {
                    Task {
                        await viewModel.importOxygenSaturationFromHealthKit()
                    }
                },
                onSave: {
                    viewModel.saveOxygenSaturation(context: modelContext)
                }
            )

            Spacer(minLength: HRTSpacing.xxl)
        }
    }

    // MARK: - Timing Recommendation

    private var timingRecommendation: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "clock")
                .foregroundStyle(Color.hrtTextTertiaryFallback)
            Text("For best results, check your vitals at the same time each day, ideally 2 hours after taking blood pressure medications.")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
        }
        .padding(HRTSpacing.sm)
        .background(Color.hrtBackgroundSecondaryFallback.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.small))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Timing tip: For best results, check your vitals at the same time each day, ideally 2 hours after taking blood pressure medications.")
    }

    // MARK: - Heart Rate Section

    private var heartRateSection: some View {
        HeartRateSectionView(
            heartRate: viewModel.formattedHeartRate,
            timestamp: viewModel.heartRateTimestamp,
            isLoading: viewModel.isLoadingHeartRate,
            isAvailable: viewModel.healthKitAvailable
        )
    }

    // MARK: - Weight Entry Section

    private var weightEntrySection: some View {
        VStack(spacing: HRTSpacing.md) {
            sectionHeader

            weightInputField

            if viewModel.showHealthKitTimestamp, let timestampText = viewModel.healthKitTimestampText {
                healthKitTimestampView(timestampText)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            if viewModel.isHealthKitAvailable {
                importFromHealthButton
            }

            if let healthKitError = viewModel.healthKitError {
                healthKitErrorView(healthKitError)
            }

            if let error = viewModel.validationError {
                validationErrorView(error)
            }

            saveButton

            if viewModel.showSaveSuccess {
                successFeedback
            }

            previousWeightView
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .animation(HRTAnimation.standard, value: viewModel.showHealthKitTimestamp)
    }

    private var sectionHeader: some View {
        HStack {
            Image(systemName: "scalemass.fill")
                .foregroundStyle(Color.hrtPinkFallback)
            Text("Weight")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)
            Spacer()
        }
    }

    private var weightInputField: some View {
        HStack(spacing: HRTSpacing.sm) {
            TextField("Enter weight", text: $viewModel.weightInput)
                .keyboardType(.decimalPad)
                .font(.hrtMetricMedium)
                .multilineTextAlignment(.center)
                .padding(HRTSpacing.md)
                .frame(height: 70)
                .background(Color.hrtBackgroundSecondaryFallback)
                .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
                .focused($isWeightFieldFocused)
                .accessibilityLabel("Weight input")
                .accessibilityHint("Enter your weight in pounds")
                .onChange(of: viewModel.weightInput) { _, _ in
                    if viewModel.showHealthKitTimestamp || viewModel.healthKitError != nil {
                        viewModel.clearHealthKitWeight()
                    }
                }

            Text("lbs")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
    }

    private var importFromHealthButton: some View {
        Button {
            Task {
                await viewModel.importWeightFromHealthKit()
            }
        } label: {
            HStack(spacing: HRTSpacing.sm) {
                if viewModel.isLoadingHealthKit {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(Color.hrtPinkFallback)
                        .scaleEffect(healthKitIconScale)
                } else {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(Color.hrtPinkFallback)
                        .imageScale(healthKitImageScale)
                }
                Text(viewModel.isLoadingHealthKit ? "Importing..." : "Import from Health")
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextFallback)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, healthKitButtonVerticalPadding)
            .background(Color.hrtBackgroundSecondaryFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        }
        .disabled(viewModel.isLoadingHealthKit)
        .accessibilityLabel(viewModel.isLoadingHealthKit ? "Importing weight from Health" : "Import weight from Health app")
        .accessibilityHint(viewModel.isLoadingHealthKit ? "Please wait while importing" : "Tap to import your most recent weight from Apple Health")
    }

    private func healthKitTimestampView(_ text: String) -> some View {
        HStack(spacing: HRTSpacing.xs) {
            Image(systemName: "heart.fill")
                .foregroundStyle(Color.hrtPinkFallback)
                .imageScale(healthKitTimestampImageScale)
            Text(text)
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }

    private func healthKitErrorView(_ error: String) -> some View {
        HStack(alignment: .top, spacing: HRTSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(Color.hrtCautionFallback)
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text(error)
                    .font(.hrtFootnote)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                if let recoverySuggestion = viewModel.healthKitRecoverySuggestion {
                    Text(recoverySuggestion)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Health import issue: \(error)")
    }

    private func validationErrorView(_ error: String) -> some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(Color.hrtAlertFallback)
            Text(error)
                .font(.hrtFootnote)
                .foregroundStyle(Color.hrtAlertFallback)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(error)")
    }

    private var saveButton: some View {
        Button {
            viewModel.saveWeight(context: modelContext)
            isWeightFieldFocused = false
        } label: {
            Text("Save Weight")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(HRTPrimaryButtonStyle())
        .disabled(viewModel.weightInput.isEmpty)
        .accessibilityLabel("Save weight button")
        .accessibilityHint("Tap to save your weight entry")
    }

    private var successFeedback: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.hrtGoodFallback)
            Text("Weight saved!")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtGoodFallback)
        }
        .transition(.opacity.combined(with: .scale))
        .accessibilityLabel("Weight saved successfully")
    }

    private var previousWeightView: some View {
        VStack(spacing: HRTSpacing.sm) {
            if viewModel.hasNoPreviousData {
                Text("This is your first weight entry!")
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .accessibilityLabel("This is your first weight entry")
            } else if let previousWeight = viewModel.previousWeight {
                HStack {
                    VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                        Text("Yesterday (\(viewModel.yesterdayDateText))")
                            .font(.hrtCaption)
                            .foregroundStyle(Color.hrtTextTertiaryFallback)
                        Text("\(previousWeight, specifier: "%.1f") lbs")
                            .font(.hrtCallout)
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                    }
                    Spacer()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Yesterday's weight: \(String(format: "%.1f", previousWeight)) pounds")

                if let changeText = viewModel.weightChangeText {
                    weightChangeView(text: changeText)
                }
            }
        }
        .padding(.top, HRTSpacing.sm)
    }

    private func weightChangeView(text: String) -> some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: weightChangeIcon)
                .foregroundStyle(weightChangeSwiftUIColor)
            Text(text)
                .font(.hrtCallout)
                .foregroundStyle(weightChangeSwiftUIColor)
        }
        .padding(.horizontal, HRTSpacing.md)
        .padding(.vertical, HRTSpacing.sm)
        .background(weightChangeBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.small))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
        .accessibilityHint("Weight change from yesterday")
    }

    // MARK: - Weight Change Styling

    private enum WeightChangeCategory {
        case gained
        case lost
        case stable
    }

    private var weightChangeCategory: WeightChangeCategory {
        guard let change = viewModel.weightChange else { return .stable }
        if change > AlertConstants.weightStabilityThreshold { return .gained }
        if change < -AlertConstants.weightStabilityThreshold { return .lost }
        return .stable
    }

    private var weightChangeIcon: String {
        switch weightChangeCategory {
        case .gained: return "arrow.up.circle.fill"
        case .lost: return "arrow.down.circle.fill"
        case .stable: return "equal.circle.fill"
        }
    }

    private var weightChangeSwiftUIColor: Color {
        switch weightChangeCategory {
        case .gained: return Color.hrtCautionFallback
        case .lost: return Color.hrtTextSecondaryFallback
        case .stable: return Color.hrtGoodFallback
        }
    }

    private var weightChangeBackgroundColor: Color {
        switch weightChangeCategory {
        case .gained: return Color.hrtCautionFallback.opacity(0.15)
        case .lost: return Color.hrtBackgroundSecondaryFallback
        case .stable: return Color.hrtGoodFallback.opacity(0.15)
        }
    }

    // MARK: - Dynamic Type Support

    private var healthKitIconScale: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return 0.8
        case .large, .xLarge:
            return 0.9
        case .xxLarge, .xxxLarge:
            return 1.0
        case .accessibility1, .accessibility2:
            return 1.1
        case .accessibility3, .accessibility4, .accessibility5:
            return 1.2
        @unknown default:
            return 0.9
        }
    }

    private var healthKitImageScale: Image.Scale {
        dynamicTypeSize.isAccessibilitySize ? .large : .medium
    }

    private var healthKitButtonVerticalPadding: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return 12
        case .large, .xLarge:
            return 14
        case .xxLarge, .xxxLarge:
            return 16
        case .accessibility1, .accessibility2:
            return 18
        case .accessibility3, .accessibility4, .accessibility5:
            return 20
        @unknown default:
            return 14
        }
    }

    private var healthKitTimestampImageScale: Image.Scale {
        dynamicTypeSize.isAccessibilitySize ? .medium : .small
    }
}

#Preview {
    VitalSignsTabView(viewModel: TodayViewModel())
        .modelContainer(for: DailyEntry.self, inMemory: true)
        .padding()
        .background(Color.hrtBackgroundFallback)
}
