import SwiftUI
import SwiftData

/// Tab selection for the TodayView segmented control
enum TodayTab: String, CaseIterable {
    case vitalSigns = "Vital Signs"
    case symptoms = "Symptoms"
}

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var viewModel = TodayViewModel()
    @State private var selectedTab: TodayTab = .vitalSigns

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HRTSpacing.lg) {
                        alertsSection

                        headerSection

                        tabPicker

                        tabContent
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
            }
            .onChange(of: viewModel.activeWeightAlerts.count) { oldCount, newCount in
                if newCount > oldCount {
                    announceWeightAlertForVoiceOver()
                }
            }
            .onChange(of: viewModel.activeSymptomAlerts.count) { oldCount, newCount in
                if newCount > oldCount {
                    announceSymptomAlertForVoiceOver()
                }
            }
            .onChange(of: viewModel.activeHeartRateAlerts.count) { oldCount, newCount in
                if newCount > oldCount {
                    announceHeartRateAlertForVoiceOver()
                }
            }
            .onChange(of: viewModel.activeDizzinessBPAlerts.count) { oldCount, newCount in
                if newCount > oldCount {
                    announceDizzinessBPAlertForVoiceOver()
                }
            }
            .onChange(of: viewModel.activeVitalSignsAlerts.count) { oldCount, newCount in
                if newCount > oldCount {
                    announceVitalSignsAlertForVoiceOver()
                }
            }
        }
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        Picker("Today View", selection: $selectedTab) {
            ForEach(TodayTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Select tab")
        .accessibilityHint("Choose between vital signs and symptom management")
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case .vitalSigns:
                VitalSignsTabView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    ))
            case .symptoms:
                SymptomManagementTabView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    ))
            }
        }
        .animation(HRTAnimation.standard, value: selectedTab)
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

    private func announceVitalSignsAlertForVoiceOver() {
        guard let firstAlert = viewModel.activeVitalSignsAlerts.first else { return }
        let announcement = "Vital signs alert: \(firstAlert.alertType.accessibilityDescription)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }

    // MARK: - Alerts Section
    @ViewBuilder
    private var alertsSection: some View {
        let hasAlerts = !viewModel.activeWeightAlerts.isEmpty ||
                        !viewModel.activeSymptomAlerts.isEmpty ||
                        !viewModel.activeHeartRateAlerts.isEmpty ||
                        !viewModel.activeDizzinessBPAlerts.isEmpty ||
                        !viewModel.activeVitalSignsAlerts.isEmpty

        if hasAlerts {
            VStack(spacing: 12) {
                // Vital signs alerts
                ForEach(viewModel.activeVitalSignsAlerts, id: \.persistentModelID) { alert in
                    WeightAlertView(alert: alert) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.acknowledgeAlert(alert, context: modelContext)
                        }
                    }
                }

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
}

#Preview {
    TodayView()
        .modelContainer(for: DailyEntry.self, inMemory: true)
}
