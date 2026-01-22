import SwiftUI

/// Welcome page explaining the app's purpose.
/// First screen users see when launching the app for the first time.
struct WelcomePageView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App icon
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundStyle(.pink)
                .accessibilityHidden(true)

            // Welcome text
            VStack(spacing: 16) {
                Text("Welcome to HRTY")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your personal heart health companion")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // Purpose explanation
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(
                    icon: "scalemass",
                    text: "Track your daily weight"
                )
                FeatureRow(
                    icon: "list.bullet.clipboard",
                    text: "Log how you're feeling"
                )
                FeatureRow(
                    icon: "pills",
                    text: "Record your medications"
                )
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    text: "See your trends over time"
                )
            }
            .padding(.horizontal, 32)

            // Disclaimer
            Text("This app helps you keep track of your health information to share with your care team. It does not provide medical advice.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            // Continue button
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

/// A row displaying a feature with an icon.
private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.pink)
                .frame(width: 32)
                .accessibilityHidden(true)

            Text(text)
                .font(.body)

            Spacer()
        }
    }
}

#Preview {
    WelcomePageView(onContinue: {})
}
