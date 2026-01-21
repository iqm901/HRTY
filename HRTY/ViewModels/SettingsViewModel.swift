import Foundation
import SwiftUI

@Observable
final class SettingsViewModel {
    // MARK: - Reminder Settings
    @ObservationIgnored
    @AppStorage("reminderEnabled") var reminderEnabled: Bool = false

    @ObservationIgnored
    @AppStorage("reminderHour") private var reminderHour: Int = 8

    @ObservationIgnored
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    // MARK: - Patient Identifier
    @ObservationIgnored
    @AppStorage("patientIdentifier") var patientIdentifier: String = ""

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
}
