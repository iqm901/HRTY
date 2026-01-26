import Foundation
import SwiftData

/// Tracks incomplete symptom check-in progress to allow users to resume later.
/// One record per day, stores responses as JSON-encoded Data.
@Model
final class SymptomCheckInProgress {
    /// The date this check-in is for (start of day)
    var date: Date

    /// Current step index (0-7, which symptom user is on)
    var currentStepIndex: Int

    /// JSON-encoded responses: [symptomType.rawValue: severity]
    var responsesData: Data?

    /// When the check-in was started
    var startedAt: Date

    /// When the check-in was last updated
    var updatedAt: Date

    /// Relationship to the daily entry
    @Relationship
    var dailyEntry: DailyEntry?

    init(
        date: Date = Date(),
        currentStepIndex: Int = 0,
        responsesData: Data? = nil,
        startedAt: Date = Date(),
        updatedAt: Date = Date(),
        dailyEntry: DailyEntry? = nil
    ) {
        self.date = Calendar.current.startOfDay(for: date)
        self.currentStepIndex = currentStepIndex
        self.responsesData = responsesData
        self.startedAt = startedAt
        self.updatedAt = updatedAt
        self.dailyEntry = dailyEntry
    }

    // MARK: - Computed Properties

    /// Decoded responses dictionary
    var responses: [SymptomType: Int] {
        get {
            guard let data = responsesData else { return [:] }
            do {
                let rawDict = try JSONDecoder().decode([String: Int].self, from: data)
                var result: [SymptomType: Int] = [:]
                for (key, value) in rawDict {
                    if let symptomType = SymptomType(rawValue: key) {
                        result[symptomType] = value
                    }
                }
                return result
            } catch {
                return [:]
            }
        }
        set {
            let rawDict = Dictionary(uniqueKeysWithValues: newValue.map { ($0.key.rawValue, $0.value) })
            responsesData = try? JSONEncoder().encode(rawDict)
        }
    }

    /// Number of completed responses
    var completedCount: Int {
        responses.count
    }

    /// Total number of symptoms to check
    static var totalSymptoms: Int {
        SymptomType.allCases.count
    }

    /// Whether all symptoms have been answered
    var isComplete: Bool {
        completedCount >= Self.totalSymptoms
    }

    /// Progress fraction (0.0 to 1.0)
    var progressFraction: Double {
        Double(completedCount) / Double(Self.totalSymptoms)
    }
}

// MARK: - Fetch Helpers

extension SymptomCheckInProgress {
    /// Fetch incomplete check-in progress for today
    static func fetchForToday(in context: ModelContext) -> SymptomCheckInProgress? {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = #Predicate<SymptomCheckInProgress> { progress in
            progress.date == startOfDay
        }
        var descriptor = FetchDescriptor<SymptomCheckInProgress>(predicate: predicate)
        descriptor.fetchLimit = 1

        return try? context.fetch(descriptor).first
    }

    /// Create a new check-in progress for today
    static func createForToday(in context: ModelContext, dailyEntry: DailyEntry? = nil) -> SymptomCheckInProgress {
        let progress = SymptomCheckInProgress(
            date: Date(),
            dailyEntry: dailyEntry
        )
        context.insert(progress)
        return progress
    }

    /// Get or create check-in progress for today
    static func getOrCreateForToday(in context: ModelContext, dailyEntry: DailyEntry? = nil) -> SymptomCheckInProgress {
        if let existing = fetchForToday(in: context) {
            return existing
        }
        return createForToday(in: context, dailyEntry: dailyEntry)
    }
}
