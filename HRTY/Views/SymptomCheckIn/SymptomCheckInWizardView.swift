import SwiftUI
import SwiftData

/// Full-screen wizard for symptom check-in
struct SymptomCheckInWizardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var viewModel: SymptomCheckInViewModel
    let dailyEntry: DailyEntry?
    let onComplete: () -> Void

    @State private var showCloseConfirmation = false

    var body: some View {
        ZStack {
            Color.hrtBackgroundFallback
                .ignoresSafeArea()

            if viewModel.showingSummary {
                summaryView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            } else {
                wizardContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(HRTAnimation.standard, value: viewModel.showingSummary)
        .confirmationDialog(
            "Save your progress?",
            isPresented: $showCloseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Save and Close") {
                saveAndClose()
            }

            Button("Discard", role: .destructive) {
                discardAndClose()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can resume your check-in later from where you left off.")
        }
    }

    // MARK: - Wizard Content

    private var wizardContent: some View {
        VStack(spacing: 0) {
            wizardHeader

            TabView(selection: $viewModel.currentStep) {
                ForEach(Array(viewModel.symptoms.enumerated()), id: \.element) { index, symptom in
                    SymptomStepView(
                        symptom: symptom,
                        selectedSeverity: viewModel.responses[symptom],
                        onSeveritySelected: { severity in
                            viewModel.setSeverity(severity)
                            // Auto-advance after brief delay for visual feedback
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                viewModel.nextStep()
                            }
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            navigationButtons
        }
    }

    // MARK: - Wizard Header

    private var wizardHeader: some View {
        VStack(spacing: HRTSpacing.sm) {
            HStack {
                progressIndicator

                Spacer()

                closeButton
            }
            .padding(.horizontal, HRTSpacing.md)
            .padding(.top, HRTSpacing.md)

            progressBar
        }
        .background(Color.hrtCardFallback)
    }

    private var progressIndicator: some View {
        Text(viewModel.progressText)
            .font(.hrtHeadline)
            .foregroundStyle(Color.hrtTextFallback)
            .accessibilityLabel("Step \(viewModel.currentStep + 1) of \(viewModel.totalSteps)")
    }

    private var closeButton: some View {
        Button {
            if viewModel.completedCount > 0 {
                showCloseConfirmation = true
            } else {
                dismiss()
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
        }
        .accessibilityLabel("Close check-in")
        .accessibilityHint(viewModel.completedCount > 0
                          ? "Opens dialog to save or discard progress"
                          : "Closes the check-in wizard")
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.hrtBackgroundSecondaryFallback)
                    .frame(height: 4)

                Rectangle()
                    .fill(Color.hrtPinkFallback)
                    .frame(width: geometry.size.width * viewModel.progressFraction, height: 4)
                    .animation(HRTAnimation.standard, value: viewModel.progressFraction)
            }
        }
        .frame(height: 4)
        .accessibilityHidden(true)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: HRTSpacing.md) {
            if !viewModel.isFirstStep {
                backButton
            }

            Spacer()

            // Only show Next/Review button on last step (auto-advance handles other steps)
            if viewModel.isLastStep {
                nextButton
            }
        }
        .padding(HRTSpacing.md)
    }

    private var backButton: some View {
        Button {
            withAnimation(HRTAnimation.standard) {
                viewModel.previousStep()
            }
        } label: {
            HStack(spacing: HRTSpacing.xs) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        }
        .buttonStyle(HRTSecondaryButtonStyle())
        .accessibilityLabel("Go back")
        .accessibilityHint("Returns to the previous symptom")
    }

    private var nextButton: some View {
        let canProceed = viewModel.currentSeverity != nil

        return Button {
            withAnimation(HRTAnimation.standard) {
                viewModel.nextStep()
            }
        } label: {
            HStack(spacing: HRTSpacing.xs) {
                Text(viewModel.isLastStep ? "Review Responses" : "Next")
                Image(systemName: viewModel.isLastStep ? "checkmark.circle" : "chevron.right")
            }
        }
        .buttonStyle(HRTPrimaryButtonStyle())
        .disabled(!canProceed)
        .accessibilityLabel(viewModel.isLastStep ? "Review responses" : "Next symptom")
        .accessibilityHint(canProceed
                          ? (viewModel.isLastStep
                             ? "Opens the summary screen"
                             : "Moves to the next symptom")
                          : "Select a severity level first")
    }

    // MARK: - Summary View

    private var summaryView: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    withAnimation(HRTAnimation.standard) {
                        viewModel.showingSummary = false
                    }
                } label: {
                    HStack(spacing: HRTSpacing.xs) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundStyle(Color.hrtPinkFallback)
                }

                Spacer()

                closeButton
            }
            .padding(HRTSpacing.md)
            .background(Color.hrtCardFallback)

            SymptomCheckInSummaryView(
                responses: viewModel.responses,
                onEditSymptom: { symptom in
                    withAnimation(HRTAnimation.standard) {
                        viewModel.goToSymptom(symptom)
                    }
                },
                onComplete: {
                    completeCheckIn()
                }
            )
        }
    }

    // MARK: - Actions

    private func saveAndClose() {
        viewModel.saveProgress(context: modelContext, dailyEntry: dailyEntry)
        dismiss()
    }

    private func discardAndClose() {
        viewModel.deleteProgress(context: modelContext)
        dismiss()
    }

    private func completeCheckIn() {
        if viewModel.completeCheckIn(context: modelContext, dailyEntry: dailyEntry) {
            onComplete()
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview("Step 1") {
    let viewModel = SymptomCheckInViewModel()
    return SymptomCheckInWizardView(
        viewModel: viewModel,
        dailyEntry: nil,
        onComplete: {}
    )
}

#Preview("Step 5 with responses") {
    let viewModel = SymptomCheckInViewModel()
    viewModel.currentStep = 4
    viewModel.responses = [
        .dyspneaAtRest: 2,
        .dyspneaOnExertion: 3,
        .orthopnea: 1,
        .pnd: 1
    ]
    return SymptomCheckInWizardView(
        viewModel: viewModel,
        dailyEntry: nil,
        onComplete: {}
    )
}

#Preview("Summary") {
    let viewModel = SymptomCheckInViewModel()
    viewModel.showingSummary = true
    viewModel.responses = [
        .dyspneaAtRest: 2,
        .dyspneaOnExertion: 3,
        .orthopnea: 1,
        .pnd: 1,
        .chestPain: 2,
        .dizziness: 4,
        .syncope: 1,
        .reducedUrineOutput: 2
    ]
    return SymptomCheckInWizardView(
        viewModel: viewModel,
        dailyEntry: nil,
        onComplete: {}
    )
}
