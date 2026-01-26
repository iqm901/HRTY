import Foundation

/// Common medications for cardiac patients (beyond core heart failure GDMT)
/// Includes statins, anticoagulants, antiplatelets, calcium channel blockers, and more
struct OtherMedication: Identifiable, Hashable {
    let id = UUID()
    let genericName: String
    let brandName: String?
    let category: OtherMedicationCategory
    let availableDosages: [String]
    let defaultFrequency: String
    let isDiuretic: Bool
    let unit: String

    var displayName: String {
        if let brand = brandName {
            return "\(genericName) (\(brand))"
        }
        return genericName
    }
}

enum OtherMedicationCategory: String, CaseIterable {
    case statin = "Statins"
    case anticoagulant = "Anticoagulants"
    case antiplatelet = "Antiplatelets"
    case calciumChannelBlockerDHP = "CCBs (DHP)"
    case calciumChannelBlockerNonDHP = "CCBs (Non-DHP)"
    case antiarrhythmic = "Antiarrhythmics"
    case nitrate = "Nitrates"
    case alphaBlocker = "Alpha Blockers"
    case centralAgent = "Central Agents"
    case additionalBetaBlocker = "Additional Beta Blockers"
    case additionalAceInhibitor = "Additional ACE-I"
    case additionalArb = "Additional ARBs"
    case additionalDiuretic = "Additional Diuretics"
    case potassiumSupplement = "Potassium"
    case glp1Agonist = "GLP-1 Agonists"
    case diabetesMed = "Diabetes Meds"
    case thyroid = "Thyroid"
    case pulmonaryHTN = "Pulmonary HTN"
    case other = "Other"
}

// MARK: - Predefined Other Medications

extension OtherMedication {

    /// All predefined other medications organized by category
    static let allMedications: [OtherMedication] = [
        // MARK: - Statins
        OtherMedication(
            genericName: "Atorvastatin",
            brandName: "Lipitor",
            category: .statin,
            availableDosages: ["10", "20", "40", "80"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Rosuvastatin",
            brandName: "Crestor",
            category: .statin,
            availableDosages: ["5", "10", "20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Simvastatin",
            brandName: "Zocor",
            category: .statin,
            availableDosages: ["5", "10", "20", "40"],
            defaultFrequency: "Once daily (evening)",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Pravastatin",
            brandName: "Pravachol",
            category: .statin,
            availableDosages: ["10", "20", "40", "80"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Lovastatin",
            brandName: "Mevacor",
            category: .statin,
            availableDosages: ["10", "20", "40"],
            defaultFrequency: "Once daily (evening)",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Fluvastatin",
            brandName: "Lescol",
            category: .statin,
            availableDosages: ["20", "40", "80"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Pitavastatin",
            brandName: "Livalo",
            category: .statin,
            availableDosages: ["1", "2", "4"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Ezetimibe",
            brandName: "Zetia",
            category: .statin,
            availableDosages: ["10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Ezetimibe/Simvastatin",
            brandName: "Vytorin",
            category: .statin,
            availableDosages: ["10/10", "10/20", "10/40", "10/80"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Anticoagulants
        OtherMedication(
            genericName: "Warfarin",
            brandName: "Coumadin",
            category: .anticoagulant,
            availableDosages: ["1", "2", "2.5", "3", "4", "5", "6", "7.5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Apixaban",
            brandName: "Eliquis",
            category: .anticoagulant,
            availableDosages: ["2.5", "5"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Rivaroxaban",
            brandName: "Xarelto",
            category: .anticoagulant,
            availableDosages: ["2.5", "10", "15", "20"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Dabigatran",
            brandName: "Pradaxa",
            category: .anticoagulant,
            availableDosages: ["75", "110", "150"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Edoxaban",
            brandName: "Savaysa",
            category: .anticoagulant,
            availableDosages: ["30", "60"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Enoxaparin",
            brandName: "Lovenox",
            category: .anticoagulant,
            availableDosages: ["30", "40", "60", "80", "100", "120"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Antiplatelets
        OtherMedication(
            genericName: "Aspirin (cardiac)",
            brandName: "Bayer",
            category: .antiplatelet,
            availableDosages: ["81", "325"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Clopidogrel",
            brandName: "Plavix",
            category: .antiplatelet,
            availableDosages: ["75", "300"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Ticagrelor",
            brandName: "Brilinta",
            category: .antiplatelet,
            availableDosages: ["60", "90"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Prasugrel",
            brandName: "Effient",
            category: .antiplatelet,
            availableDosages: ["5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Dipyridamole",
            brandName: "Persantine",
            category: .antiplatelet,
            availableDosages: ["25", "50", "75"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Aspirin/Dipyridamole",
            brandName: "Aggrenox",
            category: .antiplatelet,
            availableDosages: ["25/200"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Calcium Channel Blockers (DHP)
        OtherMedication(
            genericName: "Amlodipine",
            brandName: "Norvasc",
            category: .calciumChannelBlockerDHP,
            availableDosages: ["2.5", "5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Nifedipine",
            brandName: "Procardia",
            category: .calciumChannelBlockerDHP,
            availableDosages: ["10", "20", "30", "60", "90"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Felodipine",
            brandName: "Plendil",
            category: .calciumChannelBlockerDHP,
            availableDosages: ["2.5", "5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Nicardipine",
            brandName: "Cardene",
            category: .calciumChannelBlockerDHP,
            availableDosages: ["20", "30"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Nisoldipine",
            brandName: "Sular",
            category: .calciumChannelBlockerDHP,
            availableDosages: ["8.5", "17", "25.5", "34"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Isradipine",
            brandName: "DynaCirc",
            category: .calciumChannelBlockerDHP,
            availableDosages: ["2.5", "5"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Calcium Channel Blockers (Non-DHP)
        OtherMedication(
            genericName: "Diltiazem",
            brandName: "Cardizem",
            category: .calciumChannelBlockerNonDHP,
            availableDosages: ["30", "60", "90", "120", "180", "240", "300", "360"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Verapamil",
            brandName: "Calan",
            category: .calciumChannelBlockerNonDHP,
            availableDosages: ["40", "80", "120", "180", "240"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Antiarrhythmics
        OtherMedication(
            genericName: "Amiodarone",
            brandName: "Pacerone",
            category: .antiarrhythmic,
            availableDosages: ["100", "200", "400"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Flecainide",
            brandName: "Tambocor",
            category: .antiarrhythmic,
            availableDosages: ["50", "100", "150"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Propafenone",
            brandName: "Rythmol",
            category: .antiarrhythmic,
            availableDosages: ["150", "225", "300"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Sotalol",
            brandName: "Betapace",
            category: .antiarrhythmic,
            availableDosages: ["80", "120", "160", "240"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Dronedarone",
            brandName: "Multaq",
            category: .antiarrhythmic,
            availableDosages: ["400"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Dofetilide",
            brandName: "Tikosyn",
            category: .antiarrhythmic,
            availableDosages: ["125", "250", "500"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mcg"
        ),
        OtherMedication(
            genericName: "Mexiletine",
            brandName: "Mexitil",
            category: .antiarrhythmic,
            availableDosages: ["150", "200", "250"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Nitrates
        OtherMedication(
            genericName: "Isosorbide Mononitrate",
            brandName: "Imdur",
            category: .nitrate,
            availableDosages: ["30", "60", "120"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Nitroglycerin patch",
            brandName: "Nitro-Dur",
            category: .nitrate,
            availableDosages: ["0.1", "0.2", "0.4", "0.6", "0.8"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg/hr"
        ),
        OtherMedication(
            genericName: "Nitroglycerin sublingual",
            brandName: "Nitrostat",
            category: .nitrate,
            availableDosages: ["0.3", "0.4", "0.6"],
            defaultFrequency: "As needed",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Ranolazine",
            brandName: "Ranexa",
            category: .nitrate,
            availableDosages: ["500", "1000"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Alpha Blockers
        OtherMedication(
            genericName: "Prazosin",
            brandName: "Minipress",
            category: .alphaBlocker,
            availableDosages: ["1", "2", "5"],
            defaultFrequency: "Two times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Doxazosin",
            brandName: "Cardura",
            category: .alphaBlocker,
            availableDosages: ["1", "2", "4", "8"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Terazosin",
            brandName: "Hytrin",
            category: .alphaBlocker,
            availableDosages: ["1", "2", "5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Central Agents
        OtherMedication(
            genericName: "Clonidine",
            brandName: "Catapres",
            category: .centralAgent,
            availableDosages: ["0.1", "0.2", "0.3"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Clonidine patch",
            brandName: "Catapres-TTS",
            category: .centralAgent,
            availableDosages: ["0.1", "0.2", "0.3"],
            defaultFrequency: "Weekly",
            isDiuretic: false,
            unit: "mg/day"
        ),
        OtherMedication(
            genericName: "Methyldopa",
            brandName: "Aldomet",
            category: .centralAgent,
            availableDosages: ["250", "500"],
            defaultFrequency: "Two times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Guanfacine",
            brandName: "Tenex",
            category: .centralAgent,
            availableDosages: ["1", "2"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Additional Beta Blockers
        OtherMedication(
            genericName: "Atenolol",
            brandName: "Tenormin",
            category: .additionalBetaBlocker,
            availableDosages: ["25", "50", "100"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Propranolol",
            brandName: "Inderal",
            category: .additionalBetaBlocker,
            availableDosages: ["10", "20", "40", "60", "80"],
            defaultFrequency: "Two times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Propranolol LA",
            brandName: "Inderal LA",
            category: .additionalBetaBlocker,
            availableDosages: ["60", "80", "120", "160"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Nadolol",
            brandName: "Corgard",
            category: .additionalBetaBlocker,
            availableDosages: ["20", "40", "80", "120", "160"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Labetalol",
            brandName: "Trandate",
            category: .additionalBetaBlocker,
            availableDosages: ["100", "200", "300"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Nebivolol",
            brandName: "Bystolic",
            category: .additionalBetaBlocker,
            availableDosages: ["2.5", "5", "10", "20"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Additional ACE Inhibitors
        OtherMedication(
            genericName: "Benazepril",
            brandName: "Lotensin",
            category: .additionalAceInhibitor,
            availableDosages: ["5", "10", "20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Fosinopril",
            brandName: "Monopril",
            category: .additionalAceInhibitor,
            availableDosages: ["10", "20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Quinapril",
            brandName: "Accupril",
            category: .additionalAceInhibitor,
            availableDosages: ["5", "10", "20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Trandolapril",
            brandName: "Mavik",
            category: .additionalAceInhibitor,
            availableDosages: ["1", "2", "4"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Perindopril",
            brandName: "Aceon",
            category: .additionalAceInhibitor,
            availableDosages: ["2", "4", "8"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Moexipril",
            brandName: "Univasc",
            category: .additionalAceInhibitor,
            availableDosages: ["7.5", "15"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Additional ARBs
        OtherMedication(
            genericName: "Irbesartan",
            brandName: "Avapro",
            category: .additionalArb,
            availableDosages: ["75", "150", "300"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Olmesartan",
            brandName: "Benicar",
            category: .additionalArb,
            availableDosages: ["5", "20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Telmisartan",
            brandName: "Micardis",
            category: .additionalArb,
            availableDosages: ["20", "40", "80"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Azilsartan",
            brandName: "Edarbi",
            category: .additionalArb,
            availableDosages: ["40", "80"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Additional Diuretics
        OtherMedication(
            genericName: "Chlorthalidone",
            brandName: "Thalitone",
            category: .additionalDiuretic,
            availableDosages: ["12.5", "25", "50"],
            defaultFrequency: "Once daily",
            isDiuretic: true,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Indapamide",
            brandName: "Lozol",
            category: .additionalDiuretic,
            availableDosages: ["1.25", "2.5"],
            defaultFrequency: "Once daily",
            isDiuretic: true,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Hydrochlorothiazide",
            brandName: "Microzide",
            category: .additionalDiuretic,
            availableDosages: ["12.5", "25", "50"],
            defaultFrequency: "Once daily",
            isDiuretic: true,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Amiloride",
            brandName: "Midamor",
            category: .additionalDiuretic,
            availableDosages: ["5"],
            defaultFrequency: "Once daily",
            isDiuretic: true,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Triamterene",
            brandName: "Dyrenium",
            category: .additionalDiuretic,
            availableDosages: ["50", "100"],
            defaultFrequency: "Once daily",
            isDiuretic: true,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Triamterene/HCTZ",
            brandName: "Dyazide",
            category: .additionalDiuretic,
            availableDosages: ["37.5/25", "75/50"],
            defaultFrequency: "Once daily",
            isDiuretic: true,
            unit: "mg"
        ),

        // MARK: - Potassium Supplements
        OtherMedication(
            genericName: "Potassium chloride",
            brandName: "Klor-Con",
            category: .potassiumSupplement,
            availableDosages: ["8", "10", "20"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mEq"
        ),
        OtherMedication(
            genericName: "Potassium chloride liquid",
            brandName: "Kay Ciel",
            category: .potassiumSupplement,
            availableDosages: ["10", "20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mEq"
        ),

        // MARK: - GLP-1 Agonists
        OtherMedication(
            genericName: "Semaglutide (oral)",
            brandName: "Rybelsus",
            category: .glp1Agonist,
            availableDosages: ["3", "7", "14"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Semaglutide (injection)",
            brandName: "Ozempic",
            category: .glp1Agonist,
            availableDosages: ["0.25", "0.5", "1", "2"],
            defaultFrequency: "Once weekly",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Liraglutide",
            brandName: "Victoza",
            category: .glp1Agonist,
            availableDosages: ["0.6", "1.2", "1.8"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Dulaglutide",
            brandName: "Trulicity",
            category: .glp1Agonist,
            availableDosages: ["0.75", "1.5", "3", "4.5"],
            defaultFrequency: "Once weekly",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Tirzepatide",
            brandName: "Mounjaro",
            category: .glp1Agonist,
            availableDosages: ["2.5", "5", "7.5", "10", "12.5", "15"],
            defaultFrequency: "Once weekly",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Diabetes Medications (Cardiac-Relevant)
        OtherMedication(
            genericName: "Metformin",
            brandName: "Glucophage",
            category: .diabetesMed,
            availableDosages: ["500", "850", "1000"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Metformin XR",
            brandName: "Glucophage XR",
            category: .diabetesMed,
            availableDosages: ["500", "750", "1000"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Pioglitazone",
            brandName: "Actos",
            category: .diabetesMed,
            availableDosages: ["15", "30", "45"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Thyroid Medications
        OtherMedication(
            genericName: "Levothyroxine",
            brandName: "Synthroid",
            category: .thyroid,
            availableDosages: ["25", "50", "75", "88", "100", "112", "125", "137", "150", "175", "200"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mcg"
        ),
        OtherMedication(
            genericName: "Methimazole",
            brandName: "Tapazole",
            category: .thyroid,
            availableDosages: ["5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Propylthiouracil",
            brandName: "PTU",
            category: .thyroid,
            availableDosages: ["50"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Pulmonary Hypertension
        OtherMedication(
            genericName: "Sildenafil",
            brandName: "Revatio",
            category: .pulmonaryHTN,
            availableDosages: ["20"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Tadalafil",
            brandName: "Adcirca",
            category: .pulmonaryHTN,
            availableDosages: ["20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Bosentan",
            brandName: "Tracleer",
            category: .pulmonaryHTN,
            availableDosages: ["62.5", "125"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Ambrisentan",
            brandName: "Letairis",
            category: .pulmonaryHTN,
            availableDosages: ["5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Macitentan",
            brandName: "Opsumit",
            category: .pulmonaryHTN,
            availableDosages: ["10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Riociguat",
            brandName: "Adempas",
            category: .pulmonaryHTN,
            availableDosages: ["0.5", "1", "1.5", "2", "2.5"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Other (Vasodilators, etc.)
        OtherMedication(
            genericName: "Minoxidil",
            brandName: "Loniten",
            category: .other,
            availableDosages: ["2.5", "5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
    ]

    /// Medications grouped by category for display
    static var medicationsByCategory: [(category: OtherMedicationCategory, medications: [OtherMedication])] {
        OtherMedicationCategory.allCases.compactMap { category in
            let meds = allMedications.filter { $0.category == category }
            return meds.isEmpty ? nil : (category, meds)
        }
    }

    /// Search medications by name (generic or brand)
    /// - Parameter query: The search query string
    /// - Returns: Array of matching medications, sorted by relevance
    static func search(query: String) -> [OtherMedication] {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespaces)
        guard !normalizedQuery.isEmpty else { return [] }

        return allMedications.filter { medication in
            medication.genericName.lowercased().contains(normalizedQuery) ||
            (medication.brandName?.lowercased().contains(normalizedQuery) ?? false)
        }.sorted { med1, med2 in
            // Prioritize medications that start with the query
            let med1StartsWithQuery = med1.genericName.lowercased().hasPrefix(normalizedQuery) ||
                                      (med1.brandName?.lowercased().hasPrefix(normalizedQuery) ?? false)
            let med2StartsWithQuery = med2.genericName.lowercased().hasPrefix(normalizedQuery) ||
                                      (med2.brandName?.lowercased().hasPrefix(normalizedQuery) ?? false)

            if med1StartsWithQuery != med2StartsWithQuery {
                return med1StartsWithQuery
            }

            return med1.displayName.localizedCaseInsensitiveCompare(med2.displayName) == .orderedAscending
        }
    }

    /// All known diuretic names from Other Medications
    static let knownDiureticNames: Set<String> = {
        var names = Set<String>()
        for med in allMedications where med.isDiuretic {
            names.insert(med.genericName.lowercased())
            if let brand = med.brandName {
                names.insert(brand.lowercased())
            }
        }
        return names
    }()
}
