import SwiftUI

/// Summary screen showing all responses before final save
struct SymptomCheckInSummaryView: View {
    let responses: [SymptomType: Int]
    let onEditSymptom: (SymptomType) -> Void
    let onComplete: () -> Void

    private var sortedSymptoms: [SymptomType] {
        SymptomType.allCases
    }

    private var hasConcerningSeverities: Bool {
        responses.values.contains { $0 >= 4 }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView {
                VStack(spacing: HRTSpacing.sm) {
                    if hasConcerningSeverities {
                        concerningWarning
                    }

                    symptomsList

                    editHint
                }
                .padding(.horizontal, HRTSpacing.md)
                .padding(.vertical, HRTSpacing.md)
            }

            completeButton
        }
        .background(Color.hrtBackgroundFallback)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: HRTSpacing.xs) {
            Text("Review Your Check-in")
                .font(.hrtTitle2)
                .foregroundStyle(Color.hrtTextFallback)

            Text("Tap any symptom to make changes")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
        }
        .padding(.vertical, HRTSpacing.md)
        .frame(maxWidth: .infinity)
        .background(Color.hrtCardFallback)
    }

    // MARK: - Concerning Warning

    private var concerningWarning: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.hrtCautionFallback)

            Text("Some symptoms are significant. Consider reaching out to your care team if this continues.")
                .font(.hrtFootnote)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCautionFallback.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Warning: Some symptoms are significant. Consider reaching out to your care team.")
    }

    // MARK: - Symptoms List

    private var symptomsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(sortedSymptoms.enumerated()), id: \.element) { index, symptom in
                symptomRow(for: symptom)

                if index < sortedSymptoms.count - 1 {
                    HRTDivider()
                }
            }
        }
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
    }

    private func symptomRow(for symptom: SymptomType) -> some View {
        let severity = responses[symptom] ?? 1
        let isConcerning = severity >= 4

        return Button {
            onEditSymptom(symptom)
        } label: {
            HStack(spacing: HRTSpacing.md) {
                Image(systemName: symptom.iconName)
                    .font(.title3)
                    .foregroundStyle(Color.hrtPinkFallback)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                    Text(symptom.displayName)
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtTextFallback)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                severityBadge(severity: severity, isConcerning: isConcerning)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
            }
            .padding(.horizontal, HRTSpacing.md)
            .padding(.vertical, HRTSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(symptom.displayName), severity \(severity)")
        .accessibilityHint("Tap to edit this response")
        .accessibilityAddTraits(isConcerning ? [] : [])
    }

    private func severityBadge(severity: Int, isConcerning: Bool) -> some View {
        HStack(spacing: HRTSpacing.xs) {
            if isConcerning {
                Image(systemName: "exclamationmark")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
            }

            Text("\(severity)")
                .font(.hrtBodyMedium)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, HRTSpacing.sm)
        .padding(.vertical, HRTSpacing.xs)
        .background(severityColor(for: severity))
        .clipShape(Capsule())
    }

    // MARK: - Edit Hint

    private var editHint: some View {
        HStack(spacing: HRTSpacing.xs) {
            Image(systemName: "hand.tap.fill")
                .foregroundStyle(Color.hrtTextTertiaryFallback)
            Text("Tap any symptom to change it")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
        }
        .padding(.top, HRTSpacing.sm)
    }

    // MARK: - Complete Button

    private var completeButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                onComplete()
            } label: {
                HStack(spacing: HRTSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Complete Check-in")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(HRTPrimaryButtonStyle())
            .padding(HRTSpacing.md)
        }
        .background(Color.hrtCardFallback)
        .accessibilityLabel("Complete check-in")
        .accessibilityHint("Saves all your responses and closes the wizard")
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
}

// MARK: - Preview

#Preview("Normal") {
    SymptomCheckInSummaryView(
        responses: [
            .dyspneaAtRest: 2,
            .dyspneaOnExertion: 3,
            .orthopnea: 1,
            .pnd: 1,
            .chestPain: 2,
            .dizziness: 2,
            .syncope: 1,
            .reducedUrineOutput: 2
        ],
        onEditSymptom: { _ in },
        onComplete: {}
    )
}

#Preview("With Concerning") {
    SymptomCheckInSummaryView(
        responses: [
            .dyspneaAtRest: 2,
            .dyspneaOnExertion: 3,
            .orthopnea: 1,
            .pnd: 1,
            .chestPain: 2,
            .dizziness: 4,
            .syncope: 1,
            .reducedUrineOutput: 5
        ],
        onEditSymptom: { _ in },
        onComplete: {}
    )
}
