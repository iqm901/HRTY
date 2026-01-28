import XCTest
@testable import HRTY

final class AntiplateletRecommendationServiceTests: XCTestCase {

    // MARK: - No Procedures Tests

    func testNoProceduresReturnsNoRecommendation() {
        // Given: no procedures
        let procedures: [CoronaryProcedure] = []
        let medications: [Medication] = []

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: procedures,
            medications: medications
        )

        // Then: no recommendation should be made
        XCTAssertEqual(recommendation.recommendationType, .none)
        XCTAssertTrue(recommendation.missingMedications.isEmpty)
        XCTAssertFalse(recommendation.shouldShowWarning)
    }

    // MARK: - Recent Stent (DAPT) Tests

    func testRecentStentRequiresDAPT() {
        // Given: stent placed 6 months ago
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: sixMonthsAgo,
            dateIsUnknown: false
        )
        let medications: [Medication] = []

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: medications
        )

        // Then: DAPT should be recommended with both medications missing
        XCTAssertEqual(recommendation.recommendationType, .dapt)
        XCTAssertEqual(recommendation.missingMedications.count, 2)
        XCTAssertTrue(recommendation.missingMedications.contains(.aspirin))
        XCTAssertTrue(recommendation.missingMedications.contains(.p2y12))
        XCTAssertTrue(recommendation.shouldShowWarning)
    }

    func testRecentStentWithAspirinOnlyMissesP2Y12() {
        // Given: stent placed 3 months ago, patient on aspirin
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: threeMonthsAgo,
            dateIsUnknown: false
        )
        let aspirin = Medication(name: "Aspirin", dosage: "81", isActive: true)

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: [aspirin]
        )

        // Then: DAPT should be recommended with P2Y12 missing
        XCTAssertEqual(recommendation.recommendationType, .dapt)
        XCTAssertEqual(recommendation.missingMedications.count, 1)
        XCTAssertTrue(recommendation.missingMedications.contains(.p2y12))
        XCTAssertFalse(recommendation.missingMedications.contains(.aspirin))
        XCTAssertTrue(recommendation.shouldShowWarning)
    }

    func testRecentStentWithP2Y12OnlyMissesAspirin() {
        // Given: stent placed 3 months ago, patient on P2Y12
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: threeMonthsAgo,
            dateIsUnknown: false
        )
        let clopidogrel = Medication(name: "Clopidogrel", dosage: "75", isActive: true)

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: [clopidogrel]
        )

        // Then: DAPT should be recommended with aspirin missing
        XCTAssertEqual(recommendation.recommendationType, .dapt)
        XCTAssertEqual(recommendation.missingMedications.count, 1)
        XCTAssertTrue(recommendation.missingMedications.contains(.aspirin))
        XCTAssertFalse(recommendation.missingMedications.contains(.p2y12))
        XCTAssertTrue(recommendation.shouldShowWarning)
    }

    func testRecentStentWithBothMedicationsNoWarning() {
        // Given: stent placed 3 months ago, patient on both medications
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: threeMonthsAgo,
            dateIsUnknown: false
        )
        let aspirin = Medication(name: "Aspirin", dosage: "81", isActive: true)
        let ticagrelor = Medication(name: "Ticagrelor", dosage: "90", isActive: true)

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: [aspirin, ticagrelor]
        )

        // Then: DAPT recommended, but no missing medications
        XCTAssertEqual(recommendation.recommendationType, .dapt)
        XCTAssertTrue(recommendation.missingMedications.isEmpty)
        XCTAssertFalse(recommendation.shouldShowWarning)
    }

    // MARK: - Older Stent (Single Antiplatelet) Tests

    func testOldStentRequiresSingleAntiplatelet() {
        // Given: stent placed 18 months ago
        let eighteenMonthsAgo = Calendar.current.date(byAdding: .month, value: -18, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: eighteenMonthsAgo,
            dateIsUnknown: false
        )
        let medications: [Medication] = []

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: medications
        )

        // Then: single antiplatelet should be recommended
        XCTAssertEqual(recommendation.recommendationType, .singleAntiplatelet)
        XCTAssertTrue(recommendation.missingMedications.contains(.aspirin))
        XCTAssertTrue(recommendation.shouldShowWarning)
    }

    func testOldStentWithAspirinNoWarning() {
        // Given: stent placed 2 years ago, patient on aspirin
        let twoYearsAgo = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: twoYearsAgo,
            dateIsUnknown: false
        )
        let aspirin = Medication(name: "Aspirin", dosage: "81", isActive: true)

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: [aspirin]
        )

        // Then: single antiplatelet recommended, no missing medications
        XCTAssertEqual(recommendation.recommendationType, .singleAntiplatelet)
        XCTAssertTrue(recommendation.missingMedications.isEmpty)
        XCTAssertFalse(recommendation.shouldShowWarning)
    }

    func testOldStentWithP2Y12OnlyNoWarning() {
        // Given: stent placed 2 years ago, patient on P2Y12 only
        let twoYearsAgo = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: twoYearsAgo,
            dateIsUnknown: false
        )
        let plavix = Medication(name: "Plavix", dosage: "75", isActive: true)

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: [plavix]
        )

        // Then: single antiplatelet recommended, no missing medications
        XCTAssertEqual(recommendation.recommendationType, .singleAntiplatelet)
        XCTAssertTrue(recommendation.missingMedications.isEmpty)
        XCTAssertFalse(recommendation.shouldShowWarning)
    }

    // MARK: - Unknown Date Tests

    func testUnknownDateStentTreatedAsSingleAntiplatelet() {
        // Given: stent with unknown date
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: nil,
            dateIsUnknown: true
        )
        let medications: [Medication] = []

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: medications
        )

        // Then: single antiplatelet should be recommended (conservative approach)
        XCTAssertEqual(recommendation.recommendationType, .singleAntiplatelet)
        XCTAssertTrue(recommendation.shouldShowWarning)
    }

    // MARK: - CABG Tests

    func testCABGRequiresSingleAntiplatelet() {
        // Given: CABG done 6 months ago
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let cabg = CoronaryProcedure(
            procedureType: .cabg,
            procedureDate: sixMonthsAgo,
            dateIsUnknown: false
        )
        let medications: [Medication] = []

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [cabg],
            medications: medications
        )

        // Then: single antiplatelet should be recommended (CABG doesn't trigger DAPT)
        XCTAssertEqual(recommendation.recommendationType, .singleAntiplatelet)
        XCTAssertTrue(recommendation.shouldShowWarning)
    }

    func testCABGWithAspirinNoWarning() {
        // Given: CABG done 6 months ago, patient on aspirin
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let cabg = CoronaryProcedure(
            procedureType: .cabg,
            procedureDate: sixMonthsAgo,
            dateIsUnknown: false
        )
        let aspirin = Medication(name: "Baby Aspirin", dosage: "81", isActive: true)

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [cabg],
            medications: [aspirin]
        )

        // Then: single antiplatelet recommended, no missing medications
        XCTAssertEqual(recommendation.recommendationType, .singleAntiplatelet)
        XCTAssertTrue(recommendation.missingMedications.isEmpty)
        XCTAssertFalse(recommendation.shouldShowWarning)
    }

    // MARK: - Mixed Procedures Tests

    func testRecentStentWithOldCABGTriggersDAPT() {
        // Given: old CABG and recent stent
        let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!

        let cabg = CoronaryProcedure(
            procedureType: .cabg,
            procedureDate: fiveYearsAgo,
            dateIsUnknown: false
        )
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: sixMonthsAgo,
            dateIsUnknown: false
        )
        let medications: [Medication] = []

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [cabg, stent],
            medications: medications
        )

        // Then: DAPT should be recommended due to recent stent
        XCTAssertEqual(recommendation.recommendationType, .dapt)
        XCTAssertEqual(recommendation.missingMedications.count, 2)
    }

    func testMultipleOldProceduresRequireSingleAntiplatelet() {
        // Given: old CABG and old stent
        let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        let threeYearsAgo = Calendar.current.date(byAdding: .year, value: -3, to: Date())!

        let cabg = CoronaryProcedure(
            procedureType: .cabg,
            procedureDate: fiveYearsAgo,
            dateIsUnknown: false
        )
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: threeYearsAgo,
            dateIsUnknown: false
        )
        let medications: [Medication] = []

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [cabg, stent],
            medications: medications
        )

        // Then: single antiplatelet should be recommended
        XCTAssertEqual(recommendation.recommendationType, .singleAntiplatelet)
    }

    // MARK: - Medication Detection Tests

    func testDetectsAspirinVariants() {
        // Given: various aspirin brand names
        let aspirinVariants = [
            Medication(name: "Aspirin", dosage: "81", isActive: true),
            Medication(name: "Bayer Aspirin", dosage: "325", isActive: true),
            Medication(name: "Ecotrin", dosage: "81", isActive: true),
            Medication(name: "ASPIRIN Low Dose", dosage: "81", isActive: true)
        ]

        // Then: all should be detected as aspirin
        for medication in aspirinVariants {
            XCTAssertTrue(
                AntiplateletRecommendationService.hasAspirin(in: [medication]),
                "Should detect '\(medication.name)' as aspirin"
            )
        }
    }

    func testDetectsP2Y12Variants() {
        // Given: various P2Y12 inhibitor names
        let p2y12Variants = [
            Medication(name: "Clopidogrel", dosage: "75", isActive: true),
            Medication(name: "Plavix", dosage: "75", isActive: true),
            Medication(name: "Ticagrelor", dosage: "90", isActive: true),
            Medication(name: "Brilinta", dosage: "90", isActive: true),
            Medication(name: "Prasugrel", dosage: "10", isActive: true),
            Medication(name: "Effient", dosage: "10", isActive: true),
            Medication(name: "CLOPIDOGREL 75mg", dosage: "75", isActive: true)
        ]

        // Then: all should be detected as P2Y12 inhibitors
        for medication in p2y12Variants {
            XCTAssertTrue(
                AntiplateletRecommendationService.hasP2Y12Inhibitor(in: [medication]),
                "Should detect '\(medication.name)' as P2Y12 inhibitor"
            )
        }
    }

    func testIgnoresInactiveMedications() {
        // Given: inactive aspirin
        let inactiveAspirin = Medication(name: "Aspirin", dosage: "81", isActive: false)

        // Then: should not be detected
        XCTAssertFalse(AntiplateletRecommendationService.hasAspirin(in: [inactiveAspirin]))
    }

    func testNonAntiplateletMedicationsNotDetected() {
        // Given: non-antiplatelet medications
        let otherMeds = [
            Medication(name: "Lisinopril", dosage: "10", isActive: true),
            Medication(name: "Metoprolol", dosage: "25", isActive: true),
            Medication(name: "Atorvastatin", dosage: "40", isActive: true)
        ]

        // Then: should not be detected as antiplatelet
        XCTAssertFalse(AntiplateletRecommendationService.hasAspirin(in: otherMeds))
        XCTAssertFalse(AntiplateletRecommendationService.hasP2Y12Inhibitor(in: otherMeds))
    }

    // MARK: - Edge Case Tests

    func testExactlyTwelveMonthsAgoIsDAPT() {
        // Given: stent placed exactly 12 months ago
        let twelveMonthsAgo = Calendar.current.date(byAdding: .month, value: -12, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: twelveMonthsAgo,
            dateIsUnknown: false
        )
        let medications: [Medication] = []

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: medications
        )

        // Then: should still be DAPT (within 12 months means >= 12 months ago is the cutoff)
        XCTAssertEqual(recommendation.recommendationType, .dapt)
    }

    func testThirteenMonthsAgoIsSingleAntiplatelet() {
        // Given: stent placed 13 months ago
        let thirteenMonthsAgo = Calendar.current.date(byAdding: .month, value: -13, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: thirteenMonthsAgo,
            dateIsUnknown: false
        )
        let medications: [Medication] = []

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: medications
        )

        // Then: should be single antiplatelet
        XCTAssertEqual(recommendation.recommendationType, .singleAntiplatelet)
    }

    // MARK: - Detail Message Tests

    func testDAPTDetailMessageIsAppropriate() {
        // Given: recent stent with no medications
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: sixMonthsAgo,
            dateIsUnknown: false
        )

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: []
        )

        // Then: detail message should mention 12 months and both medications
        XCTAssertNotNil(recommendation.detailMessage)
        XCTAssertTrue(recommendation.detailMessage?.contains("12 months") ?? false)
        XCTAssertTrue(recommendation.detailMessage?.contains("aspirin") ?? false)
        XCTAssertTrue(recommendation.detailMessage?.contains("P2Y12") ?? false)
    }

    func testSingleAntiplateletDetailMessageIsAppropriate() {
        // Given: old stent with no medications
        let twoYearsAgo = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: twoYearsAgo,
            dateIsUnknown: false
        )

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: []
        )

        // Then: detail message should mention antiplatelet
        XCTAssertNotNil(recommendation.detailMessage)
        XCTAssertTrue(recommendation.detailMessage?.contains("antiplatelet") ?? false)
    }

    func testNoWarningMessageWhenMedicationsComplete() {
        // Given: recent stent with complete DAPT
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let stent = CoronaryProcedure(
            procedureType: .stent,
            procedureDate: sixMonthsAgo,
            dateIsUnknown: false
        )
        let aspirin = Medication(name: "Aspirin", dosage: "81", isActive: true)
        let ticagrelor = Medication(name: "Ticagrelor", dosage: "90", isActive: true)

        // When: evaluating recommendation
        let recommendation = AntiplateletRecommendationService.evaluate(
            procedures: [stent],
            medications: [aspirin, ticagrelor]
        )

        // Then: no warning or detail message needed
        XCTAssertNil(recommendation.warningMessage)
        XCTAssertNil(recommendation.detailMessage)
    }
}
