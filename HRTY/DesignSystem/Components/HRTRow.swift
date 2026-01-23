import SwiftUI

// MARK: - HRT Row

/// A standardized row component for lists
struct HRTRow<Trailing: View>: View {
    let icon: String?
    let iconColor: Color
    let title: String
    let subtitle: String?
    let trailing: Trailing

    init(
        icon: String? = nil,
        iconColor: Color = .hrtPinkFallback,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: HRTSpacing.md) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: HRTLayout.iconSize, weight: .medium))
                    .foregroundStyle(iconColor)
                    .frame(width: HRTLayout.iconSizeLarge)
            }

            VStack(alignment: .leading, spacing: HRTSpacing.textStack) {
                Text(title)
                    .font(.hrtBody)
                    .foregroundStyle(Color.hrtTextFallback)

                if let subtitle {
                    Text(subtitle)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }
            }

            Spacer()

            trailing
        }
        .padding(.horizontal, HRTSpacing.md)
        .padding(.vertical, HRTSpacing.md)
        .contentShape(Rectangle())
    }
}

// MARK: - HRT Navigation Row

/// A row with a chevron for navigation
struct HRTNavigationRow: View {
    let icon: String?
    let iconColor: Color
    let title: String
    let subtitle: String?
    let value: String?

    init(
        icon: String? = nil,
        iconColor: Color = .hrtPinkFallback,
        title: String,
        subtitle: String? = nil,
        value: String? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.value = value
    }

    var body: some View {
        HRTRow(
            icon: icon,
            iconColor: iconColor,
            title: title,
            subtitle: subtitle
        ) {
            HStack(spacing: HRTSpacing.sm) {
                if let value {
                    Text(value)
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
            }
        }
    }
}

// MARK: - HRT Toggle Row

/// A row with a toggle switch
struct HRTToggleRow: View {
    let icon: String?
    let iconColor: Color
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool

    init(
        icon: String? = nil,
        iconColor: Color = .hrtPinkFallback,
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    var body: some View {
        HRTRow(
            icon: icon,
            iconColor: iconColor,
            title: title,
            subtitle: subtitle
        ) {
            Toggle("", isOn: $isOn)
                .tint(Color.hrtPinkFallback)
                .labelsHidden()
        }
    }
}

// MARK: - HRT Value Row

/// A row displaying a value with optional unit
struct HRTValueRow: View {
    let icon: String?
    let iconColor: Color
    let title: String
    let value: String
    let unit: String?

    init(
        icon: String? = nil,
        iconColor: Color = .hrtPinkFallback,
        title: String,
        value: String,
        unit: String? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.value = value
        self.unit = unit
    }

    var body: some View {
        HRTRow(
            icon: icon,
            iconColor: iconColor,
            title: title
        ) {
            HStack(alignment: .firstTextBaseline, spacing: HRTSpacing.xs) {
                Text(value)
                    .font(.hrtMetricTiny)
                    .foregroundStyle(Color.hrtTextFallback)

                if let unit {
                    Text(unit)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }
            }
        }
    }
}

// MARK: - HRT Medication Row

/// A specialized row for displaying medications
struct HRTMedicationRow: View {
    let name: String
    let dosage: String
    let schedule: String?
    let isDiuretic: Bool

    var body: some View {
        HStack(spacing: HRTSpacing.md) {
            // Icon
            Image(systemName: isDiuretic ? "drop.fill" : "pills.fill")
                .font(.system(size: HRTLayout.iconSize, weight: .medium))
                .foregroundStyle(isDiuretic ? Color.hrtCoralFallback : Color.hrtPinkFallback)
                .frame(width: HRTLayout.iconSizeLarge)

            // Content
            VStack(alignment: .leading, spacing: HRTSpacing.textStack) {
                HStack(spacing: HRTSpacing.sm) {
                    Text(name)
                        .font(.hrtBodyMedium)
                        .foregroundStyle(Color.hrtTextFallback)

                    if isDiuretic {
                        Text("Diuretic")
                            .font(.hrtSmall)
                            .foregroundStyle(Color.hrtCoralFallback)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.hrtCoralFallback.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: HRTSpacing.sm) {
                    Text(dosage)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    if let schedule, !schedule.isEmpty {
                        Text("•")
                            .foregroundStyle(Color.hrtTextTertiaryFallback)
                        Text(schedule)
                            .font(.hrtCaption)
                            .foregroundStyle(Color.hrtTextTertiaryFallback)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.hrtTextTertiaryFallback)
        }
        .padding(.horizontal, HRTSpacing.md)
        .padding(.vertical, HRTSpacing.md)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview("Rows") {
    ScrollView {
        VStack(spacing: 0) {
            HRTSection("Basic Rows") {
                HRTRow(icon: "heart.fill", title: "Basic Row")
                HRTDivider()
                HRTRow(icon: "bell.fill", iconColor: .orange, title: "With Subtitle", subtitle: "Additional information here")
            }

            HRTSection("Navigation Rows") {
                HRTNavigationRow(icon: "gearshape.fill", title: "Settings")
                HRTDivider()
                HRTNavigationRow(icon: "clock.fill", title: "Reminder Time", value: "9:00 AM")
            }
            .padding(.top)

            HRTSection("Toggle Rows") {
                HRTToggleRow(icon: "bell.fill", title: "Notifications", isOn: .constant(true))
                HRTDivider()
                HRTToggleRow(icon: "moon.fill", title: "Dark Mode", subtitle: "Use system setting", isOn: .constant(false))
            }
            .padding(.top)

            HRTSection("Value Rows") {
                HRTValueRow(icon: "scalemass.fill", title: "Weight", value: "165.5", unit: "lbs")
                HRTDivider()
                HRTValueRow(icon: "heart.fill", iconColor: .red, title: "Heart Rate", value: "72", unit: "bpm")
            }
            .padding(.top)

            HRTSection("Medication Rows") {
                HRTMedicationRow(name: "Lisinopril", dosage: "10 mg", schedule: "Once daily", isDiuretic: false)
                HRTDivider()
                HRTMedicationRow(name: "Furosemide", dosage: "40 mg", schedule: "Twice daily", isDiuretic: true)
            }
            .padding(.top)
        }
        .padding(.vertical)
    }
    .background(Color.hrtBackgroundFallback)
}
