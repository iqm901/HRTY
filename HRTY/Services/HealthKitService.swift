import Foundation
import HealthKit

/// Protocol for HealthKit service operations
/// Enables dependency injection and testability

/// Simple struct for weight readings from HealthKit
struct WeightReading: Identifiable, Equatable {
    let id: UUID
    let weight: Double
    let date: Date

    init(weight: Double, date: Date) {
        self.id = UUID()
        self.weight = weight
        self.date = date
    }
}

// BloodPressureReading is defined in HRTY/Models/BloodPressureReading.swift
// OxygenSaturationReading is defined in HRTY/Models/OxygenSaturationReading.swift

protocol HealthKitServiceProtocol {
    var isAvailable: Bool { get }
    func requestAuthorization() async -> Bool
    func fetchLatestRestingHeartRate() async -> HeartRateReading?
    func fetchHeartRateHistory(days: Int) async -> [HeartRateReading]
    func checkForPersistentAbnormalHeartRate() async -> (isAbnormal: Bool, isLow: Bool, readings: [HeartRateReading])
    func hasRecentBloodPressureReading(withinHours hours: Int) async -> Bool
    func fetchLatestWeight() async -> WeightReading?
    func fetchLatestBloodPressure() async -> BloodPressureReading?
    func fetchLatestOxygenSaturation() async -> OxygenSaturationReading?
}

/// Service responsible for HealthKit integration
/// Handles heart rate data fetching and authorization
final class HealthKitService: HealthKitServiceProtocol {

    private let healthStore: HKHealthStore?

    /// Minimum number of abnormal readings to be considered "persistent"
    private let persistentReadingThreshold = 3

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
        } else {
            self.healthStore = nil
        }
    }

    // MARK: - Availability

    var isAvailable: Bool {
        healthStore != nil
    }

    // MARK: - Authorization

    /// Request authorization to read health data from HealthKit
    /// - Returns: True if authorization was granted or already exists
    func requestAuthorization() async -> Bool {
        guard let healthStore = healthStore else { return false }

        guard let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return false
        }

        var typesToRead: Set<HKObjectType> = [restingHeartRateType]

        // Add weight type
        if let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
            typesToRead.insert(weightType)
        }

        // Add blood pressure types (systolic and diastolic)
        if let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
           let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) {
            typesToRead.insert(systolicType)
            typesToRead.insert(diastolicType)
        }

        // Add oxygen saturation type
        if let oxygenType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) {
            typesToRead.insert(oxygenType)
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            return true
        } catch {
            #if DEBUG
            print("HealthKit authorization error: \(error.localizedDescription)")
            #endif
            return false
        }
    }

    // MARK: - Fetch Latest Resting Heart Rate

    /// Fetch the most recent resting heart rate reading
    /// - Returns: The latest heart rate reading, or nil if not available
    func fetchLatestRestingHeartRate() async -> HeartRateReading? {
        guard let healthStore = healthStore else { return nil }

        guard let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return nil
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: restingHeartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                guard error == nil,
                      let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let heartRate = Int(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
                let reading = HeartRateReading(heartRate: heartRate, date: sample.startDate)
                continuation.resume(returning: reading)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Fetch Heart Rate History

    /// Fetch heart rate history for the specified number of days
    /// - Parameter days: Number of days of history to fetch
    /// - Returns: Array of heart rate readings, sorted by date ascending
    func fetchHeartRateHistory(days: Int) async -> [HeartRateReading] {
        guard let healthStore = healthStore else { return [] }

        guard let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return []
        }

        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            return []
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: restingHeartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                guard error == nil,
                      let quantitySamples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }

                let readings = quantitySamples.map { sample in
                    HeartRateReading(
                        heartRate: Int(sample.quantity.doubleValue(for: HKUnit(from: "count/min"))),
                        date: sample.startDate
                    )
                }

                continuation.resume(returning: readings)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Check for Persistent Abnormal Heart Rate

    /// Check if there are persistent abnormal heart rate readings
    /// "Persistent" means 3+ consecutive abnormal readings
    /// - Returns: Tuple containing whether HR is abnormal, whether it's low (vs high), and the abnormal readings
    func checkForPersistentAbnormalHeartRate() async -> (isAbnormal: Bool, isLow: Bool, readings: [HeartRateReading]) {
        // Fetch recent readings (last 7 days to have enough data)
        let readings = await fetchHeartRateHistory(days: 7)

        guard readings.count >= persistentReadingThreshold else {
            return (isAbnormal: false, isLow: false, readings: [])
        }

        // Get the most recent readings
        let recentReadings = Array(readings.suffix(persistentReadingThreshold))

        // Check for persistent low heart rate
        let lowReadings = recentReadings.filter { $0.heartRate < AlertConstants.heartRateLowThreshold }
        if lowReadings.count >= persistentReadingThreshold {
            return (isAbnormal: true, isLow: true, readings: lowReadings)
        }

        // Check for persistent high heart rate
        let highReadings = recentReadings.filter { $0.heartRate > AlertConstants.heartRateHighThreshold }
        if highReadings.count >= persistentReadingThreshold {
            return (isAbnormal: true, isLow: false, readings: highReadings)
        }

        return (isAbnormal: false, isLow: false, readings: [])
    }

    // MARK: - Blood Pressure Check

    /// Check if there's a blood pressure reading within the specified timeframe
    /// - Parameter hours: Number of hours to look back (default 24)
    /// - Returns: True if a BP reading exists within the timeframe
    func hasRecentBloodPressureReading(withinHours hours: Int = 24) async -> Bool {
        guard let healthStore = healthStore else { return false }

        guard let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic) else {
            return false
        }

        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .hour, value: -hours, to: endDate) else {
            return false
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: systolicType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: nil
            ) { _, samples, error in
                guard error == nil,
                      let samples = samples else {
                    continuation.resume(returning: false)
                    return
                }

                continuation.resume(returning: !samples.isEmpty)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Fetch Latest Weight

    /// Fetch the most recent weight reading
    /// - Returns: The latest weight reading in pounds, or nil if not available
    func fetchLatestWeight() async -> WeightReading? {
        guard let healthStore = healthStore else { return nil }

        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return nil
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                guard error == nil,
                      let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let weightInPounds = sample.quantity.doubleValue(for: HKUnit.pound())
                let reading = WeightReading(weight: weightInPounds, date: sample.startDate)
                continuation.resume(returning: reading)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Fetch Latest Blood Pressure

    /// Fetch the most recent blood pressure reading
    /// - Returns: The latest blood pressure reading, or nil if not available
    func fetchLatestBloodPressure() async -> BloodPressureReading? {
        guard let healthStore = healthStore else { return nil }

        guard let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
              let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
            return nil
        }

        // Fetch systolic first
        let systolicReading = await fetchLatestQuantitySample(type: systolicType, unit: HKUnit.millimeterOfMercury())
        guard let systolicValue = systolicReading?.value,
              let systolicDate = systolicReading?.date else {
            return nil
        }

        // Fetch diastolic from the same time window (within 1 minute of systolic)
        let diastolicReading = await fetchQuantitySampleNear(
            type: diastolicType,
            unit: HKUnit.millimeterOfMercury(),
            targetDate: systolicDate,
            toleranceSeconds: 60
        )

        guard let diastolicValue = diastolicReading?.value else {
            return nil
        }

        return BloodPressureReading(
            systolic: Int(systolicValue),
            diastolic: Int(diastolicValue),
            date: systolicDate
        )
    }

    // MARK: - Fetch Latest Oxygen Saturation

    /// Fetch the most recent oxygen saturation reading
    /// - Returns: The latest SpO2 reading, or nil if not available
    func fetchLatestOxygenSaturation() async -> OxygenSaturationReading? {
        guard let healthStore = healthStore else { return nil }

        guard let oxygenType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else {
            return nil
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: oxygenType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                guard error == nil,
                      let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                // SpO2 is stored as a fraction (0.0-1.0), convert to percentage
                let percentage = Int(sample.quantity.doubleValue(for: HKUnit.percent()) * 100)
                let reading = OxygenSaturationReading(percentage: percentage, date: sample.startDate)
                continuation.resume(returning: reading)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Helper Methods

    private func fetchLatestQuantitySample(type: HKQuantityType, unit: HKUnit) async -> (value: Double, date: Date)? {
        guard let healthStore = healthStore else { return nil }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                guard error == nil,
                      let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let value = sample.quantity.doubleValue(for: unit)
                continuation.resume(returning: (value, sample.startDate))
            }

            healthStore.execute(query)
        }
    }

    private func fetchQuantitySampleNear(
        type: HKQuantityType,
        unit: HKUnit,
        targetDate: Date,
        toleranceSeconds: Int
    ) async -> (value: Double, date: Date)? {
        guard let healthStore = healthStore else { return nil }

        let startDate = targetDate.addingTimeInterval(-Double(toleranceSeconds))
        let endDate = targetDate.addingTimeInterval(Double(toleranceSeconds))
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                guard error == nil,
                      let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let value = sample.quantity.doubleValue(for: unit)
                continuation.resume(returning: (value, sample.startDate))
            }

            healthStore.execute(query)
        }
    }
}
