import SwiftUI

/// Medication setup page.
/// Prompts user to add their medications or skip for later.
struct MedicationSetupPageView: View {
    let onAddMedications: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: "pills.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
                .accessibilityHidden(true)

            // Title and explanation
            VStack(spacing: 16) {
                Text("Your Medications")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Keep track of what you take each day")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Benefits
            VStack(alignment: .leading, spacing: 12) {
                BenefitRow(text: "Log your diuretic doses easily")
                BenefitRow(text: "Never miss a dose")
                BenefitRow(text: "Share a clear list with your care team")
            }
            .padding(.horizontal, 32)

            // Reassurance
            Text("You can add, edit, or remove medications anytime.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                Button(action: onAddMedications) {
                    Text("Add Medications")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button(action: onSkip) {
                    Text("Skip for Now")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .foregroundStyle(Color.accentColor)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

/// A row displaying a benefit with a checkmark.
private struct BenefitRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 32)
                .accessibilityHidden(true)

            Text(text)
                .font(.body)

            Spacer()
        }
    }
}

#Preview {
    MedicationSetupPageView(
        onAddMedications: {},
        onSkip: {}
    )
}
