import SwiftUI

/// Individual symptom page in the check-in wizard
struct SymptomStepView: View {
    let symptom: SymptomType
    let selectedSeverity: Int?
    let onSeveritySelected: (Int) -> Void

    @State private var showSymptomInfo = false

    var body: some View {
        VStack(spacing: HRTSpacing.xl) {
            Spacer()

            symptomHeader

            questionText

            severitySelector

            severityDescription

            Spacer()
            Spacer()
        }
        .padding(.horizontal, HRTSpacing.lg)
    }

    // MARK: - Symptom Header

    private var symptomHeader: some View {
        VStack(spacing: HRTSpacing.md) {
            Image(systemName: symptom.iconName)
                .font(.system(size: 48))
                .foregroundStyle(Color.hrtPinkFallback)
                .accessibilityHidden(true)

            HStack(spacing: HRTSpacing.xs) {
                Text(symptom.displayName)
                    .font(.hrtTitle2)
                    .foregroundStyle(Color.hrtTextFallback)
                    .multilineTextAlignment(.center)

                Button {
                    showSymptomInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.hrtPinkFallback.opacity(0.7))
                }
                .accessibilityLabel("Learn more about \(symptom.displayName)")
            }
        }
        .sheet(isPresented: $showSymptomInfo) {
            symptomInfoSheet
        }
    }

    // MARK: - Symptom Info Sheet

    private var symptomInfoSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: HRTSpacing.lg) {
                    // Icon and title
                    HStack(spacing: HRTSpacing.md) {
                        Image(systemName: symptom.iconName)
                            .font(.system(size: 32))
                            .foregroundStyle(Color.hrtPinkFallback)

                        Text(symptom.displayName)
                            .font(.hrtTitle2)
                            .foregroundStyle(Color.hrtTextFallback)
                    }
                    .padding(.top, HRTSpacing.md)

                    // Educational content
                    Text(EducationContent.Symptoms.description(for: symptom))
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                        .fixedSize(horizontal: false, vertical: true)

                    // Source citation
                    Text("Source: \(EducationContent.Symptoms.source)")
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                        .padding(.top, HRTSpacing.sm)

                    Spacer()
                }
                .padding(.horizontal, HRTSpacing.lg)
            }
            .background(Color.hrtBackgroundFallback)
            .navigationTitle("About This Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showSymptomInfo = false
                    }
                    .foregroundStyle(Color.hrtPinkFallback)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Question

    private var questionText: some View {
        Text("How much are you experiencing\nthis symptom today?")
            .font(.hrtBody)
            .foregroundStyle(Color.hrtTextSecondaryFallback)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Severity Selector

    private var severitySelector: some View {
        VStack(spacing: HRTSpacing.sm) {
            ForEach(1...5, id: \.self) { severity in
                severityButton(for: severity)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Severity level selector")
    }

    private func severityButton(for severity: Int) -> some View {
        let isSelected = selectedSeverity == severity
        let severityLevel = SeverityLevel(rawValue: severity) ?? .none

        return Button {
            onSeveritySelected(severity)
        } label: {
            HStack(spacing: HRTSpacing.md) {
                Text("\(severity)")
                    .font(.hrtTitle2)
                    .fontWeight(.semibold)
                    .frame(width: 32)
                Text(severityLevel.label)
                    .font(.hrtBody)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(HRTSpacing.md)
            .background(
                isSelected
                    ? severityColor(for: severity)
                    : Color.hrtBackgroundSecondaryFallback
            )
            .foregroundStyle(
                isSelected
                    ? .white
                    : Color.hrtTextFallback
            )
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: HRTRadius.medium)
                    .strokeBorder(
                        isSelected ? Color.clear : Color.hrtTextTertiaryFallback.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .accessibilityLabel("\(severityLevel.label), level \(severity)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint("Tap to select this severity level")
    }

    // MARK: - Severity Description

    @ViewBuilder
    private var severityDescription: some View {
        if let severity = selectedSeverity,
           let level = SeverityLevel(rawValue: severity) {
            Text(descriptionForSeverity(level))
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .multilineTextAlignment(.center)
                .padding(.horizontal, HRTSpacing.md)
                .transition(.opacity)
        } else {
            Text("Select how you're feeling")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Helper Methods

    private func severityColor(for severity: Int) -> Color {
        switch severity {
        case 1: return Color.hrtSeverity1Fallback
        case 2: return Color.hrtSeverity2Fallback
        case 3: return Color.hrtSeverity3Fallback
        case 4: return Color.hrtSeverity4Fallback
        case 5: return Color.hrtSeverity5Fallback
        default: return Color.hrtSeverity1Fallback
        }
    }

    private func descriptionForSeverity(_ level: SeverityLevel) -> String {
        switch level {
        case .none:
            return "Not experiencing this symptom at all"
        case .mild:
            return "Barely noticeable, not affecting daily activities"
        case .moderate:
            return "Noticeable but manageable"
        case .significant:
            return "Affecting your daily activities"
        case .severe:
            return "Significantly impacting your day"
        }
    }
}

// MARK: - SymptomType Icon Extension

extension SymptomType {
    var iconName: String {
        switch self {
        case .dyspneaAtRest:
            return "lungs.fill"
        case .dyspneaOnExertion:
            return "figure.walk"
        case .orthopnea:
            return "bed.double.fill"
        case .pnd:
            return "moon.zzz.fill"
        case .chestPain:
            return "heart.fill"
        case .dizziness:
            return "tornado"
        case .syncope:
            return "figure.fall"
        case .reducedUrineOutput:
            return "drop.fill"
        }
    }
}

// MARK: - Preview

#Preview("No Selection") {
    SymptomStepView(
        symptom: .dyspneaAtRest,
        selectedSeverity: nil,
        onSeveritySelected: { _ in }
    )
    .background(Color.hrtBackgroundFallback)
}

#Preview("Selected") {
    SymptomStepView(
        symptom: .chestPain,
        selectedSeverity: 3,
        onSeveritySelected: { _ in }
    )
    .background(Color.hrtBackgroundFallback)
}

#Preview("Severe") {
    SymptomStepView(
        symptom: .dizziness,
        selectedSeverity: 5,
        onSeveritySelected: { _ in }
    )
    .background(Color.hrtBackgroundFallback)
}
