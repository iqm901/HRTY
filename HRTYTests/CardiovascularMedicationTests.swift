import XCTest
@testable import HRTY

final class CardiovascularMedicationTests: XCTestCase {

    // MARK: - Effects OptionSet Tests

    func testEffectsLowersBP() {
        let effects: CardiovascularMedication.Effects = [.lowersBP]
        XCTAssertTrue(effects.contains(.lowersBP))
        XCTAssertFalse(effects.contains(.lowersHR))
        XCTAssertFalse(effects.contains(.diuretic))
    }

    func testEffectsLowersHR() {
        let effects: CardiovascularMedication.Effects = [.lowersHR]
        XCTAssertFalse(effects.contains(.lowersBP))
        XCTAssertTrue(effects.contains(.lowersHR))
        XCTAssertFalse(effects.contains(.diuretic))
    }

    func testEffectsDiuretic() {
        let effects: CardiovascularMedication.Effects = [.diuretic]
        XCTAssertFalse(effects.contains(.lowersBP))
        XCTAssertFalse(effects.contains(.lowersHR))
        XCTAssertTrue(effects.contains(.diuretic))
    }

    func testEffectsBPAndHR() {
        let effects = CardiovascularMedication.Effects.bpAndHR
        XCTAssertTrue(effects.contains(.lowersBP))
        XCTAssertTrue(effects.contains(.lowersHR))
        XCTAssertFalse(effects.contains(.diuretic))
    }

    func testEffectsBPAndDiuretic() {
        let effects = CardiovascularMedication.Effects.bpAndDiuretic
        XCTAssertTrue(effects.contains(.lowersBP))
        XCTAssertFalse(effects.contains(.lowersHR))
        XCTAssertTrue(effects.contains(.diuretic))
    }

    func testEffectsDescription() {
        let bpOnly: CardiovascularMedication.Effects = [.lowersBP]
        XCTAssertEqual(bpOnly.description, "BP")

        let hrOnly: CardiovascularMedication.Effects = [.lowersHR]
        XCTAssertEqual(hrOnly.description, "HR")

        let bpAndHR = CardiovascularMedication.Effects.bpAndHR
        XCTAssertTrue(bpAndHR.description.contains("BP"))
        XCTAssertTrue(bpAndHR.description.contains("HR"))
    }

    // MARK: - Beta Blocker Tests

    func testCarvedilolEffects() {
        let effects = CardiovascularMedication.effects(for: "Carvedilol")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.lowersHR))
    }

    func testMetoprololEffects() {
        let effects = CardiovascularMedication.effects(for: "metoprolol")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.lowersHR))
    }

    func testBisoprolol() {
        let effects = CardiovascularMedication.effects(for: "Bisoprolol")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.lowersHR))
    }

    func testCoregBrandName() {
        let effects = CardiovascularMedication.effects(for: "Coreg")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.lowersHR))
    }

    // MARK: - ARNI Tests

    func testEntrestoEffects() {
        let effects = CardiovascularMedication.effects(for: "Entresto")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertFalse(effects!.contains(.lowersHR))
    }

    func testSacubitrilValsartanEffects() {
        let effects = CardiovascularMedication.effects(for: "sacubitril/valsartan")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
    }

    // MARK: - ACE Inhibitor Tests

    func testLisinoprilEffects() {
        let effects = CardiovascularMedication.effects(for: "Lisinopril")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertFalse(effects!.contains(.lowersHR))
    }

    func testEnalaprilEffects() {
        let effects = CardiovascularMedication.effects(for: "enalapril")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
    }

    // MARK: - ARB Tests

    func testLosartanEffects() {
        let effects = CardiovascularMedication.effects(for: "Losartan")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertFalse(effects!.contains(.lowersHR))
    }

    func testValsartanEffects() {
        let effects = CardiovascularMedication.effects(for: "valsartan")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
    }

    // MARK: - MRA Tests

    func testSpironolactoneEffects() {
        let effects = CardiovascularMedication.effects(for: "Spironolactone")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.diuretic))
        XCTAssertFalse(effects!.contains(.lowersHR))
    }

    func testEplerenoneEffects() {
        let effects = CardiovascularMedication.effects(for: "eplerenone")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.diuretic))
    }

    // MARK: - SGLT2 Inhibitor Tests

    func testDapagliflozinEffects() {
        let effects = CardiovascularMedication.effects(for: "Dapagliflozin")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertFalse(effects!.contains(.diuretic))
    }

    func testEmpagliflozinEffects() {
        let effects = CardiovascularMedication.effects(for: "empagliflozin")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
    }

    func testFarxigaBrandName() {
        let effects = CardiovascularMedication.effects(for: "Farxiga")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
    }

    // MARK: - Loop Diuretic Tests

    func testFurosemideEffects() {
        let effects = CardiovascularMedication.effects(for: "Furosemide")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.diuretic))
        XCTAssertFalse(effects!.contains(.lowersHR))
    }

    func testLasixBrandName() {
        let effects = CardiovascularMedication.effects(for: "Lasix")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.diuretic))
    }

    func testTorsemideEffects() {
        let effects = CardiovascularMedication.effects(for: "torsemide")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.diuretic))
    }

    // MARK: - Calcium Channel Blocker Tests

    func testDiltiazemEffects() {
        let effects = CardiovascularMedication.effects(for: "Diltiazem")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.lowersHR))
    }

    func testVerapamilEffects() {
        let effects = CardiovascularMedication.effects(for: "Verapamil")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.lowersHR))
    }

    func testAmlodipineEffects() {
        // DHP CCB - only lowers BP, not HR
        let effects = CardiovascularMedication.effects(for: "Amlodipine")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertFalse(effects!.contains(.lowersHR))
    }

    func testNifedipineEffects() {
        let effects = CardiovascularMedication.effects(for: "nifedipine")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertFalse(effects!.contains(.lowersHR))
    }

    // MARK: - Rate Control Tests

    func testDigoxinEffects() {
        let effects = CardiovascularMedication.effects(for: "Digoxin")
        XCTAssertNotNil(effects)
        XCTAssertFalse(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.lowersHR))
    }

    func testIvabradineEffects() {
        let effects = CardiovascularMedication.effects(for: "Ivabradine")
        XCTAssertNotNil(effects)
        XCTAssertFalse(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.lowersHR))
    }

    func testAmiodaroneEffects() {
        let effects = CardiovascularMedication.effects(for: "Amiodarone")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersHR))
    }

    // MARK: - Vasodilator Tests

    func testHydralazineEffects() {
        let effects = CardiovascularMedication.effects(for: "Hydralazine")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertFalse(effects!.contains(.lowersHR))
    }

    func testIsosorbideDinitrateEffects() {
        let effects = CardiovascularMedication.effects(for: "Isosorbide dinitrate")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
    }

    // MARK: - Case Insensitivity Tests

    func testCaseInsensitivityUppercase() {
        let effects = CardiovascularMedication.effects(for: "CARVEDILOL")
        XCTAssertNotNil(effects)
    }

    func testCaseInsensitivityLowercase() {
        let effects = CardiovascularMedication.effects(for: "carvedilol")
        XCTAssertNotNil(effects)
    }

    func testCaseInsensitivityMixedCase() {
        let effects = CardiovascularMedication.effects(for: "CarVeDiLoL")
        XCTAssertNotNil(effects)
    }

    // MARK: - Partial Match Tests

    func testPartialMatchWithDosage() {
        let effects = CardiovascularMedication.effects(for: "Carvedilol 25mg")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.lowersBP))
        XCTAssertTrue(effects!.contains(.lowersHR))
    }

    func testPartialMatchWithBrandAndGeneric() {
        let effects = CardiovascularMedication.effects(for: "Lasix (furosemide)")
        XCTAssertNotNil(effects)
        XCTAssertTrue(effects!.contains(.diuretic))
    }

    func testPartialMatchWithSchedule() {
        let effects = CardiovascularMedication.effects(for: "metoprolol succinate twice daily")
        XCTAssertNotNil(effects)
    }

    // MARK: - Unknown Medication Tests

    func testUnknownMedicationReturnsNil() {
        let effects = CardiovascularMedication.effects(for: "Aspirin")
        XCTAssertNil(effects)
    }

    func testUnknownMedicationEmptyString() {
        let effects = CardiovascularMedication.effects(for: "")
        XCTAssertNil(effects)
    }

    func testUnknownMedicationWhitespace() {
        let effects = CardiovascularMedication.effects(for: "   ")
        XCTAssertNil(effects)
    }

    // MARK: - Convenience Methods Tests

    func testAffectsBloodPressureTrue() {
        XCTAssertTrue(CardiovascularMedication.affectsBloodPressure("Carvedilol"))
        XCTAssertTrue(CardiovascularMedication.affectsBloodPressure("Lisinopril"))
        XCTAssertTrue(CardiovascularMedication.affectsBloodPressure("Furosemide"))
    }

    func testAffectsBloodPressureFalse() {
        XCTAssertFalse(CardiovascularMedication.affectsBloodPressure("Digoxin"))
        XCTAssertFalse(CardiovascularMedication.affectsBloodPressure("Unknown Drug"))
    }

    func testAffectsHeartRateTrue() {
        XCTAssertTrue(CardiovascularMedication.affectsHeartRate("Carvedilol"))
        XCTAssertTrue(CardiovascularMedication.affectsHeartRate("Digoxin"))
        XCTAssertTrue(CardiovascularMedication.affectsHeartRate("Diltiazem"))
    }

    func testAffectsHeartRateFalse() {
        XCTAssertFalse(CardiovascularMedication.affectsHeartRate("Lisinopril"))
        XCTAssertFalse(CardiovascularMedication.affectsHeartRate("Amlodipine"))
        XCTAssertFalse(CardiovascularMedication.affectsHeartRate("Unknown Drug"))
    }

    func testIsDiureticTrue() {
        XCTAssertTrue(CardiovascularMedication.isDiuretic("Furosemide"))
        XCTAssertTrue(CardiovascularMedication.isDiuretic("Spironolactone"))
        XCTAssertTrue(CardiovascularMedication.isDiuretic("Metolazone"))
    }

    func testIsDiureticFalse() {
        XCTAssertFalse(CardiovascularMedication.isDiuretic("Carvedilol"))
        XCTAssertFalse(CardiovascularMedication.isDiuretic("Lisinopril"))
        XCTAssertFalse(CardiovascularMedication.isDiuretic("Unknown Drug"))
    }

    // MARK: - Relevant Parameters Tests

    func testRelevantParametersBetaBlocker() {
        let params = CardiovascularMedication.relevantParameters(for: "Carvedilol")
        XCTAssertTrue(params.checkBP)
        XCTAssertTrue(params.checkHR)
        XCTAssertFalse(params.checkUrine)
    }

    func testRelevantParametersACEInhibitor() {
        let params = CardiovascularMedication.relevantParameters(for: "Lisinopril")
        XCTAssertTrue(params.checkBP)
        XCTAssertFalse(params.checkHR)
        XCTAssertFalse(params.checkUrine)
    }

    func testRelevantParametersDiuretic() {
        let params = CardiovascularMedication.relevantParameters(for: "Furosemide")
        XCTAssertTrue(params.checkBP)
        XCTAssertFalse(params.checkHR)
        XCTAssertTrue(params.checkUrine)
    }

    func testRelevantParametersDigoxin() {
        let params = CardiovascularMedication.relevantParameters(for: "Digoxin")
        XCTAssertFalse(params.checkBP)
        XCTAssertTrue(params.checkHR)
        XCTAssertFalse(params.checkUrine)
    }

    func testRelevantParametersUnknown() {
        let params = CardiovascularMedication.relevantParameters(for: "Unknown")
        XCTAssertFalse(params.checkBP)
        XCTAssertFalse(params.checkHR)
        XCTAssertFalse(params.checkUrine)
    }

    // MARK: - Context Message Template Tests

    func testContextMessageBetaBlocker() {
        let message = CardiovascularMedication.contextMessageTemplate(
            for: .betaBlocker,
            medicationName: "Carvedilol"
        )
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.contains("beta-blocker"))
        XCTAssertTrue(message!.contains("care team"))
    }

    func testContextMessageARNI() {
        let message = CardiovascularMedication.contextMessageTemplate(
            for: .arni,
            medicationName: "Entresto"
        )
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.contains("hypotension"))
        XCTAssertTrue(message!.contains("ARNI"))
    }

    func testContextMessageMRA() {
        let message = CardiovascularMedication.contextMessageTemplate(
            for: .mra,
            medicationName: "Spironolactone"
        )
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.contains("lab values"))
    }

    func testContextMessageSGLT2() {
        let message = CardiovascularMedication.contextMessageTemplate(
            for: .sglt2Inhibitor,
            medicationName: "Dapagliflozin"
        )
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.contains("SGLT2"))
    }

    func testContextMessageFallbackBPAndHR() {
        // Unknown category but known medication with BP + HR effects
        let message = CardiovascularMedication.contextMessageTemplate(
            for: nil,
            medicationName: "Carvedilol"
        )
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.contains("heart rate") || message!.contains("blood pressure"))
    }

    func testContextMessageFallbackBPOnly() {
        let message = CardiovascularMedication.contextMessageTemplate(
            for: nil,
            medicationName: "Amlodipine"
        )
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.lowercased().contains("blood pressure"))
    }

    func testContextMessageFallbackHROnly() {
        let message = CardiovascularMedication.contextMessageTemplate(
            for: nil,
            medicationName: "Digoxin"
        )
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.lowercased().contains("heart rate"))
    }

    func testContextMessageUnknownMedication() {
        let message = CardiovascularMedication.contextMessageTemplate(
            for: nil,
            medicationName: "Unknown Medication"
        )
        XCTAssertNil(message)
    }

    // MARK: - Database Coverage Tests

    func testDatabaseContainsBetaBlockers() {
        let betaBlockers = ["carvedilol", "metoprolol", "bisoprolol", "atenolol", "propranolol"]
        for med in betaBlockers {
            XCTAssertNotNil(CardiovascularMedication.effects(for: med), "Missing beta blocker: \(med)")
        }
    }

    func testDatabaseContainsACEInhibitors() {
        let aceInhibitors = ["lisinopril", "enalapril", "ramipril", "captopril", "benazepril"]
        for med in aceInhibitors {
            XCTAssertNotNil(CardiovascularMedication.effects(for: med), "Missing ACE inhibitor: \(med)")
        }
    }

    func testDatabaseContainsARBs() {
        let arbs = ["losartan", "valsartan", "candesartan", "irbesartan", "olmesartan"]
        for med in arbs {
            XCTAssertNotNil(CardiovascularMedication.effects(for: med), "Missing ARB: \(med)")
        }
    }

    func testDatabaseContainsDiuretics() {
        let diuretics = ["furosemide", "torsemide", "bumetanide", "metolazone", "hydrochlorothiazide"]
        for med in diuretics {
            XCTAssertNotNil(CardiovascularMedication.effects(for: med), "Missing diuretic: \(med)")
            XCTAssertTrue(CardiovascularMedication.isDiuretic(med), "Should be marked as diuretic: \(med)")
        }
    }

    func testDatabaseContainsSGLT2Inhibitors() {
        let sglt2i = ["dapagliflozin", "empagliflozin", "canagliflozin", "sotagliflozin"]
        for med in sglt2i {
            XCTAssertNotNil(CardiovascularMedication.effects(for: med), "Missing SGLT2i: \(med)")
        }
    }
}
