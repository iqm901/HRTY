import Foundation

/// Expanded medication database for cardiovascular effect analysis.
/// Maps medications to their effects on blood pressure and heart rate.
enum CardiovascularMedication {

    // MARK: - Effects OptionSet

    /// Effects a medication can have on cardiovascular parameters
    struct Effects: OptionSet, Hashable {
        let rawValue: Int

        static let lowersBP = Effects(rawValue: 1 << 0)
        static let lowersHR = Effects(rawValue: 1 << 1)
        static let diuretic = Effects(rawValue: 1 << 2)

        /// Common combinations
        static let bpAndHR: Effects = [.lowersBP, .lowersHR]
        static let bpAndDiuretic: Effects = [.lowersBP, .diuretic]

        var description: String {
            var effects: [String] = []
            if contains(.lowersBP) { effects.append("BP") }
            if contains(.lowersHR) { effects.append("HR") }
            if contains(.diuretic) { effects.append("diuretic") }
            return effects.isEmpty ? "none" : effects.joined(separator: ", ")
        }
    }

    // MARK: - Medication Database

    /// Database of medications and their cardiovascular effects.
    /// Keys are lowercase medication names (generic and brand).
    static let database: [String: Effects] = [
        // MARK: Beta Blockers (HR + BP)
        "carvedilol": .bpAndHR,
        "coreg": .bpAndHR,
        "metoprolol": .bpAndHR,
        "metoprolol succinate": .bpAndHR,
        "toprol": .bpAndHR,
        "toprol-xl": .bpAndHR,
        "bisoprolol": .bpAndHR,
        "zebeta": .bpAndHR,
        "atenolol": .bpAndHR,
        "tenormin": .bpAndHR,
        "propranolol": .bpAndHR,
        "inderal": .bpAndHR,
        "nadolol": .bpAndHR,
        "corgard": .bpAndHR,
        "labetalol": .bpAndHR,
        "trandate": .bpAndHR,
        "nebivolol": .bpAndHR,
        "bystolic": .bpAndHR,

        // MARK: ARNIs (BP)
        "sacubitril/valsartan": [.lowersBP],
        "entresto": [.lowersBP],

        // MARK: ACE Inhibitors (BP)
        "lisinopril": [.lowersBP],
        "zestril": [.lowersBP],
        "prinivil": [.lowersBP],
        "enalapril": [.lowersBP],
        "vasotec": [.lowersBP],
        "ramipril": [.lowersBP],
        "altace": [.lowersBP],
        "captopril": [.lowersBP],
        "capoten": [.lowersBP],
        "benazepril": [.lowersBP],
        "lotensin": [.lowersBP],
        "fosinopril": [.lowersBP],
        "monopril": [.lowersBP],
        "quinapril": [.lowersBP],
        "accupril": [.lowersBP],
        "trandolapril": [.lowersBP],
        "mavik": [.lowersBP],
        "perindopril": [.lowersBP],
        "aceon": [.lowersBP],

        // MARK: ARBs (BP)
        "losartan": [.lowersBP],
        "cozaar": [.lowersBP],
        "valsartan": [.lowersBP],
        "diovan": [.lowersBP],
        "candesartan": [.lowersBP],
        "atacand": [.lowersBP],
        "irbesartan": [.lowersBP],
        "avapro": [.lowersBP],
        "olmesartan": [.lowersBP],
        "benicar": [.lowersBP],
        "telmisartan": [.lowersBP],
        "micardis": [.lowersBP],
        "azilsartan": [.lowersBP],
        "edarbi": [.lowersBP],

        // MARK: MRAs (BP + Diuretic)
        "spironolactone": .bpAndDiuretic,
        "aldactone": .bpAndDiuretic,
        "eplerenone": .bpAndDiuretic,
        "inspra": .bpAndDiuretic,

        // MARK: SGLT2 Inhibitors (mild BP effect)
        "dapagliflozin": [.lowersBP],
        "farxiga": [.lowersBP],
        "empagliflozin": [.lowersBP],
        "jardiance": [.lowersBP],
        "sotagliflozin": [.lowersBP],
        "inpefa": [.lowersBP],
        "canagliflozin": [.lowersBP],
        "invokana": [.lowersBP],
        "ertugliflozin": [.lowersBP],
        "steglatro": [.lowersBP],

        // MARK: Loop Diuretics (BP + Diuretic)
        "furosemide": .bpAndDiuretic,
        "lasix": .bpAndDiuretic,
        "torsemide": .bpAndDiuretic,
        "demadex": .bpAndDiuretic,
        "bumetanide": .bpAndDiuretic,
        "bumex": .bpAndDiuretic,
        "ethacrynic acid": .bpAndDiuretic,
        "edecrin": .bpAndDiuretic,

        // MARK: Thiazide/Thiazide-like Diuretics (BP + Diuretic)
        "metolazone": .bpAndDiuretic,
        "zaroxolyn": .bpAndDiuretic,
        "hydrochlorothiazide": .bpAndDiuretic,
        "hctz": .bpAndDiuretic,
        "chlorthalidone": .bpAndDiuretic,
        "thalitone": .bpAndDiuretic,
        "indapamide": .bpAndDiuretic,
        "lozol": .bpAndDiuretic,

        // MARK: Non-DHP Calcium Channel Blockers (HR + BP)
        "diltiazem": .bpAndHR,
        "cardizem": .bpAndHR,
        "tiazac": .bpAndHR,
        "verapamil": .bpAndHR,
        "calan": .bpAndHR,
        "verelan": .bpAndHR,
        "isoptin": .bpAndHR,

        // MARK: DHP Calcium Channel Blockers (BP only)
        "amlodipine": [.lowersBP],
        "norvasc": [.lowersBP],
        "nifedipine": [.lowersBP],
        "procardia": [.lowersBP],
        "adalat": [.lowersBP],
        "felodipine": [.lowersBP],
        "plendil": [.lowersBP],
        "nisoldipine": [.lowersBP],
        "sular": [.lowersBP],
        "nicardipine": [.lowersBP],
        "cardene": [.lowersBP],
        "isradipine": [.lowersBP],

        // MARK: Rate Control Agents (HR primarily)
        "digoxin": [.lowersHR],
        "lanoxin": [.lowersHR],
        "ivabradine": [.lowersHR],
        "corlanor": [.lowersHR],

        // MARK: Antiarrhythmics (HR effects)
        "amiodarone": [.lowersHR],
        "pacerone": [.lowersHR],
        "cordarone": [.lowersHR],
        "sotalol": .bpAndHR,  // Also a beta blocker
        "betapace": .bpAndHR,
        "flecainide": [.lowersHR],
        "tambocor": [.lowersHR],
        "propafenone": [.lowersHR],
        "rythmol": [.lowersHR],
        "dronedarone": [.lowersHR],
        "multaq": [.lowersHR],
        "dofetilide": [.lowersHR],
        "tikosyn": [.lowersHR],

        // MARK: Alpha Blockers (BP)
        "prazosin": [.lowersBP],
        "minipress": [.lowersBP],
        "doxazosin": [.lowersBP],
        "cardura": [.lowersBP],
        "terazosin": [.lowersBP],
        "hytrin": [.lowersBP],

        // MARK: Direct Vasodilators (BP)
        "hydralazine": [.lowersBP],
        "apresoline": [.lowersBP],
        "minoxidil": [.lowersBP],
        "loniten": [.lowersBP],

        // MARK: Nitrates (BP)
        "isosorbide dinitrate": [.lowersBP],
        "isordil": [.lowersBP],
        "dilatrate": [.lowersBP],
        "isosorbide mononitrate": [.lowersBP],
        "imdur": [.lowersBP],
        "monoket": [.lowersBP],
        "nitroglycerin": [.lowersBP],
        "nitrostat": [.lowersBP],
        "nitro-dur": [.lowersBP],
        "nitrolingual": [.lowersBP],
        "hydralazine/isosorbide dinitrate": [.lowersBP],
        "bidil": [.lowersBP],

        // MARK: Central Alpha Agonists (BP)
        "clonidine": [.lowersBP],
        "catapres": [.lowersBP],
        "methyldopa": [.lowersBP],
        "aldomet": [.lowersBP],
        "guanfacine": [.lowersBP],
        "tenex": [.lowersBP],
        "intuniv": [.lowersBP],

        // MARK: Direct Renin Inhibitors (BP)
        "aliskiren": [.lowersBP],
        "tekturna": [.lowersBP],
    ]

    // MARK: - Lookup Methods

    /// Find effects for a medication by name (case-insensitive, supports partial matching)
    /// - Parameter medicationName: The medication name to look up
    /// - Returns: The cardiovascular effects if found, nil otherwise
    static func effects(for medicationName: String) -> Effects? {
        let normalized = medicationName.lowercased().trimmingCharacters(in: .whitespaces)

        // Try exact match first
        if let effects = database[normalized] {
            return effects
        }

        // Try matching medication name that contains a known drug
        // This handles cases like "Carvedilol 25mg" or "Lasix (furosemide)"
        for (drugName, effects) in database {
            if normalized.contains(drugName) {
                return effects
            }
        }

        return nil
    }

    /// Check if a medication affects blood pressure
    static func affectsBloodPressure(_ medicationName: String) -> Bool {
        effects(for: medicationName)?.contains(.lowersBP) ?? false
    }

    /// Check if a medication affects heart rate
    static func affectsHeartRate(_ medicationName: String) -> Bool {
        effects(for: medicationName)?.contains(.lowersHR) ?? false
    }

    /// Check if a medication is a diuretic
    static func isDiuretic(_ medicationName: String) -> Bool {
        effects(for: medicationName)?.contains(.diuretic) ?? false
    }

    /// Get relevant clinical thresholds for a medication based on its effects
    /// - Parameter medicationName: The medication name
    /// - Returns: Tuple indicating which clinical parameters to analyze
    static func relevantParameters(for medicationName: String) -> (checkBP: Bool, checkHR: Bool, checkUrine: Bool) {
        guard let effects = effects(for: medicationName) else {
            return (false, false, false)
        }

        return (
            checkBP: effects.contains(.lowersBP),
            checkHR: effects.contains(.lowersHR),
            checkUrine: effects.contains(.diuretic)
        )
    }

    /// Get category-specific context message template
    /// - Parameters:
    ///   - category: The HeartFailureMedication category
    ///   - medicationName: The medication name (for fallback effects lookup)
    /// - Returns: A patient-friendly explanation of why this medication might be adjusted
    static func contextMessageTemplate(for category: HeartFailureMedication.Category?, medicationName: String) -> String? {
        // Use category if available, otherwise infer from medication effects
        if let category = category {
            switch category {
            case .betaBlocker:
                return "These patterns are commonly associated with beta-blocker dose adjustments. Share this summary with your care team."
            case .arni:
                return "Symptomatic hypotension is a known consideration for ARNI dosing. Discuss these observations with your care team."
            case .aceInhibitor, .arb:
                return "Blood pressure changes may influence ACE inhibitor or ARB dosing. Discuss these observations with your care team."
            case .mra:
                return "MRA dosing may be affected by factors including lab values not tracked in this app. Discuss with your care team."
            case .sglt2Inhibitor:
                return "Volume changes may influence SGLT2 inhibitor management. Share these observations with your care team."
            case .loopDiuretic, .thiazideDiuretic:
                return "Diuretic dosing often responds to blood pressure and volume status. Discuss these patterns with your care team."
            case .other:
                return "These observations may be relevant to your medication management. Share this summary with your care team."
            }
        }

        // Fallback based on medication effects
        guard let effects = effects(for: medicationName) else {
            return nil
        }

        if effects.contains(.lowersHR) && effects.contains(.lowersBP) {
            return "Medications affecting both heart rate and blood pressure may be adjusted based on these readings. Discuss with your care team."
        } else if effects.contains(.lowersHR) {
            return "Medications affecting heart rate may be adjusted based on these readings. Discuss with your care team."
        } else if effects.contains(.lowersBP) {
            return "Blood pressure-lowering medications may be adjusted based on these readings. Discuss with your care team."
        }

        return nil
    }
}
