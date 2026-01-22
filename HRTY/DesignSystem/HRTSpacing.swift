import SwiftUI

// MARK: - HRTY Spacing System
// Consistent spacing throughout the app

/// Spacing constants for consistent layout
enum HRTSpacing {

    // MARK: - Base Spacing Scale

    /// Extra small - 4pt (tight spacing)
    static let xs: CGFloat = 4

    /// Small - 8pt (compact elements)
    static let sm: CGFloat = 8

    /// Medium - 16pt (standard spacing)
    static let md: CGFloat = 16

    /// Large - 24pt (section spacing)
    static let lg: CGFloat = 24

    /// Extra large - 32pt (major sections)
    static let xl: CGFloat = 32

    /// Extra extra large - 48pt (page-level spacing)
    static let xxl: CGFloat = 48

    // MARK: - Semantic Spacing

    /// Spacing between items in a list
    static let listItem: CGFloat = sm

    /// Spacing between form fields
    static let formField: CGFloat = md

    /// Spacing between sections
    static let section: CGFloat = lg

    /// Page margins (horizontal padding)
    static let pageMargin: CGFloat = md

    /// Card internal padding
    static let cardPadding: CGFloat = md

    /// Button internal padding (vertical)
    static let buttonPaddingV: CGFloat = 14

    /// Button internal padding (horizontal)
    static let buttonPaddingH: CGFloat = lg

    /// Icon spacing from text
    static let iconText: CGFloat = sm

    /// Spacing between stacked text elements
    static let textStack: CGFloat = xs
}

// MARK: - Corner Radius

/// Corner radius constants
enum HRTRadius {

    /// Small - 8pt (buttons, chips, small elements)
    static let small: CGFloat = 8

    /// Medium - 12pt (cards, inputs, standard containers)
    static let medium: CGFloat = 12

    /// Large - 16pt (sections, modals, large containers)
    static let large: CGFloat = 16

    /// Extra large - 20pt (prominent cards)
    static let xl: CGFloat = 20

    /// Full - capsule/pill shape
    static let full: CGFloat = 9999
}

// MARK: - Shadow Styles

/// Shadow configurations for elevation
enum HRTShadow {

    /// Subtle shadow for cards
    static let card = Shadow(
        color: Color.black.opacity(0.06),
        radius: 8,
        x: 0,
        y: 2
    )

    /// Light shadow for floating elements
    static let floating = Shadow(
        color: Color.black.opacity(0.10),
        radius: 16,
        x: 0,
        y: 4
    )

    /// No shadow
    static let none = Shadow(
        color: Color.clear,
        radius: 0,
        x: 0,
        y: 0
    )

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - View Extensions for Spacing

extension View {

    /// Apply standard page margins
    func hrtPagePadding() -> some View {
        self.padding(.horizontal, HRTSpacing.pageMargin)
    }

    /// Apply standard card padding
    func hrtCardPadding() -> some View {
        self.padding(HRTSpacing.cardPadding)
    }

    /// Apply section spacing below
    func hrtSectionSpacing() -> some View {
        self.padding(.bottom, HRTSpacing.section)
    }

    /// Apply card shadow
    func hrtCardShadow() -> some View {
        self.shadow(
            color: HRTShadow.card.color,
            radius: HRTShadow.card.radius,
            x: HRTShadow.card.x,
            y: HRTShadow.card.y
        )
    }

    /// Apply floating shadow
    func hrtFloatingShadow() -> some View {
        self.shadow(
            color: HRTShadow.floating.color,
            radius: HRTShadow.floating.radius,
            x: HRTShadow.floating.x,
            y: HRTShadow.floating.y
        )
    }
}

// MARK: - Layout Constants

enum HRTLayout {

    /// Minimum touch target size (44pt for accessibility)
    static let minTouchTarget: CGFloat = 44

    /// Standard icon size in lists
    static let iconSize: CGFloat = 24

    /// Large icon size
    static let iconSizeLarge: CGFloat = 32

    /// Small icon size
    static let iconSizeSmall: CGFloat = 20

    /// Avatar/profile image size
    static let avatarSize: CGFloat = 40

    /// Chart height (standard)
    static let chartHeight: CGFloat = 220

    /// Chart height (compact)
    static let chartHeightCompact: CGFloat = 160

    /// Severity button size
    static let severityButtonSize: CGFloat = 48

    /// Divider thickness
    static let dividerThickness: CGFloat = 0.5

    /// Maximum content width (for iPad)
    static let maxContentWidth: CGFloat = 600
}

// MARK: - Animation Constants

enum HRTAnimation {

    /// Quick animation - 0.15s
    static let quick: Animation = .easeInOut(duration: 0.15)

    /// Standard animation - 0.25s
    static let standard: Animation = .easeInOut(duration: 0.25)

    /// Smooth animation - 0.35s
    static let smooth: Animation = .easeInOut(duration: 0.35)

    /// Spring animation for interactive elements
    static let spring: Animation = .spring(response: 0.35, dampingFraction: 0.7)

    /// Gentle spring for subtle movements
    static let gentleSpring: Animation = .spring(response: 0.5, dampingFraction: 0.8)
}
