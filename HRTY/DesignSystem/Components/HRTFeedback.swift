import SwiftUI

// MARK: - HRT Empty State

/// A view displayed when there's no content
struct HRTEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: HRTSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Color.hrtPinkLightFallback)

            VStack(spacing: HRTSpacing.sm) {
                Text(title)
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)

                Text(message)
                    .font(.hrtBody)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.hrtPrimary)
            }
        }
        .padding(HRTSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - HRT Success Toast

/// A toast notification for successful actions
struct HRTSuccessToast: View {
    let message: String

    var body: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.hrtGoodFallback)

            Text(message)
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextFallback)
        }
        .padding(.horizontal, HRTSpacing.md)
        .padding(.vertical, HRTSpacing.sm + 2)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .hrtFloatingShadow()
    }
}

// MARK: - HRT Error Toast

/// A toast notification for errors
struct HRTErrorToast: View {
    let message: String

    var body: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(Color.hrtAlertFallback)

            Text(message)
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextFallback)
        }
        .padding(.horizontal, HRTSpacing.md)
        .padding(.vertical, HRTSpacing.sm + 2)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .hrtFloatingShadow()
    }
}

// MARK: - HRT Alert Banner

/// A non-intrusive alert banner for important information
struct HRTAlertBanner: View {
    let type: AlertType
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    enum AlertType {
        case info
        case warning
        case urgent

        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .urgent: return "heart.fill"
            }
        }

        var color: Color {
            switch self {
            case .info: return Color.hrtPinkFallback
            case .warning: return Color.hrtCautionFallback
            case .urgent: return Color.hrtAlertFallback
            }
        }

        var backgroundColor: Color {
            switch self {
            case .info: return Color.hrtPinkLightFallback.opacity(0.5)
            case .warning: return Color.hrtCautionFallback.opacity(0.2)
            case .urgent: return Color.hrtAlertFallback.opacity(0.15)
            }
        }
    }

    init(
        type: AlertType,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack(alignment: .top, spacing: HRTSpacing.md) {
            Image(systemName: type.icon)
                .font(.system(size: 24))
                .foregroundStyle(type.color)

            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text(title)
                    .font(.hrtBodySemibold)
                    .foregroundStyle(Color.hrtTextFallback)

                Text(message)
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .font(.hrtBodyMedium)
                        .foregroundStyle(type.color)
                        .padding(.top, HRTSpacing.xs)
                }
            }

            Spacer()
        }
        .padding(HRTSpacing.md)
        .background(type.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: HRTRadius.medium)
                .strokeBorder(type.color.opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - HRT Loading View

/// A loading indicator with optional message
struct HRTLoadingView: View {
    let message: String?

    init(_ message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: HRTSpacing.md) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.hrtPinkFallback)
                .scaleEffect(1.2)

            if let message {
                Text(message)
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - HRT Encouragement Message

/// A warm, encouraging message for positive reinforcement
struct HRTEncouragementMessage: View {
    let message: String

    static let messages = [
        "Great job staying on top of your health!",
        "Every check-in helps you and your care team.",
        "You're doing wonderfully—keep it up!",
        "Taking care of yourself matters.",
        "Small steps lead to big progress."
    ]

    var body: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "heart.fill")
                .foregroundStyle(Color.hrtPinkFallback)

            Text(message)
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .italic()
        }
        .padding(HRTSpacing.md)
        .frame(maxWidth: .infinity)
        .background(Color.hrtPinkLightFallback.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
    }
}

// MARK: - Preview

#Preview("Feedback Components") {
    ScrollView {
        VStack(spacing: 32) {
            // Empty State
            VStack(alignment: .leading, spacing: 12) {
                Text("Empty State")
                    .font(.hrtSectionLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .textCase(.uppercase)
                    .padding(.horizontal)

                HRTEmptyState(
                    icon: "pills",
                    title: "No Medications Yet",
                    message: "Add your medications to keep track of what you're taking.",
                    actionTitle: "Add Medication"
                ) {}
            }

            // Toasts
            VStack(alignment: .leading, spacing: 12) {
                Text("Toasts")
                    .font(.hrtSectionLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .textCase(.uppercase)
                    .padding(.horizontal)

                HRTSuccessToast(message: "Medication added")
                HRTErrorToast(message: "Unable to save")
            }

            // Alert Banners
            VStack(alignment: .leading, spacing: 12) {
                Text("Alert Banners")
                    .font(.hrtSectionLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .textCase(.uppercase)

                HRTAlertBanner(
                    type: .info,
                    title: "Daily Check-In",
                    message: "Don't forget to log your weight today."
                )

                HRTAlertBanner(
                    type: .warning,
                    title: "Weight Change",
                    message: "Your weight has increased 2 lbs since yesterday.",
                    actionTitle: "View Details"
                ) {}

                HRTAlertBanner(
                    type: .urgent,
                    title: "Contact Your Care Team",
                    message: "You reported severe symptoms. Please reach out to your doctor.",
                    actionTitle: "I've Contacted Them"
                ) {}
            }
            .padding(.horizontal)

            // Loading
            VStack(alignment: .leading, spacing: 12) {
                Text("Loading")
                    .font(.hrtSectionLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .textCase(.uppercase)
                    .padding(.horizontal)

                HRTLoadingView("Loading your data...")
                    .frame(height: 100)
            }

            // Encouragement
            VStack(alignment: .leading, spacing: 12) {
                Text("Encouragement")
                    .font(.hrtSectionLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .textCase(.uppercase)

                HRTEncouragementMessage(message: "Great job staying on top of your health!")
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    .background(Color.hrtBackgroundFallback)
}
