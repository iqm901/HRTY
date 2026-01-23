import Foundation
import SwiftUI

/// View model for the onboarding flow.
/// Manages page navigation and permission requests.
@Observable
final class OnboardingViewModel {
    // MARK: - Pages

    enum Page: Int, CaseIterable {
        case welcome = 0
        case healthKit = 1
        case notifications = 2
        case medications = 3
    }

    // MARK: - Properties

    var currentPage: Page = .welcome
    var isRequestingPermission = false
    var healthKitGranted = false
    var notificationsGranted = false
    var showMedicationForm = false

    // MARK: - Services

    private let healthKitService: HealthKitServiceProtocol
    private let notificationService: NotificationService

    // MARK: - Callbacks

    var onComplete: (() -> Void)?

    // MARK: - Computed Properties

    var isHealthKitAvailable: Bool {
        healthKitService.isAvailable
    }

    var totalPages: Int {
        Page.allCases.count
    }

    var progress: Double {
        Double(currentPage.rawValue) / Double(totalPages - 1)
    }

    // MARK: - Initialization

    init(
        healthKitService: HealthKitServiceProtocol = HealthKitService(),
        notificationService: NotificationService = .shared
    ) {
        self.healthKitService = healthKitService
        self.notificationService = notificationService
    }

    // MARK: - Navigation

    func nextPage() {
        guard let nextPage = Page(rawValue: currentPage.rawValue + 1) else {
            completeOnboarding()
            return
        }
        currentPage = nextPage
    }

    func skip() {
        nextPage()
    }

    // MARK: - Permission Requests

    @MainActor
    func requestHealthKitPermission() async {
        isRequestingPermission = true
        healthKitGranted = await healthKitService.requestAuthorization()
        isRequestingPermission = false
        nextPage()
    }

    @MainActor
    func requestNotificationPermission() async {
        isRequestingPermission = true
        notificationsGranted = await notificationService.requestPermission()
        isRequestingPermission = false
        nextPage()
    }

    // MARK: - Medication Setup

    func addMedications() {
        showMedicationForm = true
    }

    func skipMedications() {
        completeOnboarding()
    }

    func medicationFormDismissed() {
        showMedicationForm = false
        completeOnboarding()
    }

    // MARK: - Completion

    private func completeOnboarding() {
        onComplete?()
    }
}
