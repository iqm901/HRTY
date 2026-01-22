import SwiftUI

// MARK: - HRTY Color System
// A warm, caring color palette for heart failure self-management

extension Color {

    // MARK: - Brand Colors

    /// Primary heart pink - the app's signature color
    static let hrtPink = Color("HRTPink")

    /// Light pink for backgrounds and subtle highlights
    static let hrtPinkLight = Color("HRTPinkLight")

    /// Dark pink for pressed states and emphasis
    static let hrtPinkDark = Color("HRTPinkDark")

    /// Warm rose for secondary accents
    static let hrtRose = Color("HRTRose")

    /// Soft coral for warmth
    static let hrtCoral = Color("HRTCoral")

    // MARK: - Semantic Colors

    /// Good health status - soft sage green
    static let hrtGood = Color("HRTGood")

    /// Caution status - warm amber
    static let hrtCaution = Color("HRTCaution")

    /// Alert status - soft coral red (not alarming)
    static let hrtAlert = Color("HRTAlert")

    // MARK: - Severity Scale (1-5)

    static let hrtSeverity1 = Color("HRTSeverity1") // Soft mint - None
    static let hrtSeverity2 = Color("HRTSeverity2") // Light sage - Mild
    static let hrtSeverity3 = Color("HRTSeverity3") // Warm yellow - Moderate
    static let hrtSeverity4 = Color("HRTSeverity4") // Soft orange - Significant
    static let hrtSeverity5 = Color("HRTSeverity5") // Soft red - Severe

    /// Returns the appropriate severity color for a given level (1-5)
    static func hrtSeverity(_ level: Int) -> Color {
        switch level {
        case 1: return .hrtSeverity1
        case 2: return .hrtSeverity2
        case 3: return .hrtSeverity3
        case 4: return .hrtSeverity4
        case 5: return .hrtSeverity5
        default: return .hrtSeverity1
        }
    }

    // MARK: - Background Colors

    /// Primary background - warm white/near-black
    static let hrtBackground = Color("HRTBackground")

    /// Secondary background - for sections and groups
    static let hrtBackgroundSecondary = Color("HRTBackgroundSecondary")

    /// Card background - elevated content
    static let hrtCard = Color("HRTCard")

    // MARK: - Text Colors

    /// Primary text - warm charcoal
    static let hrtText = Color("HRTText")

    /// Secondary text - warm gray
    static let hrtTextSecondary = Color("HRTTextSecondary")

    /// Tertiary text - light warm gray
    static let hrtTextTertiary = Color("HRTTextTertiary")

    // MARK: - Chart Colors

    /// Weight chart line color
    static let hrtChartWeight = Color.hrtPink

    /// Heart rate chart line color
    static let hrtChartHeartRate = Color.hrtRose

    /// Chart grid lines
    static let hrtChartGrid = Color.hrtTextTertiary.opacity(0.3)

    /// Chart fill gradient
    static var hrtChartFill: LinearGradient {
        LinearGradient(
            colors: [Color.hrtPink.opacity(0.3), Color.hrtPink.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Fallback Colors (when assets not yet created)
// These provide immediate visual feedback during development

extension Color {

    // Brand colors - fallbacks
    static let hrtPinkFallback = Color(red: 0.95, green: 0.40, blue: 0.50)
    static let hrtPinkLightFallback = Color(red: 0.98, green: 0.85, blue: 0.88)
    static let hrtPinkDarkFallback = Color(red: 0.85, green: 0.30, blue: 0.40)
    static let hrtRoseFallback = Color(red: 0.96, green: 0.56, blue: 0.56)
    static let hrtCoralFallback = Color(red: 0.98, green: 0.70, blue: 0.65)

    // Semantic colors - fallbacks
    static let hrtGoodFallback = Color(red: 0.55, green: 0.78, blue: 0.60)
    static let hrtCautionFallback = Color(red: 0.95, green: 0.80, blue: 0.45)
    static let hrtAlertFallback = Color(red: 0.92, green: 0.55, blue: 0.50)

    // Severity scale - fallbacks
    static let hrtSeverity1Fallback = Color(red: 0.70, green: 0.85, blue: 0.72)
    static let hrtSeverity2Fallback = Color(red: 0.80, green: 0.88, blue: 0.60)
    static let hrtSeverity3Fallback = Color(red: 0.95, green: 0.85, blue: 0.55)
    static let hrtSeverity4Fallback = Color(red: 0.95, green: 0.70, blue: 0.50)
    static let hrtSeverity5Fallback = Color(red: 0.92, green: 0.50, blue: 0.50)

    // Background colors - fallbacks (soft warm pink)
    static let hrtBackgroundFallback = Color(red: 1.0, green: 0.96, blue: 0.97)
    static let hrtBackgroundSecondaryFallback = Color(red: 0.99, green: 0.94, blue: 0.95)
    static let hrtCardFallback = Color.white

    // Text colors - fallbacks
    static let hrtTextFallback = Color(red: 0.20, green: 0.18, blue: 0.22)
    static let hrtTextSecondaryFallback = Color(red: 0.45, green: 0.42, blue: 0.48)
    static let hrtTextTertiaryFallback = Color(red: 0.65, green: 0.62, blue: 0.68)
}

// MARK: - Adaptive Colors (Light/Dark)
// Use these when you need programmatic light/dark adaptation

extension Color {

    /// Creates an adaptive color that changes based on color scheme
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

// MARK: - Symptom Chart Colors
// Distinct colors for each symptom type in trend charts

extension Color {
    static let hrtSymptomDyspneaRest = Color.hrtPink
    static let hrtSymptomDyspneaExertion = Color(red: 0.40, green: 0.75, blue: 0.85) // Soft cyan
    static let hrtSymptomOrthopnea = Color(red: 0.55, green: 0.50, blue: 0.80)       // Soft indigo
    static let hrtSymptomPND = Color(red: 0.70, green: 0.55, blue: 0.80)             // Soft purple
    static let hrtSymptomChestPain = Color.hrtRose
    static let hrtSymptomDizziness = Color.hrtCoral
    static let hrtSymptomSyncope = Color(red: 0.90, green: 0.65, blue: 0.75)         // Soft pink
    static let hrtSymptomReducedUrine = Color(red: 0.45, green: 0.75, blue: 0.70)    // Soft teal
}
