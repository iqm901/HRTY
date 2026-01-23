import SwiftUI

/// Notification permission request page.
/// Explains the benefit of daily reminders and allows user to grant or skip.
struct NotificationPermissionPageView: View {
    let isRequesting: Bool
    let onAllow: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: "bell.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            // Title and explanation
            VStack(spacing: 16) {
                Text("Daily Reminders")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("A gentle nudge to check in each day")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Benefits
            VStack(alignment: .leading, spacing: 12) {
                BenefitRow(text: "Stay on track with daily logging")
                BenefitRow(text: "Build a healthy habit")
                BenefitRow(text: "Customize your reminder time")
            }
            .padding(.horizontal, 32)

            // Reassurance
            Text("You can adjust or turn off reminders anytime in Settings.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                Button(action: onAllow) {
                    if isRequesting {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Allow Notifications")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(isRequesting)

                Button(action: onSkip) {
                    Text("Skip for Now")
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
    NotificationPermissionPageView(
        isRequesting: false,
        onAllow: {},
        onSkip: {}
    )
}
