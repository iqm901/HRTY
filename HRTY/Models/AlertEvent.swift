import Foundation
import SwiftData

@Model
final class AlertEvent {
    var alertType: AlertType
    var message: String
    var triggeredAt: Date
    var isAcknowledged: Bool
    var relatedDailyEntry: DailyEntry?

    init(
        alertType: AlertType,
        message: String,
        triggeredAt: Date = Date(),
        isAcknowledged: Bool = false,
        relatedDailyEntry: DailyEntry? = nil
    ) {
        self.alertType = alertType
        self.message = message
        self.triggeredAt = triggeredAt
        self.isAcknowledged = isAcknowledged
        self.relatedDailyEntry = relatedDailyEntry
    }
}
