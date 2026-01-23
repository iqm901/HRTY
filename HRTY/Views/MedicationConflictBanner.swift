import SwiftUI

/// A dismissible yellow banner that appears when medication conflicts are detected.
/// Uses warm, non-alarmist messaging to encourage verification with care team.
struct MedicationConflictBanner: View {
    let conflicts: [MedicationConflict]
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: HRTSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(Color.hrtCautionDark)

            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text("Medication Note")
                    .font(.hrtBodySemibold)
                    .foregroundStyle(Color.hrtCautionDark)

                Text(bannerMessage)
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextFallback)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Verify with your care team if you have questions.")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }

            Spacer()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.hrtCautionDark)
                    .padding(HRTSpacing.xs)
            }
            .accessibilityLabel("Dismiss medication note")
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCautionLight)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .padding(.horizontal, HRTSpacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Medication note: \(bannerMessage). Verify with your care team if you have questions.")
        .accessibilityAddTraits(.isStaticText)
    }

    private var bannerMessage: String {
        guard let firstConflict = conflicts.first else {
            return "Some medications may need review."
        }

        if conflicts.count == 1 {
            return firstConflict.message
        } else {
            return "You have \(conflicts.count) medication combinations that may need review."
        }
    }
}

// MARK: - Color Extension for Caution Colors

extension Color {
    /// Dark amber for caution text and icons
    static let hrtCautionDark = Color(red: 0.70, green: 0.55, blue: 0.20)

    /// Light amber/yellow for caution backgrounds
    static let hrtCautionLight = Color(red: 1.0, green: 0.96, blue: 0.85)
}

#Preview {
    VStack(spacing: HRTSpacing.lg) {
        MedicationConflictBanner(
            conflicts: [
                MedicationConflict(
                    type: .sameClass(.betaBlocker),
                    medications: [],
                    message: "You have multiple beta blockers listed: Metoprolol Succinate, Carvedilol. Most people take only one at a time."
                )
            ],
            onDismiss: {}
        )

        MedicationConflictBanner(
            conflicts: [
                MedicationConflict(
                    type: .sameClass(.betaBlocker),
                    medications: [],
                    message: "You have multiple beta blockers."
                ),
                MedicationConflict(
                    type: .crossClass(.aceInhibitor, .arb),
                    medications: [],
                    message: "ACEi and ARB together."
                )
            ],
            onDismiss: {}
        )
    }
    .padding(.vertical)
    .background(Color.hrtBackgroundFallback)
}
