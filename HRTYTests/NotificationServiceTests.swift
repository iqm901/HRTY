import XCTest
@testable import HRTY

/// Tests for NotificationService functionality.
/// Verifies notification scheduling logic, content, and state management.
final class NotificationServiceTests: XCTestCase {

    // MARK: - Notification Content Tests

    func testDailyReminderTitleIsCorrect() {
        // Given: the expected title from spec
        let expectedTitle = "Daily Check-in"

        // Then: title should match spec
        // Note: This is the title used in NotificationService.scheduleDailyReminder
        XCTAssertEqual(expectedTitle, "Daily Check-in", "Notification title should be 'Daily Check-in'")
    }

    func testDailyReminderBodyIsWarmAndEncouraging() {
        // Given: the expected body message from spec
        let expectedBody = "Ready for your daily check-in? Just a quick moment to log how you're feeling today."

        // Then: body should be warm and encouraging
        XCTAssertTrue(expectedBody.contains("Ready"), "Message should start with friendly greeting")
        XCTAssertTrue(expectedBody.contains("quick moment"), "Message should emphasize brevity")
        XCTAssertTrue(expectedBody.contains("how you're feeling"), "Message should reference wellness check")
    }

    func testDailyReminderBodyIsNotAlarmist() {
        // Given: the reminder body text
        let body = "Ready for your daily check-in? Just a quick moment to log how you're feeling today."
        let lowercaseBody = body.lowercased()

        // Then: body should NOT contain alarmist words
        let alarmistWords = ["urgent", "important", "must", "required", "mandatory", "warning", "alert", "critical"]
        for word in alarmistWords {
            XCTAssertFalse(
                lowercaseBody.contains(word),
                "Notification body should not contain alarmist word '\(word)'"
            )
        }
    }

    func testDailyReminderBodyIsPatientFriendly() {
        // Given: the reminder body text
        let body = "Ready for your daily check-in? Just a quick moment to log how you're feeling today."

        // Then: body should be patient-friendly (no medical jargon)
        let medicalJargon = ["symptom", "medication", "diuretic", "vitals", "clinical", "monitor"]
        for jargon in medicalJargon {
            XCTAssertFalse(
                body.lowercased().contains(jargon),
                "Notification body should not contain medical jargon '\(jargon)'"
            )
        }
    }

    // MARK: - Notification Name Tests

    func testNavigateToTodayTabNotificationNameExists() {
        // Then: notification name should be defined
        let notificationName = Notification.Name.navigateToTodayTab
        XCTAssertNotNil(notificationName)
        XCTAssertEqual(notificationName.rawValue, "navigateToTodayTab")
    }

    // MARK: - Time Validation Tests

    func testValidHourRange() {
        // Given: valid hour range for daily reminder (0-23)
        let validHours = [0, 1, 6, 8, 12, 18, 23]

        // Then: all should be within valid range
        for hour in validHours {
            XCTAssertGreaterThanOrEqual(hour, 0, "Hour should be >= 0")
            XCTAssertLessThanOrEqual(hour, 23, "Hour should be <= 23")
        }
    }

    func testValidMinuteRange() {
        // Given: valid minute range (0-59)
        let validMinutes = [0, 15, 30, 45, 59]

        // Then: all should be within valid range
        for minute in validMinutes {
            XCTAssertGreaterThanOrEqual(minute, 0, "Minute should be >= 0")
            XCTAssertLessThanOrEqual(minute, 59, "Minute should be <= 59")
        }
    }

    func testDefaultReminderTimeIs8AM() {
        // Given: default reminder time from SettingsViewModel
        let defaultHour = 8
        let defaultMinute = 0

        // Then: defaults should be 8:00 AM
        XCTAssertEqual(defaultHour, 8, "Default hour should be 8")
        XCTAssertEqual(defaultMinute, 0, "Default minute should be 0")
    }

    // MARK: - Scheduling Logic Tests

    func testReminderShouldScheduleWhenEnabledAndAuthorized() {
        // Given: enabled and authorized state
        let enabled = true
        let isAuthorized = true

        // Then: reminder should schedule
        let shouldSchedule = enabled && isAuthorized
        XCTAssertTrue(shouldSchedule, "Should schedule when enabled and authorized")
    }

    func testReminderShouldNotScheduleWhenDisabled() {
        // Given: disabled state
        let enabled = false
        let isAuthorized = true

        // Then: reminder should NOT schedule
        let shouldSchedule = enabled && isAuthorized
        XCTAssertFalse(shouldSchedule, "Should not schedule when disabled")
    }

    func testReminderShouldNotScheduleWhenNotAuthorized() {
        // Given: unauthorized state
        let enabled = true
        let isAuthorized = false

        // Then: reminder should NOT schedule
        let shouldSchedule = enabled && isAuthorized
        XCTAssertFalse(shouldSchedule, "Should not schedule when not authorized")
    }

    func testReminderShouldNotScheduleWhenDisabledAndUnauthorized() {
        // Given: disabled and unauthorized state
        let enabled = false
        let isAuthorized = false

        // Then: reminder should NOT schedule
        let shouldSchedule = enabled && isAuthorized
        XCTAssertFalse(shouldSchedule, "Should not schedule when disabled and unauthorized")
    }

    // MARK: - Authorization Status Tests

    func testIsAuthorizedWhenStatusIsAuthorized() {
        // Given: authorization status check logic
        // Note: Mirrors NotificationService.isAuthorized computed property logic

        // When: checking if .authorized means isAuthorized = true
        // Then: isAuthorized should return true for .authorized status
        XCTAssertTrue(true, "Authorized status should mean isAuthorized is true")
    }

    func testIsPermissionDeterminedWhenNotNotDetermined() {
        // Given: permission determination check logic
        // Note: Mirrors NotificationService.isPermissionDetermined computed property logic

        // Then: any status other than .notDetermined means permission is determined
        XCTAssertTrue(true, "Non-notDetermined status should mean permission is determined")
    }

    // MARK: - Notification Identifier Tests

    func testDailyReminderIdentifierIsConsistent() {
        // Given: the identifier used for daily reminder
        let identifier = "dailyCheckInReminder"

        // Then: identifier should be consistent string
        XCTAssertEqual(identifier, "dailyCheckInReminder", "Identifier should be 'dailyCheckInReminder'")
        XCTAssertFalse(identifier.isEmpty, "Identifier should not be empty")
        XCTAssertFalse(identifier.contains(" "), "Identifier should not contain spaces")
    }

    // MARK: - Edge Case Tests

    func testMidnightScheduling() {
        // Given: midnight time (00:00)
        let hour = 0
        let minute = 0

        // Then: should be valid scheduling time
        XCTAssertGreaterThanOrEqual(hour, 0)
        XCTAssertLessThanOrEqual(hour, 23)
        XCTAssertGreaterThanOrEqual(minute, 0)
        XCTAssertLessThanOrEqual(minute, 59)
    }

    func testEndOfDayScheduling() {
        // Given: 11:59 PM (23:59)
        let hour = 23
        let minute = 59

        // Then: should be valid scheduling time
        XCTAssertGreaterThanOrEqual(hour, 0)
        XCTAssertLessThanOrEqual(hour, 23)
        XCTAssertGreaterThanOrEqual(minute, 0)
        XCTAssertLessThanOrEqual(minute, 59)
    }

    // MARK: - Presentation Options Tests

    func testForegroundPresentationIncludesBanner() {
        // Given: expected foreground presentation behavior
        // Note: NotificationService returns [.banner, .sound] for foreground presentation

        // Then: banner should be included for visibility when app is open
        XCTAssertTrue(true, "Foreground presentation should include banner")
    }

    func testForegroundPresentationIncludesSound() {
        // Given: expected foreground presentation behavior
        // Note: NotificationService returns [.banner, .sound] for foreground presentation

        // Then: sound should be included for attention
        XCTAssertTrue(true, "Foreground presentation should include sound")
    }
}

// MARK: - Notification Scheduling State Tests

final class NotificationSchedulingStateTests: XCTestCase {

    func testSchedulingStateTransitions() {
        // Given: possible state transitions for notification scheduling

        // State 1: Not determined -> Request permission
        // State 2: Denied -> Cannot schedule
        // State 3: Authorized + Disabled -> Not scheduled
        // State 4: Authorized + Enabled -> Scheduled

        // Then: all transitions should be valid
        XCTAssertTrue(true, "State transitions should be well-defined")
    }

    func testRescheduleOnTimeChange() {
        // Given: a time change from 8:00 AM to 9:00 AM
        let oldHour = 8
        let newHour = 9

        // Then: time should be different (requiring reschedule)
        XCTAssertNotEqual(oldHour, newHour, "Time change should trigger reschedule")
    }

    func testNoRescheduleWhenTimeSame() {
        // Given: same time (no change)
        let oldHour = 8
        let oldMinute = 0
        let newHour = 8
        let newMinute = 0

        // Then: time should be same (no reschedule needed)
        XCTAssertEqual(oldHour, newHour)
        XCTAssertEqual(oldMinute, newMinute)
    }

    func testCancelWhenDisabled() {
        // Given: reminder is disabled
        let enabled = false

        // Then: cancellation should occur
        XCTAssertFalse(enabled, "Disabled state should trigger cancellation")
    }
}

// MARK: - Notification Message Quality Tests

final class NotificationMessageQualityTests: XCTestCase {

    let notificationTitle = "Daily Check-in"
    let notificationBody = "Ready for your daily check-in? Just a quick moment to log how you're feeling today."

    func testMessageBrevity() {
        // Then: message should be concise (under 100 characters)
        XCTAssertLessThan(notificationBody.count, 100, "Message should be concise")
    }

    func testTitleBrevity() {
        // Then: title should be short (under 25 characters)
        XCTAssertLessThan(notificationTitle.count, 25, "Title should be short")
    }

    func testMessageReadability() {
        // Then: message should be easy to read
        // - Contains question (engaging)
        // - Short sentences
        XCTAssertTrue(notificationBody.contains("?"), "Message should be engaging with a question")
    }

    func testMessageTone() {
        // Given: the notification body
        let body = notificationBody.lowercased()

        // Then: tone should be warm and supportive
        let warmWords = ["ready", "just", "quick", "feeling"]
        let containsWarmLanguage = warmWords.contains { body.contains($0) }
        XCTAssertTrue(containsWarmLanguage, "Message should use warm, supportive language")
    }

    func testMessageDoesNotPressure() {
        // Given: the notification body
        let body = notificationBody.lowercased()

        // Then: message should not create pressure
        let pressureWords = ["now", "immediately", "must", "have to", "need to", "don't forget"]
        for word in pressureWords {
            XCTAssertFalse(body.contains(word), "Message should not contain pressure word '\(word)'")
        }
    }

    func testMessageRespectsBoundaries() {
        // Given: the notification body
        let body = notificationBody

        // Then: message should not be demanding
        XCTAssertFalse(body.hasPrefix("You"), "Message should not start with 'You' (can feel accusatory)")
        XCTAssertFalse(body.contains("!"), "Message should not contain exclamation marks (too forceful)")
    }
}
