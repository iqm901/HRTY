import Foundation
import SwiftData

@Model
final class SymptomEntry {
    var symptomType: SymptomType
    var severity: Int
    var dailyEntry: DailyEntry?

    init(
        symptomType: SymptomType,
        severity: Int = 1,
        dailyEntry: DailyEntry? = nil
    ) {
        self.symptomType = symptomType
        self.severity = min(max(severity, 1), 5)
        self.dailyEntry = dailyEntry
    }
}
