import XCTest
@testable import HRTY

final class OtherMedicationTests: XCTestCase {

    // MARK: - Category Tests

    func testAllCategoriesHaveMedications() {
        // Verify each category has at least one medication (except "other" which may be empty)
        for category in OtherMedicationCategory.allCases {
            if category == .other {
                continue // "other" category is a catch-all and may be empty
            }
            let meds = OtherMedication.allMedications.filter { $0.category == category }
            XCTAssertFalse(meds.isEmpty, "Category \(category.rawValue) should have medications")
        }
    }

    func testMedicationCountIsSubstantial() {
        // Verify we have a substantial medication database (80+ medications)
        XCTAssertGreaterThan(OtherMedication.allMedications.count, 80, "Should have over 80 medications")
    }

    // MARK: - Statin Tests

    func testStatinsExist() {
        let statins = OtherMedication.allMedications.filter { $0.category == .statin }
        XCTAssertFalse(statins.isEmpty)

        let genericNames = statins.map { $0.genericName.lowercased() }
        XCTAssertTrue(genericNames.contains("atorvastatin"))
        XCTAssertTrue(genericNames.contains("rosuvastatin"))
        XCTAssertTrue(genericNames.contains("simvastatin"))
    }

    func testAtorvastatinProperties() {
        let atorvastatin = OtherMedication.allMedications.first { $0.genericName == "Atorvastatin" }
        XCTAssertNotNil(atorvastatin)
        XCTAssertEqual(atorvastatin?.brandName, "Lipitor")
        XCTAssertEqual(atorvastatin?.category, .statin)
        XCTAssertTrue(atorvastatin?.availableDosages.contains("10") ?? false)
        XCTAssertTrue(atorvastatin?.availableDosages.contains("80") ?? false)
        XCTAssertFalse(atorvastatin?.isDiuretic ?? true)
    }

    // MARK: - Anticoagulant Tests

    func testAnticoagulantsExist() {
        let anticoagulants = OtherMedication.allMedications.filter { $0.category == .anticoagulant }
        XCTAssertFalse(anticoagulants.isEmpty)

        let genericNames = anticoagulants.map { $0.genericName.lowercased() }
        XCTAssertTrue(genericNames.contains("warfarin"))
        XCTAssertTrue(genericNames.contains("apixaban"))
        XCTAssertTrue(genericNames.contains("rivaroxaban"))
    }

    func testApixabanProperties() {
        let apixaban = OtherMedication.allMedications.first { $0.genericName == "Apixaban" }
        XCTAssertNotNil(apixaban)
        XCTAssertEqual(apixaban?.brandName, "Eliquis")
        XCTAssertEqual(apixaban?.defaultFrequency, "Twice daily")
        XCTAssertFalse(apixaban?.isDiuretic ?? true)
    }

    // MARK: - Antiplatelet Tests

    func testAntiplateletsExist() {
        let antiplatelets = OtherMedication.allMedications.filter { $0.category == .antiplatelet }
        XCTAssertFalse(antiplatelets.isEmpty)

        let genericNames = antiplatelets.map { $0.genericName.lowercased() }
        XCTAssertTrue(genericNames.contains { $0.contains("aspirin") })
        XCTAssertTrue(genericNames.contains("clopidogrel"))
        XCTAssertTrue(genericNames.contains("ticagrelor"))
    }

    // MARK: - Calcium Channel Blocker Tests

    func testDHPCCBsExist() {
        let dhpCCBs = OtherMedication.allMedications.filter { $0.category == .calciumChannelBlockerDHP }
        XCTAssertFalse(dhpCCBs.isEmpty)

        let genericNames = dhpCCBs.map { $0.genericName.lowercased() }
        XCTAssertTrue(genericNames.contains("amlodipine"))
        XCTAssertTrue(genericNames.contains("nifedipine"))
    }

    func testNonDHPCCBsExist() {
        let nonDHPCCBs = OtherMedication.allMedications.filter { $0.category == .calciumChannelBlockerNonDHP }
        XCTAssertFalse(nonDHPCCBs.isEmpty)

        let genericNames = nonDHPCCBs.map { $0.genericName.lowercased() }
        XCTAssertTrue(genericNames.contains("diltiazem"))
        XCTAssertTrue(genericNames.contains("verapamil"))
    }

    // MARK: - Antiarrhythmic Tests

    func testAntiarrhythmicsExist() {
        let antiarrhythmics = OtherMedication.allMedications.filter { $0.category == .antiarrhythmic }
        XCTAssertFalse(antiarrhythmics.isEmpty)

        let genericNames = antiarrhythmics.map { $0.genericName.lowercased() }
        XCTAssertTrue(genericNames.contains("amiodarone"))
        XCTAssertTrue(genericNames.contains("flecainide"))
        XCTAssertTrue(genericNames.contains("sotalol"))
    }

    // MARK: - Diuretic Tests (Additional)

    func testAdditionalDiureticsAreDiuretics() {
        let additionalDiuretics = OtherMedication.allMedications.filter { $0.category == .additionalDiuretic }
        XCTAssertFalse(additionalDiuretics.isEmpty)

        for diuretic in additionalDiuretics {
            XCTAssertTrue(diuretic.isDiuretic, "\(diuretic.genericName) should be marked as a diuretic")
        }
    }

    func testChlortalidoneProperties() {
        let chlorthalidone = OtherMedication.allMedications.first { $0.genericName == "Chlorthalidone" }
        XCTAssertNotNil(chlorthalidone)
        XCTAssertTrue(chlorthalidone?.isDiuretic ?? false)
        XCTAssertEqual(chlorthalidone?.category, .additionalDiuretic)
    }

    // MARK: - GLP-1 Agonist Tests

    func testGLP1AgonistsExist() {
        let glp1s = OtherMedication.allMedications.filter { $0.category == .glp1Agonist }
        XCTAssertFalse(glp1s.isEmpty)

        let genericNames = glp1s.map { $0.genericName.lowercased() }
        XCTAssertTrue(genericNames.contains { $0.contains("semaglutide") })
        XCTAssertTrue(genericNames.contains("liraglutide"))
        XCTAssertTrue(genericNames.contains("dulaglutide"))
        XCTAssertTrue(genericNames.contains("tirzepatide"))
    }

    func testSemaglutideWeeklyFrequency() {
        let semaglutideInjection = OtherMedication.allMedications.first { $0.genericName == "Semaglutide (injection)" }
        XCTAssertNotNil(semaglutideInjection)
        XCTAssertEqual(semaglutideInjection?.defaultFrequency, "Once weekly")
    }

    // MARK: - Pulmonary HTN Tests

    func testPulmonaryHTNMedsExist() {
        let pulmonaryHTNMeds = OtherMedication.allMedications.filter { $0.category == .pulmonaryHTN }
        XCTAssertFalse(pulmonaryHTNMeds.isEmpty)

        let genericNames = pulmonaryHTNMeds.map { $0.genericName.lowercased() }
        XCTAssertTrue(genericNames.contains("sildenafil"))
        XCTAssertTrue(genericNames.contains("bosentan"))
    }

    // MARK: - Display Name Tests

    func testDisplayNameWithBrandName() {
        let atorvastatin = OtherMedication.allMedications.first { $0.genericName == "Atorvastatin" }
        XCTAssertNotNil(atorvastatin)
        XCTAssertEqual(atorvastatin?.displayName, "Atorvastatin (Lipitor)")
    }

    func testDisplayNameWithoutBrandName() {
        // All medications in OtherMedication have brand names, but test the logic
        let medication = OtherMedication(
            genericName: "TestMed",
            brandName: nil,
            category: .other,
            availableDosages: ["10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        )
        XCTAssertEqual(medication.displayName, "TestMed")
    }

    // MARK: - Search Tests

    func testSearchByGenericName() {
        let results = OtherMedication.search(query: "atorva")
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.first?.genericName.lowercased().contains("atorva") ?? false)
    }

    func testSearchByBrandName() {
        let results = OtherMedication.search(query: "Lipitor")
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.first?.brandName?.lowercased().contains("lipitor") ?? false)
    }

    func testSearchCaseInsensitive() {
        let resultsLower = OtherMedication.search(query: "lipitor")
        let resultsUpper = OtherMedication.search(query: "LIPITOR")
        let resultsMixed = OtherMedication.search(query: "LiPiToR")

        XCTAssertFalse(resultsLower.isEmpty)
        XCTAssertFalse(resultsUpper.isEmpty)
        XCTAssertFalse(resultsMixed.isEmpty)
        XCTAssertEqual(resultsLower.first?.genericName, resultsUpper.first?.genericName)
        XCTAssertEqual(resultsLower.first?.genericName, resultsMixed.first?.genericName)
    }

    func testSearchPrioritizesExactPrefix() {
        let results = OtherMedication.search(query: "Ator")
        XCTAssertFalse(results.isEmpty)
        // First result should start with "Ator"
        if let first = results.first {
            XCTAssertTrue(
                first.genericName.lowercased().hasPrefix("ator") ||
                (first.brandName?.lowercased().hasPrefix("ator") ?? false)
            )
        }
    }

    func testSearchEmptyQuery() {
        let results = OtherMedication.search(query: "")
        XCTAssertTrue(results.isEmpty)
    }

    func testSearchWhitespaceQuery() {
        let results = OtherMedication.search(query: "   ")
        XCTAssertTrue(results.isEmpty)
    }

    func testSearchNoResults() {
        let results = OtherMedication.search(query: "zzzznonexistent")
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Medications By Category Tests

    func testMedicationsByCategoryNotEmpty() {
        let grouped = OtherMedication.medicationsByCategory
        XCTAssertFalse(grouped.isEmpty)
    }

    func testMedicationsByCategoryContainsStatins() {
        let grouped = OtherMedication.medicationsByCategory
        let statinGroup = grouped.first { $0.category == .statin }
        XCTAssertNotNil(statinGroup)
        XCTAssertFalse(statinGroup?.medications.isEmpty ?? true)
    }

    // MARK: - Known Diuretic Names Tests

    func testKnownDiureticNamesContainsDiuretics() {
        XCTAssertTrue(OtherMedication.knownDiureticNames.contains("chlorthalidone"))
        XCTAssertTrue(OtherMedication.knownDiureticNames.contains("hydrochlorothiazide"))
        XCTAssertTrue(OtherMedication.knownDiureticNames.contains("indapamide"))
    }

    func testKnownDiureticNamesDoesNotContainNonDiuretics() {
        XCTAssertFalse(OtherMedication.knownDiureticNames.contains("atorvastatin"))
        XCTAssertFalse(OtherMedication.knownDiureticNames.contains("lipitor"))
        XCTAssertFalse(OtherMedication.knownDiureticNames.contains("amiodarone"))
    }

    // MARK: - Unit Tests

    func testMostMedicationsUseMg() {
        let mgMeds = OtherMedication.allMedications.filter { $0.unit == "mg" }
        // Most medications should use mg
        XCTAssertGreaterThan(mgMeds.count, OtherMedication.allMedications.count / 2)
    }

    func testLevothyroxineUsesMcg() {
        let levothyroxine = OtherMedication.allMedications.first { $0.genericName == "Levothyroxine" }
        XCTAssertNotNil(levothyroxine)
        XCTAssertEqual(levothyroxine?.unit, "mcg")
    }

    func testPotassiumUsesMEq() {
        let potassium = OtherMedication.allMedications.first { $0.genericName == "Potassium chloride" }
        XCTAssertNotNil(potassium)
        XCTAssertEqual(potassium?.unit, "mEq")
    }

    // MARK: - Frequency Tests

    func testWeeklyMedicationsHaveCorrectFrequency() {
        let weeklyMeds = ["Semaglutide (injection)", "Dulaglutide", "Tirzepatide"]
        for medName in weeklyMeds {
            let med = OtherMedication.allMedications.first { $0.genericName == medName }
            XCTAssertNotNil(med, "\(medName) should exist")
            XCTAssertEqual(med?.defaultFrequency, "Once weekly", "\(medName) should be once weekly")
        }
    }

    func testTwiceDailyMedicationsHaveCorrectFrequency() {
        let twiceDailyMeds = ["Apixaban", "Dabigatran", "Ticagrelor"]
        for medName in twiceDailyMeds {
            let med = OtherMedication.allMedications.first { $0.genericName == medName }
            XCTAssertNotNil(med, "\(medName) should exist")
            XCTAssertEqual(med?.defaultFrequency, "Twice daily", "\(medName) should be twice daily")
        }
    }

    // MARK: - Unique ID Tests

    func testAllMedicationsHaveUniqueIDs() {
        let ids = OtherMedication.allMedications.map { $0.id }
        let uniqueIDs = Set(ids)
        XCTAssertEqual(ids.count, uniqueIDs.count, "All medication IDs should be unique")
    }

    // MARK: - Hashable Tests

    func testMedicationsAreHashable() {
        let med1 = OtherMedication.allMedications[0]
        let med2 = OtherMedication.allMedications[1]

        var set = Set<OtherMedication>()
        set.insert(med1)
        set.insert(med2)

        XCTAssertEqual(set.count, 2)
    }

    // MARK: - Coverage Tests

    func testDatabaseContainsStatins() {
        let statins = ["atorvastatin", "rosuvastatin", "simvastatin", "pravastatin", "lovastatin"]
        for med in statins {
            let found = OtherMedication.allMedications.contains { $0.genericName.lowercased() == med }
            XCTAssertTrue(found, "Missing statin: \(med)")
        }
    }

    func testDatabaseContainsAnticoagulants() {
        let anticoagulants = ["warfarin", "apixaban", "rivaroxaban", "dabigatran", "edoxaban"]
        for med in anticoagulants {
            let found = OtherMedication.allMedications.contains { $0.genericName.lowercased() == med }
            XCTAssertTrue(found, "Missing anticoagulant: \(med)")
        }
    }

    func testDatabaseContainsCalciumChannelBlockers() {
        let ccbs = ["amlodipine", "diltiazem", "verapamil", "nifedipine"]
        for med in ccbs {
            let found = OtherMedication.allMedications.contains { $0.genericName.lowercased() == med }
            XCTAssertTrue(found, "Missing CCB: \(med)")
        }
    }

    func testDatabaseContainsAntiarrhythmics() {
        let antiarrhythmics = ["amiodarone", "flecainide", "sotalol", "dronedarone"]
        for med in antiarrhythmics {
            let found = OtherMedication.allMedications.contains { $0.genericName.lowercased() == med }
            XCTAssertTrue(found, "Missing antiarrhythmic: \(med)")
        }
    }
}
