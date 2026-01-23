import SwiftUI

// MARK: - Primary Button Style

/// Heart pink filled button for primary actions
struct HRTPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.hrtButton)
            .foregroundStyle(.white)
            .padding(.horizontal, HRTSpacing.buttonPaddingH)
            .padding(.vertical, HRTSpacing.buttonPaddingV)
            .frame(minHeight: HRTLayout.minTouchTarget)
            .background(isEnabled ? Color.hrtPinkFallback : Color.hrtTextTertiaryFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(HRTAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

/// Outlined/tinted button for secondary actions
struct HRTSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.hrtButton)
            .foregroundStyle(isEnabled ? Color.hrtPinkFallback : Color.hrtTextTertiaryFallback)
            .padding(.horizontal, HRTSpacing.buttonPaddingH)
            .padding(.vertical, HRTSpacing.buttonPaddingV)
            .frame(minHeight: HRTLayout.minTouchTarget)
            .background(Color.hrtPinkLightFallback.opacity(isEnabled ? 0.3 : 0.15))
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(HRTAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Tertiary Button Style

/// Text-only button for tertiary actions
struct HRTTertiaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.hrtBodyMedium)
            .foregroundStyle(isEnabled ? Color.hrtPinkFallback : Color.hrtTextTertiaryFallback)
            .padding(.horizontal, HRTSpacing.sm)
            .padding(.vertical, HRTSpacing.xs)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(HRTAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Chip Button Style

/// Small pill-shaped button for filters and tags
struct HRTChipButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.hrtChip)
            .foregroundStyle(isSelected ? .white : Color.hrtTextFallback)
            .padding(.horizontal, HRTSpacing.md)
            .padding(.vertical, HRTSpacing.sm)
            .background(isSelected ? Color.hrtPinkFallback : Color.hrtBackgroundSecondaryFallback)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(HRTAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Icon Button Style

/// Circular icon button
struct HRTIconButtonStyle: ButtonStyle {
    let size: CGFloat

    init(size: CGFloat = HRTLayout.minTouchTarget) {
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.5, weight: .medium))
            .foregroundStyle(Color.hrtPinkFallback)
            .frame(width: size, height: size)
            .background(Color.hrtPinkLightFallback.opacity(0.3))
            .clipShape(Circle())
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(HRTAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Destructive Button Style

/// Red button for destructive actions
struct HRTDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.hrtButton)
            .foregroundStyle(.white)
            .padding(.horizontal, HRTSpacing.buttonPaddingH)
            .padding(.vertical, HRTSpacing.buttonPaddingV)
            .frame(minHeight: HRTLayout.minTouchTarget)
            .background(Color.hrtAlertFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(HRTAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Full Width Button

/// Full-width primary button
struct HRTFullWidthButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: HRTSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(HRTPrimaryButtonStyle())
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == HRTPrimaryButtonStyle {
    static var hrtPrimary: HRTPrimaryButtonStyle { HRTPrimaryButtonStyle() }
}

extension ButtonStyle where Self == HRTSecondaryButtonStyle {
    static var hrtSecondary: HRTSecondaryButtonStyle { HRTSecondaryButtonStyle() }
}

extension ButtonStyle where Self == HRTTertiaryButtonStyle {
    static var hrtTertiary: HRTTertiaryButtonStyle { HRTTertiaryButtonStyle() }
}

extension ButtonStyle where Self == HRTDestructiveButtonStyle {
    static var hrtDestructive: HRTDestructiveButtonStyle { HRTDestructiveButtonStyle() }
}

// MARK: - Preview

#Preview("Button Styles") {
    VStack(spacing: 20) {
        Button("Primary Button") {}
            .buttonStyle(.hrtPrimary)

        Button("Secondary Button") {}
            .buttonStyle(.hrtSecondary)

        Button("Tertiary Button") {}
            .buttonStyle(.hrtTertiary)

        Button("Destructive") {}
            .buttonStyle(.hrtDestructive)

        HStack {
            Button("Unselected") {}
                .buttonStyle(HRTChipButtonStyle(isSelected: false))

            Button("Selected") {}
                .buttonStyle(HRTChipButtonStyle(isSelected: true))
        }

        Button {} label: {
            Image(systemName: "plus")
        }
        .buttonStyle(HRTIconButtonStyle())

        HRTFullWidthButton("Full Width", icon: "heart.fill") {}
    }
    .padding()
}
