import Foundation
import SwiftData

@Model
final class DiureticDose {
    var dosageAmount: Double
    var timestamp: Date
    var isExtraDose: Bool
    var medication: Medication?
    var dailyEntry: DailyEntry?

    init(
        dosageAmount: Double,
        timestamp: Date = Date(),
        isExtraDose: Bool = false,
        medication: Medication? = nil,
        dailyEntry: DailyEntry? = nil
    ) {
        self.dosageAmount = dosageAmount
        self.timestamp = timestamp
        self.isExtraDose = isExtraDose
        self.medication = medication
        self.dailyEntry = dailyEntry
    }
}
