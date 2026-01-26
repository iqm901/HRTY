import Foundation
import SwiftData
import SwiftUI

/// Represents the different vital sign types that can be selected in the Vitals section
enum VitalType: String, CaseIterable {
    case overview
    case weight
    case bloodPressure
    case heartRate
    case oxygenSaturation

    var label: String {
        switch self {
        case .overview: return "Overview"
        case .weight: return "Weight"
        case .bloodPressure: return "BP"
        case .heartRate: return "HR"
        case .oxygenSaturation: return "O₂"
        }
    }

    var icon: String {
        switch self {
        case .overview: return "chart.line.text.clipboard"
        case .weight: return "scalemass.fill"
        case .bloodPressure: return "heart.text.clipboard.fill"
        case .heartRate: return "heart.fill"
        case .oxygenSaturation: return "lungs.fill"
        }
    }

    var color: Color {
        switch self {
        case .overview: return Color.hrtPinkFallback
        case .weight: return .blue
        case .bloodPressure: return .purple
        case .heartRate: return .red
        case .oxygenSaturation: return .teal
        }
    }
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

    // MARK: - Heart Rate Data
    var heartRateEntries: [HeartRateDataPoint] = []
    var heartRateAlertDates: Set<Date> = []
    var isLoadingHeartRate: Bool = false
    var healthKitAvailable: Bool = false

    // MARK: - Vital Toggle State
    var selectedVital: VitalType = .overview

    // MARK: - Blood Pressure Data
    var bloodPressureEntries: [BloodPressureDataPoint] = []
    var bloodPressureAlertDates: Set<Date> = []

    // MARK: - Oxygen Saturation Data
    var oxygenSaturationEntries: [OxygenSaturationDataPoint] = []
    var oxygenSaturationAlertDates: Set<Date> = []

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

    /// Load heart rate data for the past 30 days from Core Data and HealthKit
    func loadHeartRateData(context: ModelContext) async {
        isLoadingHeartRate = true

        // Group by day and get daily averages (one reading per day for the chart)
        var dailyReadings: [Date: [HeartRateReading]] = [:]

        // Fetch from HealthKit if available
        if healthKitAvailable {
            let authorized = await healthKitService.requestAuthorization()
            if authorized {
                let readings = await healthKitService.fetchHeartRateHistory(days: 30)
                for reading in readings {
                    let day = Calendar.current.startOfDay(for: reading.date)
                    dailyReadings[day, default: []].append(reading)
                }
            }
        }

        // Fetch from Core Data (user-entered readings) - takes precedence over HealthKit
        let endDate = Date()
        if let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) {
            let entries = DailyEntry.fetchForDateRange(from: startDate, to: endDate, in: context)

            for entry in entries {
                guard let vitalSigns = entry.vitalSigns,
                      let heartRate = vitalSigns.heartRate else {
                    continue
                }
                let day = Calendar.current.startOfDay(for: entry.date)
                // Core Data entry overwrites HealthKit for that day
                dailyReadings[day] = [HeartRateReading(heartRate: heartRate, date: day)]
            }
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

    /// Load all trend data including heart rate, blood pressure, and oxygen saturation
    func loadAllTrendDataWithHeartRate(context: ModelContext) async {
        isLoading = true
        loadWeightData(context: context)
        loadSymptomData(context: context)
        loadBloodPressureData(context: context)
        loadOxygenSaturationData(context: context)
        await loadHeartRateData(context: context)
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

    // MARK: - Blood Pressure Computed Properties

    /// Whether there is blood pressure data to display
    var hasBloodPressureData: Bool {
        !bloodPressureEntries.isEmpty
    }

    /// Number of days with blood pressure data
    var daysWithBloodPressureData: Int {
        bloodPressureEntries.count
    }

    /// The most recent blood pressure entry
    var currentBloodPressure: (systolic: Int, diastolic: Int)? {
        guard let last = bloodPressureEntries.last else { return nil }
        return (last.systolic, last.diastolic)
    }

    /// Average systolic blood pressure over the period
    var averageSystolic: Int? {
        guard !bloodPressureEntries.isEmpty else { return nil }
        let sum = bloodPressureEntries.reduce(0) { $0 + $1.systolic }
        return sum / bloodPressureEntries.count
    }

    /// Average diastolic blood pressure over the period
    var averageDiastolic: Int? {
        guard !bloodPressureEntries.isEmpty else { return nil }
        let sum = bloodPressureEntries.reduce(0) { $0 + $1.diastolic }
        return sum / bloodPressureEntries.count
    }

    /// Formatted current blood pressure for display (e.g., "120/80")
    var formattedCurrentBP: String? {
        guard let bp = currentBloodPressure else { return nil }
        return "\(bp.systolic)/\(bp.diastolic)"
    }

    /// Formatted average blood pressure for display
    var formattedAverageBP: String? {
        guard let sys = averageSystolic, let dia = averageDiastolic else { return nil }
        return "\(sys)/\(dia)"
    }

    // MARK: - Blood Pressure Data Loading

    /// Load blood pressure data for the past 30 days
    func loadBloodPressureData(context: ModelContext) {
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) else {
            return
        }

        let entries = DailyEntry.fetchForDateRange(from: startDate, to: endDate, in: context)

        var dataPoints: [BloodPressureDataPoint] = []
        var alertDateSet: Set<Date> = []

        for entry in entries {
            guard let vitalSigns = entry.vitalSigns,
                  let systolic = vitalSigns.systolicBP,
                  let diastolic = vitalSigns.diastolicBP else {
                continue
            }

            let entryDate = Calendar.current.startOfDay(for: entry.date)

            // Check for alerts - low systolic or high values
            let hasAlert = systolic < AlertConstants.systolicBPLowThreshold ||
                           systolic >= AlertConstants.systolicBPCriticalHigh ||
                           diastolic >= AlertConstants.diastolicBPCriticalHigh

            if hasAlert {
                alertDateSet.insert(entryDate)
            }

            dataPoints.append(BloodPressureDataPoint(
                date: entryDate,
                systolic: systolic,
                diastolic: diastolic,
                hasAlert: hasAlert
            ))
        }

        bloodPressureEntries = dataPoints.sorted { $0.date < $1.date }
        bloodPressureAlertDates = alertDateSet
    }

    // MARK: - Blood Pressure Accessibility

    /// Accessibility summary for blood pressure trends
    var bloodPressureAccessibilitySummary: String {
        guard hasBloodPressureData else {
            return "No blood pressure data recorded in the past 30 days"
        }

        var summary = "Blood pressure chart showing \(daysWithBloodPressureData) days of data. "

        if let current = formattedCurrentBP {
            summary += "Most recent: \(current) mmHg. "
        }

        if let avg = formattedAverageBP {
            summary += "30-day average: \(avg) mmHg. "
        }

        let alertCount = bloodPressureAlertDates.count
        if alertCount > 0 {
            summary += "\(alertCount) day\(alertCount == 1 ? "" : "s") with blood pressure values that may need attention."
        } else {
            summary += "No blood pressure alerts in this period."
        }

        return summary
    }

    // MARK: - Oxygen Saturation Computed Properties

    /// Whether there is oxygen saturation data to display
    var hasOxygenSaturationData: Bool {
        !oxygenSaturationEntries.isEmpty
    }

    /// Number of days with oxygen saturation data
    var daysWithOxygenSaturationData: Int {
        oxygenSaturationEntries.count
    }

    /// The most recent oxygen saturation entry
    var currentOxygenSaturation: Int? {
        oxygenSaturationEntries.last?.percentage
    }

    /// Average oxygen saturation over the period
    var averageOxygenSaturation: Int? {
        guard !oxygenSaturationEntries.isEmpty else { return nil }
        let sum = oxygenSaturationEntries.reduce(0) { $0 + $1.percentage }
        return sum / oxygenSaturationEntries.count
    }

    /// Oxygen saturation range (min to max) over the period
    var oxygenSaturationRange: (min: Int, max: Int)? {
        guard !oxygenSaturationEntries.isEmpty else { return nil }
        let values = oxygenSaturationEntries.map { $0.percentage }
        guard let min = values.min(), let max = values.max() else { return nil }
        return (min, max)
    }

    /// Formatted current oxygen saturation for display
    var formattedCurrentO2: String? {
        guard let o2 = currentOxygenSaturation else { return nil }
        return "\(o2)%"
    }

    /// Formatted average oxygen saturation for display
    var formattedAverageO2: String? {
        guard let avg = averageOxygenSaturation else { return nil }
        return "\(avg)%"
    }

    /// Formatted oxygen saturation range for display
    var formattedO2Range: String? {
        guard let range = oxygenSaturationRange else { return nil }
        return "\(range.min)-\(range.max)%"
    }

    // MARK: - Oxygen Saturation Data Loading

    /// Load oxygen saturation data for the past 30 days
    func loadOxygenSaturationData(context: ModelContext) {
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) else {
            return
        }

        let entries = DailyEntry.fetchForDateRange(from: startDate, to: endDate, in: context)

        var dataPoints: [OxygenSaturationDataPoint] = []
        var alertDateSet: Set<Date> = []

        for entry in entries {
            guard let vitalSigns = entry.vitalSigns,
                  let o2 = vitalSigns.oxygenSaturation else {
                continue
            }

            let entryDate = Calendar.current.startOfDay(for: entry.date)

            // Check for alerts - low oxygen saturation
            let hasAlert = o2 < AlertConstants.oxygenSaturationLowThreshold

            if hasAlert {
                alertDateSet.insert(entryDate)
            }

            dataPoints.append(OxygenSaturationDataPoint(
                date: entryDate,
                percentage: o2,
                hasAlert: hasAlert
            ))
        }

        oxygenSaturationEntries = dataPoints.sorted { $0.date < $1.date }
        oxygenSaturationAlertDates = alertDateSet
    }

    // MARK: - Oxygen Saturation Accessibility

    /// Accessibility summary for oxygen saturation trends
    var oxygenSaturationAccessibilitySummary: String {
        guard hasOxygenSaturationData else {
            return "No oxygen saturation data recorded in the past 30 days"
        }

        var summary = "Oxygen saturation chart showing \(daysWithOxygenSaturationData) days of data. "

        if let current = formattedCurrentO2 {
            summary += "Most recent: \(current). "
        }

        if let avg = formattedAverageO2 {
            summary += "30-day average: \(avg). "
        }

        let alertCount = oxygenSaturationAlertDates.count
        if alertCount > 0 {
            summary += "\(alertCount) day\(alertCount == 1 ? "" : "s") with oxygen levels that may need attention."
        } else {
            summary += "No oxygen saturation alerts in this period."
        }

        return summary
    }

    // MARK: - Load All Vital Signs Data

    /// Load all vital signs data including blood pressure and oxygen saturation
    func loadAllVitalSignsData(context: ModelContext) {
        loadBloodPressureData(context: context)
        loadOxygenSaturationData(context: context)
    }
}
