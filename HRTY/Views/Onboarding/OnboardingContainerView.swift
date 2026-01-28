import SwiftUI

/// Container view for the onboarding flow.
/// Manages navigation between onboarding pages with a progress indicator.
struct OnboardingContainerView: View {
    @State private var viewModel = OnboardingViewModel()
    @State private var medicationsViewModel = MedicationsViewModel()
    @Environment(\.modelContext) private var modelContext

    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            ProgressView(value: viewModel.progress)
                .progressViewStyle(.linear)
                .tint(.pink)
                .padding(.horizontal)
                .padding(.top, 8)
                .accessibilityLabel("Onboarding progress")
                .accessibilityValue("\(viewModel.currentPage.rawValue + 1) of \(viewModel.totalPages)")

            // Page content
            TabView(selection: $viewModel.currentPage) {
                WelcomePageView(onContinue: viewModel.nextPage)
                    .tag(OnboardingViewModel.Page.welcome)

                // Education pages
                EducationPageView(
                    education: EducationContent.Onboarding.whyTrackingMatters,
                    pageNumber: 0,
                    totalEducationPages: OnboardingViewModel.educationPages.count,
                    onContinue: viewModel.nextPage,
                    onSkip: viewModel.skipEducation
                )
                .tag(OnboardingViewModel.Page.educationTracking)

                EducationPageView(
                    education: EducationContent.Onboarding.knowYourZones,
                    pageNumber: 1,
                    totalEducationPages: OnboardingViewModel.educationPages.count,
                    onContinue: viewModel.nextPage,
                    onSkip: viewModel.skipEducation
                )
                .tag(OnboardingViewModel.Page.educationZones)

                EducationPageView(
                    education: EducationContent.Onboarding.youAreInControl,
                    pageNumber: 2,
                    totalEducationPages: OnboardingViewModel.educationPages.count,
                    onContinue: viewModel.nextPage,
                    onSkip: viewModel.skipEducation
                )
                .tag(OnboardingViewModel.Page.educationControl)

                HealthKitPermissionPageView(
                    isAvailable: viewModel.isHealthKitAvailable,
                    isRequesting: viewModel.isRequestingPermission,
                    onAllow: {
                        Task {
                            await viewModel.requestHealthKitPermission()
                        }
                    },
                    onSkip: viewModel.skip
                )
                .tag(OnboardingViewModel.Page.healthKit)

                NotificationPermissionPageView(
                    isRequesting: viewModel.isRequestingPermission,
                    onAllow: {
                        Task {
                            await viewModel.requestNotificationPermission()
                        }
                    },
                    onSkip: viewModel.skip
                )
                .tag(OnboardingViewModel.Page.notifications)

                MedicationSetupPageView(
                    onAddMedications: viewModel.addMedications,
                    onSkip: viewModel.skipMedications
                )
                .tag(OnboardingViewModel.Page.medications)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentPage)
        }
        .onAppear {
            viewModel.onComplete = onComplete
        }
        .sheet(isPresented: $viewModel.showMedicationForm) {
            viewModel.medicationFormDismissed()
        } content: {
            MedicationFormView(viewModel: medicationsViewModel, isEditing: false)
        }
    }
}

#Preview {
    OnboardingContainerView(onComplete: {})
}
