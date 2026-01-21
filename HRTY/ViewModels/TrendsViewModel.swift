import Foundation
import SwiftData

@Observable
final class TrendsViewModel {
    // MARK: - Weight Data
    var weightEntries: [(date: Date, weight: Double)] = []
    var isLoading: Bool = false

    // MARK: - Computed Properties

    /// The most recent weight entry
    var currentWeight: Double? {
        weightEntries.last?.weight
    }

    /// The earliest weight in the 30-day range
    var startingWeight: Double? {
        weightEntries.first?.weight
    }

    /// Weight change over the 30-day period
    var weightChange: Double? {
        guard let current = currentWeight,
              let starting = startingWeight,
              weightEntries.count > 1 else {
            return nil
        }
        return current - starting
    }

    /// Formatted weight change text for display
    var weightChangeText: String? {
        guard let change = weightChange else { return nil }
        let absChange = abs(change)
        let formattedChange = String(format: "%.1f", absChange)

        if change > 0.1 {
            return "+\(formattedChange) lbs"
        } else if change < -0.1 {
            return "-\(formattedChange) lbs"
        } else {
            return "No change"
        }
    }

    /// Description of weight trend direction
    var weightTrendDescription: String? {
        guard let change = weightChange else { return nil }

        if change > 0.1 {
            return "gained"
        } else if change < -0.1 {
            return "lost"
        } else {
            return "maintained"
        }
    }

    /// Start date of the chart range
    var chartStartDate: Date {
        Calendar.current.date(byAdding: .day, value: -29, to: Date()) ?? Date()
    }

    /// End date of the chart range (today)
    var chartEndDate: Date {
        Date()
    }

    /// Formatted date range string
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: chartStartDate)) - \(formatter.string(from: chartEndDate))"
    }

    /// Whether there is weight data to display
    var hasWeightData: Bool {
        !weightEntries.isEmpty
    }

    /// Number of days with recorded weight
    var daysWithData: Int {
        weightEntries.count
    }

    // MARK: - Methods

    /// Load weight data for the past 30 days
    func loadWeightData(context: ModelContext) {
        isLoading = true

        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) else {
            isLoading = false
            return
        }

        let entries = DailyEntry.fetchForDateRange(from: startDate, to: endDate, in: context)

        // Filter to entries with weight and map to tuples
        weightEntries = entries
            .compactMap { entry -> (date: Date, weight: Double)? in
                guard let weight = entry.weight else { return nil }
                return (date: entry.date, weight: weight)
            }
            .sorted { $0.date < $1.date }

        isLoading = false
    }

    /// Formatted current weight for display
    var formattedCurrentWeight: String? {
        guard let weight = currentWeight else { return nil }
        return String(format: "%.1f lbs", weight)
    }

    /// Accessibility summary for VoiceOver
    var accessibilitySummary: String {
        guard hasWeightData else {
            return "No weight data recorded in the past 30 days"
        }

        var summary = "Weight chart showing \(daysWithData) days of data. "

        if let current = formattedCurrentWeight {
            summary += "Current weight: \(current). "
        }

        if let change = weightChange, let direction = weightTrendDescription {
            let absChange = abs(change)
            summary += "Over 30 days, you have \(direction) \(String(format: "%.1f", absChange)) pounds."
        }

        return summary
    }
}
