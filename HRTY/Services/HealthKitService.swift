import Foundation
import HealthKit

// MARK: - HealthKit Weight Data

/// Represents weight data imported from HealthKit
struct HealthKitWeight {
    let weight: Double // in pounds
    let timestamp: Date

    /// Static formatter for timestamp display (DateFormatter is expensive to create)
    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var formattedWeight: String {
        String(format: "%.1f", weight)
    }

    var formattedTimestamp: String {
        Self.timestampFormatter.string(from: timestamp)
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

    /// Tracks whether we've attempted authorization for read access.
    /// Since HealthKit doesn't expose read authorization status, we track it ourselves.
    private var hasAttemptedAuthorization = false

    var authorizationStatus: HealthKitAuthorizationStatus {
        guard isHealthKitAvailable else {
            return .unavailable
        }

        // Note: HealthKit's authorizationStatus(for:) only reports WRITE authorization status.
        // For read-only access, Apple intentionally hides whether user granted or denied
        // to protect privacy. We cannot determine read authorization status via API.
        // Instead, we rely on attempting to fetch and handling the result.
        return hasAttemptedAuthorization ? .authorized : .notDetermined
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

        // Mark that we've attempted authorization (user has seen the prompt or already responded)
        hasAttemptedAuthorization = true
    }

    func fetchLatestWeight() async throws -> HealthKitWeight? {
        guard isHealthKitAvailable,
              let healthStore = healthStore,
              let weightType = weightType else {
            throw HealthKitError.unavailable
        }

        return try await executeWeightQuery(healthStore: healthStore, weightType: weightType)
    }

    // MARK: - Private Helpers

    /// Executes a HealthKit query for the most recent weight sample.
    /// Isolated to encapsulate the continuation-based async pattern.
    private func executeWeightQuery(
        healthStore: HKHealthStore,
        weightType: HKQuantityType
    ) async throws -> HealthKitWeight? {
        // Create a query for the most recent weight sample
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
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
                let healthKitWeight = HealthKitWeight(
                    weight: weightInPounds,
                    timestamp: quantitySample.endDate
                )

                continuation.resume(returning: healthKitWeight)
            }

            healthStore.execute(query)
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
    /// Generic error for testing non-HealthKitError catch paths
    var mockGenericError: Error?

    var isHealthKitAvailable: Bool { mockIsAvailable }
    var authorizationStatus: HealthKitAuthorizationStatus { mockAuthorizationStatus }

    func requestAuthorization() async throws {
        if let error = mockGenericError {
            throw error
        }
        if let error = mockError {
            throw error
        }
        mockAuthorizationStatus = .authorized
    }

    func fetchLatestWeight() async throws -> HealthKitWeight? {
        if let error = mockGenericError {
            throw error
        }
        if let error = mockError {
            throw error
        }
        return mockWeight
    }
}
