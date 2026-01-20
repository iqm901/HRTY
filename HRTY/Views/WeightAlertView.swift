import SwiftUI

struct WeightAlertView: View {
    let alert: AlertEvent
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            alertIcon

            VStack(alignment: .leading, spacing: 8) {
                alertTitle
                alertMessage
                dismissButton
            }
        }
        .padding()
        .background(Color.alertBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.alertBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint("Double tap dismiss button to acknowledge this alert")
        .accessibilityAddTraits(.isStaticText)
    }

    // MARK: - Subviews

    private var alertIcon: some View {
        Image(systemName: "heart.circle.fill")
            .font(.title2)
            .foregroundStyle(Color.alertAccent)
            .accessibilityHidden(true)
    }

    private var alertTitle: some View {
        Text(alert.alertType.displayName)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(Color.alertAccent)
    }

    private var alertMessage: some View {
        Text(alert.message)
            .font(.subheadline)
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var dismissButton: some View {
        Button(action: onDismiss) {
            Text("Got it")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.alertAccent.opacity(0.15))
                .foregroundStyle(Color.alertAccent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .accessibilityLabel("Dismiss alert")
        .accessibilityHint("Acknowledges this weight alert")
    }

    // MARK: - Accessibility

    private var accessibilityLabelText: String {
        "Weight alert: \(alert.alertType.accessibilityDescription)"
    }
}

// MARK: - Custom Colors

private extension Color {
    static let alertBackground = Color(red: 255/255, green: 248/255, blue: 235/255)
    static let alertBorder = Color(red: 245/255, green: 215/255, blue: 160/255)
    static let alertAccent = Color(red: 180/255, green: 120/255, blue: 50/255)
}

#Preview {
    VStack(spacing: 16) {
        WeightAlertView(
            alert: AlertEvent(
                alertType: .weightGain24h,
                message: "Your weight has increased by 2.5 lbs since yesterday. This is good information to share with your care team. Consider reaching out to discuss."
            ),
            onDismiss: {}
        )

        WeightAlertView(
            alert: AlertEvent(
                alertType: .weightGain7d,
                message: "Over the past week, your weight has increased by 5.5 lbs. Your clinician may want to know about this trend. It might be a good time to check in with them."
            ),
            onDismiss: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
