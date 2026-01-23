import Foundation
import SwiftData
import SwiftUI

@Observable
final class TrendsViewModel {
    // MARK: - Weight Data
    var weightEntries: [WeightDataPoint] = []
    var isLoading: Bool = false

    // MARK: - Symptom Data
    var symptomEntries: [SymptomDataPoint] = []
    var symptomToggleStates: [SymptomType: Bool] = [:]
    var alertDates: Set<Date> = []

    // MARK: - Heart Rate Data
    var heartRateEntries: [HeartRateDataPoint] = []
    var heartRateAlertDates: Set<Date> = []
    var isLoadingHeartRate: Bool = false
    var healthKitAvailable: Bool = false

    // MARK: - Services
    private let healthKitService: HealthKitServiceProtocol

    // MARK: - Initialization
    init(healthKitService: HealthKitServiceProtocol = HealthKitService()) {
        self.healthKitService = healthKitService
        self.healthKitAvailable = healthKitService.isAvailable
    }

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

    // MARK: - Heart Rate Computed Properties

    /// Whether there is heart rate data to display
    var hasHeartRateData: Bool {
        !heartRateEntries.isEmpty
    }

    /// Number of days with heart rate data
    var daysWithHeartRateData: Int {
        heartRateEntries.count
    }

    /// The most recent heart rate entry
    var currentHeartRate: Int? {
        heartRateEntries.last?.heartRate
    }

    /// The earliest heart rate in the 30-day range
    var startingHeartRate: Int? {
        heartRateEntries.first?.heartRate
    }

    /// Average heart rate over the period
    var averageHeartRate: Int? {
        guard !heartRateEntries.isEmpty else { return nil }
        let sum = heartRateEntries.reduce(0) { $0 + $1.heartRate }
        return sum / heartRateEntries.count
    }

    /// Heart rate range (min to max) over the period
    var heartRateRange: (min: Int, max: Int)? {
        guard !heartRateEntries.isEmpty else { return nil }
        let heartRates = heartRateEntries.map { $0.heartRate }
        guard let min = heartRates.min(), let max = heartRates.max() else { return nil }
        return (min, max)
    }

    /// Formatted current heart rate for display
    var formattedCurrentHeartRate: String? {
        guard let hr = currentHeartRate else { return nil }
        return "\(hr) bpm"
    }

    /// Formatted average heart rate for display
    var formattedAverageHeartRate: String? {
        guard let avg = averageHeartRate else { return nil }
        return "\(avg) bpm"
    }

    /// Formatted heart rate range for display
    var formattedHeartRateRange: String? {
        guard let range = heartRateRange else { return nil }
        return "\(range.min)-\(range.max) bpm"
    }

    // MARK: - Heart Rate Data Loading

    /// Load heart rate data for the past 30 days from HealthKit
    func loadHeartRateData() async {
        guard healthKitAvailable else { return }

        isLoadingHeartRate = true

        // Request authorization
        let authorized = await healthKitService.requestAuthorization()
        guard authorized else {
            isLoadingHeartRate = false
            return
        }

        // Fetch heart rate history
        let readings = await healthKitService.fetchHeartRateHistory(days: 30)

        // Group by day and get daily averages (one reading per day for the chart)
        var dailyReadings: [Date: [HeartRateReading]] = [:]
        for reading in readings {
            let day = Calendar.current.startOfDay(for: reading.date)
            dailyReadings[day, default: []].append(reading)
        }

        // Convert to HeartRateDataPoints with daily averages
        var dataPoints: [HeartRateDataPoint] = []
        var alertDateSet: Set<Date> = []

        for (day, dayReadings) in dailyReadings {
            let avgHeartRate = dayReadings.reduce(0) { $0 + $1.heartRate } / dayReadings.count
            let hasAlert = avgHeartRate < AlertConstants.heartRateLowThreshold ||
                           avgHeartRate > AlertConstants.heartRateHighThreshold

            if hasAlert {
                alertDateSet.insert(day)
            }

            dataPoints.append(HeartRateDataPoint(
                date: day,
                heartRate: avgHeartRate,
                hasAlert: hasAlert
            ))
        }

        heartRateEntries = dataPoints.sorted { $0.date < $1.date }
        heartRateAlertDates = alertDateSet

        isLoadingHeartRate = false
    }

    /// Load all trend data including heart rate
    func loadAllTrendDataWithHeartRate(context: ModelContext) async {
        isLoading = true
        loadWeightData(context: context)
        loadSymptomData(context: context)
        await loadHeartRateData()
        isLoading = false
    }

    // MARK: - Heart Rate Accessibility

    /// Accessibility summary for heart rate trends
    var heartRateAccessibilitySummary: String {
        guard hasHeartRateData else {
            return "No heart rate data recorded in the past 30 days"
        }

        var summary = "Heart rate chart showing \(daysWithHeartRateData) days of data. "

        if let current = formattedCurrentHeartRate {
            summary += "Most recent: \(current). "
        }

        if let avg = formattedAverageHeartRate {
            summary += "30-day average: \(avg). "
        }

        let alertCount = heartRateAlertDates.count
        if alertCount > 0 {
            summary += "\(alertCount) day\(alertCount == 1 ? "" : "s") with heart rate values that may need attention."
        } else {
            summary += "No heart rate alerts in this period."
        }

        return summary
    }
}
