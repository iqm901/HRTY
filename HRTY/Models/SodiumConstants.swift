import Foundation
import SwiftUI

/// Constants for sodium tracking feature
enum SodiumConstants {

    // MARK: - Daily Limits

    /// AHA recommended daily sodium limit for heart failure patients (mg)
    static let dailyLimitMg: Int = 2000

    /// Percentage threshold for caution status (yellow)
    static let cautionThresholdPercent: Double = 0.75

    /// Percentage threshold for alert status (red)
    static let alertThresholdPercent: Double = 0.90

    // MARK: - Quick Add Values

    /// Preset sodium amounts for quick-add buttons (mg)
    static let quickAddValues: [Int] = [100, 250, 500, 1000]

    // MARK: - Display Formatting

    /// Number formatter for sodium values with thousands separator
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()

    /// Format sodium value for display (e.g., "1,240 mg")
    static func formatSodium(_ mg: Int) -> String {
        let formatted = numberFormatter.string(from: NSNumber(value: mg)) ?? "\(mg)"
        return "\(formatted) mg"
    }

    /// Format sodium with limit (e.g., "1,240 / 2,000 mg")
    static func formatSodiumWithLimit(_ current: Int, limit: Int = dailyLimitMg) -> String {
        let currentFormatted = numberFormatter.string(from: NSNumber(value: current)) ?? "\(current)"
        let limitFormatted = numberFormatter.string(from: NSNumber(value: limit)) ?? "\(limit)"
        return "\(currentFormatted) / \(limitFormatted) mg"
    }

    /// Format remaining sodium (e.g., "760 mg remaining")
    static func formatRemaining(_ remaining: Int) -> String {
        if remaining <= 0 {
            return "Daily limit reached"
        }
        let formatted = numberFormatter.string(from: NSNumber(value: remaining)) ?? "\(remaining)"
        return "\(formatted) mg remaining"
    }

    // MARK: - Progress Calculation

    /// Calculate progress percentage (0.0 to 1.0+)
    static func progressPercent(current: Int, limit: Int = dailyLimitMg) -> Double {
        guard limit > 0 else { return 0 }
        return Double(current) / Double(limit)
    }

    /// Get appropriate color for progress percentage
    static func progressColor(for percent: Double) -> Color {
        if percent >= alertThresholdPercent {
            return .hrtAlertFallback
        } else if percent >= cautionThresholdPercent {
            return .hrtCautionFallback
        } else {
            return .hrtGoodFallback
        }
    }

    /// Get status message based on progress
    static func statusMessage(for percent: Double) -> String {
        if percent >= 1.0 {
            return "You've reached your daily sodium goal. Be mindful of additional intake."
        } else if percent >= alertThresholdPercent {
            return "Approaching daily limit. Consider low-sodium options."
        } else if percent >= cautionThresholdPercent {
            return "Past the halfway point. Plan your remaining meals carefully."
        } else {
            return "You're on track for today!"
        }
    }
}
