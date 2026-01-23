import SwiftUI
import SwiftData

/// Tab view containing symptom severity logging
struct SymptomManagementTabView: View {
    @Bindable var viewModel: TodayViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: HRTSpacing.lg) {
            symptomsSection

            Spacer(minLength: HRTSpacing.xxl)
        }
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
        .accessibilityLabel("How are you feeling today")
        .accessibilityHint("Rate how you're feeling from 1 meaning not at all to 5 meaning a lot")
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
}

#Preview {
    SymptomManagementTabView(viewModel: TodayViewModel())
        .modelContainer(for: DailyEntry.self, inMemory: true)
        .padding()
        .background(Color.hrtBackgroundFallback)
}
