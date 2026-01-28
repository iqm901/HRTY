import Foundation
import SwiftData

/// Service responsible for querying medication regimens at any point in time
/// and generating a complete timeline of medication changes.
final class MedicationHistoryService {

    // MARK: - Types

    /// Snapshot of a single medication at a specific point in time
    struct MedicationSnapshot: Identifiable {
        let id: UUID
        let medicationName: String
        let dosage: String
        let unit: String
        let schedule: String
        let isDiuretic: Bool
        let category: HeartFailureMedication.Category?
        let periodStartDate: Date

        /// Formatted dosage for display, e.g., "40 mg daily"
        var dosageDisplay: String {
            let scheduleText = schedule.isEmpty ? "" : " \(schedule)"
            return "\(dosage) \(unit)\(scheduleText)"
        }

        /// Short dosage display without schedule
        var shortDosageDisplay: String {
            "\(dosage) \(unit)"
        }
    }

    /// Full regimen (all medications) at a specific point in time
    struct RegimenSnapshot {
        let date: Date
        let medications: [MedicationSnapshot]

        /// Whether this snapshot has any medications
        var isEmpty: Bool {
            medications.isEmpty
        }

        /// Count of active medications
        var medicationCount: Int {
            medications.count
        }

        /// Formatted date for display
        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }

    /// Timeline event representing a medication change
    struct TimelineEvent: Identifiable {
        let id = UUID()
        let date: Date
        let medicationName: String
        let medicationId: PersistentIdentifier
        let eventType: EventType
        let details: String?
        let previousDosage: String?
        let newDosage: String?
        let category: HeartFailureMedication.Category?

        enum EventType: String, CaseIterable {
            case started = "Started"
            case doseChanged = "Dose Changed"
            case discontinued = "Discontinued"
            case reactivated = "Reactivated"

            var icon: String {
                switch self {
                case .started: return "plus.circle.fill"
                case .doseChanged: return "arrow.up.arrow.down.circle.fill"
                case .discontinued: return "xmark.circle.fill"
                case .reactivated: return "arrow.counterclockwise.circle.fill"
                }
            }

            var colorName: String {
                switch self {
                case .started: return "hrtGood"
                case .doseChanged: return "hrtWarning"
                case .discontinued: return "hrtBad"
                case .reactivated: return "hrtPink"
                }
            }
        }

        /// Formatted date for display
        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }

        /// Short date display (e.g., "Jan 15")
        var shortDate: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }

        /// Display text describing the change
        var changeDescription: String {
            switch eventType {
            case .started:
                if let newDosage = newDosage {
                    return "Started at \(newDosage)"
                }
                return "Started"
            case .doseChanged:
                if let prev = previousDosage, let new = newDosage {
                    return "\(prev) → \(new)"
                }
                return "Dose changed"
            case .discontinued:
                if let prev = previousDosage {
                    return "Stopped (\(prev))"
                }
                return "Discontinued"
            case .reactivated:
                if let newDosage = newDosage {
                    return "Resumed at \(newDosage)"
                }
                return "Reactivated"
            }
        }
    }

    // MARK: - Public Methods

    /// Get all medications that were active at a specific date
    /// - Parameters:
    ///   - date: The target date to query
    ///   - context: SwiftData model context
    /// - Returns: RegimenSnapshot containing all active medications at that date
    func getMedicationRegimen(asOf date: Date, context: ModelContext) -> RegimenSnapshot {
        let medications = fetchAllMedications(context: context)
        var snapshots: [MedicationSnapshot] = []

        for medication in medications {
            if let snapshot = getMedicationSnapshot(medication: medication, asOf: date) {
                snapshots.append(snapshot)
            }
        }

        // Sort: diuretics first, then alphabetically
        snapshots.sort { lhs, rhs in
            if lhs.isDiuretic != rhs.isDiuretic {
                return lhs.isDiuretic
            }
            return lhs.medicationName.localizedCaseInsensitiveCompare(rhs.medicationName) == .orderedAscending
        }

        return RegimenSnapshot(date: date, medications: snapshots)
    }

    /// Get complete timeline of all medication changes
    /// - Parameter context: SwiftData model context
    /// - Returns: Array of timeline events sorted by date (most recent first)
    func getMedicationTimeline(context: ModelContext) -> [TimelineEvent] {
        let medications = fetchAllMedications(context: context)
        var events: [TimelineEvent] = []

        for medication in medications {
            let medicationEvents = getTimelineEvents(for: medication)
            events.append(contentsOf: medicationEvents)
        }

        // Sort by date (most recent first)
        events.sort { $0.date > $1.date }

        return events
    }

    /// Get medication timeline for a specific date range
    /// - Parameters:
    ///   - startDate: Start of the date range
    ///   - endDate: End of the date range
    ///   - context: SwiftData model context
    /// - Returns: Array of timeline events within the date range
    func getMedicationTimeline(from startDate: Date, to endDate: Date, context: ModelContext) -> [TimelineEvent] {
        let allEvents = getMedicationTimeline(context: context)
        return allEvents.filter { event in
            event.date >= startDate && event.date <= endDate
        }
    }

    /// Compare two regimens and identify changes
    /// - Parameters:
    ///   - startRegimen: Regimen at the start of the period
    ///   - endRegimen: Regimen at the end of the period
    /// - Returns: Array of medication comparisons showing what changed
    func compareRegimens(
        start startRegimen: RegimenSnapshot,
        end endRegimen: RegimenSnapshot
    ) -> [MedicationComparison] {
        var comparisons: [MedicationComparison] = []

        // Create lookup by medication name
        let startMeds = Dictionary(
            uniqueKeysWithValues: startRegimen.medications.map { ($0.medicationName, $0) }
        )
        let endMeds = Dictionary(
            uniqueKeysWithValues: endRegimen.medications.map { ($0.medicationName, $0) }
        )

        // All medication names
        let allNames = Set(startMeds.keys).union(Set(endMeds.keys))

        for name in allNames.sorted() {
            let startMed = startMeds[name]
            let endMed = endMeds[name]

            let comparison: MedicationComparison

            if let start = startMed, let end = endMed {
                // Medication existed at both times
                let changeType: MedicationComparison.ChangeType
                if start.dosage == end.dosage && start.unit == end.unit {
                    changeType = .noChange
                } else if let startValue = parseDosageValue(start.dosage),
                          let endValue = parseDosageValue(end.dosage) {
                    changeType = endValue > startValue ? .increased : .decreased
                } else {
                    changeType = .changed
                }

                comparison = MedicationComparison(
                    medicationName: name,
                    startDosage: start.shortDosageDisplay,
                    endDosage: end.shortDosageDisplay,
                    changeType: changeType,
                    category: start.category ?? end.category
                )
            } else if let end = endMed {
                // Medication was started
                comparison = MedicationComparison(
                    medicationName: name,
                    startDosage: "Not taking",
                    endDosage: end.shortDosageDisplay,
                    changeType: .started,
                    category: end.category
                )
            } else if let start = startMed {
                // Medication was discontinued
                comparison = MedicationComparison(
                    medicationName: name,
                    startDosage: start.shortDosageDisplay,
                    endDosage: "Discontinued",
                    changeType: .discontinued,
                    category: start.category
                )
            } else {
                continue
            }

            comparisons.append(comparison)
        }

        // Sort: changes first, then by name
        comparisons.sort { lhs, rhs in
            let lhsChanged = lhs.changeType != .noChange
            let rhsChanged = rhs.changeType != .noChange
            if lhsChanged != rhsChanged {
                return lhsChanged
            }
            return lhs.medicationName.localizedCaseInsensitiveCompare(rhs.medicationName) == .orderedAscending
        }

        return comparisons
    }

    // MARK: - Private Methods

    private func fetchAllMedications(context: ModelContext) -> [Medication] {
        let descriptor = FetchDescriptor<Medication>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Get a snapshot of a single medication at a specific date
    private func getMedicationSnapshot(medication: Medication, asOf date: Date) -> MedicationSnapshot? {
        guard let periods = medication.periods, !periods.isEmpty else {
            // No periods - check if medication was created before the date and is active
            if medication.createdAt <= date {
                if medication.isActive || (medication.archivedAt != nil && medication.archivedAt! > date) {
                    return MedicationSnapshot(
                        id: UUID(),
                        medicationName: medication.name,
                        dosage: medication.dosage,
                        unit: medication.unit,
                        schedule: medication.schedule,
                        isDiuretic: medication.isDiuretic,
                        category: medication.category,
                        periodStartDate: medication.createdAt
                    )
                }
            }
            return nil
        }

        // Find the period that was active on the target date
        // A period is active if: startDate <= targetDate AND (endDate == nil OR endDate >= targetDate)
        let activePeriod = periods.first { period in
            let startedOnOrBefore = period.startDate <= date
            let notEndedYet = period.endDate == nil || period.endDate! >= date
            return startedOnOrBefore && notEndedYet
        }

        guard let period = activePeriod else {
            return nil
        }

        return MedicationSnapshot(
            id: UUID(),
            medicationName: medication.name,
            dosage: period.dosage,
            unit: period.unit,
            schedule: period.schedule,
            isDiuretic: medication.isDiuretic,
            category: medication.category,
            periodStartDate: period.startDate
        )
    }

    /// Get all timeline events for a single medication
    private func getTimelineEvents(for medication: Medication) -> [TimelineEvent] {
        guard let periods = medication.periods, !periods.isEmpty else {
            // Single event: medication started
            return [
                TimelineEvent(
                    date: medication.createdAt,
                    medicationName: medication.name,
                    medicationId: medication.id,
                    eventType: .started,
                    details: nil,
                    previousDosage: nil,
                    newDosage: "\(medication.dosage) \(medication.unit)",
                    category: medication.category
                )
            ]
        }

        var events: [TimelineEvent] = []
        let sortedPeriods = periods.sorted { $0.startDate < $1.startDate }

        for (index, period) in sortedPeriods.enumerated() {
            if index == 0 {
                // First period - medication started
                events.append(TimelineEvent(
                    date: period.startDate,
                    medicationName: medication.name,
                    medicationId: medication.id,
                    eventType: .started,
                    details: nil,
                    previousDosage: nil,
                    newDosage: "\(period.dosage) \(period.unit)",
                    category: medication.category
                ))
            } else {
                let previousPeriod = sortedPeriods[index - 1]

                // Check if there was a gap (medication was discontinued and reactivated)
                if let previousEnd = previousPeriod.endDate,
                   !Calendar.current.isDate(previousEnd, inSameDayAs: period.startDate) {
                    // Discontinued event
                    events.append(TimelineEvent(
                        date: previousEnd,
                        medicationName: medication.name,
                        medicationId: medication.id,
                        eventType: .discontinued,
                        details: nil,
                        previousDosage: "\(previousPeriod.dosage) \(previousPeriod.unit)",
                        newDosage: nil,
                        category: medication.category
                    ))

                    // Reactivated event
                    events.append(TimelineEvent(
                        date: period.startDate,
                        medicationName: medication.name,
                        medicationId: medication.id,
                        eventType: .reactivated,
                        details: nil,
                        previousDosage: nil,
                        newDosage: "\(period.dosage) \(period.unit)",
                        category: medication.category
                    ))
                } else {
                    // Dose change (continuous period)
                    events.append(TimelineEvent(
                        date: period.startDate,
                        medicationName: medication.name,
                        medicationId: medication.id,
                        eventType: .doseChanged,
                        details: nil,
                        previousDosage: "\(previousPeriod.dosage) \(previousPeriod.unit)",
                        newDosage: "\(period.dosage) \(period.unit)",
                        category: medication.category
                    ))
                }
            }
        }

        // Check if medication is currently archived (final discontinuation)
        if !medication.isActive, let archivedAt = medication.archivedAt {
            if let lastPeriod = sortedPeriods.last {
                // Only add discontinued event if we haven't already
                let hasDiscontinuedEvent = events.contains { event in
                    event.eventType == .discontinued &&
                    Calendar.current.isDate(event.date, inSameDayAs: archivedAt)
                }

                if !hasDiscontinuedEvent {
                    events.append(TimelineEvent(
                        date: archivedAt,
                        medicationName: medication.name,
                        medicationId: medication.id,
                        eventType: .discontinued,
                        details: nil,
                        previousDosage: "\(lastPeriod.dosage) \(lastPeriod.unit)",
                        newDosage: nil,
                        category: medication.category
                    ))
                }
            }
        }

        return events
    }

    /// Parse dosage string to extract numeric value for comparison
    private func parseDosageValue(_ dosage: String) -> Double? {
        // Handle combination dosages like "49/51"
        if dosage.contains("/") {
            let parts = dosage.split(separator: "/")
            if let first = parts.first, let value = Double(first) {
                return value
            }
        }
        return Double(dosage)
    }
}

// MARK: - Supporting Types

/// Comparison between two medication states for PDF export
struct MedicationComparison: Identifiable {
    let id = UUID()
    let medicationName: String
    let startDosage: String
    let endDosage: String
    let changeType: ChangeType
    let category: HeartFailureMedication.Category?

    enum ChangeType: String {
        case noChange = "No change"
        case increased = "Increased"
        case decreased = "Decreased"
        case changed = "Changed"
        case started = "Started"
        case discontinued = "Discontinued"

        var symbol: String {
            switch self {
            case .noChange: return "—"
            case .increased: return "↑"
            case .decreased: return "↓"
            case .changed: return "↔"
            case .started: return "+"
            case .discontinued: return "−"
            }
        }
    }

    /// Whether this medication had any change
    var hasChanged: Bool {
        changeType != .noChange
    }
}
