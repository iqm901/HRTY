import XCTest
@testable import HRTY

final class MedicationChangeAnalysisServiceTests: XCTestCase {

    // MARK: - MedicationChangeInsight Tests

    func testMedicationChangeInsightInitialization() {
        // Given: insight data
        let changeDate = Date()
        let observations = [
            ClinicalObservation(
                type: .lowBloodPressure,
                description: "Systolic BP below 100 mmHg on 3 days",
                severity: .notable
            )
        ]

        // When: creating an insight
        let insight = MedicationChangeInsight(
            medicationName: "Carvedilol",
            category: .betaBlocker,
            changeDate: changeDate,
            previousDosage: "25 mg twice daily",
            newDosage: "12.5 mg twice daily",
            changeType: .doseReduction,
            observations: observations,
            contextMessage: "Test context message"
        )

        // Then: values should be set correctly
        XCTAssertEqual(insight.medicationName, "Carvedilol")
        XCTAssertEqual(insight.category, .betaBlocker)
        XCTAssertEqual(insight.changeDate, changeDate)
        XCTAssertEqual(insight.previousDosage, "25 mg twice daily")
        XCTAssertEqual(insight.newDosage, "12.5 mg twice daily")
        XCTAssertEqual(insight.changeType, .doseReduction)
        XCTAssertEqual(insight.observations.count, 1)
        XCTAssertEqual(insight.contextMessage, "Test context message")
    }

    func testMedicationChangeInsightHasUniqueId() {
        // Given: two insights with same values
        let insight1 = MedicationChangeInsight(
            medicationName: "Test",
            category: nil,
            changeDate: Date(),
            previousDosage: nil,
            newDosage: nil,
            changeType: .started,
            observations: [],
            contextMessage: nil
        )
        let insight2 = MedicationChangeInsight(
            medicationName: "Test",
            category: nil,
            changeDate: Date(),
            previousDosage: nil,
            newDosage: nil,
            changeType: .started,
            observations: [],
            contextMessage: nil
        )

        // Then: IDs should be different
        XCTAssertNotEqual(insight1.id, insight2.id)
    }

    func testMedicationChangeInsightHasObservations() {
        // Given: insight with observations
        let insightWithObs = MedicationChangeInsight(
            medicationName: "Test",
            category: nil,
            changeDate: Date(),
            previousDosage: nil,
            newDosage: nil,
            changeType: .started,
            observations: [ClinicalObservation(type: .dizziness, description: "Test", severity: .notable)],
            contextMessage: nil
        )

        // Given: insight without observations
        let insightWithoutObs = MedicationChangeInsight(
            medicationName: "Test",
            category: nil,
            changeDate: Date(),
            previousDosage: nil,
            newDosage: nil,
            changeType: .started,
            observations: [],
            contextMessage: nil
        )

        // Then
        XCTAssertTrue(insightWithObs.hasObservations)
        XCTAssertFalse(insightWithoutObs.hasObservations)
    }

    // MARK: - Change Type Tests

    func testChangeTypeDoseReduction() {
        let insight = MedicationChangeInsight(
            medicationName: "Carvedilol",
            category: .betaBlocker,
            changeDate: Date(),
            previousDosage: "25 mg",
            newDosage: "12.5 mg",
            changeType: .doseReduction,
            observations: [],
            contextMessage: nil
        )

        XCTAssertEqual(insight.changeType, .doseReduction)
        XCTAssertTrue(insight.changeDescription.contains("→"))
    }

    func testChangeTypeDoseIncrease() {
        let insight = MedicationChangeInsight(
            medicationName: "Carvedilol",
            category: .betaBlocker,
            changeDate: Date(),
            previousDosage: "12.5 mg",
            newDosage: "25 mg",
            changeType: .doseIncrease,
            observations: [],
            contextMessage: nil
        )

        XCTAssertEqual(insight.changeType, .doseIncrease)
    }

    func testChangeTypeDiscontinued() {
        let insight = MedicationChangeInsight(
            medicationName: "Carvedilol",
            category: .betaBlocker,
            changeDate: Date(),
            previousDosage: "25 mg",
            newDosage: nil,
            changeType: .discontinued,
            observations: [],
            contextMessage: nil
        )

        XCTAssertEqual(insight.changeType, .discontinued)
        XCTAssertTrue(insight.changeDescription.contains("Discontinued"))
    }

    func testChangeTypeStarted() {
        let insight = MedicationChangeInsight(
            medicationName: "Carvedilol",
            category: .betaBlocker,
            changeDate: Date(),
            previousDosage: nil,
            newDosage: "6.25 mg",
            changeType: .started,
            observations: [],
            contextMessage: nil
        )

        XCTAssertEqual(insight.changeType, .started)
        XCTAssertTrue(insight.changeDescription.contains("Started"))
    }

    func testChangeTypeScheduleChange() {
        let insight = MedicationChangeInsight(
            medicationName: "Carvedilol",
            category: .betaBlocker,
            changeDate: Date(),
            previousDosage: "25 mg once daily",
            newDosage: "25 mg twice daily",
            changeType: .scheduleChange,
            observations: [],
            contextMessage: nil
        )

        XCTAssertEqual(insight.changeType, .scheduleChange)
    }

    // MARK: - Change Description Tests

    func testChangeDescriptionDoseReduction() {
        let insight = MedicationChangeInsight(
            medicationName: "Test",
            category: nil,
            changeDate: Date(),
            previousDosage: "50 mg",
            newDosage: "25 mg",
            changeType: .doseReduction,
            observations: [],
            contextMessage: nil
        )

        XCTAssertEqual(insight.changeDescription, "50 mg → 25 mg")
    }

    func testChangeDescriptionDiscontinuedWithPrevious() {
        let insight = MedicationChangeInsight(
            medicationName: "Test",
            category: nil,
            changeDate: Date(),
            previousDosage: "50 mg",
            newDosage: nil,
            changeType: .discontinued,
            observations: [],
            contextMessage: nil
        )

        XCTAssertEqual(insight.changeDescription, "50 mg → Discontinued")
    }

    func testChangeDescriptionDiscontinuedWithoutPrevious() {
        let insight = MedicationChangeInsight(
            medicationName: "Test",
            category: nil,
            changeDate: Date(),
            previousDosage: nil,
            newDosage: nil,
            changeType: .discontinued,
            observations: [],
            contextMessage: nil
        )

        XCTAssertEqual(insight.changeDescription, "Discontinued")
    }

    func testChangeDescriptionStartedWithDosage() {
        let insight = MedicationChangeInsight(
            medicationName: "Test",
            category: nil,
            changeDate: Date(),
            previousDosage: nil,
            newDosage: "25 mg",
            changeType: .started,
            observations: [],
            contextMessage: nil
        )

        XCTAssertEqual(insight.changeDescription, "Started at 25 mg")
    }

    func testChangeDescriptionStartedWithoutDosage() {
        let insight = MedicationChangeInsight(
            medicationName: "Test",
            category: nil,
            changeDate: Date(),
            previousDosage: nil,
            newDosage: nil,
            changeType: .started,
            observations: [],
            contextMessage: nil
        )

        XCTAssertEqual(insight.changeDescription, "Started")
    }

    // MARK: - Formatted Date Tests

    func testFormattedDate() {
        // Given: a specific date
        let calendar = Calendar.current
        let components = DateComponents(year: 2025, month: 1, day: 15)
        let date = calendar.date(from: components)!

        let insight = MedicationChangeInsight(
            medicationName: "Test",
            category: nil,
            changeDate: date,
            previousDosage: nil,
            newDosage: nil,
            changeType: .started,
            observations: [],
            contextMessage: nil
        )

        // Then: formatted date should contain the date components
        XCTAssertTrue(insight.formattedDate.contains("Jan") || insight.formattedDate.contains("15") || insight.formattedDate.contains("2025"))
    }

    // MARK: - ClinicalObservation Tests

    func testClinicalObservationInitialization() {
        let observation = ClinicalObservation(
            type: .lowBloodPressure,
            description: "Systolic BP below 100 mmHg on 3 days",
            severity: .significant
        )

        XCTAssertEqual(observation.type, .lowBloodPressure)
        XCTAssertEqual(observation.description, "Systolic BP below 100 mmHg on 3 days")
        XCTAssertEqual(observation.severity, .significant)
    }

    func testClinicalObservationHasUniqueId() {
        let obs1 = ClinicalObservation(type: .dizziness, description: "Test", severity: .notable)
        let obs2 = ClinicalObservation(type: .dizziness, description: "Test", severity: .notable)

        XCTAssertNotEqual(obs1.id, obs2.id)
    }

    func testClinicalObservationTypes() {
        // Test all observation types exist
        let types: [ClinicalObservation.ObservationType] = [
            .lowBloodPressure, .lowHeartRate, .lowMAP, .dizziness,
            .syncope, .reducedUrineOutput, .alert, .averageBP, .averageHR
        ]

        for type in types {
            let observation = ClinicalObservation(type: type, description: "Test", severity: .informational)
            XCTAssertEqual(observation.type, type)
        }
    }

    func testClinicalObservationSeverityLevels() {
        let informational = ClinicalObservation(type: .averageBP, description: "Test", severity: .informational)
        let notable = ClinicalObservation(type: .lowBloodPressure, description: "Test", severity: .notable)
        let significant = ClinicalObservation(type: .syncope, description: "Test", severity: .significant)

        XCTAssertEqual(informational.severity.rawValue, 1)
        XCTAssertEqual(notable.severity.rawValue, 2)
        XCTAssertEqual(significant.severity.rawValue, 3)
    }

    func testClinicalObservationSeverityDisplayColor() {
        XCTAssertEqual(ClinicalObservation.Severity.informational.displayColor, "secondary")
        XCTAssertEqual(ClinicalObservation.Severity.notable.displayColor, "orange")
        XCTAssertEqual(ClinicalObservation.Severity.significant.displayColor, "red")
    }

    // MARK: - VitalSignsSummary Tests

    func testVitalSignsSummaryInitialization() {
        let summary = VitalSignsSummary(
            averageSystolic: 95,
            averageDiastolic: 60,
            averageHeartRate: 55,
            lowBPDays: 3,
            lowHRDays: 2,
            lowMAPDays: 1,
            readingCount: 7
        )

        XCTAssertEqual(summary.averageSystolic, 95)
        XCTAssertEqual(summary.averageDiastolic, 60)
        XCTAssertEqual(summary.averageHeartRate, 55)
        XCTAssertEqual(summary.lowBPDays, 3)
        XCTAssertEqual(summary.lowHRDays, 2)
        XCTAssertEqual(summary.lowMAPDays, 1)
        XCTAssertEqual(summary.readingCount, 7)
    }

    func testVitalSignsSummaryFormattedAverageBP() {
        let summary = VitalSignsSummary(
            averageSystolic: 120,
            averageDiastolic: 80,
            averageHeartRate: nil,
            lowBPDays: 0,
            lowHRDays: 0,
            lowMAPDays: 0,
            readingCount: 5
        )

        XCTAssertEqual(summary.formattedAverageBP, "120/80 mmHg")
    }

    func testVitalSignsSummaryFormattedAverageBPNil() {
        let summary = VitalSignsSummary(
            averageSystolic: nil,
            averageDiastolic: nil,
            averageHeartRate: nil,
            lowBPDays: 0,
            lowHRDays: 0,
            lowMAPDays: 0,
            readingCount: 0
        )

        XCTAssertNil(summary.formattedAverageBP)
    }

    func testVitalSignsSummaryFormattedAverageHR() {
        let summary = VitalSignsSummary(
            averageSystolic: nil,
            averageDiastolic: nil,
            averageHeartRate: 72,
            lowBPDays: 0,
            lowHRDays: 0,
            lowMAPDays: 0,
            readingCount: 5
        )

        XCTAssertEqual(summary.formattedAverageHR, "72 bpm")
    }

    func testVitalSignsSummaryFormattedAverageHRNil() {
        let summary = VitalSignsSummary(
            averageSystolic: nil,
            averageDiastolic: nil,
            averageHeartRate: nil,
            lowBPDays: 0,
            lowHRDays: 0,
            lowMAPDays: 0,
            readingCount: 0
        )

        XCTAssertNil(summary.formattedAverageHR)
    }

    func testVitalSignsSummaryHasData() {
        let summaryWithData = VitalSignsSummary(
            averageSystolic: 120,
            averageDiastolic: 80,
            averageHeartRate: 72,
            lowBPDays: 0,
            lowHRDays: 0,
            lowMAPDays: 0,
            readingCount: 5
        )

        let summaryWithoutData = VitalSignsSummary(
            averageSystolic: nil,
            averageDiastolic: nil,
            averageHeartRate: nil,
            lowBPDays: 0,
            lowHRDays: 0,
            lowMAPDays: 0,
            readingCount: 0
        )

        XCTAssertTrue(summaryWithData.hasData)
        XCTAssertFalse(summaryWithoutData.hasData)
    }

    // MARK: - SymptomSummary Tests

    func testSymptomSummaryInitialization() {
        let summary = SymptomSummary(
            symptomType: .dizziness,
            daysReported: 4,
            maxSeverity: 4,
            averageSeverity: 3.5
        )

        XCTAssertEqual(summary.symptomType, .dizziness)
        XCTAssertEqual(summary.daysReported, 4)
        XCTAssertEqual(summary.maxSeverity, 4)
        XCTAssertEqual(summary.averageSeverity, 3.5)
    }

    func testSymptomSummaryIsNotable() {
        let notableSummary = SymptomSummary(
            symptomType: .dizziness,
            daysReported: 2,
            maxSeverity: 3,
            averageSeverity: 2.5
        )

        let notNotableSummary = SymptomSummary(
            symptomType: .dizziness,
            daysReported: 2,
            maxSeverity: 2,
            averageSeverity: 1.5
        )

        XCTAssertTrue(notableSummary.isNotable)
        XCTAssertFalse(notNotableSummary.isNotable)
    }

    func testSymptomSummaryIsSevere() {
        let severeSummary = SymptomSummary(
            symptomType: .syncope,
            daysReported: 1,
            maxSeverity: 4,
            averageSeverity: 4.0
        )

        let notSevereSummary = SymptomSummary(
            symptomType: .syncope,
            daysReported: 2,
            maxSeverity: 3,
            averageSeverity: 2.5
        )

        XCTAssertTrue(severeSummary.isSevere)
        XCTAssertFalse(notSevereSummary.isSevere)
    }

    // MARK: - AlertSummary Tests

    func testAlertSummaryInitialization() {
        let date = Date()
        let summary = AlertSummary(
            alertType: .lowBloodPressure,
            count: 3,
            mostRecentDate: date
        )

        XCTAssertEqual(summary.alertType, .lowBloodPressure)
        XCTAssertEqual(summary.count, 3)
        XCTAssertEqual(summary.mostRecentDate, date)
    }

    func testAlertSummaryFormattedDate() {
        let calendar = Calendar.current
        let components = DateComponents(year: 2025, month: 1, day: 8)
        let date = calendar.date(from: components)!

        let summary = AlertSummary(
            alertType: .heartRateLow,
            count: 1,
            mostRecentDate: date
        )

        // Then: formatted date should be readable
        XCTAssertFalse(summary.formattedDate.isEmpty)
        XCTAssertTrue(summary.formattedDate.contains("Jan") || summary.formattedDate.contains("8") || summary.formattedDate.contains("2025"))
    }

    // MARK: - Service Constants Tests

    func testLookbackDays() {
        XCTAssertEqual(MedicationChangeAnalysisService.lookbackDays, 14)
    }

    // MARK: - Insight Language Tests

    func testInsightLanguageIsPatientFriendly() {
        // Context messages should be warm and non-alarmist
        let contextMessages = [
            CardiovascularMedication.contextMessageTemplate(for: .betaBlocker, medicationName: "Carvedilol"),
            CardiovascularMedication.contextMessageTemplate(for: .arni, medicationName: "Entresto"),
            CardiovascularMedication.contextMessageTemplate(for: .mra, medicationName: "Spironolactone"),
            CardiovascularMedication.contextMessageTemplate(for: .loopDiuretic, medicationName: "Furosemide")
        ]

        for message in contextMessages {
            guard let msg = message else { continue }

            // Should mention care team
            XCTAssertTrue(msg.contains("care team"), "Message should mention care team: \(msg)")

            // Should not contain alarmist language
            XCTAssertFalse(msg.lowercased().contains("danger"), "Message should not contain 'danger': \(msg)")
            XCTAssertFalse(msg.lowercased().contains("emergency"), "Message should not contain 'emergency': \(msg)")
            XCTAssertFalse(msg.lowercased().contains("warning"), "Message should not contain 'warning': \(msg)")
            XCTAssertFalse(msg.lowercased().contains("critical"), "Message should not contain 'critical': \(msg)")
            XCTAssertFalse(msg.lowercased().contains("stop taking"), "Message should not say 'stop taking': \(msg)")
        }
    }
}
