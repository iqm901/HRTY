import Foundation
import SwiftData

/// Service responsible for analyzing medication changes and correlating them with clinical data.
/// Generates insights for the PDF export to help patients discuss medication adjustments with their care team.
final class MedicationChangeAnalysisService {

    // MARK: - Constants

    /// Number of days to look back before a medication change for clinical context
    static let lookbackDays: Int = 14

    /// Thresholds for identifying concerning patterns
    private enum Thresholds {
        static let lowSystolicBP: Int = 100
        static let lowHeartRate: Int = 60
        static let lowMAP: Int = 65
        static let notableSymptomSeverity: Int = 3
        static let severeSymptomSeverity: Int = 4
    }

    // MARK: - Public Methods

    /// Analyze medication changes within a date range and generate insights
    /// - Parameters:
    ///   - startDate: Start of the analysis period
    ///   - endDate: End of the analysis period
    ///   - context: SwiftData model context for querying data
    /// - Returns: Array of medication change insights with clinical context
    func analyzeChanges(
        from startDate: Date,
        to endDate: Date,
        context: ModelContext
    ) -> [MedicationChangeInsight] {
        // Fetch all medications with their periods
        let medications = fetchMedications(context: context)

        var insights: [MedicationChangeInsight] = []

        for medication in medications {
            // Find medication changes within the date range
            let changes = findChangesInRange(
                medication: medication,
                from: startDate,
                to: endDate
            )

            for change in changes {
                // Gather clinical context for each change
                let insight = analyzeChange(
                    change: change,
                    medication: medication,
                    context: context
                )

                if let insight = insight {
                    insights.append(insight)
                }
            }
        }

        // Sort by date (most recent first)
        return insights.sorted { $0.changeDate > $1.changeDate }
    }

    // MARK: - Private Methods

    private func fetchMedications(context: ModelContext) -> [Medication] {
        let descriptor = FetchDescriptor<Medication>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Identify medication changes within a date range
    private func findChangesInRange(
        medication: Medication,
        from startDate: Date,
        to endDate: Date
    ) -> [DetectedChange] {
        guard let periods = medication.periods, periods.count > 0 else {
            return []
        }

        var changes: [DetectedChange] = []
        let sortedPeriods = periods.sorted { $0.startDate < $1.startDate }

        for (index, period) in sortedPeriods.enumerated() {
            // Check if this period started within our date range
            let startInRange = period.startDate >= startDate && period.startDate <= endDate

            // Check if this period ended within our date range
            let endInRange = period.endDate != nil &&
                             period.endDate! >= startDate &&
                             period.endDate! <= endDate

            if startInRange && index > 0 {
                // This is a change from a previous period
                let previousPeriod = sortedPeriods[index - 1]
                let changeType = determineChangeType(
                    from: previousPeriod,
                    to: period
                )

                changes.append(DetectedChange(
                    date: period.startDate,
                    changeType: changeType,
                    previousDosage: "\(previousPeriod.dosage) \(previousPeriod.unit) \(previousPeriod.schedule)",
                    newDosage: "\(period.dosage) \(period.unit) \(period.schedule)"
                ))
            } else if startInRange && index == 0 {
                // First period started in range - this is a new medication
                changes.append(DetectedChange(
                    date: period.startDate,
                    changeType: .started,
                    previousDosage: nil,
                    newDosage: "\(period.dosage) \(period.unit) \(period.schedule)"
                ))
            }

            // Check if discontinued within range
            if endInRange && index == sortedPeriods.count - 1 && !medication.isActive {
                changes.append(DetectedChange(
                    date: period.endDate!,
                    changeType: .discontinued,
                    previousDosage: "\(period.dosage) \(period.unit) \(period.schedule)",
                    newDosage: nil
                ))
            }
        }

        return changes
    }

    /// Determine the type of change between two periods
    private func determineChangeType(
        from previous: MedicationPeriod,
        to current: MedicationPeriod
    ) -> MedicationChangeInsight.ChangeType {
        // Try to parse dosage as numbers for comparison
        let prevValue = parseDosageValue(previous.dosage)
        let currValue = parseDosageValue(current.dosage)

        if let prev = prevValue, let curr = currValue {
            if curr < prev {
                return .doseReduction
            } else if curr > prev {
                return .doseIncrease
            }
        }

        // Dosage changed but not numerically comparable, or schedule changed
        if previous.dosage != current.dosage || previous.unit != current.unit {
            // String comparison fallback
            if current.dosage < previous.dosage {
                return .doseReduction
            } else if current.dosage > previous.dosage {
                return .doseIncrease
            }
        }

        return .scheduleChange
    }

    /// Parse dosage string to extract numeric value
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

    /// Analyze a specific change and generate insight with clinical context
    private func analyzeChange(
        change: DetectedChange,
        medication: Medication,
        context: ModelContext
    ) -> MedicationChangeInsight? {
        // Get the cardiovascular effects of this medication
        let effects = CardiovascularMedication.effects(for: medication.name)
        let category = medication.category

        // Skip medications we can't analyze (no known CV effects and no category)
        guard effects != nil || category != nil else {
            return nil
        }

        // Calculate lookback period
        let lookbackStart = Calendar.current.date(
            byAdding: .day,
            value: -Self.lookbackDays,
            to: change.date
        ) ?? change.date

        // Gather clinical data from the lookback period
        let dailyEntries = DailyEntry.fetchForDateRange(
            from: lookbackStart,
            to: change.date,
            in: context
        )

        // Generate observations based on medication type
        let observations = generateObservations(
            for: medication,
            effects: effects,
            category: category,
            entries: dailyEntries
        )

        // Generate context message
        let contextMessage = CardiovascularMedication.contextMessageTemplate(
            for: category,
            medicationName: medication.name
        )

        return MedicationChangeInsight(
            medicationName: medication.name,
            category: category,
            changeDate: change.date,
            previousDosage: change.previousDosage,
            newDosage: change.newDosage,
            changeType: change.changeType,
            observations: observations,
            contextMessage: observations.isEmpty ? nil : contextMessage
        )
    }

    /// Generate clinical observations based on medication type and available data
    private func generateObservations(
        for medication: Medication,
        effects: CardiovascularMedication.Effects?,
        category: HeartFailureMedication.Category?,
        entries: [DailyEntry]
    ) -> [ClinicalObservation] {
        var observations: [ClinicalObservation] = []

        // Determine what to check based on effects and category
        let checkBP = effects?.contains(.lowersBP) ?? false ||
                      category == .betaBlocker || category == .arni ||
                      category == .aceInhibitor || category == .arb ||
                      category == .mra || category == .sglt2Inhibitor ||
                      category == .loopDiuretic || category == .thiazideDiuretic

        let checkHR = effects?.contains(.lowersHR) ?? false ||
                      category == .betaBlocker

        let checkUrine = effects?.contains(.diuretic) ?? false ||
                         medication.isDiuretic || category == .sglt2Inhibitor

        // Analyze vital signs
        let vitalsSummary = analyzeVitalSigns(entries: entries, checkBP: checkBP, checkHR: checkHR)

        if checkBP {
            // Blood pressure observations
            if let avgBP = vitalsSummary.formattedAverageBP, vitalsSummary.readingCount > 0 {
                let severity: ClinicalObservation.Severity =
                    (vitalsSummary.averageSystolic ?? 999) < Thresholds.lowSystolicBP ? .notable : .informational

                observations.append(ClinicalObservation(
                    type: .averageBP,
                    description: "Blood pressure readings averaged \(avgBP) (\(vitalsSummary.readingCount) readings)",
                    severity: severity
                ))
            }

            if vitalsSummary.lowBPDays > 0 {
                observations.append(ClinicalObservation(
                    type: .lowBloodPressure,
                    description: "Systolic BP below \(Thresholds.lowSystolicBP) mmHg on \(vitalsSummary.lowBPDays) day\(vitalsSummary.lowBPDays == 1 ? "" : "s")",
                    severity: vitalsSummary.lowBPDays >= 3 ? .significant : .notable
                ))
            }

            if vitalsSummary.lowMAPDays > 0 {
                observations.append(ClinicalObservation(
                    type: .lowMAP,
                    description: "Mean arterial pressure below \(Thresholds.lowMAP) mmHg on \(vitalsSummary.lowMAPDays) day\(vitalsSummary.lowMAPDays == 1 ? "" : "s")",
                    severity: .significant
                ))
            }
        }

        if checkHR {
            // Heart rate observations
            if let avgHR = vitalsSummary.formattedAverageHR, vitalsSummary.readingCount > 0 {
                let severity: ClinicalObservation.Severity =
                    (vitalsSummary.averageHeartRate ?? 999) < Thresholds.lowHeartRate ? .notable : .informational

                observations.append(ClinicalObservation(
                    type: .averageHR,
                    description: "Heart rate averaged \(avgHR)",
                    severity: severity
                ))
            }

            if vitalsSummary.lowHRDays > 0 {
                observations.append(ClinicalObservation(
                    type: .lowHeartRate,
                    description: "Heart rate below \(Thresholds.lowHeartRate) bpm on \(vitalsSummary.lowHRDays) day\(vitalsSummary.lowHRDays == 1 ? "" : "s")",
                    severity: vitalsSummary.lowHRDays >= 3 ? .significant : .notable
                ))
            }
        }

        // Analyze symptoms
        let symptomSummaries = analyzeSymptoms(entries: entries)

        // Dizziness (relevant for BP and HR medications)
        if checkBP || checkHR {
            if let dizziness = symptomSummaries.first(where: { $0.symptomType == .dizziness }),
               dizziness.isNotable {
                observations.append(ClinicalObservation(
                    type: .dizziness,
                    description: "Dizziness reported at severity \(dizziness.maxSeverity) on \(dizziness.daysReported) day\(dizziness.daysReported == 1 ? "" : "s")",
                    severity: dizziness.isSevere ? .significant : .notable
                ))
            }

            if let syncope = symptomSummaries.first(where: { $0.symptomType == .syncope }),
               syncope.daysReported > 0 && syncope.maxSeverity > 1 {
                observations.append(ClinicalObservation(
                    type: .syncope,
                    description: "Fainting/near-fainting reported at severity \(syncope.maxSeverity) on \(syncope.daysReported) day\(syncope.daysReported == 1 ? "" : "s")",
                    severity: .significant
                ))
            }
        }

        // Reduced urine output (relevant for diuretics and SGLT2i)
        if checkUrine {
            if let urineOutput = symptomSummaries.first(where: { $0.symptomType == .reducedUrineOutput }),
               urineOutput.isNotable {
                observations.append(ClinicalObservation(
                    type: .reducedUrineOutput,
                    description: "Reduced urine output reported at severity \(urineOutput.maxSeverity) on \(urineOutput.daysReported) day\(urineOutput.daysReported == 1 ? "" : "s")",
                    severity: urineOutput.isSevere ? .significant : .notable
                ))
            }
        }

        // Analyze alerts
        let alertSummaries = analyzeAlerts(entries: entries)

        for alertSummary in alertSummaries {
            // Only include relevant alerts based on medication type
            let isRelevant: Bool
            switch alertSummary.alertType {
            case .lowBloodPressure, .lowMAP:
                isRelevant = checkBP
            case .heartRateLow:
                isRelevant = checkHR
            case .dizzinessBPCheck:
                isRelevant = checkBP
            default:
                isRelevant = false
            }

            if isRelevant {
                observations.append(ClinicalObservation(
                    type: .alert,
                    description: "\(alertSummary.alertType.displayName) alert triggered on \(alertSummary.formattedDate)",
                    severity: .notable
                ))
            }
        }

        // Special note for MRAs (limited analysis due to no K+ tracking)
        if category == .mra && observations.isEmpty {
            observations.append(ClinicalObservation(
                type: .alert,
                description: "Lab values (potassium, kidney function) are not tracked in this app",
                severity: .informational
            ))
        }

        return observations
    }

    /// Analyze vital signs from daily entries
    private func analyzeVitalSigns(
        entries: [DailyEntry],
        checkBP: Bool,
        checkHR: Bool
    ) -> VitalSignsSummary {
        var systolicValues: [Int] = []
        var diastolicValues: [Int] = []
        var heartRateValues: [Int] = []
        var lowBPDays = 0
        var lowHRDays = 0
        var lowMAPDays = 0

        for entry in entries {
            guard let vitals = entry.vitalSigns else { continue }

            if let systolic = vitals.systolicBP, let diastolic = vitals.diastolicBP {
                systolicValues.append(systolic)
                diastolicValues.append(diastolic)

                if systolic < Thresholds.lowSystolicBP {
                    lowBPDays += 1
                }

                if let map = vitals.meanArterialPressure, map < Thresholds.lowMAP {
                    lowMAPDays += 1
                }
            }

            if let hr = vitals.heartRate {
                heartRateValues.append(hr)
                if hr < Thresholds.lowHeartRate {
                    lowHRDays += 1
                }
            }
        }

        let avgSystolic = systolicValues.isEmpty ? nil : systolicValues.reduce(0, +) / systolicValues.count
        let avgDiastolic = diastolicValues.isEmpty ? nil : diastolicValues.reduce(0, +) / diastolicValues.count
        let avgHR = heartRateValues.isEmpty ? nil : heartRateValues.reduce(0, +) / heartRateValues.count

        return VitalSignsSummary(
            averageSystolic: avgSystolic,
            averageDiastolic: avgDiastolic,
            averageHeartRate: avgHR,
            lowBPDays: lowBPDays,
            lowHRDays: lowHRDays,
            lowMAPDays: lowMAPDays,
            readingCount: max(systolicValues.count, heartRateValues.count)
        )
    }

    /// Analyze symptoms from daily entries
    private func analyzeSymptoms(entries: [DailyEntry]) -> [SymptomSummary] {
        var symptomData: [SymptomType: (days: Int, maxSeverity: Int, totalSeverity: Int)] = [:]

        for entry in entries {
            guard let symptoms = entry.symptoms else { continue }

            for symptom in symptoms {
                if var existing = symptomData[symptom.symptomType] {
                    existing.days += 1
                    existing.maxSeverity = max(existing.maxSeverity, symptom.severity)
                    existing.totalSeverity += symptom.severity
                    symptomData[symptom.symptomType] = existing
                } else {
                    symptomData[symptom.symptomType] = (
                        days: 1,
                        maxSeverity: symptom.severity,
                        totalSeverity: symptom.severity
                    )
                }
            }
        }

        return symptomData.map { type, data in
            SymptomSummary(
                symptomType: type,
                daysReported: data.days,
                maxSeverity: data.maxSeverity,
                averageSeverity: Double(data.totalSeverity) / Double(data.days)
            )
        }
    }

    /// Analyze alerts from daily entries
    private func analyzeAlerts(entries: [DailyEntry]) -> [AlertSummary] {
        var alertData: [AlertType: (count: Int, mostRecent: Date)] = [:]

        for entry in entries {
            guard let alerts = entry.alertEvents else { continue }

            for alert in alerts {
                if var existing = alertData[alert.alertType] {
                    existing.count += 1
                    if alert.triggeredAt > existing.mostRecent {
                        existing.mostRecent = alert.triggeredAt
                    }
                    alertData[alert.alertType] = existing
                } else {
                    alertData[alert.alertType] = (count: 1, mostRecent: alert.triggeredAt)
                }
            }
        }

        return alertData.map { type, data in
            AlertSummary(
                alertType: type,
                count: data.count,
                mostRecentDate: data.mostRecent
            )
        }.sorted { $0.mostRecentDate > $1.mostRecentDate }
    }
}

// MARK: - Supporting Types

/// Internal struct for tracking detected medication changes
private struct DetectedChange {
    let date: Date
    let changeType: MedicationChangeInsight.ChangeType
    let previousDosage: String?
    let newDosage: String?
}
