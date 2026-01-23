import SwiftUI

/// HealthKit permission request page.
/// Explains why HealthKit access is helpful and allows user to grant or skip.
struct HealthKitPermissionPageView: View {
    let isAvailable: Bool
    let isRequesting: Bool
    let onAllow: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.pink)
                .accessibilityHidden(true)

            // Title and explanation
            VStack(spacing: 16) {
                Text("Connect to Health")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Sync your weight and heart rate from Apple Health")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Benefits
            VStack(alignment: .leading, spacing: 12) {
                BenefitRow(text: "Automatically import weight readings")
                BenefitRow(text: "Track your resting heart rate")
                BenefitRow(text: "Less manual data entry")
            }
            .padding(.horizontal, 32)

            // Privacy note
            Text("Your health data stays on your device. HRTY only reads data — it never writes or shares your information.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                if isAvailable {
                    Button(action: onAllow) {
                        if isRequesting {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Allow Health Access")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(isRequesting)
                } else {
                    Text("Health data is not available on this device")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                }

                Button(action: onSkip) {
                    Text(isAvailable ? "Skip for Now" : "Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .foregroundStyle(Color.accentColor)
                .disabled(isRequesting)
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
    HealthKitPermissionPageView(
        isAvailable: true,
        isRequesting: false,
        onAllow: {},
        onSkip: {}
    )
}
