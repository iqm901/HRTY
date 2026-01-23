import SwiftUI

struct WeightAlertView: View {
    let alert: AlertEvent
    let onDismiss: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    alertIcon
                    alertTitle
                    alertMessage
                    dismissButton
                }
            } else {
                HStack(alignment: .top, spacing: 12) {
                    alertIcon

                    VStack(alignment: .leading, spacing: 8) {
                        alertTitle
                        alertMessage
                        dismissButton
                    }
                }
            }
        }
        .padding()
        .background(Color.alertBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.alertBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabelText)
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
            .accessibilityHidden(true)
    }

    private var alertMessage: some View {
        Text(alert.message)
            .font(.subheadline)
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("\(alert.alertType.displayName): \(alert.message)")
    }

    private var dismissButton: some View {
        Button(action: onDismiss) {
            Text("Got it, thanks")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.alertAccent.opacity(0.15))
                .foregroundStyle(Color.alertAccent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .accessibilityLabel("Acknowledge alert")
        .accessibilityHint("Marks this \(alertCategoryLabel) alert as reviewed")
    }

    // MARK: - Accessibility

    /// Returns context-appropriate label based on alert type
    private var alertCategoryLabel: String {
        switch alert.alertType {
        case .severeSymptom:
            return "symptom"
        case .weightGain24h, .weightGain7d:
            return "weight"
        case .heartRateLow, .heartRateHigh:
            return "heart rate"
        case .dizzinessBPCheck, .lowBloodPressure, .lowMAP:
            return "blood pressure"
        case .lowOxygenSaturation:
            return "oxygen level"
        }
    }

    private var accessibilityLabelText: String {
        "\(alertCategoryLabel.capitalized) alert: \(alert.alertType.accessibilityDescription)"
    }
}

// MARK: - Custom Colors

private extension Color {
    /// Warm amber background that adapts to Dark Mode
    /// Light: soft peach/cream | Dark: warm brown
    static let alertBackground = Color(
        light: Color(red: 255/255, green: 248/255, blue: 235/255),
        dark: Color(red: 50/255, green: 40/255, blue: 30/255)
    )

    /// Subtle border that complements the background in both modes
    /// Light: golden amber | Dark: muted amber
    static let alertBorder = Color(
        light: Color(red: 245/255, green: 215/255, blue: 160/255),
        dark: Color(red: 100/255, green: 80/255, blue: 55/255)
    )

    /// Accent color for text and icons, warm and readable
    /// Light: warm brown | Dark: soft amber
    static let alertAccent = Color(
        light: Color(red: 180/255, green: 120/255, blue: 50/255),
        dark: Color(red: 230/255, green: 180/255, blue: 100/255)
    )

    /// Creates a color that adapts to light/dark mode
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

#Preview("Light Mode") {
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

#Preview("Dark Mode") {
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
    .preferredColorScheme(.dark)
}

#Preview("Symptom Alert") {
    VStack(spacing: 16) {
        WeightAlertView(
            alert: AlertEvent(
                alertType: .severeSymptom,
                message: "You've noted that shortness of breath at rest is bothering you more than usual today. This is helpful information to share with your care team when you get a chance."
            ),
            onDismiss: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
