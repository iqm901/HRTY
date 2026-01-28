import SwiftUI

/// A banner component that displays antiplatelet medication suggestions
struct AntiplateletWarningBanner: View {
    let recommendation: AntiplateletRecommendation
    let onAddMedication: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            // Header with warning icon
            HStack(spacing: HRTSpacing.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.hrtCautionFallback)
                    .font(.subheadline)

                Text(recommendation.warningMessage ?? "Medication Suggestion")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.hrtTextFallback)
            }

            // Detail message
            if let detailMessage = recommendation.detailMessage {
                Text(detailMessage)
                    .font(.caption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Missing medications suggestions
            if !recommendation.missingMedications.isEmpty {
                VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                    ForEach(recommendation.missingMedications, id: \.rawValue) { missing in
                        HStack(spacing: HRTSpacing.xs) {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(Color.hrtPinkFallback)
                                .font(.caption)

                            Text("Consider: \(missing.suggestionText)")
                                .font(.caption)
                                .foregroundStyle(Color.hrtTextSecondaryFallback)
                        }
                    }
                }
                .padding(.top, HRTSpacing.xs)
            }

            // Add Medication button
            Button(action: onAddMedication) {
                HStack(spacing: HRTSpacing.xs) {
                    Image(systemName: "plus")
                        .font(.caption.weight(.semibold))
                    Text("Add Medication")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(Color.hrtPinkFallback)
                .padding(.vertical, HRTSpacing.sm)
                .padding(.horizontal, HRTSpacing.md)
                .background(Color.hrtPinkFallback.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: HRTRadius.small))
            }
            .buttonStyle(.plain)
            .padding(.top, HRTSpacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HRTSpacing.md)
        .background(Color.hrtCautionFallback.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: HRTRadius.medium)
                .stroke(Color.hrtCautionFallback.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview("DAPT Warning") {
    AntiplateletWarningBanner(
        recommendation: AntiplateletRecommendation(
            recommendationType: .dapt,
            currentStatus: AntiplateletStatus(hasAspirin: false, hasP2Y12: false),
            missingMedications: [.aspirin, .p2y12],
            warningMessage: "Medication Suggestion",
            detailMessage: "For stents placed within the last 12 months, guidelines recommend both aspirin and a P2Y12 inhibitor."
        ),
        onAddMedication: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("Single Antiplatelet Warning") {
    AntiplateletWarningBanner(
        recommendation: AntiplateletRecommendation(
            recommendationType: .singleAntiplatelet,
            currentStatus: AntiplateletStatus(hasAspirin: false, hasP2Y12: false),
            missingMedications: [.aspirin],
            warningMessage: "Medication Suggestion",
            detailMessage: "After coronary procedures, guidelines recommend taking an antiplatelet medication."
        ),
        onAddMedication: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("Partial DAPT Warning") {
    AntiplateletWarningBanner(
        recommendation: AntiplateletRecommendation(
            recommendationType: .dapt,
            currentStatus: AntiplateletStatus(hasAspirin: true, hasP2Y12: false),
            missingMedications: [.p2y12],
            warningMessage: "Medication Suggestion",
            detailMessage: "For stents placed within the last 12 months, guidelines recommend both aspirin and a P2Y12 inhibitor."
        ),
        onAddMedication: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}
