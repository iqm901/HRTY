import Foundation
import HealthKit

// MARK: - HealthKit Weight Data

/// Represents weight data imported from HealthKit
struct HealthKitWeight {
    let weight: Double // in pounds
    let timestamp: Date

    var formattedWeight: String {
        String(format: "%.1f", weight)
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - Authorization Status

/// Represents the authorization status for HealthKit weight access
enum HealthKitAuthorizationStatus {
    case notDetermined
    case authorized
    case denied
    case unavailable
}

// MARK: - HealthKit Service Protocol

/// Protocol defining HealthKit service operations.
/// Enables dependency injection and testability for HealthKit integration.
protocol HealthKitServiceProtocol {
    /// Check if HealthKit is available on this device
    var isHealthKitAvailable: Bool { get }

    /// Current authorization status for reading weight
    var authorizationStatus: HealthKitAuthorizationStatus { get }

    /// Request authorization to read weight from HealthKit
    func requestAuthorization() async throws

    /// Fetch the most recent weight from HealthKit
    func fetchLatestWeight() async throws -> HealthKitWeight?
}

// MARK: - HealthKit Errors

/// Errors that can occur during HealthKit operations
enum HealthKitError: LocalizedError {
    case unavailable
    case authorizationDenied
    case noData
    case queryFailed(Error)

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Health app is not available on this device"
        case .authorizationDenied:
            return "HRTY needs permission to read your weight from the Health app"
        case .noData:
            return "No weight data found in Health"
        case .queryFailed:
            return "We couldn't read your weight from Health right now"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unavailable:
            return "No worries! You can enter your weight manually below."
        case .authorizationDenied:
            return "You can enable this in Settings > Privacy & Security > Health > HRTY."
        case .noData:
            return "Make sure you have weight data recorded in the Health app, or enter it manually below."
        case .queryFailed:
            return "Please try again in a moment, or enter your weight manually."
        }
    }
}

// MARK: - HealthKit Service Implementation

/// Service responsible for HealthKit weight data access.
/// Follows the same pattern as WeightAlertService and SymptomAlertService.
final class HealthKitService: HealthKitServiceProtocol {

    // MARK: - Properties

    private let healthStore: HKHealthStore?
    private let weightType: HKQuantityType?

    // MARK: - Initialization

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
            self.weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)
        } else {
            self.healthStore = nil
            self.weightType = nil
        }
    }

    // MARK: - HealthKitServiceProtocol

    var isHealthKitAvailable: Bool {
        healthStore != nil && weightType != nil
    }

    var authorizationStatus: HealthKitAuthorizationStatus {
        guard isHealthKitAvailable,
              let healthStore = healthStore,
              let weightType = weightType else {
            return .unavailable
        }

        let status = healthStore.authorizationStatus(for: weightType)
        switch status {
        case .notDetermined:
            return .notDetermined
        case .sharingAuthorized:
            // Note: For read-only access, sharingAuthorized means we have read access
            return .authorized
        case .sharingDenied:
            return .denied
        @unknown default:
            return .notDetermined
        }
    }

    func requestAuthorization() async throws {
        guard isHealthKitAvailable,
              let healthStore = healthStore,
              let weightType = weightType else {
            throw HealthKitError.unavailable
        }

        // Request read-only access to body mass
        let typesToRead: Set<HKObjectType> = [weightType]

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }

    func fetchLatestWeight() async throws -> HealthKitWeight? {
        guard isHealthKitAvailable,
              let healthStore = healthStore,
              let weightType = weightType else {
            throw HealthKitError.unavailable
        }

        // Create a query for the most recent weight sample
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: weightType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, _, _ in }

        // Execute query using async/await pattern
        return try await withCheckedThrowingContinuation { continuation in
            let asyncQuery = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                guard let quantitySample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                // Convert to pounds
                let weightInPounds = quantitySample.quantity.doubleValue(for: .pound())
                let timestamp = quantitySample.endDate

                let healthKitWeight = HealthKitWeight(
                    weight: weightInPounds,
                    timestamp: timestamp
                )

                continuation.resume(returning: healthKitWeight)
            }

            healthStore.execute(asyncQuery)
        }
    }
}

// MARK: - Mock Service for Testing/Previews

/// Mock implementation for testing and SwiftUI previews
final class MockHealthKitService: HealthKitServiceProtocol {
    var mockIsAvailable = true
    var mockAuthorizationStatus: HealthKitAuthorizationStatus = .notDetermined
    var mockWeight: HealthKitWeight?
    var mockError: HealthKitError?

    var isHealthKitAvailable: Bool { mockIsAvailable }
    var authorizationStatus: HealthKitAuthorizationStatus { mockAuthorizationStatus }

    func requestAuthorization() async throws {
        if let error = mockError {
            throw error
        }
        mockAuthorizationStatus = .authorized
    }

    func fetchLatestWeight() async throws -> HealthKitWeight? {
        if let error = mockError {
            throw error
        }
        return mockWeight
    }
}
