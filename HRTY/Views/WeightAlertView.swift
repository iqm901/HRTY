import SwiftUI

struct WeightAlertView: View {
    let alert: AlertEvent
    let onDismiss: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var isLearnMoreExpanded = false

    /// The zone classification for this alert
    private var zone: EducationContent.Zone {
        EducationContent.Zones.zone(for: alert.alertType)
    }

    /// Zone-specific accent color
    private var zoneAccentColor: Color {
        switch zone {
        case .green:
            return Color.zoneGreen
        case .yellow:
            return Color.zoneYellow
        case .red:
            return Color.zoneRed
        }
    }

    /// Zone-specific background color
    private var zoneBackgroundColor: Color {
        switch zone {
        case .green:
            return Color.zoneGreenBackground
        case .yellow:
            return Color.zoneYellowBackground
        case .red:
            return Color.zoneRedBackground
        }
    }

    /// Zone-specific border color
    private var zoneBorderColor: Color {
        switch zone {
        case .green:
            return Color.zoneGreenBorder
        case .yellow:
            return Color.zoneYellowBorder
        case .red:
            return Color.zoneRedBorder
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Zone badge at top
            zoneBadge
                .padding(.horizontal)
                .padding(.top, 12)

            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 12) {
                        alertIcon
                        alertTitle
                        alertMessage
                        alertActions
                    }
                } else {
                    HStack(alignment: .top, spacing: 12) {
                        alertIcon

                        VStack(alignment: .leading, spacing: 8) {
                            alertTitle
                            alertMessage
                            alertActions
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .padding(.top, 8)

            // Expandable "Learn more" section
            if isLearnMoreExpanded {
                learnMoreContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(zoneBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(zoneBorderColor, lineWidth: 1.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabelText)
        .animation(.easeInOut(duration: 0.2), value: isLearnMoreExpanded)
    }

    // MARK: - Subviews

    private var zoneBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(zoneAccentColor)
                .frame(width: 8, height: 8)

            Text(zone.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(zoneAccentColor)

            Text("·")
                .foregroundStyle(zoneAccentColor.opacity(0.6))

            Text(zone.actionText)
                .font(.caption)
                .foregroundStyle(zoneAccentColor.opacity(0.8))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(zone.title): \(zone.actionText)")
    }

    private var alertIcon: some View {
        Image(systemName: zone == .red ? "exclamationmark.triangle.fill" : "heart.circle.fill")
            .font(.title2)
            .foregroundStyle(zoneAccentColor)
            .accessibilityHidden(true)
    }

    private var alertTitle: some View {
        Text(alert.alertType.displayName)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(zoneAccentColor)
            .accessibilityHidden(true)
    }

    private var alertMessage: some View {
        Text(alert.message)
            .font(.subheadline)
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("\(alert.alertType.displayName): \(alert.message)")
    }

    private var alertActions: some View {
        HStack(spacing: 12) {
            Button(action: onDismiss) {
                Text("Got it, thanks")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(zoneAccentColor.opacity(0.15))
                    .foregroundStyle(zoneAccentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel("Acknowledge alert")
            .accessibilityHint("Marks this \(alertCategoryLabel) alert as reviewed")

            Button {
                withAnimation {
                    isLearnMoreExpanded.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(isLearnMoreExpanded ? "Less" : "Why this matters")
                        .font(.subheadline)
                    Image(systemName: isLearnMoreExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .foregroundStyle(zoneAccentColor.opacity(0.8))
            }
            .accessibilityLabel(isLearnMoreExpanded ? "Hide additional information" : "Learn why this matters")
        }
    }

    private var learnMoreContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(zoneBorderColor)
                .frame(height: 1)

            // Zone explanation
            VStack(alignment: .leading, spacing: 4) {
                Text("About \(zone.title)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(zoneAccentColor)

                Text(zone.description)
                    .font(.subheadline)
                    .foregroundStyle(.primary.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 4)

            Rectangle()
                .fill(zoneBorderColor.opacity(0.5))
                .frame(height: 1)

            Text(EducationContent.Alerts.learnMore(for: alert.alertType))
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            if let action = EducationContent.Alerts.actionSuggestion(for: alert.alertType) {
                Text(action)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(zoneAccentColor)
                    .padding(.top, 4)
            }

            Text("Source: \(EducationContent.Alerts.source(for: alert.alertType)) · \(EducationContent.Zones.source)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding(.horizontal)
        .padding(.bottom)
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

    // MARK: - Zone Colors (HSAG Traffic Light System)

    // Green Zone - Symptoms under control
    static let zoneGreen = Color(
        light: Color(red: 34/255, green: 139/255, blue: 34/255),
        dark: Color(red: 76/255, green: 187/255, blue: 76/255)
    )

    static let zoneGreenBackground = Color(
        light: Color(red: 240/255, green: 255/255, blue: 240/255),
        dark: Color(red: 30/255, green: 50/255, blue: 30/255)
    )

    static let zoneGreenBorder = Color(
        light: Color(red: 144/255, green: 238/255, blue: 144/255),
        dark: Color(red: 60/255, green: 100/255, blue: 60/255)
    )

    // Yellow Zone - Symptoms changing, call doctor
    static let zoneYellow = Color(
        light: Color(red: 180/255, green: 120/255, blue: 50/255),
        dark: Color(red: 230/255, green: 180/255, blue: 100/255)
    )

    static let zoneYellowBackground = Color(
        light: Color(red: 255/255, green: 248/255, blue: 235/255),
        dark: Color(red: 50/255, green: 40/255, blue: 30/255)
    )

    static let zoneYellowBorder = Color(
        light: Color(red: 245/255, green: 215/255, blue: 160/255),
        dark: Color(red: 100/255, green: 80/255, blue: 55/255)
    )

    // Red Zone - Emergency, call 911
    static let zoneRed = Color(
        light: Color(red: 200/255, green: 50/255, blue: 50/255),
        dark: Color(red: 255/255, green: 100/255, blue: 100/255)
    )

    static let zoneRedBackground = Color(
        light: Color(red: 255/255, green: 240/255, blue: 240/255),
        dark: Color(red: 60/255, green: 30/255, blue: 30/255)
    )

    static let zoneRedBorder = Color(
        light: Color(red: 255/255, green: 180/255, blue: 180/255),
        dark: Color(red: 120/255, green: 60/255, blue: 60/255)
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
