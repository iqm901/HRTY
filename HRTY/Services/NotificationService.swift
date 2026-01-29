import Foundation
import UserNotifications

/// Service for managing daily reminder notifications.
/// Handles permission requests, scheduling, and notification lifecycle.
@Observable
final class NotificationService: NSObject {
    // MARK: - Singleton

    static let shared = NotificationService()

    // MARK: - Properties

    /// Current notification authorization status
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    /// Identifier for the daily reminder notification
    private let dailyReminderIdentifier = "dailyCheckInReminder"

    /// The notification center instance
    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Initialization

    private override init() {
        super.init()
        notificationCenter.delegate = self
        Task {
            await refreshAuthorizationStatus()
        }
    }

    // MARK: - Permission Management

    /// Requests notification permission from the user.
    /// - Returns: `true` if permission was granted, `false` otherwise.
    @MainActor
    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            return false
        }
    }

    /// Refreshes the current authorization status from the system.
    func refreshAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            authorizationStatus = settings.authorizationStatus
        }
    }

    /// Whether notifications are authorized
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    /// Whether permission has been determined
    var isPermissionDetermined: Bool {
        authorizationStatus != .notDetermined
    }

    // MARK: - Scheduling

    /// Schedules a daily reminder notification at the specified time.
    /// - Parameters:
    ///   - hour: The hour component (0-23)
    ///   - minute: The minute component (0-59)
    func scheduleDailyReminder(hour: Int, minute: Int) async {
        // Cancel any existing reminder first
        cancelDailyReminder()

        // Create notification content with warm, encouraging message
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-in"
        content.body = "Ready for your daily check-in? Just a quick moment to log how you're feeling today."
        content.sound = .default

        // Create date components for the trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        // Create a repeating daily trigger
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        // Create and add the request
        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            // Silently fail - notification scheduling is best-effort
        }
    }

    /// Cancels the scheduled daily reminder notification.
    func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [dailyReminderIdentifier]
        )
    }

    /// Updates the reminder schedule based on the enabled state and time.
    /// - Parameters:
    ///   - enabled: Whether reminders should be enabled
    ///   - hour: The hour component (0-23)
    ///   - minute: The minute component (0-59)
    func updateReminderSchedule(enabled: Bool, hour: Int, minute: Int) async {
        if enabled && isAuthorized {
            await scheduleDailyReminder(hour: hour, minute: minute)
        } else {
            cancelDailyReminder()
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    /// Handles notification presentation when app is in foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Show banner and play sound even when app is open
        [.banner, .sound]
    }

    /// Handles notification tap to open app to Today view.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // Post notification to navigate to Today tab
        if response.notification.request.identifier == dailyReminderIdentifier {
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .navigateToTodayTab,
                    object: nil
                )
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted when the app should navigate to the Today tab.
    static let navigateToTodayTab = Notification.Name("navigateToTodayTab")
    /// Posted when the app should navigate to the My Heart tab.
    static let navigateToMyHeartTab = Notification.Name("navigateToMyHeartTab")
    /// Posted when the app should navigate to the Export tab.
    static let navigateToExportTab = Notification.Name("navigateToExportTab")
    /// Posted when the app should navigate to the Settings tab.
    static let navigateToSettingsTab = Notification.Name("navigateToSettingsTab")
}
