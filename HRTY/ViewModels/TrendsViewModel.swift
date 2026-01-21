import Foundation
import SwiftData
import SwiftUI

/// Data point for weight chart visualization
struct WeightDataPoint: Identifiable, Equatable {
    let date: Date
    let weight: Double

    var id: Date { date }
}

/// Data point for symptom trend chart visualization
struct SymptomDataPoint: Identifiable, Equatable {
    let date: Date
    let symptomType: SymptomType
    let severity: Int
    let hasAlert: Bool

    var id: String { "\(date.timeIntervalSince1970)-\(symptomType.rawValue)" }
}

@Observable
final class TrendsViewModel {
    // MARK: - Weight Data
    var weightEntries: [WeightDataPoint] = []
    var isLoading: Bool = false

    // MARK: - Symptom Data
    var symptomEntries: [SymptomDataPoint] = []
    var symptomToggleStates: [SymptomType: Bool] = [:]
    var alertDates: Set<Date> = []

    // MARK: - Computed Properties

    /// The most recent weight entry
    var currentWeight: Double? {
        weightEntries.last?.weight
    }

    /// The earliest weight in the 30-day range
    var startingWeight: Double? {
        weightEntries.first?.weight
    }

    /// The most recent weight entry date
    var latestEntryDate: Date? {
        weightEntries.last?.date
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
            return "Stable"
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

        // Filter to entries with weight and map to WeightDataPoint
        weightEntries = entries
            .compactMap { entry -> WeightDataPoint? in
                guard let weight = entry.weight else { return nil }
                return WeightDataPoint(date: entry.date, weight: weight)
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

        if let change = weightChange {
            let absChange = abs(change)
            if absChange < 0.1 {
                summary += "Your weight has been stable over the past 30 days."
            } else {
                let direction = change > 0 ? "up" : "down"
                summary += "Your weight is \(direction) \(String(format: "%.1f", absChange)) pounds over 30 days."
            }
        }

        return summary
    }

    // MARK: - Symptom Computed Properties

    /// Whether there is symptom data to display
    var hasSymptomData: Bool {
        !symptomEntries.isEmpty
    }

    /// Number of unique days with symptom data
    var daysWithSymptomData: Int {
        Set(symptomEntries.map { Calendar.current.startOfDay(for: $0.date) }).count
    }

    /// Filtered symptom entries based on toggle states
    var filteredSymptomEntries: [SymptomDataPoint] {
        symptomEntries.filter { symptomToggleStates[$0.symptomType] ?? true }
    }

    /// Get symptom entries grouped by symptom type
    func symptomEntries(for symptomType: SymptomType) -> [SymptomDataPoint] {
        symptomEntries.filter { $0.symptomType == symptomType }
            .sorted { $0.date < $1.date }
    }

    /// Visible symptom types based on toggle states
    var visibleSymptomTypes: [SymptomType] {
        SymptomType.allCases.filter { symptomToggleStates[$0] ?? true }
    }

    /// Check if a specific date has an alert
    func hasAlert(on date: Date) -> Bool {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return alertDates.contains(normalizedDate)
    }

    /// Toggle visibility for a symptom type
    func toggleSymptom(_ symptomType: SymptomType) {
        symptomToggleStates[symptomType] = !(symptomToggleStates[symptomType] ?? true)
    }

    /// Check if a symptom type is currently visible
    func isSymptomVisible(_ symptomType: SymptomType) -> Bool {
        symptomToggleStates[symptomType] ?? true
    }

    // MARK: - Symptom Data Loading

    /// Load symptom data for the past 30 days
    func loadSymptomData(context: ModelContext) {
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) else {
            return
        }

        // Initialize toggle states with all symptoms visible
        if symptomToggleStates.isEmpty {
            for symptomType in SymptomType.allCases {
                symptomToggleStates[symptomType] = true
            }
        }

        let entries = DailyEntry.fetchForDateRange(from: startDate, to: endDate, in: context)

        // Collect all symptom data points and identify alert days
        var dataPoints: [SymptomDataPoint] = []
        var alertDateSet: Set<Date> = []

        for entry in entries {
            guard let symptoms = entry.symptoms else { continue }

            let entryDate = Calendar.current.startOfDay(for: entry.date)

            // Check if this entry has any symptom alerts
            let hasSymptomAlert = entry.alertEvents?.contains { $0.alertType == .severeSymptom } ?? false
            if hasSymptomAlert {
                alertDateSet.insert(entryDate)
            }

            for symptom in symptoms {
                let hasAlert = symptom.severity >= AlertConstants.severeSymptomThreshold
                dataPoints.append(SymptomDataPoint(
                    date: entryDate,
                    symptomType: symptom.symptomType,
                    severity: symptom.severity,
                    hasAlert: hasAlert
                ))
            }
        }

        symptomEntries = dataPoints.sorted { $0.date < $1.date }
        alertDates = alertDateSet
    }

    /// Load all trend data (weight and symptoms)
    func loadAllTrendData(context: ModelContext) {
        isLoading = true
        loadWeightData(context: context)
        loadSymptomData(context: context)
        isLoading = false
    }

    // MARK: - Symptom Accessibility

    /// Accessibility summary for symptom trends
    var symptomAccessibilitySummary: String {
        guard hasSymptomData else {
            return "No symptom data recorded in the past 30 days"
        }

        let visibleCount = visibleSymptomTypes.count
        let alertCount = alertDates.count

        var summary = "Symptom trends showing \(daysWithSymptomData) days of data. "
        summary += "\(visibleCount) of 8 symptoms visible. "

        if alertCount > 0 {
            summary += "\(alertCount) day\(alertCount == 1 ? "" : "s") with symptoms that needed attention."
        } else {
            summary += "No symptom alerts in this period."
        }

        return summary
    }

    // MARK: - Symptom Colors

    /// Get a distinct color for each symptom type
    static func color(for symptomType: SymptomType) -> Color {
        switch symptomType {
        case .dyspneaAtRest:
            return .blue
        case .dyspneaOnExertion:
            return .cyan
        case .orthopnea:
            return .indigo
        case .pnd:
            return .purple
        case .chestPain:
            return .red
        case .dizziness:
            return .orange
        case .syncope:
            return .pink
        case .reducedUrineOutput:
            return .teal
        }
    }
}
