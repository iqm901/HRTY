import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var viewModel = TodayViewModel()
    @FocusState private var isWeightFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    weightAlertsSection
                    headerSection
                    weightEntrySection
                    symptomsSection
                    diureticSection
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("Today")
            .onAppear {
                viewModel.loadData(context: modelContext)
                viewModel.loadSymptoms(context: modelContext)
                viewModel.loadDiuretics(context: modelContext)
                viewModel.loadWeightAlerts(context: modelContext)
                viewModel.loadSymptomAlerts(context: modelContext)
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

    // MARK: - Alerts Section
    @ViewBuilder
    private var weightAlertsSection: some View {
        let hasAlerts = !viewModel.activeWeightAlerts.isEmpty || !viewModel.activeSymptomAlerts.isEmpty

        if hasAlerts {
            VStack(spacing: 12) {
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
        HStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.pink)
            Text("Thanks for staying on top of your health!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Thanks for staying on top of your health")
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("How are you feeling today?")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Your daily check-in takes just a couple of minutes.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Symptoms Section
    private var symptomsSection: some View {
        VStack(spacing: 16) {
            symptomsSectionHeader

            VStack(spacing: 4) {
                ForEach(SymptomType.allCases, id: \.self) { symptomType in
                    SymptomRowView(
                        symptomType: symptomType,
                        severity: viewModel.severity(for: symptomType),
                        onSeverityChange: { newSeverity in
                            viewModel.updateSeverity(newSeverity, for: symptomType, context: modelContext)
                        }
                    )

                    if symptomType != SymptomType.allCases.last {
                        Divider()
                    }
                }
            }

            severityLegend

            if viewModel.hasLoggedSymptoms {
                symptomsEncouragement
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var symptomsEncouragement: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Thanks for checking in today!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
        .transition(.opacity.combined(with: .scale))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Thanks for checking in today")
    }

    private var symptomsSectionHeader: some View {
        HStack {
            Image(systemName: "heart.text.square.fill")
                .foregroundStyle(.pink)
            Text("How are you feeling?")
                .font(.headline)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Symptoms section")
        .accessibilityHint("Rate your symptoms from 1 (none) to 5 (severe)")
    }

    private var severityLegend: some View {
        HStack(spacing: 16) {
            Text("1 = None")
            Text("3 = Moderate")
            Text("5 = Severe")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
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
        VStack(spacing: 16) {
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
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.25), value: viewModel.showHealthKitTimestamp)
    }

    private var sectionHeader: some View {
        HStack {
            Image(systemName: "scalemass.fill")
                .foregroundStyle(.blue)
            Text("Weight")
                .font(.headline)
            Spacer()
        }
    }

    private var weightInputField: some View {
        HStack(spacing: 8) {
            TextField("Enter weight", text: $viewModel.weightInput)
                .keyboardType(.decimalPad)
                .font(.system(size: 28, weight: .medium))
                .multilineTextAlignment(.center)
                .padding()
                .frame(height: 60)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .focused($isWeightFieldFocused)
                .accessibilityLabel("Weight input")
                .accessibilityHint("Enter your weight in pounds")
                .onChange(of: viewModel.weightInput) { _, _ in
                    // Clear HealthKit timestamp when user manually edits
                    if viewModel.showHealthKitTimestamp {
                        viewModel.clearHealthKitWeight()
                    }
                }

            Text("lbs")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }

    private var importFromHealthButton: some View {
        Button {
            Task {
                await viewModel.importWeightFromHealthKit()
            }
        } label: {
            HStack(spacing: 8) {
                if viewModel.isLoadingHealthKit {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(healthKitIconScale)
                } else {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                        .imageScale(healthKitImageScale)
                }
                Text(viewModel.isLoadingHealthKit ? "Importing..." : "Import from Health")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, healthKitButtonVerticalPadding)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(viewModel.isLoadingHealthKit)
        .accessibilityLabel(viewModel.isLoadingHealthKit ? "Importing weight from Health" : "Import weight from Health app")
        .accessibilityHint(viewModel.isLoadingHealthKit ? "Please wait while importing" : "Tap to import your most recent weight from Apple Health")
    }

    private func healthKitTimestampView(_ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.pink)
                .imageScale(healthKitTimestampImageScale)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }

    private func healthKitErrorView(_ error: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if viewModel.isHealthKitAuthorizationDenied {
                    Text("You can enable Health access in Settings.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Health import issue: \(error)")
    }

    private func validationErrorView(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
            Text(error)
                .font(.footnote)
                .foregroundStyle(.red)
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
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.weightInput.isEmpty ? Color.gray : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(viewModel.weightInput.isEmpty)
        .accessibilityLabel("Save weight button")
        .accessibilityHint("Tap to save your weight entry")
    }

    private var successFeedback: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Weight saved!")
                .font(.subheadline)
                .foregroundStyle(.green)
        }
        .transition(.opacity.combined(with: .scale))
        .accessibilityLabel("Weight saved successfully")
    }

    private var previousWeightView: some View {
        VStack(spacing: 8) {
            if viewModel.hasNoPreviousData {
                Text("This is your first weight entry!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("This is your first weight entry")
            } else if let previousWeight = viewModel.previousWeight {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Yesterday (\(viewModel.yesterdayDateText))")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text("\(previousWeight, specifier: "%.1f") lbs")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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
        .padding(.top, 8)
    }

    private func weightChangeView(text: String) -> some View {
        HStack {
            Image(systemName: weightChangeIcon)
                .foregroundStyle(weightChangeSwiftUIColor)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(weightChangeSwiftUIColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(weightChangeBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
        case .gained: return .orange
        case .lost: return .secondary
        case .stable: return .green
        }
    }

    private var weightChangeBackgroundColor: Color {
        switch weightChangeCategory {
        case .gained: return .orange.opacity(0.1)
        case .lost: return Color(.secondarySystemBackground)
        case .stable: return .green.opacity(0.1)
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
