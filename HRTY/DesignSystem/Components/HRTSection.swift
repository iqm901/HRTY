import SwiftUI

// MARK: - HRT Section

/// A styled section container with optional header and footer
struct HRTSection<Content: View>: View {
    let title: String?
    let footer: String?
    let content: Content

    init(
        _ title: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            if let title {
                Text(title)
                    .font(.hrtSectionLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .padding(.horizontal, HRTSpacing.md)
            }

            VStack(spacing: 0) {
                content
            }
            .background(Color.hrtCardFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))

            if let footer {
                Text(footer)
                    .font(.hrtFootnote)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
                    .padding(.horizontal, HRTSpacing.md)
            }
        }
        .padding(.horizontal, HRTSpacing.md)
    }
}

// MARK: - HRT Card

/// A simple card container with rounded corners and optional shadow
struct HRTCard<Content: View>: View {
    let hasShadow: Bool
    let content: Content

    init(
        hasShadow: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.hasShadow = hasShadow
        self.content = content()
    }

    var body: some View {
        content
            .padding(HRTSpacing.md)
            .background(Color.hrtCardFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
            .if(hasShadow) { view in
                view.hrtCardShadow()
            }
    }
}

// MARK: - HRT Divider

/// A styled divider for separating content
struct HRTDivider: View {
    enum Direction {
        case horizontal
        case vertical
    }

    let direction: Direction
    let inset: Bool

    init(direction: Direction = .horizontal, inset: Bool = true) {
        self.direction = direction
        self.inset = inset
    }

    var body: some View {
        switch direction {
        case .horizontal:
            Rectangle()
                .fill(Color.hrtTextTertiaryFallback.opacity(0.3))
                .frame(height: HRTLayout.dividerThickness)
                .padding(.leading, inset ? HRTSpacing.md : 0)
        case .vertical:
            Rectangle()
                .fill(Color.hrtTextTertiaryFallback.opacity(0.3))
                .frame(width: HRTLayout.dividerThickness)
        }
    }
}

// MARK: - HRT Section Header

/// A standalone section header for use outside of HRTSection
struct HRTSectionHeader: View {
    let title: String
    let icon: String?
    let action: (() -> Void)?
    let actionIcon: String

    init(
        _ title: String,
        icon: String? = nil,
        actionIcon: String = "plus.circle.fill",
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.actionIcon = actionIcon
        self.action = action
    }

    var body: some View {
        HStack {
            if let icon {
                Label(title, systemImage: icon)
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)
            } else {
                Text(title)
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)
            }

            Spacer()

            if let action {
                Button(action: action) {
                    Image(systemName: actionIcon)
                        .font(.title2)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
                .accessibilityLabel("Add \(title.lowercased())")
            }
        }
        .padding(.horizontal, HRTSpacing.md)
    }
}

// MARK: - Conditional Modifier

extension View {
    /// Applies a modifier conditionally
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview

#Preview("Sections") {
    ScrollView {
        VStack(spacing: 24) {
            HRTSectionHeader("My Medications", icon: "pills") {
                print("Add tapped")
            }

            HRTSection("Section Title", footer: "This is a footer with additional information.") {
                Text("Section content goes here")
                    .padding()
            }

            HRTCard(hasShadow: true) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Title")
                        .font(.hrtHeadline)
                    Text("Card content with shadow")
                        .font(.hrtBody)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            HRTSection("With Dividers") {
                Text("Item 1").padding()
                HRTDivider()
                Text("Item 2").padding()
                HRTDivider()
                Text("Item 3").padding()
            }
        }
        .padding(.vertical)
    }
    .background(Color.hrtBackgroundFallback)
}
