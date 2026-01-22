import SwiftUI

// MARK: - HRTY Typography System
// SF Rounded throughout for a warm, friendly feel

extension Font {

    // MARK: - Display Fonts
    // For welcome screens, big moments, celebrations

    /// Large display title - 34pt bold rounded
    static let hrtLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)

    /// Display title - 28pt bold rounded
    static let hrtTitle = Font.system(size: 28, weight: .bold, design: .rounded)

    /// Secondary title - 22pt semibold rounded
    static let hrtTitle2 = Font.system(size: 22, weight: .semibold, design: .rounded)

    /// Tertiary title - 20pt semibold rounded
    static let hrtTitle3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    // MARK: - Header Fonts
    // For section headers and prominent labels

    /// Headline - 17pt semibold rounded
    static let hrtHeadline = Font.system(size: 17, weight: .semibold, design: .rounded)

    /// Subheadline - 15pt medium rounded
    static let hrtSubheadline = Font.system(size: 15, weight: .medium, design: .rounded)

    // MARK: - Body Fonts
    // For main content text

    /// Body text - 17pt regular rounded
    static let hrtBody = Font.system(size: 17, weight: .regular, design: .rounded)

    /// Body text medium - 17pt medium rounded
    static let hrtBodyMedium = Font.system(size: 17, weight: .medium, design: .rounded)

    /// Body text semibold - 17pt semibold rounded
    static let hrtBodySemibold = Font.system(size: 17, weight: .semibold, design: .rounded)

    /// Callout - 16pt regular rounded
    static let hrtCallout = Font.system(size: 16, weight: .regular, design: .rounded)

    // MARK: - Caption Fonts
    // For metadata, labels, and small text

    /// Caption - 13pt medium rounded
    static let hrtCaption = Font.system(size: 13, weight: .medium, design: .rounded)

    /// Caption 2 - 12pt regular rounded
    static let hrtCaption2 = Font.system(size: 12, weight: .regular, design: .rounded)

    /// Footnote - 13pt regular rounded
    static let hrtFootnote = Font.system(size: 13, weight: .regular, design: .rounded)

    /// Small text - 11pt regular rounded
    static let hrtSmall = Font.system(size: 11, weight: .regular, design: .rounded)

    // MARK: - Metric Fonts
    // For displaying numbers and data values

    /// Extra large metric - 56pt bold rounded (hero numbers)
    static let hrtMetricXL = Font.system(size: 56, weight: .bold, design: .rounded)

    /// Large metric - 48pt bold rounded (main data display)
    static let hrtMetricLarge = Font.system(size: 48, weight: .bold, design: .rounded)

    /// Medium metric - 36pt bold rounded (secondary data)
    static let hrtMetricMedium = Font.system(size: 36, weight: .bold, design: .rounded)

    /// Small metric - 28pt semibold rounded (smaller data points)
    static let hrtMetricSmall = Font.system(size: 28, weight: .semibold, design: .rounded)

    /// Tiny metric - 20pt medium rounded (inline metrics)
    static let hrtMetricTiny = Font.system(size: 20, weight: .medium, design: .rounded)

    // MARK: - Label Fonts
    // For form labels and input descriptions

    /// Section label - 13pt medium rounded, uppercase tracking
    static let hrtSectionLabel = Font.system(size: 13, weight: .medium, design: .rounded)

    /// Input label - 15pt medium rounded
    static let hrtInputLabel = Font.system(size: 15, weight: .medium, design: .rounded)

    // MARK: - Button Fonts

    /// Primary button text - 17pt semibold rounded
    static let hrtButton = Font.system(size: 17, weight: .semibold, design: .rounded)

    /// Small button text - 15pt medium rounded
    static let hrtButtonSmall = Font.system(size: 15, weight: .medium, design: .rounded)

    /// Chip/tag text - 13pt medium rounded
    static let hrtChip = Font.system(size: 13, weight: .medium, design: .rounded)
}

// MARK: - Text Styles

extension View {

    /// Apply section label styling (uppercase, tracking)
    func hrtSectionLabelStyle() -> some View {
        self
            .font(.hrtSectionLabel)
            .foregroundStyle(Color.hrtTextSecondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }

    /// Apply primary text styling
    func hrtPrimaryTextStyle() -> some View {
        self
            .font(.hrtBody)
            .foregroundStyle(Color.hrtText)
    }

    /// Apply secondary text styling
    func hrtSecondaryTextStyle() -> some View {
        self
            .font(.hrtCallout)
            .foregroundStyle(Color.hrtTextSecondary)
    }

    /// Apply caption styling
    func hrtCaptionStyle() -> some View {
        self
            .font(.hrtCaption)
            .foregroundStyle(Color.hrtTextSecondary)
    }

    /// Apply headline styling
    func hrtHeadlineStyle() -> some View {
        self
            .font(.hrtHeadline)
            .foregroundStyle(Color.hrtText)
    }
}

// MARK: - Dynamic Type Support

extension Font {

    /// Returns a scaled font that respects Dynamic Type settings
    static func hrtScaled(_ style: Font.TextStyle, design: Font.Design = .rounded) -> Font {
        Font.system(style, design: design)
    }
}

// MARK: - Accessibility

extension View {

    /// Applies minimum touch target sizing for accessibility
    func hrtAccessibleTapTarget() -> some View {
        self.frame(minWidth: 44, minHeight: 44)
    }
}
