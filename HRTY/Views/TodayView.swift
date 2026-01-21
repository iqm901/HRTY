import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TodayViewModel()
    @FocusState private var isWeightFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    alertsSection
                    headerSection
                    heartRateSection
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
                viewModel.loadHeartRateAlerts(context: modelContext)
                isWeightFieldFocused = true
            }
            .task {
                await viewModel.loadHeartRateData(context: modelContext)
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
                        !viewModel.activeHeartRateAlerts.isEmpty

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

            Text("lbs")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
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
}

#Preview {
    TodayView()
        .modelContainer(for: DailyEntry.self, inMemory: true)
}
