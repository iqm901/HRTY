import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var viewModel = TodayViewModel()

    // MARK: - Symptom Check-in State
    @State private var showSymptomWizard = false
    @State private var checkInViewModel = SymptomCheckInViewModel()
    @State private var hasIncompleteCheckIn = false
    @State private var incompleteProgress: SymptomCheckInProgress?

    // MARK: - Profile State
    @State private var showProfileSheet = false
    @State private var clinicalProfile: ClinicalProfile?

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero image extending to top
                        Image("TodayHero")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 280)
                            .containerRelativeFrame(.horizontal)
                            .clipped()
                            .overlay(alignment: .top) {
                                // Light top scrim for readability
                                // White 12% at top, fading to transparent by 70% height
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
                                // "Today" title styled with Nunito to complement the soft illustration
                                Text("Today")
                                    .font(.custom("Nunito-SemiBold", size: 34))
                                    .foregroundStyle(Color.hrtHeroTitle)
                                    .shadow(color: Color.hrtHeroTitleShadow, radius: 8, x: 0, y: 2)
                                    .padding(.top, 60)
                                    .padding(.leading, HRTSpacing.md)
                            }
                            .overlay(alignment: .topTrailing) {
                                Menu {
                                    Button {
                                        NotificationCenter.default.post(name: .navigateToMyHeartTab, object: nil)
                                    } label: {
                                        Label("My Heart", systemImage: "heart.circle")
                                    }

                                    Button {
                                        NotificationCenter.default.post(name: .navigateToExportTab, object: nil)
                                    } label: {
                                        Label("Export", systemImage: "square.and.arrow.up")
                                    }

                                    Button {
                                        NotificationCenter.default.post(name: .navigateToSettingsTab, object: nil)
                                    } label: {
                                        Label("Settings", systemImage: "gear")
                                    }
                                } label: {
                                    ZStack(alignment: .topTrailing) {
                                        Image(systemName: "person.circle")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color.hrtHeroTitle)
                                            .shadow(color: Color.hrtHeroTitleShadow, radius: 8, x: 0, y: 2)

                                        // Red dot badge when profile incomplete
                                        if !(clinicalProfile?.isProfileComplete ?? true) {
                                            Circle()
                                                .fill(Color.hrtAlertFallback)
                                                .frame(width: 10, height: 10)
                                                .offset(x: 2, y: -2)
                                        }
                                    }
                                }
                                .accessibilityLabel(clinicalProfile?.isProfileComplete == true
                                    ? "View health profile"
                                    : "Complete health profile")
                                .padding(.top, 60)
                                .padding(.trailing, HRTSpacing.md)
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
                .opacity(viewModel.isLoading ? 0.3 : 1.0)
                .disabled(viewModel.isLoading)

                if viewModel.isLoading {
                    HRTLoadingView("Loading your data...")
                }
            }
            .toolbarBackground(Color.hrtBackgroundFallback.opacity(0), for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadAllData(context: modelContext)
                loadCheckInProgress()
                clinicalProfile = ClinicalProfile.getOrCreate(in: modelContext)
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
            .fullScreenCover(isPresented: $showSymptomWizard) {
                SymptomCheckInWizardView(
                    viewModel: checkInViewModel,
                    dailyEntry: viewModel.todayEntry,
                    onComplete: {
                        handleCheckInComplete()
                    }
                )
            }
            .sheet(isPresented: $showProfileSheet) {
                ProfileSheetView()
                    .onDisappear {
                        // Refresh profile state when sheet closes
                        clinicalProfile = ClinicalProfile.getOrCreate(in: modelContext)
                    }
            }
        }
    }

    // MARK: - Symptom Check-in Prompt

    private var symptomCheckInPrompt: some View {
        SymptomCheckInPromptView(
            hasIncompleteCheckIn: hasIncompleteCheckIn,
            completedCount: incompleteProgress?.completedCount ?? 0,
            totalCount: SymptomCheckInProgress.totalSymptoms,
            hasCompletedToday: viewModel.hasLoggedSymptoms && !hasIncompleteCheckIn,
            onStartCheckIn: {
                startCheckIn()
            }
        )
    }

    // MARK: - Vital Signs Section

    private var vitalSignsSection: some View {
        VitalSignsTabView(viewModel: viewModel)
    }

    // MARK: - Check-in Methods

    private func loadCheckInProgress() {
        incompleteProgress = SymptomCheckInProgress.fetchForToday(in: modelContext)
        hasIncompleteCheckIn = incompleteProgress != nil && !(incompleteProgress?.isComplete ?? true)
    }

    private func startCheckIn() {
        // Reset or load the check-in view model
        if hasIncompleteCheckIn, let progress = incompleteProgress {
            checkInViewModel.loadFromProgress(progress)
        } else {
            checkInViewModel.reset()
            // Pre-populate with existing symptom data if any
            for (symptomType, severity) in viewModel.symptomSeverities {
                if severity > 1 {
                    checkInViewModel.responses[symptomType] = severity
                }
            }
        }
        showSymptomWizard = true
    }

    private func handleCheckInComplete() {
        // Reload symptom data after check-in completes
        viewModel.loadSymptoms(context: modelContext)

        // Check for alerts
        viewModel.checkSymptomAlerts(context: modelContext)

        // Reset check-in state
        hasIncompleteCheckIn = false
        incompleteProgress = nil
        checkInViewModel.reset()
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

    // MARK: - Profile Completion Prompt

    @ViewBuilder
    private var profileCompletionPrompt: some View {
        if !(clinicalProfile?.isProfileComplete ?? true) {
            ProfileCompletionPromptView(
                completedCount: clinicalProfile?.completedRequiredFieldsCount ?? 0,
                totalCount: ClinicalProfile.requiredFieldsCount,
                onTapComplete: { showProfileSheet = true }
            )
        }
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: HRTSpacing.lg) {
            alertsSection

            profileCompletionPrompt

            headerSection

            vitalSignsSection

            symptomCheckInPrompt
        }
        .padding(.horizontal, HRTSpacing.md)
        .padding(.vertical, HRTSpacing.lg)
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [DailyEntry.self, SymptomCheckInProgress.self, ClinicalProfile.self], inMemory: true)
}
