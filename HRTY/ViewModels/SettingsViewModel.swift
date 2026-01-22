import Foundation
import SwiftUI

@Observable
final class SettingsViewModel {
    // MARK: - Reminder Settings
    @ObservationIgnored
    @AppStorage(AppStorageKeys.reminderEnabled) var reminderEnabled: Bool = false {
        didSet {
            Task {
                await updateNotificationSchedule()
            }
        }
    }

    @ObservationIgnored
    @AppStorage(AppStorageKeys.reminderHour) private var reminderHour: Int = 8

    @ObservationIgnored
    @AppStorage(AppStorageKeys.reminderMinute) private var reminderMinute: Int = 0

    // MARK: - Notification Service
    private let notificationService = NotificationService.shared

    // MARK: - Patient Identifier
    @ObservationIgnored
    @AppStorage(AppStorageKeys.patientIdentifier) var patientIdentifier: String = ""

    // MARK: - Computed Properties

    /// The reminder time as a Date for use with DatePicker
    var reminderTime: Date {
        get {
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? 8
            reminderMinute = components.minute ?? 0
            Task {
                await updateNotificationSchedule()
            }
        }
    }

    /// Formatted reminder time for display
    var formattedReminderTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: reminderTime)
    }

    /// App version from Bundle
    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    /// Build number from Bundle
    var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    /// Combined version string
    var versionString: String {
        "Version \(appVersion) (\(buildNumber))"
    }

    // MARK: - Methods

    /// Clear the patient identifier
    func clearPatientIdentifier() {
        patientIdentifier = ""
    }

    /// Reset reminder to default time (8:00 AM)
    func resetReminderToDefault() {
        reminderHour = 8
        reminderMinute = 0
    }

    // MARK: - Notification Methods

    /// Requests notification permission and enables reminders if granted.
    @MainActor
    func requestNotificationPermission() async {
        let granted = await notificationService.requestPermission()
        if granted {
            await updateNotificationSchedule()
        } else {
            // If permission denied, disable the toggle
            reminderEnabled = false
        }
    }

    /// Updates the notification schedule based on current settings.
    private func updateNotificationSchedule() async {
        await notificationService.updateReminderSchedule(
            enabled: reminderEnabled,
            hour: reminderHour,
            minute: reminderMinute
        )
    }

    /// Whether notification permission has been determined.
    var isNotificationPermissionDetermined: Bool {
        notificationService.isPermissionDetermined
    }

    /// Whether notifications are currently authorized.
    var isNotificationAuthorized: Bool {
        notificationService.isAuthorized
    }
}
