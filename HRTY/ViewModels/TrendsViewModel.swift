import Foundation
import SwiftData
import SwiftUI

/// Data point for weight chart visualization
struct WeightDataPoint: Identifiable, Equatable {
    let date: Date
    let weight: Double

    var id: Date { date }
}

/// Data point for symptom chart visualization
struct SymptomDataPoint: Identifiable, Equatable {
    let date: Date
    let symptomType: SymptomType
    let severity: Int
    let hasAlert: Bool

    /// Unique identifier combining date (as yyyy-MM-dd) and symptom type for stable identity
    var id: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return "\(formatter.string(from: date))-\(symptomType.rawValue)"
    }
}

@Observable
final class TrendsViewModel {
    // MARK: - Weight Data
    var weightEntries: [WeightDataPoint] = []
    var isLoading: Bool = false

    // MARK: - Symptom Trend Data
    var symptomEntries: [SymptomDataPoint] = []
    var symptomToggles: [SymptomType: Bool] = [:]
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

    // MARK: - Symptom Trend Computed Properties

    /// Whether there is symptom data to display
    var hasSymptomData: Bool {
        !symptomEntries.isEmpty
    }

    /// Number of days with recorded symptoms
    var daysWithSymptomData: Int {
        Set(symptomEntries.map { Calendar.current.startOfDay(for: $0.date) }).count
    }

    /// Get symptom entries for a specific type (respects toggle state)
    func entriesForSymptom(_ type: SymptomType) -> [SymptomDataPoint] {
        guard isSymptomVisible(type) else { return [] }
        return symptomEntries
            .filter { $0.symptomType == type }
            .sorted { $0.date < $1.date }
    }

    /// Check if a symptom is currently visible
    func isSymptomVisible(_ type: SymptomType) -> Bool {
        symptomToggles[type] ?? true
    }

    /// Toggle visibility of a symptom
    func toggleSymptom(_ type: SymptomType) {
        symptomToggles[type] = !(symptomToggles[type] ?? true)
    }

    /// Set visibility of a symptom
    func setSymptomVisibility(_ type: SymptomType, visible: Bool) {
        symptomToggles[type] = visible
    }

    /// Check if a date has an alert
    func dateHasAlert(_ date: Date) -> Bool {
        let dayStart = Calendar.current.startOfDay(for: date)
        return alertDates.contains(dayStart)
    }

    /// Color for a specific symptom type
    func colorForSymptom(_ type: SymptomType) -> Color {
        switch type {
        case .dyspneaAtRest:
            return .blue
        case .dyspneaOnExertion:
            return .cyan
        case .orthopnea:
            return .purple
        case .pnd:
            return .indigo
        case .chestPain:
            return .red
        case .dizziness:
            return .orange
        case .syncope:
            return .pink
        case .reducedUrineOutput:
            return .brown
        }
    }

    /// Accessibility summary for symptom trends
    var symptomAccessibilitySummary: String {
        guard hasSymptomData else {
            return "No symptom data recorded in the past 30 days"
        }

        let visibleSymptoms = SymptomType.allCases.filter { isSymptomVisible($0) }
        let visibleCount = visibleSymptoms.count
        let alertCount = alertDates.count

        var summary = "Symptom chart showing \(daysWithSymptomData) days of data. "
        summary += "\(visibleCount) of 8 symptoms visible. "

        if alertCount > 0 {
            summary += "\(alertCount) days had symptom alerts."
        }

        return summary
    }

    // MARK: - Symptom Data Loading

    /// Load symptom data for the past 30 days
    func loadSymptomData(context: ModelContext) {
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) else {
            return
        }

        let entries = DailyEntry.fetchForDateRange(from: startDate, to: endDate, in: context)

        // Initialize toggles if empty (default all visible)
        if symptomToggles.isEmpty {
            for symptomType in SymptomType.allCases {
                symptomToggles[symptomType] = true
            }
        }

        // Collect alert dates
        var alerts: Set<Date> = []
        for entry in entries {
            if let alertEvents = entry.alertEvents, !alertEvents.isEmpty {
                // Check if any alert is symptom-related
                let hasSymptomAlert = alertEvents.contains { $0.alertType == .severeSymptom }
                if hasSymptomAlert {
                    alerts.insert(Calendar.current.startOfDay(for: entry.date))
                }
            }
        }
        alertDates = alerts

        // Map symptoms to data points
        var dataPoints: [SymptomDataPoint] = []
        for entry in entries {
            guard let symptoms = entry.symptoms else { continue }
            let dayStart = Calendar.current.startOfDay(for: entry.date)
            let hasAlert = alerts.contains(dayStart)

            for symptom in symptoms {
                dataPoints.append(SymptomDataPoint(
                    date: entry.date,
                    symptomType: symptom.symptomType,
                    severity: symptom.severity,
                    hasAlert: hasAlert
                ))
            }
        }

        symptomEntries = dataPoints.sorted { $0.date < $1.date }
    }

    /// Load all trends data (weight and symptoms)
    func loadAllData(context: ModelContext) {
        isLoading = true
        loadWeightData(context: context)
        loadSymptomData(context: context)
        isLoading = false
    }
}
