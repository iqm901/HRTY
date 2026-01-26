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
    // Cardiovascular
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
    case pulmonaryHTN = "Pulmonary HTN"

    // Diabetes & Metabolic
    case glp1Agonist = "GLP-1 Agonists"
    case diabetesMed = "Diabetes Meds"
    case insulin = "Insulins"

    // Endocrine
    case thyroid = "Thyroid"

    // Mental Health
    case antidepressant = "Antidepressants"
    case antipsychotic = "Antipsychotics"
    case anxiolytic = "Anxiolytics"
    case sleepAid = "Sleep Aids"
    case adhd = "ADHD Meds"

    // Pain & Inflammation
    case painNsaid = "NSAIDs"
    case painOpioid = "Opioids"
    case painNeuropathic = "Neuropathic Pain"
    case muscleRelaxant = "Muscle Relaxants"
    case gout = "Gout Meds"

    // Neurological
    case anticonvulsant = "Anticonvulsants"
    case dementia = "Dementia Meds"

    // Gastrointestinal
    case gastrointestinal = "GI Meds"

    // Respiratory
    case respiratory = "Respiratory"

    // Antibiotics & Antivirals
    case antibiotic = "Antibiotics"
    case antiviral = "Antivirals"
    case antifungal = "Antifungals"

    // Allergy
    case antihistamine = "Antihistamines"

    // Urological
    case urological = "Urological"

    // Hormones
    case hormone = "Hormones"

    // Bone Health
    case boneHealth = "Bone Health"

    // Immunology
    case immunology = "Immunology"

    // Steroids
    case corticosteroid = "Corticosteroids"

    // Other
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

        // MARK: - Antidepressants
        OtherMedication(
            genericName: "Sertraline",
            brandName: "Zoloft",
            category: .antidepressant,
            availableDosages: ["25", "50", "100"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Escitalopram",
            brandName: "Lexapro",
            category: .antidepressant,
            availableDosages: ["5", "10", "20"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Bupropion",
            brandName: "Wellbutrin",
            category: .antidepressant,
            availableDosages: ["75", "100", "150", "200", "300"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Bupropion SR",
            brandName: "Wellbutrin SR",
            category: .antidepressant,
            availableDosages: ["100", "150", "200"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Bupropion XL",
            brandName: "Wellbutrin XL",
            category: .antidepressant,
            availableDosages: ["150", "300", "450"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Fluoxetine",
            brandName: "Prozac",
            category: .antidepressant,
            availableDosages: ["10", "20", "40", "60"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Trazodone",
            brandName: "Desyrel",
            category: .antidepressant,
            availableDosages: ["50", "100", "150", "300"],
            defaultFrequency: "Once daily (bedtime)",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Duloxetine",
            brandName: "Cymbalta",
            category: .antidepressant,
            availableDosages: ["20", "30", "60"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Citalopram",
            brandName: "Celexa",
            category: .antidepressant,
            availableDosages: ["10", "20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Venlafaxine",
            brandName: "Effexor",
            category: .antidepressant,
            availableDosages: ["37.5", "75", "150"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Venlafaxine XR",
            brandName: "Effexor XR",
            category: .antidepressant,
            availableDosages: ["37.5", "75", "150", "225"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Paroxetine",
            brandName: "Paxil",
            category: .antidepressant,
            availableDosages: ["10", "20", "30", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Amitriptyline",
            brandName: "Elavil",
            category: .antidepressant,
            availableDosages: ["10", "25", "50", "75", "100", "150"],
            defaultFrequency: "Once daily (bedtime)",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Mirtazapine",
            brandName: "Remeron",
            category: .antidepressant,
            availableDosages: ["7.5", "15", "30", "45"],
            defaultFrequency: "Once daily (bedtime)",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Doxepin",
            brandName: "Sinequan",
            category: .antidepressant,
            availableDosages: ["10", "25", "50", "75", "100", "150"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Desvenlafaxine",
            brandName: "Pristiq",
            category: .antidepressant,
            availableDosages: ["25", "50", "100"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Nortriptyline",
            brandName: "Pamelor",
            category: .antidepressant,
            availableDosages: ["10", "25", "50", "75"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Anxiolytics
        OtherMedication(
            genericName: "Alprazolam",
            brandName: "Xanax",
            category: .anxiolytic,
            availableDosages: ["0.25", "0.5", "1", "2"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Alprazolam XR",
            brandName: "Xanax XR",
            category: .anxiolytic,
            availableDosages: ["0.5", "1", "2", "3"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Buspirone",
            brandName: "Buspar",
            category: .anxiolytic,
            availableDosages: ["5", "7.5", "10", "15", "30"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Hydroxyzine",
            brandName: "Vistaril",
            category: .anxiolytic,
            availableDosages: ["10", "25", "50"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Clonazepam",
            brandName: "Klonopin",
            category: .anxiolytic,
            availableDosages: ["0.5", "1", "2"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Lorazepam",
            brandName: "Ativan",
            category: .anxiolytic,
            availableDosages: ["0.5", "1", "2"],
            defaultFrequency: "Two to three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Diazepam",
            brandName: "Valium",
            category: .anxiolytic,
            availableDosages: ["2", "5", "10"],
            defaultFrequency: "Two to four times daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Gastrointestinal
        OtherMedication(
            genericName: "Omeprazole",
            brandName: "Prilosec",
            category: .gastrointestinal,
            availableDosages: ["10", "20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Pantoprazole",
            brandName: "Protonix",
            category: .gastrointestinal,
            availableDosages: ["20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Esomeprazole",
            brandName: "Nexium",
            category: .gastrointestinal,
            availableDosages: ["20", "40"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Lansoprazole",
            brandName: "Prevacid",
            category: .gastrointestinal,
            availableDosages: ["15", "30"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Famotidine",
            brandName: "Pepcid",
            category: .gastrointestinal,
            availableDosages: ["10", "20", "40"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Ranitidine",
            brandName: "Zantac",
            category: .gastrointestinal,
            availableDosages: ["75", "150", "300"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Ondansetron",
            brandName: "Zofran",
            category: .gastrointestinal,
            availableDosages: ["4", "8"],
            defaultFrequency: "As needed",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Docusate sodium",
            brandName: "Colace",
            category: .gastrointestinal,
            availableDosages: ["50", "100", "250"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Linaclotide",
            brandName: "Linzess",
            category: .gastrointestinal,
            availableDosages: ["72", "145", "290"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mcg"
        ),
        OtherMedication(
            genericName: "Dicyclomine",
            brandName: "Bentyl",
            category: .gastrointestinal,
            availableDosages: ["10", "20"],
            defaultFrequency: "Four times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Polyethylene glycol 3350",
            brandName: "MiraLAX",
            category: .gastrointestinal,
            availableDosages: ["17"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "g"
        ),
        OtherMedication(
            genericName: "Sucralfate",
            brandName: "Carafate",
            category: .gastrointestinal,
            availableDosages: ["1"],
            defaultFrequency: "Four times daily",
            isDiuretic: false,
            unit: "g"
        ),
        OtherMedication(
            genericName: "Metoclopramide",
            brandName: "Reglan",
            category: .gastrointestinal,
            availableDosages: ["5", "10"],
            defaultFrequency: "Four times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Promethazine",
            brandName: "Phenergan",
            category: .gastrointestinal,
            availableDosages: ["12.5", "25", "50"],
            defaultFrequency: "Every 4-6 hours as needed",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Respiratory
        OtherMedication(
            genericName: "Albuterol inhaler",
            brandName: "ProAir/Ventolin",
            category: .respiratory,
            availableDosages: ["90"],
            defaultFrequency: "As needed",
            isDiuretic: false,
            unit: "mcg/puff"
        ),
        OtherMedication(
            genericName: "Albuterol nebulizer",
            brandName: "Proventil",
            category: .respiratory,
            availableDosages: ["0.63", "1.25", "2.5"],
            defaultFrequency: "Every 4-6 hours as needed",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Montelukast",
            brandName: "Singulair",
            category: .respiratory,
            availableDosages: ["4", "5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Fluticasone propionate inhaler",
            brandName: "Flovent",
            category: .respiratory,
            availableDosages: ["44", "110", "220"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mcg/puff"
        ),
        OtherMedication(
            genericName: "Fluticasone nasal spray",
            brandName: "Flonase",
            category: .respiratory,
            availableDosages: ["50"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mcg/spray"
        ),
        OtherMedication(
            genericName: "Budesonide/Formoterol",
            brandName: "Symbicort",
            category: .respiratory,
            availableDosages: ["80/4.5", "160/4.5"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mcg"
        ),
        OtherMedication(
            genericName: "Fluticasone/Salmeterol",
            brandName: "Advair",
            category: .respiratory,
            availableDosages: ["100/50", "250/50", "500/50"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mcg"
        ),
        OtherMedication(
            genericName: "Tiotropium",
            brandName: "Spiriva",
            category: .respiratory,
            availableDosages: ["18"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mcg"
        ),
        OtherMedication(
            genericName: "Benzonatate",
            brandName: "Tessalon",
            category: .respiratory,
            availableDosages: ["100", "200"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Ipratropium/Albuterol",
            brandName: "Combivent",
            category: .respiratory,
            availableDosages: ["20/100"],
            defaultFrequency: "Four times daily",
            isDiuretic: false,
            unit: "mcg"
        ),
        OtherMedication(
            genericName: "Budesonide inhaler",
            brandName: "Pulmicort",
            category: .respiratory,
            availableDosages: ["0.25", "0.5", "1"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Antibiotics
        OtherMedication(
            genericName: "Amoxicillin",
            brandName: "Amoxil",
            category: .antibiotic,
            availableDosages: ["250", "500", "875"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Azithromycin",
            brandName: "Z-Pack",
            category: .antibiotic,
            availableDosages: ["250", "500"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Amoxicillin/Clavulanate",
            brandName: "Augmentin",
            category: .antibiotic,
            availableDosages: ["250/125", "500/125", "875/125"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Doxycycline",
            brandName: "Vibramycin",
            category: .antibiotic,
            availableDosages: ["50", "100"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Cephalexin",
            brandName: "Keflex",
            category: .antibiotic,
            availableDosages: ["250", "500"],
            defaultFrequency: "Four times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Sulfamethoxazole/Trimethoprim",
            brandName: "Bactrim",
            category: .antibiotic,
            availableDosages: ["400/80", "800/160"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Nitrofurantoin",
            brandName: "Macrobid",
            category: .antibiotic,
            availableDosages: ["50", "100"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Clindamycin",
            brandName: "Cleocin",
            category: .antibiotic,
            availableDosages: ["150", "300"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Ciprofloxacin",
            brandName: "Cipro",
            category: .antibiotic,
            availableDosages: ["250", "500", "750"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Levofloxacin",
            brandName: "Levaquin",
            category: .antibiotic,
            availableDosages: ["250", "500", "750"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Cefdinir",
            brandName: "Omnicef",
            category: .antibiotic,
            availableDosages: ["300"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Metronidazole",
            brandName: "Flagyl",
            category: .antibiotic,
            availableDosages: ["250", "500"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Penicillin VK",
            brandName: "Pen VK",
            category: .antibiotic,
            availableDosages: ["250", "500"],
            defaultFrequency: "Four times daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - NSAIDs (Pain & Inflammation)
        OtherMedication(
            genericName: "Ibuprofen",
            brandName: "Advil/Motrin",
            category: .painNsaid,
            availableDosages: ["200", "400", "600", "800"],
            defaultFrequency: "Every 6-8 hours",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Meloxicam",
            brandName: "Mobic",
            category: .painNsaid,
            availableDosages: ["7.5", "15"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Diclofenac",
            brandName: "Voltaren",
            category: .painNsaid,
            availableDosages: ["25", "50", "75"],
            defaultFrequency: "Two to three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Naproxen",
            brandName: "Naprosyn/Aleve",
            category: .painNsaid,
            availableDosages: ["220", "250", "375", "500"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Celecoxib",
            brandName: "Celebrex",
            category: .painNsaid,
            availableDosages: ["100", "200"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Indomethacin",
            brandName: "Indocin",
            category: .painNsaid,
            availableDosages: ["25", "50"],
            defaultFrequency: "Two to three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Ketorolac",
            brandName: "Toradol",
            category: .painNsaid,
            availableDosages: ["10"],
            defaultFrequency: "Every 4-6 hours (max 5 days)",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Opioids
        OtherMedication(
            genericName: "Hydrocodone/Acetaminophen",
            brandName: "Norco/Vicodin",
            category: .painOpioid,
            availableDosages: ["5/325", "7.5/325", "10/325"],
            defaultFrequency: "Every 4-6 hours as needed",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Tramadol",
            brandName: "Ultram",
            category: .painOpioid,
            availableDosages: ["50", "100"],
            defaultFrequency: "Every 4-6 hours as needed",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Tramadol ER",
            brandName: "Ultram ER",
            category: .painOpioid,
            availableDosages: ["100", "200", "300"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Oxycodone",
            brandName: "Roxicodone",
            category: .painOpioid,
            availableDosages: ["5", "10", "15", "20", "30"],
            defaultFrequency: "Every 4-6 hours as needed",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Oxycodone/Acetaminophen",
            brandName: "Percocet",
            category: .painOpioid,
            availableDosages: ["2.5/325", "5/325", "7.5/325", "10/325"],
            defaultFrequency: "Every 4-6 hours as needed",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Morphine IR",
            brandName: "MSIR",
            category: .painOpioid,
            availableDosages: ["15", "30"],
            defaultFrequency: "Every 4 hours as needed",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Morphine ER",
            brandName: "MS Contin",
            category: .painOpioid,
            availableDosages: ["15", "30", "60", "100"],
            defaultFrequency: "Every 8-12 hours",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Codeine/Acetaminophen",
            brandName: "Tylenol #3",
            category: .painOpioid,
            availableDosages: ["30/300"],
            defaultFrequency: "Every 4-6 hours as needed",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Fentanyl patch",
            brandName: "Duragesic",
            category: .painOpioid,
            availableDosages: ["12", "25", "50", "75", "100"],
            defaultFrequency: "Every 72 hours",
            isDiuretic: false,
            unit: "mcg/hr"
        ),

        // MARK: - Muscle Relaxants
        OtherMedication(
            genericName: "Cyclobenzaprine",
            brandName: "Flexeril",
            category: .muscleRelaxant,
            availableDosages: ["5", "10"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Tizanidine",
            brandName: "Zanaflex",
            category: .muscleRelaxant,
            availableDosages: ["2", "4"],
            defaultFrequency: "Every 6-8 hours",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Baclofen",
            brandName: "Lioresal",
            category: .muscleRelaxant,
            availableDosages: ["5", "10", "20"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Methocarbamol",
            brandName: "Robaxin",
            category: .muscleRelaxant,
            availableDosages: ["500", "750"],
            defaultFrequency: "Three to four times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Carisoprodol",
            brandName: "Soma",
            category: .muscleRelaxant,
            availableDosages: ["250", "350"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Metaxalone",
            brandName: "Skelaxin",
            category: .muscleRelaxant,
            availableDosages: ["800"],
            defaultFrequency: "Three to four times daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Anticonvulsants
        OtherMedication(
            genericName: "Gabapentin",
            brandName: "Neurontin",
            category: .anticonvulsant,
            availableDosages: ["100", "300", "400", "600", "800"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Pregabalin",
            brandName: "Lyrica",
            category: .anticonvulsant,
            availableDosages: ["25", "50", "75", "100", "150", "200", "300"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Lamotrigine",
            brandName: "Lamictal",
            category: .anticonvulsant,
            availableDosages: ["25", "100", "150", "200"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Topiramate",
            brandName: "Topamax",
            category: .anticonvulsant,
            availableDosages: ["25", "50", "100", "200"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Levetiracetam",
            brandName: "Keppra",
            category: .anticonvulsant,
            availableDosages: ["250", "500", "750", "1000"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Valproic acid",
            brandName: "Depakote",
            category: .anticonvulsant,
            availableDosages: ["125", "250", "500"],
            defaultFrequency: "Two to three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Carbamazepine",
            brandName: "Tegretol",
            category: .anticonvulsant,
            availableDosages: ["100", "200", "400"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Oxcarbazepine",
            brandName: "Trileptal",
            category: .anticonvulsant,
            availableDosages: ["150", "300", "600"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Phenytoin",
            brandName: "Dilantin",
            category: .anticonvulsant,
            availableDosages: ["100", "200", "300"],
            defaultFrequency: "Once daily or divided",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Insulins
        OtherMedication(
            genericName: "Insulin glargine",
            brandName: "Lantus/Basaglar",
            category: .insulin,
            availableDosages: ["100"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "units/mL"
        ),
        OtherMedication(
            genericName: "Insulin lispro",
            brandName: "Humalog",
            category: .insulin,
            availableDosages: ["100"],
            defaultFrequency: "With meals",
            isDiuretic: false,
            unit: "units/mL"
        ),
        OtherMedication(
            genericName: "Insulin aspart",
            brandName: "NovoLog",
            category: .insulin,
            availableDosages: ["100"],
            defaultFrequency: "With meals",
            isDiuretic: false,
            unit: "units/mL"
        ),
        OtherMedication(
            genericName: "Insulin degludec",
            brandName: "Tresiba",
            category: .insulin,
            availableDosages: ["100", "200"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "units/mL"
        ),
        OtherMedication(
            genericName: "Insulin detemir",
            brandName: "Levemir",
            category: .insulin,
            availableDosages: ["100"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "units/mL"
        ),
        OtherMedication(
            genericName: "Insulin NPH",
            brandName: "Humulin N/Novolin N",
            category: .insulin,
            availableDosages: ["100"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "units/mL"
        ),
        OtherMedication(
            genericName: "Insulin regular",
            brandName: "Humulin R/Novolin R",
            category: .insulin,
            availableDosages: ["100"],
            defaultFrequency: "Before meals",
            isDiuretic: false,
            unit: "units/mL"
        ),
        OtherMedication(
            genericName: "Insulin 70/30",
            brandName: "Humulin 70/30",
            category: .insulin,
            availableDosages: ["100"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "units/mL"
        ),

        // MARK: - Additional Diabetes Medications
        OtherMedication(
            genericName: "Glipizide",
            brandName: "Glucotrol",
            category: .diabetesMed,
            availableDosages: ["2.5", "5", "10"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Glimepiride",
            brandName: "Amaryl",
            category: .diabetesMed,
            availableDosages: ["1", "2", "4"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Glyburide",
            brandName: "DiaBeta",
            category: .diabetesMed,
            availableDosages: ["1.25", "2.5", "5"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Sitagliptin",
            brandName: "Januvia",
            category: .diabetesMed,
            availableDosages: ["25", "50", "100"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Linagliptin",
            brandName: "Tradjenta",
            category: .diabetesMed,
            availableDosages: ["5"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Antipsychotics
        OtherMedication(
            genericName: "Quetiapine",
            brandName: "Seroquel",
            category: .antipsychotic,
            availableDosages: ["25", "50", "100", "200", "300", "400"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Quetiapine XR",
            brandName: "Seroquel XR",
            category: .antipsychotic,
            availableDosages: ["50", "150", "200", "300", "400"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Aripiprazole",
            brandName: "Abilify",
            category: .antipsychotic,
            availableDosages: ["2", "5", "10", "15", "20", "30"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Olanzapine",
            brandName: "Zyprexa",
            category: .antipsychotic,
            availableDosages: ["2.5", "5", "7.5", "10", "15", "20"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Risperidone",
            brandName: "Risperdal",
            category: .antipsychotic,
            availableDosages: ["0.25", "0.5", "1", "2", "3", "4"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Lithium",
            brandName: "Lithobid",
            category: .antipsychotic,
            availableDosages: ["150", "300", "600"],
            defaultFrequency: "Two to three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Haloperidol",
            brandName: "Haldol",
            category: .antipsychotic,
            availableDosages: ["0.5", "1", "2", "5", "10", "20"],
            defaultFrequency: "Two to three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Ziprasidone",
            brandName: "Geodon",
            category: .antipsychotic,
            availableDosages: ["20", "40", "60", "80"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Lurasidone",
            brandName: "Latuda",
            category: .antipsychotic,
            availableDosages: ["20", "40", "60", "80", "120"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - ADHD Medications
        OtherMedication(
            genericName: "Amphetamine/Dextroamphetamine",
            brandName: "Adderall",
            category: .adhd,
            availableDosages: ["5", "7.5", "10", "12.5", "15", "20", "30"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Amphetamine/Dextroamphetamine XR",
            brandName: "Adderall XR",
            category: .adhd,
            availableDosages: ["5", "10", "15", "20", "25", "30"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Methylphenidate",
            brandName: "Ritalin",
            category: .adhd,
            availableDosages: ["5", "10", "20"],
            defaultFrequency: "Two to three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Methylphenidate ER",
            brandName: "Concerta",
            category: .adhd,
            availableDosages: ["18", "27", "36", "54"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Lisdexamfetamine",
            brandName: "Vyvanse",
            category: .adhd,
            availableDosages: ["10", "20", "30", "40", "50", "60", "70"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Atomoxetine",
            brandName: "Strattera",
            category: .adhd,
            availableDosages: ["10", "18", "25", "40", "60", "80", "100"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Sleep Aids
        OtherMedication(
            genericName: "Zolpidem",
            brandName: "Ambien",
            category: .sleepAid,
            availableDosages: ["5", "10"],
            defaultFrequency: "Once daily (bedtime)",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Zolpidem CR",
            brandName: "Ambien CR",
            category: .sleepAid,
            availableDosages: ["6.25", "12.5"],
            defaultFrequency: "Once daily (bedtime)",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Eszopiclone",
            brandName: "Lunesta",
            category: .sleepAid,
            availableDosages: ["1", "2", "3"],
            defaultFrequency: "Once daily (bedtime)",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Suvorexant",
            brandName: "Belsomra",
            category: .sleepAid,
            availableDosages: ["5", "10", "15", "20"],
            defaultFrequency: "Once daily (bedtime)",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Melatonin",
            brandName: nil,
            category: .sleepAid,
            availableDosages: ["1", "3", "5", "10"],
            defaultFrequency: "Once daily (bedtime)",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Antihistamines
        OtherMedication(
            genericName: "Cetirizine",
            brandName: "Zyrtec",
            category: .antihistamine,
            availableDosages: ["5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Loratadine",
            brandName: "Claritin",
            category: .antihistamine,
            availableDosages: ["10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Levocetirizine",
            brandName: "Xyzal",
            category: .antihistamine,
            availableDosages: ["2.5", "5"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Fexofenadine",
            brandName: "Allegra",
            category: .antihistamine,
            availableDosages: ["60", "180"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Meclizine",
            brandName: "Antivert",
            category: .antihistamine,
            availableDosages: ["12.5", "25"],
            defaultFrequency: "Three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Diphenhydramine",
            brandName: "Benadryl",
            category: .antihistamine,
            availableDosages: ["25", "50"],
            defaultFrequency: "Every 4-6 hours",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Urological
        OtherMedication(
            genericName: "Tamsulosin",
            brandName: "Flomax",
            category: .urological,
            availableDosages: ["0.4"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Oxybutynin",
            brandName: "Ditropan",
            category: .urological,
            availableDosages: ["5", "10", "15"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Finasteride",
            brandName: "Proscar",
            category: .urological,
            availableDosages: ["1", "5"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Silodosin",
            brandName: "Rapaflo",
            category: .urological,
            availableDosages: ["4", "8"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Tolterodine",
            brandName: "Detrol",
            category: .urological,
            availableDosages: ["1", "2", "4"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Solifenacin",
            brandName: "Vesicare",
            category: .urological,
            availableDosages: ["5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Dutasteride",
            brandName: "Avodart",
            category: .urological,
            availableDosages: ["0.5"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Alfuzosin",
            brandName: "Uroxatral",
            category: .urological,
            availableDosages: ["10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Hormones
        OtherMedication(
            genericName: "Estradiol",
            brandName: "Estrace",
            category: .hormone,
            availableDosages: ["0.5", "1", "2"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Estradiol patch",
            brandName: "Vivelle-Dot",
            category: .hormone,
            availableDosages: ["0.025", "0.0375", "0.05", "0.075", "0.1"],
            defaultFrequency: "Twice weekly",
            isDiuretic: false,
            unit: "mg/day"
        ),
        OtherMedication(
            genericName: "Progesterone",
            brandName: "Prometrium",
            category: .hormone,
            availableDosages: ["100", "200"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Medroxyprogesterone",
            brandName: "Provera",
            category: .hormone,
            availableDosages: ["2.5", "5", "10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Testosterone gel",
            brandName: "AndroGel",
            category: .hormone,
            availableDosages: ["1", "1.62"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "%"
        ),
        OtherMedication(
            genericName: "Testosterone cypionate",
            brandName: "Depo-Testosterone",
            category: .hormone,
            availableDosages: ["100", "200"],
            defaultFrequency: "Every 1-2 weeks",
            isDiuretic: false,
            unit: "mg/mL"
        ),
        OtherMedication(
            genericName: "Conjugated estrogens",
            brandName: "Premarin",
            category: .hormone,
            availableDosages: ["0.3", "0.45", "0.625", "0.9", "1.25"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Norethindrone/Ethinyl estradiol",
            brandName: "Lo Loestrin Fe",
            category: .hormone,
            availableDosages: ["1/10"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg/mcg"
        ),

        // MARK: - Bone Health
        OtherMedication(
            genericName: "Ergocalciferol (Vitamin D2)",
            brandName: "Drisdol",
            category: .boneHealth,
            availableDosages: ["50000"],
            defaultFrequency: "Once weekly",
            isDiuretic: false,
            unit: "IU"
        ),
        OtherMedication(
            genericName: "Cholecalciferol (Vitamin D3)",
            brandName: nil,
            category: .boneHealth,
            availableDosages: ["400", "1000", "2000", "5000"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "IU"
        ),
        OtherMedication(
            genericName: "Alendronate",
            brandName: "Fosamax",
            category: .boneHealth,
            availableDosages: ["5", "10", "35", "70"],
            defaultFrequency: "Once daily or weekly",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Risedronate",
            brandName: "Actonel",
            category: .boneHealth,
            availableDosages: ["5", "35", "150"],
            defaultFrequency: "Once daily/weekly/monthly",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Calcium carbonate",
            brandName: "Tums/Os-Cal",
            category: .boneHealth,
            availableDosages: ["500", "600", "750", "1000"],
            defaultFrequency: "One to three times daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Gout Medications
        OtherMedication(
            genericName: "Allopurinol",
            brandName: "Zyloprim",
            category: .gout,
            availableDosages: ["100", "300"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Febuxostat",
            brandName: "Uloric",
            category: .gout,
            availableDosages: ["40", "80"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Colchicine",
            brandName: "Colcrys",
            category: .gout,
            availableDosages: ["0.6"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Dementia Medications
        OtherMedication(
            genericName: "Donepezil",
            brandName: "Aricept",
            category: .dementia,
            availableDosages: ["5", "10", "23"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Memantine",
            brandName: "Namenda",
            category: .dementia,
            availableDosages: ["5", "10"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Memantine XR",
            brandName: "Namenda XR",
            category: .dementia,
            availableDosages: ["7", "14", "21", "28"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Rivastigmine",
            brandName: "Exelon",
            category: .dementia,
            availableDosages: ["1.5", "3", "4.5", "6"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Rivastigmine patch",
            brandName: "Exelon Patch",
            category: .dementia,
            availableDosages: ["4.6", "9.5", "13.3"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg/24hr"
        ),

        // MARK: - Antivirals
        OtherMedication(
            genericName: "Valacyclovir",
            brandName: "Valtrex",
            category: .antiviral,
            availableDosages: ["500", "1000"],
            defaultFrequency: "Two to three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Acyclovir",
            brandName: "Zovirax",
            category: .antiviral,
            availableDosages: ["200", "400", "800"],
            defaultFrequency: "Two to five times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Oseltamivir",
            brandName: "Tamiflu",
            category: .antiviral,
            availableDosages: ["30", "45", "75"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Antifungals
        OtherMedication(
            genericName: "Fluconazole",
            brandName: "Diflucan",
            category: .antifungal,
            availableDosages: ["50", "100", "150", "200"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Terbinafine",
            brandName: "Lamisil",
            category: .antifungal,
            availableDosages: ["250"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Nystatin oral",
            brandName: "Mycostatin",
            category: .antifungal,
            availableDosages: ["100000"],
            defaultFrequency: "Four times daily",
            isDiuretic: false,
            unit: "units/mL"
        ),
        OtherMedication(
            genericName: "Ketoconazole",
            brandName: "Nizoral",
            category: .antifungal,
            availableDosages: ["200"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Itraconazole",
            brandName: "Sporanox",
            category: .antifungal,
            availableDosages: ["100"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Corticosteroids
        OtherMedication(
            genericName: "Prednisone",
            brandName: "Deltasone",
            category: .corticosteroid,
            availableDosages: ["1", "2.5", "5", "10", "20", "50"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Methylprednisolone",
            brandName: "Medrol",
            category: .corticosteroid,
            availableDosages: ["4", "8", "16", "32"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Methylprednisolone dose pack",
            brandName: "Medrol Dosepak",
            category: .corticosteroid,
            availableDosages: ["4"],
            defaultFrequency: "Per package instructions",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Prednisolone",
            brandName: "Orapred",
            category: .corticosteroid,
            availableDosages: ["5", "10", "15", "20", "30"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Hydrocortisone oral",
            brandName: "Cortef",
            category: .corticosteroid,
            availableDosages: ["5", "10", "20"],
            defaultFrequency: "Two to three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Dexamethasone",
            brandName: "Decadron",
            category: .corticosteroid,
            availableDosages: ["0.5", "0.75", "1", "1.5", "4", "6"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Budesonide oral",
            brandName: "Entocort",
            category: .corticosteroid,
            availableDosages: ["3"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Immunology/Rheumatology
        OtherMedication(
            genericName: "Methotrexate",
            brandName: "Trexall",
            category: .immunology,
            availableDosages: ["2.5", "5", "7.5", "10", "15"],
            defaultFrequency: "Once weekly",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Hydroxychloroquine",
            brandName: "Plaquenil",
            category: .immunology,
            availableDosages: ["200", "400"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Adalimumab",
            brandName: "Humira",
            category: .immunology,
            availableDosages: ["10", "20", "40"],
            defaultFrequency: "Every 2 weeks",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Etanercept",
            brandName: "Enbrel",
            category: .immunology,
            availableDosages: ["25", "50"],
            defaultFrequency: "Once or twice weekly",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Sulfasalazine",
            brandName: "Azulfidine",
            category: .immunology,
            availableDosages: ["500"],
            defaultFrequency: "Two to three times daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Leflunomide",
            brandName: "Arava",
            category: .immunology,
            availableDosages: ["10", "20"],
            defaultFrequency: "Once daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Azathioprine",
            brandName: "Imuran",
            category: .immunology,
            availableDosages: ["50"],
            defaultFrequency: "Once or twice daily",
            isDiuretic: false,
            unit: "mg"
        ),
        OtherMedication(
            genericName: "Mycophenolate",
            brandName: "CellCept",
            category: .immunology,
            availableDosages: ["250", "500"],
            defaultFrequency: "Twice daily",
            isDiuretic: false,
            unit: "mg"
        ),

        // MARK: - Neuropathic Pain
        OtherMedication(
            genericName: "Lidocaine patch",
            brandName: "Lidoderm",
            category: .painNeuropathic,
            availableDosages: ["5"],
            defaultFrequency: "Up to 12 hours daily",
            isDiuretic: false,
            unit: "%"
        ),
        OtherMedication(
            genericName: "Capsaicin cream",
            brandName: "Zostrix",
            category: .painNeuropathic,
            availableDosages: ["0.025", "0.075"],
            defaultFrequency: "Three to four times daily",
            isDiuretic: false,
            unit: "%"
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
