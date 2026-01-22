import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var viewModel = TodayViewModel()
    @FocusState private var isWeightFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HRTSpacing.lg) {
                        alertsSection
                        headerSection
                        heartRateSection
                        weightEntrySection
                        symptomsSection
                        diureticSection
                        Spacer(minLength: HRTSpacing.xxl)
                    }
                    .padding(.horizontal, HRTSpacing.md)
                    .padding(.vertical, HRTSpacing.md)
                }
                .scrollContentBackground(.hidden)
                .opacity(viewModel.isLoading ? 0.3 : 1.0)
                .disabled(viewModel.isLoading)

                if viewModel.isLoading {
                    HRTLoadingView("Loading your data...")
                }
            }
            .toolbarBackground(Color.hrtBackgroundFallback, for: .navigationBar)
            .navigationTitle("Today")
            .task {
                await viewModel.loadAllData(context: modelContext)
                isWeightFieldFocused = true
            }
            .onChange(of: viewModel.activeWeightAlerts.count) { oldCount, newCount in
                // Announce new alerts to VoiceOver users
                if newCount > oldCount {
                    announceWeightAlertForVoiceOver()
                }
            }
            .onChange(of: viewModel.activeSymptomAlerts.count) { oldCount, newCount in
                // Announce new symptom alerts to VoiceOver users
                if newCount > oldCount {
                    announceSymptomAlertForVoiceOver()
                }
            }
            .onChange(of: viewModel.activeHeartRateAlerts.count) { oldCount, newCount in
                // Announce new heart rate alerts to VoiceOver users
                if newCount > oldCount {
                    announceHeartRateAlertForVoiceOver()
                }
            }
            .onChange(of: viewModel.activeDizzinessBPAlerts.count) { oldCount, newCount in
                // Announce new dizziness BP alerts to VoiceOver users
                if newCount > oldCount {
                    announceDizzinessBPAlertForVoiceOver()
                }
            }
        }
    }

    // MARK: - VoiceOver Support

    private func announceWeightAlertForVoiceOver() {
        guard let firstAlert = viewModel.activeWeightAlerts.first else { return }
        let announcement = "Weight alert: \(firstAlert.alertType.accessibilityDescription)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }

    private func announceSymptomAlertForVoiceOver() {
        guard let firstAlert = viewModel.activeSymptomAlerts.first else { return }
        let announcement = "Symptom alert: \(firstAlert.alertType.accessibilityDescription)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }

    private func announceHeartRateAlertForVoiceOver() {
        guard let firstAlert = viewModel.activeHeartRateAlerts.first else { return }
        let announcement = "Heart rate alert: \(firstAlert.alertType.accessibilityDescription)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }

    private func announceDizzinessBPAlertForVoiceOver() {
        guard let firstAlert = viewModel.activeDizzinessBPAlerts.first else { return }
        let announcement = "Blood pressure check suggested: \(firstAlert.alertType.accessibilityDescription)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
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

    // MARK: - Alerts Section
    @ViewBuilder
    private var alertsSection: some View {
        let hasAlerts = !viewModel.activeWeightAlerts.isEmpty ||
                        !viewModel.activeSymptomAlerts.isEmpty ||
                        !viewModel.activeHeartRateAlerts.isEmpty ||
                        !viewModel.activeDizzinessBPAlerts.isEmpty

        if hasAlerts {
            VStack(spacing: 12) {
                // Heart rate alerts
                ForEach(viewModel.activeHeartRateAlerts, id: \.persistentModelID) { alert in
                    WeightAlertView(alert: alert) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.acknowledgeAlert(alert, context: modelContext)
                        }
                    }
                }

                // Dizziness BP check alerts
                ForEach(viewModel.activeDizzinessBPAlerts, id: \.persistentModelID) { alert in
                    WeightAlertView(alert: alert) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.acknowledgeAlert(alert, context: modelContext)
                        }
                    }
                }

                // Weight alerts
                ForEach(viewModel.activeWeightAlerts, id: \.persistentModelID) { alert in
                    WeightAlertView(alert: alert) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.acknowledgeAlert(alert, context: modelContext)
                        }
                    }
                }

                // Symptom alerts
                ForEach(viewModel.activeSymptomAlerts, id: \.persistentModelID) { alert in
                    WeightAlertView(alert: alert) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.acknowledgeAlert(alert, context: modelContext)
                        }
                    }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        } else if viewModel.showAlertDismissedEncouragement {
            alertDismissedEncouragement
                .transition(.opacity.combined(with: .scale))
        }
    }

    private var alertDismissedEncouragement: some View {
        HRTEncouragementMessage(message: "Thanks for staying on top of your health!")
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Thanks for staying on top of your health")
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: HRTSpacing.sm) {
            Text("How are you feeling today?")
                .font(.hrtTitle2)
                .foregroundStyle(Color.hrtTextFallback)
            Text("Your daily check-in takes just a couple of minutes.")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, HRTSpacing.sm)
    }

    // MARK: - Symptoms Section
    private var symptomsSection: some View {
        VStack(spacing: HRTSpacing.md) {
            symptomsSectionHeader

            VStack(spacing: HRTSpacing.xs) {
                ForEach(SymptomType.allCases, id: \.self) { symptomType in
                    SymptomRowView(
                        symptomType: symptomType,
                        severity: viewModel.severity(for: symptomType),
                        onSeverityChange: { newSeverity in
                            viewModel.updateSeverity(newSeverity, for: symptomType, context: modelContext)
                        }
                    )

                    if symptomType != SymptomType.allCases.last {
                        HRTDivider()
                    }
                }
            }

            severityLegend

            if viewModel.hasLoggedSymptoms {
                symptomsEncouragement
            }
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
    }

    private var symptomsEncouragement: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.hrtGoodFallback)
            Text("Thanks for checking in today!")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .padding(.top, HRTSpacing.sm)
        .transition(.opacity.combined(with: .scale))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Thanks for checking in today")
    }

    private var symptomsSectionHeader: some View {
        HStack {
            Image(systemName: "heart.text.square.fill")
                .foregroundStyle(Color.hrtPinkFallback)
            Text("How are you feeling?")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Symptoms section")
        .accessibilityHint("Rate your symptoms from 1 (none) to 5 (severe)")
    }

    private var severityLegend: some View {
        HStack(spacing: HRTSpacing.md) {
            HRTSeverityBadge(level: 1, showLabel: true)
            HRTSeverityBadge(level: 3, showLabel: true)
            HRTSeverityBadge(level: 5, showLabel: true)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Severity scale: 1 means none, 3 means moderate, 5 means severe")
    }

    // MARK: - Diuretic Section
    private var diureticSection: some View {
        DiureticSectionView(viewModel: viewModel)
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
                    // Clear HealthKit timestamp and errors when user manually edits
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
        case gained   // Weight gain - amber warning
        case lost     // Weight loss - neutral
        case stable   // No significant change - green success
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

    // MARK: - Dynamic Type Support for HealthKit UI

    /// Scale factor for ProgressView spinner based on Dynamic Type size
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

    /// Image scale for HealthKit heart icon in import button
    private var healthKitImageScale: Image.Scale {
        dynamicTypeSize.isAccessibilitySize ? .large : .medium
    }

    /// Vertical padding for HealthKit import button
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

    /// Image scale for HealthKit timestamp heart icon
    private var healthKitTimestampImageScale: Image.Scale {
        dynamicTypeSize.isAccessibilitySize ? .medium : .small
    }
}

#Preview {
    TodayView()
        .modelContainer(for: DailyEntry.self, inMemory: true)
}
