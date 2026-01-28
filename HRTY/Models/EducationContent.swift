import Foundation
import SwiftUI

/// Centralized repository of educational content for heart failure self-management.
/// All content is sourced from authoritative clinical guidelines.
enum EducationContent {

    // MARK: - Weight Monitoring

    enum Weight {
        /// Brief tip for proper weighing technique
        static let techniqueTip = "For best results, weigh at the same time each morning, after using the bathroom, in similar clothing."

        /// Why daily weighing matters
        static let whyItMatters = """
            Research shows that weight often begins increasing gradually about 30 days before a hospital visit. \
            By tracking daily, you and your care team can catch changes early and adjust your plan if needed.
            """

        /// Source citation for weight monitoring
        static let source = "American Association of Heart Failure Nurses"

        /// What weight gain means
        static let whatGainMeans = """
            A sudden weight increase usually signals fluid buildup, not fat gain. \
            Your body may be holding onto extra fluid, which can make breathing harder and cause swelling.
            """

        /// Responding to weight gain
        static let respondingToGain = """
            If your weight goes up 2 or more pounds in a day, or 5 pounds in a week: \
            consider reducing sodium intake, and contact your care team to discuss whether your diuretic dose needs adjustment.
            """
    }

    // MARK: - Diuretics

    enum Diuretics {
        /// Brief timing tip
        static let timingTip = "Taking diuretics in the morning or at lunch helps avoid nighttime bathroom trips."

        /// How diuretics work
        static let howTheyWork = """
            Diuretics (water pills) help your kidneys remove excess fluid from your body. \
            This eases breathing and reduces swelling in your legs and feet.
            """

        /// Source citation
        static let source = "European Society of Cardiology"
    }

    // MARK: - Symptoms

    enum Symptoms {
        /// Educational descriptions for each symptom type
        static func description(for symptom: SymptomType) -> String {
            switch symptom {
            case .dyspneaAtRest:
                return "Fluid buildup in the lungs can make breathing difficult even when you're not active. This is important information for your care team."

            case .dyspneaOnExertion:
                return "Some breathlessness with activity is normal. Track changes in how much activity causes shortness of breath—this helps show how your heart is doing."

            case .orthopnea:
                return "Lying flat can make fluid shift toward your lungs. Many people with heart failure use extra pillows. Note how many you need to breathe comfortably."

            case .pnd:
                return "Waking up gasping can be frightening. If this happens, sit up and dangle your legs over the side of the bed. If it doesn't improve quickly, contact your care team."

            case .chestPain:
                return "Chest discomfort can have many causes. New or worsening chest pain lasting more than 15 minutes that isn't relieved by rest needs immediate medical attention."

            case .dizziness:
                return "Dizziness can be caused by low blood pressure, medications, or heart rhythm changes. Rising slowly from sitting or lying down can help prevent it."

            case .syncope:
                return "Fainting or near-fainting should always be reported to your care team, even if you feel fine afterward. It may indicate a heart rhythm problem."

            case .reducedUrineOutput:
                return "When your heart pumps less efficiently, your kidneys receive less blood flow and produce less urine. This is useful information for adjusting diuretic doses."
            }
        }

        /// Source citation for symptom information
        static let source = "Heart Failure Society of America"
    }

    // MARK: - Alerts

    enum Alerts {
        /// Educational content for different alert types
        static func learnMore(for alertType: AlertType) -> String {
            switch alertType {
            case .weightGain24h:
                return "Research shows that weight often increases gradually in the weeks before a hospitalization. Catching a 2-pound gain early gives you and your care team time to make adjustments."

            case .weightGain7d:
                return "A 5-pound gain over a week is a yellow-zone signal—your body may be holding onto fluid. This is a good time to check in with your care team about next steps."

            case .heartRateHigh:
                return "A persistently fast heart rate can be a sign of atrial fibrillation, infection, or fluid overload. Your care team should know about sustained rates above 120 bpm."

            case .heartRateLow:
                return "Some heart failure medications like beta-blockers slow the heart rate, which is often beneficial. However, if you feel dizzy, faint, or unusually tired, let your care team know."

            case .severeSymptom:
                return "A symptom rated 4 or 5 is worth discussing with your care team soon. You know your body best—trust what you're feeling."

            case .dizzinessBPCheck:
                return "Dizziness along with low blood pressure may mean your medications need adjustment. Check your blood pressure when you feel dizzy, and share the readings with your care team."

            case .lowOxygenSaturation:
                return "Oxygen levels below 90% may indicate fluid in your lungs or other breathing problems. Sit upright to help your breathing and contact your care team."

            case .lowBloodPressure:
                return "Low blood pressure without symptoms isn't usually concerning. Only report it if you feel dizzy, lightheaded, or faint. Rising slowly can help."

            case .lowMAP:
                return "Mean arterial pressure reflects how well blood is flowing to your organs. Low readings with symptoms like confusion or fatigue should be reported to your care team."
            }
        }

        /// Action suggestions for different alert types
        static func actionSuggestion(for alertType: AlertType) -> String? {
            switch alertType {
            case .weightGain24h, .weightGain7d:
                return "Consider reducing sodium intake and reaching out to your care team."

            case .heartRateHigh:
                return "Rest and recheck in 15 minutes. If it stays high, contact your care team."

            case .heartRateLow:
                return "Note how you're feeling. If dizzy or faint, contact your care team."

            case .severeSymptom:
                return "Consider contacting your care team to discuss your symptoms."

            case .dizzinessBPCheck:
                return "Check your blood pressure and share the reading with your care team."

            case .lowOxygenSaturation:
                return "Sit upright and take slow, deep breaths. Contact your care team if it doesn't improve."

            case .lowBloodPressure, .lowMAP:
                return "Rise slowly from sitting or lying. Stay hydrated and contact your care team if you have symptoms."
            }
        }

        /// Source citations for alert information
        static func source(for alertType: AlertType) -> String {
            switch alertType {
            case .weightGain24h, .weightGain7d:
                return "American Association of Heart Failure Nurses"
            case .heartRateHigh, .heartRateLow:
                return "Heart Failure Society of America"
            case .severeSymptom:
                return "HSAG Zone Tools"
            case .dizzinessBPCheck, .lowBloodPressure, .lowMAP:
                return "European Society of Cardiology"
            case .lowOxygenSaturation:
                return "Clinical guidelines"
            }
        }
    }

    // MARK: - Zone System

    enum Zones {
        static let greenZone = """
            Green Zone means your symptoms are under control. Continue taking your medications, \
            follow healthy eating habits, and keep all medical appointments.
            """

        static let yellowZone = """
            Yellow Zone means your symptoms are changing. This is a signal to call your doctor. \
            Early action can often prevent things from getting worse.
            """

        static let redZone = """
            Red Zone is a medical emergency. Call 911 immediately. \
            Do not drive yourself to the hospital.
            """

        static let source = "HSAG Zone Tools"

        /// Map an alert type to its corresponding zone
        static func zone(for alertType: AlertType) -> Zone {
            switch alertType {
            case .severeSymptom:
                return .red
            case .weightGain24h, .weightGain7d, .heartRateHigh, .heartRateLow,
                 .dizzinessBPCheck, .lowOxygenSaturation, .lowBloodPressure, .lowMAP:
                return .yellow
            }
        }
    }

    /// Zone classification for the HSAG traffic light system
    enum Zone: String, CaseIterable {
        case green = "Green"
        case yellow = "Yellow"
        case red = "Red"

        var title: String {
            switch self {
            case .green: return "Green Zone"
            case .yellow: return "Yellow Zone"
            case .red: return "Red Zone"
            }
        }

        var description: String {
            switch self {
            case .green: return Zones.greenZone
            case .yellow: return Zones.yellowZone
            case .red: return Zones.redZone
            }
        }

        var actionText: String {
            switch self {
            case .green: return "Continue your daily routine"
            case .yellow: return "Call your doctor"
            case .red: return "Call 911 immediately"
            }
        }
    }

    // MARK: - Medication Classes

    /// Medication class types for heart failure treatment
    enum MedicationClass: String, CaseIterable {
        case aceInhibitor = "ACE Inhibitor"
        case arb = "ARB"
        case betaBlocker = "Beta-Blocker"
        case diuretic = "Diuretic"
        case sglt2Inhibitor = "SGLT2 Inhibitor"
        case aldosteroneAntagonist = "Aldosterone Antagonist"
        case arni = "ARNI"
        case unknown = "Unknown"

        /// Keywords used to detect this medication class from medication names
        var detectionKeywords: [String] {
            switch self {
            case .aceInhibitor:
                return ["lisinopril", "enalapril", "ramipril", "captopril", "benazepril",
                        "fosinopril", "quinapril", "perindopril", "trandolapril", "moexipril"]
            case .arb:
                return ["losartan", "valsartan", "candesartan", "irbesartan", "olmesartan",
                        "telmisartan", "azilsartan", "eprosartan"]
            case .betaBlocker:
                return ["metoprolol", "carvedilol", "bisoprolol", "atenolol", "propranolol",
                        "nadolol", "nebivolol", "labetalol", "acebutolol", "betaxolol",
                        "coreg", "lopressor", "toprol"]
            case .diuretic:
                return ["furosemide", "bumetanide", "torsemide", "hydrochlorothiazide",
                        "chlorthalidone", "metolazone", "indapamide", "lasix", "bumex"]
            case .sglt2Inhibitor:
                return ["dapagliflozin", "empagliflozin", "canagliflozin", "ertugliflozin",
                        "farxiga", "jardiance", "invokana", "steglatro"]
            case .aldosteroneAntagonist:
                return ["spironolactone", "eplerenone", "aldactone", "inspra"]
            case .arni:
                return ["sacubitril", "entresto"]
            case .unknown:
                return []
            }
        }

        /// Detect medication class from a medication name
        static func detect(from medicationName: String) -> MedicationClass {
            let lowercaseName = medicationName.lowercased()
            for medClass in MedicationClass.allCases where medClass != .unknown {
                for keyword in medClass.detectionKeywords {
                    if lowercaseName.contains(keyword) {
                        return medClass
                    }
                }
            }
            return .unknown
        }
    }

    enum Medications {
        /// Educational content for each medication class
        static func education(for medicationClass: MedicationClass) -> MedicationEducation? {
            switch medicationClass {
            case .aceInhibitor:
                return MedicationEducation(
                    className: "ACE Inhibitor",
                    howItHelps: """
                        ACE inhibitors block harmful stress hormones that can damage your heart over time. \
                        They help relax blood vessels, making it easier for your heart to pump blood. \
                        Studies show they can improve survival and reduce hospitalizations.
                        """,
                    commonSideEffects: """
                        Dizziness (especially when standing up quickly), dry cough, and temporary changes in kidney function. \
                        Spacing out doses throughout the day can help with dizziness.
                        """,
                    importantNotes: "Never stop taking this medication without talking to your doctor first.",
                    source: "Heart Failure Society of America"
                )

            case .arb:
                return MedicationEducation(
                    className: "ARB (Angiotensin Receptor Blocker)",
                    howItHelps: """
                        ARBs work similarly to ACE inhibitors by blocking stress hormones and relaxing blood vessels. \
                        They're often prescribed if you can't tolerate the cough that ACE inhibitors can cause.
                        """,
                    commonSideEffects: """
                        Dizziness when standing, fatigue, and possible changes in kidney function. \
                        These are usually mild and manageable.
                        """,
                    importantNotes: "Do not take ARBs together with ACE inhibitors unless specifically directed by your doctor.",
                    source: "Heart Failure Society of America"
                )

            case .betaBlocker:
                return MedicationEducation(
                    className: "Beta-Blocker",
                    howItHelps: """
                        Beta-blockers slow your heart rate and reduce the workload on your heart. \
                        Over time, they can actually improve how well your heart pumps. \
                        They're proven to extend survival and reduce hospitalizations.
                        """,
                    commonSideEffects: """
                        When you first start, you may feel more tired or have some fluid buildup. \
                        This is temporary—the benefits emerge over weeks as your body adjusts. \
                        Your doctor will start with a low dose and increase it gradually.
                        """,
                    importantNotes: "Never stop a beta-blocker suddenly, as this can be dangerous. Always talk to your doctor first.",
                    source: "Heart Failure Society of America"
                )

            case .diuretic:
                return MedicationEducation(
                    className: "Diuretic (Water Pill)",
                    howItHelps: """
                        Diuretics help your kidneys remove excess fluid from your body. \
                        This eases breathing and reduces swelling in your legs and feet. \
                        They work quickly and you'll notice you urinate more often after taking them.
                        """,
                    commonSideEffects: """
                        More frequent urination, possible potassium loss (your doctor may monitor this), \
                        and dizziness if you become dehydrated. Taking diuretics in the morning or at lunch \
                        helps avoid nighttime bathroom trips.
                        """,
                    importantNotes: "Track your weight daily. Alert your care team if you gain 2+ pounds in a day or 5+ pounds in a week.",
                    source: "European Society of Cardiology"
                )

            case .sglt2Inhibitor:
                return MedicationEducation(
                    className: "SGLT2 Inhibitor",
                    howItHelps: """
                        SGLT2 inhibitors are a newer class of medication now considered standard therapy for heart failure. \
                        Originally developed for diabetes, they've been shown to significantly improve heart failure outcomes \
                        even in people without diabetes. They help your body remove extra sugar and fluid.
                        """,
                    commonSideEffects: """
                        More frequent urination, possible genital yeast infections, and mild dehydration. \
                        Drinking adequate water and maintaining good hygiene can help prevent side effects.
                        """,
                    importantNotes: "These medications are now part of guideline-directed medical therapy for heart failure with reduced ejection fraction.",
                    source: "AHA/ACC/HFSA 2022 Guidelines"
                )

            case .aldosteroneAntagonist:
                return MedicationEducation(
                    className: "Aldosterone Antagonist",
                    howItHelps: """
                        Aldosterone antagonists block stress hormones and help prevent excessive potassium loss \
                        that can occur with other diuretics. They've been shown to improve survival and reduce hospitalizations.
                        """,
                    commonSideEffects: """
                        These medications can raise potassium levels, so your doctor will monitor your blood work regularly. \
                        Some people experience breast tenderness (more common with spironolactone).
                        """,
                    importantNotes: "Follow up regularly for potassium level monitoring as directed by your care team.",
                    source: "Heart Failure Society of America"
                )

            case .arni:
                return MedicationEducation(
                    className: "ARNI (Sacubitril/Valsartan)",
                    howItHelps: """
                        ARNI combines a neprilysin inhibitor with an ARB for enhanced benefit. \
                        It's been shown to be more effective than ACE inhibitors alone at reducing \
                        hospitalizations and improving survival in heart failure.
                        """,
                    commonSideEffects: """
                        Dizziness, low blood pressure, cough, and possible kidney function changes. \
                        Take it twice daily as prescribed.
                        """,
                    importantNotes: "Cannot be taken with ACE inhibitors. If switching from an ACE inhibitor, a 36-hour washout period is needed.",
                    source: "Heart Failure Society of America"
                )

            case .unknown:
                return nil
            }
        }

    }

    // MARK: - Trends Education

    enum Trends {
        static let weightEducation = TrendEducation(
            title: "Weight Tracking",
            whatItMeans: """
                Daily weight is one of the most important ways to monitor heart failure. \
                Changes in weight often reflect fluid levels in your body, not fat gain or loss. \
                Sudden weight increases usually signal fluid buildup.
                """,
            patternsToWatch: """
                • Weight gain of 2+ pounds in one day
                • Weight gain of 5+ pounds in one week
                • Gradual upward trend over several days
                • Sudden drops may indicate dehydration
                """,
            normalRange: "Your 'dry weight' (weight without excess fluid) should be relatively stable day-to-day.",
            source: "American Association of Heart Failure Nurses"
        )

        static let heartRateEducation = TrendEducation(
            title: "Heart Rate Tracking",
            whatItMeans: """
                Heart rate shows how fast your heart is beating. In heart failure, heart rate can be affected by \
                your medications (especially beta-blockers), fluid status, and overall heart function.
                """,
            patternsToWatch: """
                • Resting heart rate consistently above 100 bpm
                • Heart rate below 50 bpm with dizziness or fatigue
                • Irregular rhythms (skipped beats, racing)
                • Sudden sustained increases may indicate worsening condition
                """,
            normalRange: "Normal resting heart rate is typically 60-100 bpm. Beta-blockers may intentionally lower this.",
            source: "Heart Failure Society of America"
        )

        static let bloodPressureEducation = TrendEducation(
            title: "Blood Pressure Tracking",
            whatItMeans: """
                Blood pressure shows the force of blood against your artery walls. Heart failure medications \
                often lower blood pressure, which is usually beneficial. The goal is to find a balance where \
                your heart is protected without causing dizziness.
                """,
            patternsToWatch: """
                • Systolic (top number) consistently above 140 mmHg
                • Diastolic (bottom number) consistently above 90 mmHg
                • Very low readings with symptoms (dizziness, fatigue)
                • Large day-to-day variations
                """,
            normalRange: "Target is usually less than 140/90 mmHg, though your doctor may set different goals for you.",
            source: "European Society of Cardiology"
        )

        static let symptomsEducation = TrendEducation(
            title: "Symptom Tracking",
            whatItMeans: """
                Tracking symptoms helps you notice gradual changes that might otherwise go unnoticed. \
                Rating symptoms on a scale makes it easier to communicate with your care team \
                and identify patterns over time.
                """,
            patternsToWatch: """
                • Any symptom rated 4 or 5 (severe)
                • Gradual worsening of any symptom over days
                • New symptoms that weren't present before
                • Symptoms that interrupt sleep or daily activities
                """,
            normalRange: "Everyone's baseline is different. Focus on changes from YOUR normal pattern.",
            source: "HSAG Zone Tools"
        )

        static let oxygenSaturationEducation = TrendEducation(
            title: "Oxygen Saturation Tracking",
            whatItMeans: """
                Oxygen saturation (SpO2) shows how much oxygen is in your blood. \
                Low levels can indicate fluid in your lungs or breathing problems. \
                Pulse oximeters measure this by shining light through your fingertip.
                """,
            patternsToWatch: """
                • Readings consistently below 95%
                • Sudden drops below 90%
                • Lower readings during activity
                • Readings that don't improve with rest
                """,
            normalRange: "Normal oxygen saturation is typically 95-100%. Some people with lung conditions may have lower baselines.",
            source: "Clinical Guidelines"
        )
    }
}

// MARK: - Supporting Types

/// Educational content for a medication class
struct MedicationEducation {
    let className: String
    let howItHelps: String
    let commonSideEffects: String
    let importantNotes: String
    let source: String
}

/// Educational content for a trend metric
struct TrendEducation {
    let title: String
    let whatItMeans: String
    let patternsToWatch: String
    let normalRange: String
    let source: String
}

// MARK: - Learn Tab Content

extension EducationContent {

    /// All sections for the Learn tab
    static let learnSections: [LearnSection] = [
        understandingHeartFailure,
        dailySelfCare,
        dietAndSodium,
        exerciseAndActivity,
        medicationsSection,
        emotionalHealth,
        familyAndCaregivers,
        planningAhead
    ]

    // MARK: - Questions for Your Doctor

    static let questionsForYourDoctor = LearnSection(
        title: "Questions for Your Doctor",
        icon: "questionmark.bubble.fill",
        topics: [
            LearnTopic(
                title: "What is my ejection fraction?",
                content: """
                    Ejection fraction (EF) measures the percentage of blood pumped out each time your heart beats. \
                    This number helps your doctor understand how well your heart is pumping.

                    **Normal:** 50-65%
                    Your heart pumps out more than half of the blood in the main pumping chamber.

                    **Reduced (HFrEF):** Below 40%
                    Called "heart failure with reduced ejection fraction." The heart muscle is weakened.

                    **Preserved (HFpEF):** 50% or higher
                    Called "heart failure with preserved ejection fraction." The heart pumps normally \
                    but is stiff and doesn't fill well.

                    Your doctor measures this with an echocardiogram (ultrasound of the heart). \
                    Knowing your ejection fraction helps you understand your treatment plan.
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "percent",
                heroColor: .coral
            ),
            LearnTopic(
                title: "What is my NYHA class?",
                content: """
                    The New York Heart Association (NYHA) classification describes how heart failure affects your daily activities. \
                    Your class can change over time with treatment.

                    **Class I - No limitation**
                    Ordinary physical activity doesn't cause symptoms. You can do normal activities without fatigue, \
                    shortness of breath, or palpitations.

                    **Class II - Slight limitation**
                    Comfortable at rest. Ordinary activity causes some fatigue, shortness of breath, or palpitations.

                    **Class III - Marked limitation**
                    Comfortable only at rest. Less than ordinary activity causes symptoms.

                    **Class IV - Severe limitation**
                    Unable to carry on any physical activity without discomfort. Symptoms may occur even at rest.

                    Knowing your NYHA class helps you understand what activities are safe and what to expect.
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "chart.bar.fill",
                heroColor: .coral
            ),
            LearnTopic(
                title: "Are my coronary arteries blocked?",
                content: """
                    Coronary artery disease is one of the most common causes of heart failure. \
                    When arteries that supply blood to your heart become narrowed or blocked, \
                    the heart muscle doesn't get enough oxygen and can become damaged.

                    **Why this matters:**
                    • Blocked arteries can cause heart attacks, which damage heart muscle
                    • Treatment options depend on whether blockages are present
                    • Some blockages can be treated with stents or bypass surgery
                    • Medications can help prevent further blockage

                    **Tests your doctor may use:**
                    • Coronary angiogram (cardiac catheterization)
                    • CT coronary angiography
                    • Stress tests

                    If you have blockages, your doctor will discuss treatment options to improve blood flow to your heart.
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "arrow.triangle.branch",
                heroColor: .coral
            ),
            LearnTopic(
                title: "Is my blood pressure controlled?",
                content: """
                    High blood pressure makes your heart work harder than it should. Over time, \
                    this extra work can weaken the heart muscle and worsen heart failure.

                    **Target blood pressure:**
                    Your doctor will set a target based on your specific situation. \
                    Many heart failure patients aim for less than 130/80 mmHg.

                    **Why control matters:**
                    • Reduces strain on your heart
                    • Many heart failure medications also lower blood pressure
                    • Uncontrolled high blood pressure can damage your heart, kidneys, and blood vessels

                    **What you can do:**
                    • Take blood pressure medications as prescribed
                    • Monitor your blood pressure at home
                    • Follow a low-sodium diet
                    • Stay physically active as recommended

                    Note: Low blood pressure without symptoms is usually not concerning. \
                    Only report low readings if you feel dizzy, lightheaded, or faint.
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "gauge.with.dots.needle.33percent",
                heroColor: .coral
            ),
            LearnTopic(
                title: "Are my heart valves damaged?",
                content: """
                    Your heart has four valves that keep blood flowing in the right direction. \
                    When valves don't work properly, it can strain your heart and contribute to heart failure.

                    **Types of valve problems:**
                    • **Stenosis:** Valve doesn't open fully, restricting blood flow
                    • **Regurgitation:** Valve doesn't close completely, allowing blood to leak backward

                    **Why this matters:**
                    • Valve problems can be a cause of heart failure
                    • They can also develop as a result of heart failure
                    • Some valve problems can be repaired or replaced
                    • Treatment depends on which valve is affected and how severe the problem is

                    **How valves are checked:**
                    Your doctor can evaluate your heart valves with an echocardiogram (ultrasound of the heart). \
                    This painless test shows how well your valves are opening and closing.

                    If you have valve problems, your doctor will monitor them and discuss treatment options if needed.
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "arrow.up.arrow.down.circle.fill",
                heroColor: .coral
            )
        ]
    )

    // MARK: - Understanding Heart Failure

    static let understandingHeartFailure = LearnSection(
        title: "Understanding Heart Failure",
        icon: "heart.fill",
        topics: [
            LearnTopic(
                title: "What is Heart Failure?",
                content: """
                    Heart failure means the heart is not pumping blood through the body as well as it should. \
                    It is NOT cardiac arrest, but rather weakened pumping action causing blood backup and fluid congestion.

                    When the heart doesn't pump effectively:
                    • Fluid can accumulate in the lungs, causing breathing difficulty
                    • Legs and feet may become swollen
                    • You may feel tired more easily

                    Heart failure is also called congestive heart failure. While it's a serious condition, \
                    it's manageable with proper care, medications, and lifestyle changes.
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "heart.fill",
                heroColor: .coral,
                heroImage: "Education/DoctorPatient"
            ),
            LearnTopic(
                title: "Common Causes",
                content: """
                    Heart failure can develop from various conditions that damage or overwork the heart:

                    • **Heart attacks** (ischemic cardiomyopathy) - damage to heart muscle
                    • **High blood pressure** - makes the heart work harder over time
                    • **Heart valve problems** - faulty valves strain the heart
                    • **Heart muscle infection or inflammation**
                    • **Lung disease and diabetes**
                    • **Excessive long-term alcohol use**

                    Sometimes the cause is unknown (idiopathic dilated cardiomyopathy). Knowing your cause \
                    helps your care team choose the best treatments for you.
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "heart.text.square.fill",
                heroColor: .coral,
                heroImage: "Education/CommonCauses"
            ),
            LearnTopic(
                title: "Ejection Fraction Explained",
                content: """
                    Ejection fraction (EF) measures the percentage of blood pumped out each time your heart beats.

                    **Normal:** 50-65%
                    Your heart pumps out more than half of the blood in the main pumping chamber.

                    **Reduced (HFrEF):** Below 40%
                    Called "heart failure with reduced ejection fraction." The heart muscle is weakened.

                    **Preserved (HFpEF):** 50% or higher
                    Called "heart failure with preserved ejection fraction." The heart pumps normally \
                    but is stiff and doesn't fill well.

                    Your doctor measures this with an echocardiogram (ultrasound of the heart). \
                    Ask your doctor: "What is my ejection fraction?"
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "percent",
                heroColor: .coral,
                heroImage: "Education/EjectionFraction"
            )
        ]
    )

    // MARK: - Daily Self-Care

    static let dailySelfCare = LearnSection(
        title: "Daily Self-Care",
        icon: "checkmark.circle.fill",
        topics: [
            LearnTopic(
                title: "Why Weigh Daily?",
                content: """
                    Daily weight is one of the most important ways to monitor heart failure. \
                    Changes in weight often reflect fluid levels in your body, not fat gain or loss.

                    **Why it matters:**
                    Research shows that weight often begins increasing gradually about 30 days before hospitalization. \
                    Within the week before hospitalization, weight gains significantly increase the odds of being admitted:
                    • 2-5 lb gain: 2.77x higher odds
                    • 5-10 lb gain: 4.46x higher odds
                    • Over 10 lb gain: 7.65x higher odds

                    **Proper technique:**
                    • Same time each morning
                    • After using the bathroom
                    • Before eating or drinking
                    • Same scale, similar clothing

                    **When to call your care team:**
                    If your weight goes up 2 pounds in one day OR 5 pounds in one week.
                    """,
                source: "American Association of Heart Failure Nurses",
                heroIcon: "scalemass.fill",
                heroColor: .teal,
                heroImage: "Education/WhyWeighDaily"
            ),
            LearnTopic(
                title: "Recognizing Warning Signs",
                content: """
                    Learning to recognize early warning signs helps you take action before symptoms get worse.

                    **Early Warning Signs (Call your doctor):**
                    • Weight gain: 2+ pounds daily or 4+ pounds weekly
                    • Leg, feet, hand, or abdominal swelling
                    • Persistent cough or chest congestion
                    • Increasing fatigue
                    • Loss of appetite or nausea

                    **Urgent Signs (Call doctor immediately):**
                    • Increasing or new shortness of breath at rest
                    • Sleep disruption from breathing difficulties
                    • Need for extra pillows to sleep
                    • Persistent palpitations with dizziness

                    **Emergency Signs (Call 911):**
                    • Chest discomfort lasting over 15 minutes unrelieved by rest
                    • Severe persistent shortness of breath
                    • Loss of consciousness
                    • Coughing up pink foamy mucus
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "exclamationmark.triangle.fill",
                heroColor: .teal,
                heroImage: "Education/WarningSigns"
            ),
            LearnTopic(
                title: "The Zone System",
                content: """
                    The Zone system uses traffic light colors to help you recognize and respond to symptoms quickly.

                    **GREEN ZONE - All Clear**
                    Your symptoms are under control:
                    • Weight is stable
                    • No shortness of breath or chest pain
                    • Able to do usual activities
                    • Normal sleep without breathing difficulty

                    Action: Continue medications, healthy eating, and keep appointments.

                    **YELLOW ZONE - Caution**
                    Your symptoms are changing:
                    • New or increased shortness of breath
                    • Sudden weight gain (2-3 lbs/day or 5 lbs/week)
                    • Increased swelling in legs, ankles, or feet
                    • Needing extra pillows to sleep

                    Action: CALL YOUR DOCTOR

                    **RED ZONE - Emergency**
                    This is a medical emergency:
                    • Severe trouble breathing
                    • Coughing up pink, foamy mucus
                    • New irregular or fast heartbeat with severe symptoms

                    Action: CALL 911 immediately. Do not drive yourself.
                    """,
                source: "HSAG Zone Tools",
                heroIcon: "circle.inset.filled",
                heroColor: .teal,
                heroImage: "Education/ZoneSystem"
            )
        ]
    )

    // MARK: - Diet & Sodium

    static let dietAndSodium = LearnSection(
        title: "Diet & Sodium",
        icon: "leaf.fill",
        topics: [
            LearnTopic(
                title: "Why Sodium Matters",
                content: """
                    Excessive sodium intake can trigger:
                    • Weight gain from fluid retention
                    • Shortness of breath
                    • Swelling in legs, ankles, and feet

                    Adequate sodium restriction enhances how well your diuretic medications work.

                    **Recommended limits:**
                    • Mild heart failure: typically 3,000 mg daily
                    • Moderate-to-severe: typically 2,000 mg daily
                    • AHA recommends less than 1,500 mg per day

                    For reference: One teaspoon of salt = approximately 2,300 mg sodium.
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "leaf.fill",
                heroColor: .green,
                heroImage: "Education/SodiumMatters"
            ),
            LearnTopic(
                title: "Reading Food Labels",
                content: """
                    Most dietary sodium (about 70%) is "hidden" in processed foods.

                    **What to look for:**
                    • Check the "Sodium" line on Nutrition Facts
                    • "Low sodium" means 140 mg or less per serving
                    • Compare serving sizes to what you actually eat
                    • Track sodium across all meals

                    **High-sodium foods to limit:**
                    • Canned soups and vegetables
                    • Deli meats and hot dogs
                    • Frozen dinners
                    • Fast food
                    • Soy sauce, ketchup, and many condiments

                    **Note:** Some medicines are also high in sodium—always read warnings before taking OTC medications.
                    """,
                source: "American Heart Association",
                heroIcon: "doc.text.magnifyingglass",
                heroColor: .green,
                heroImage: "Education/FoodLabels"
            ),
            LearnTopic(
                title: "Seasoning Alternatives",
                content: """
                    Removing the salt shaker reduces sodium by about 30%. Your taste buds adapt over weeks.

                    **Good alternatives:**
                    Allspice, basil, bay leaves, black pepper, cayenne, chili powder, cinnamon, cloves, \
                    cumin, dill, garlic powder, ginger, lemon juice, dry mustard, nutmeg, onion powder, \
                    oregano, paprika, parsley, rosemary, sage, thyme, vinegar

                    **Avoid these high-sodium seasonings:**
                    • Garlic salt or celery salt (about 1,500 mg per teaspoon)
                    • Worcestershire sauce
                    • Soy sauce and teriyaki sauce
                    • Most ketchups and taco seasonings
                    • Bouillon cubes
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "flame.fill",
                heroColor: .green,
                heroImage: "Education/SeasoningAlternatives"
            ),
            LearnTopic(
                title: "Restaurant Tips",
                content: """
                    Eating out can be challenging, but these strategies help:

                    **Before you go:**
                    • Check sodium content online
                    • Choose restaurants offering fresh food options

                    **When ordering:**
                    • Request preparation without added salt, MSG, or soy sauce
                    • Ask for sauces and dressings on the side
                    • Avoid dishes named "au gratin," "Parmesan," "casserole," or "Newberg"

                    **At the table:**
                    • Don't add salt from the shaker
                    • Choose grilled or baked over fried
                    • Ask how dishes are prepared
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "fork.knife",
                heroColor: .green,
                heroImage: "Education/RestaurantTips"
            )
        ]
    )

    // MARK: - Exercise & Activity

    static let exerciseAndActivity = LearnSection(
        title: "Exercise & Activity",
        icon: "figure.walk",
        topics: [
            LearnTopic(
                title: "Safe Activity Levels",
                content: """
                    Activity including exercise, work, and intimacy is healthy and safe for most people with heart failure. \
                    Regular movement can enhance symptom management and may potentially improve cardiac function.

                    **Getting started:**
                    • Talk to your doctor before starting an exercise program
                    • Begin with simple aerobic activities: walking, biking, or swimming
                    • Start with as little as 5 minutes daily
                    • Increase gradually to avoid injury

                    **Goals:**
                    • Accumulate at least 30 minutes of activity per day on most days
                    • Can be split into shorter sessions (e.g., three 10-minute blocks)
                    • Exercise at levels producing mild-to-moderate breathlessness when possible
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "figure.walk",
                heroColor: .blue,
                heroImage: "Education/SafeActivityLevels"
            ),
            LearnTopic(
                title: "Warm-Up and Cool-Down",
                content: """
                    Proper warm-up and cool-down protect your heart during exercise.

                    **Warm-up (5 minutes):**
                    • Start slowly and gradually increase intensity
                    • Prepares your heart and muscles for activity
                    • Helps prevent injury

                    **Cool-down (5 minutes):**
                    • Gradually decrease intensity
                    • Never stop exercise abruptly—this can cause dizziness
                    • Allow your heart rate to return toward normal

                    **Timing tips:**
                    • Exercise during your peak energy time (typically mornings)
                    • Wait one hour after light meals before exercising
                    • Avoid outdoor activity when temperatures below 40°F or above 80°F
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "figure.cooldown",
                heroColor: .blue,
                heroImage: "Education/WarmUpCoolDown"
            ),
            LearnTopic(
                title: "When to Stop",
                content: """
                    Stop activity immediately if you experience:

                    • **Chest pain** - rest and contact your care team
                    • **Shortness of breath preventing conversation**
                    • **Dizziness** - sit down slowly
                    • **Irregular pulse** - note the pattern and duration
                    • **Extreme fatigue**

                    **Energy conservation tips:**
                    • Use sitting positions when possible
                    • Organize items at waist level
                    • Pull rather than push objects
                    • Take breaks between activities

                    Listen to your body. Some days you'll have more energy than others, and that's okay.
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "hand.raised.fill",
                heroColor: .blue,
                heroImage: "Education/WhenToStop"
            )
        ]
    )

    // MARK: - Medications

    static let medicationsSection = LearnSection(
        title: "Medications",
        icon: "pills.fill",
        topics: [
            LearnTopic(
                title: "How Your Medications Help",
                content: """
                    Heart failure medications can help you:
                    • Live longer
                    • Have fewer symptoms
                    • Breathe more easily
                    • Gain energy and increase activity
                    • Reduce swelling
                    • Stay out of the hospital

                    **Major medication classes:**
                    • **ACE inhibitors/ARBs/ARNI** - Relax blood vessels, reduce heart strain
                    • **Beta-blockers** - Slow heart rate, improve pumping over time
                    • **Diuretics** - Remove excess fluid
                    • **SGLT2 inhibitors** - Newer class, now standard therapy
                    • **Aldosterone antagonists** - Block stress hormones

                    Each medication works differently. Together, they give your heart the best chance to heal.
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "pills.fill",
                heroColor: .purple,
                heroImage: "Education/HowMedicationsHelp"
            ),
            LearnTopic(
                title: "Common Side Effects",
                content: """
                    Some side effects are temporary as your body adjusts:

                    **Dizziness**
                    Common with ACE inhibitors, ARBs, and beta-blockers. Rise slowly from sitting or lying. \
                    Spacing doses throughout the day can help.

                    **Fatigue**
                    When starting beta-blockers, temporary fatigue is common. Benefits emerge over weeks as your body adjusts.

                    **Frequent urination**
                    Diuretics cause this—it means they're working. Take them morning or lunchtime to avoid nighttime trips.

                    **Cough**
                    ACE inhibitors may cause dry cough. If bothersome, ARBs are an alternative.

                    **Never stop medications without talking to your doctor first.**
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "exclamationmark.bubble.fill",
                heroColor: .purple,
                heroImage: "Education/CommonSideEffects"
            ),
            LearnTopic(
                title: "Medications to Avoid",
                content: """
                    Some over-the-counter medications and supplements can worsen heart failure or interact with your prescribed medications.

                    **NSAIDs (Pain Relievers)**
                    Examples: Ibuprofen (Advil, Motrin), Naproxen (Aleve), Aspirin (high doses)

                    *Why to avoid:* Can cause your body to retain fluid and worsen heart failure. May also reduce the effectiveness of your heart failure medications.

                    *Safer alternative:* Use acetaminophen (Tylenol) for pain relief instead. Always check with your care team first.

                    **Cold & Cough Medicines**
                    Examples: Decongestants containing pseudoephedrine or phenylephrine (Sudafed, many cold/flu products)

                    *Why to avoid:* Can raise blood pressure, increase heart rate, and trigger irregular heart rhythms.

                    *Safer alternative:* Ask your pharmacist for heart-safe alternatives. Saline nasal spray and steam inhalation are usually safe.

                    **Herbal Supplements**
                    Examples: Ephedra, St. John's wort, ginseng, ginkgo, hawthorn, Chinese herbs

                    *Why to avoid:* May interact with heart failure medications or directly affect heart function. St. John's wort can reduce the effectiveness of many medications.

                    *Safer alternative:* Always consult your healthcare team before taking any herbal products or supplements.

                    **Certain Calcium Channel Blockers**
                    Examples: Diltiazem, verapamil, nifedipine

                    *Why to avoid:* Can worsen heart failure in some patients by reducing the heart's pumping ability.

                    *Safer alternative:* If you need a calcium channel blocker, amlodipine and felodipine are generally safer options. Your doctor will choose what's right for you.
                    """,
                source: "Heart Failure Society of America & European Society of Cardiology",
                heroIcon: "xmark.circle.fill",
                heroColor: .purple,
                heroImage: "Education/MedicationsToAvoid"
            ),
            LearnTopic(
                title: "Ways to Improve Adherence",
                content: """
                    Taking your medications consistently is key to managing heart failure effectively. \
                    Here are practical strategies to help you stay on track:

                    **Use a Pill Organizer**
                    Weekly pill organizers with day and time labels help you track whether you've taken each dose.

                    **Set Alarms**
                    Phone or watch alarms at dosing times provide helpful reminders throughout the day.

                    **Keep a Medication List**
                    Post your medication list on your refrigerator and keep a copy in your wallet for emergencies.

                    **Refill Early**
                    Reorder prescriptions a week before running out to prevent gaps in your treatment.

                    **Space Doses for Dizziness**
                    If dizziness is a problem, ask your doctor about spreading doses throughout the day.

                    **Involve Family**
                    Share your medication schedule with family members who can help remind you.
                    """,
                source: "Heart Failure Society of America & European Society of Cardiology",
                heroIcon: "checkmark.circle.fill",
                heroColor: .purple,
                heroImage: nil
            )
        ]
    )

    // MARK: - Emotional Health

    static let emotionalHealth = LearnSection(
        title: "Emotional Health",
        icon: "brain.head.profile",
        topics: [
            LearnTopic(
                title: "Common Feelings",
                content: """
                    Living with heart failure can bring many emotions:
                    • Depression
                    • Anxiety
                    • Anger
                    • Loss of control
                    • Uncertainty
                    • Feeling burdensome to others

                    These feelings are normal. However, unmanaged negative emotions can lead to hormonal imbalances \
                    that make heart failure worse and increase hospitalization risk.

                    **Coping strategies:**
                    • Confide in trusted friends, family, or support group members
                    • Exercise regularly
                    • Pursue new activities to redirect focus
                    • Spend daily time outdoors for mental clarity
                    • Learn about self-care—knowledge helps you feel more in control
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "brain.head.profile",
                heroColor: .indigo,
                heroImage: "Education/CommonFeelings"
            ),
            LearnTopic(
                title: "Signs of Depression or Anxiety",
                content: """
                    **Depression warning signs (lasting 2+ weeks):**
                    • Persistent low mood
                    • Difficulty concentrating
                    • Loss of interest in previously enjoyed activities
                    • Social withdrawal
                    • Excessive fatigue or sleepiness
                    • Feelings of worthlessness or guilt
                    • Hopelessness or suicidal thoughts
                    • Changes in appetite

                    **Anxiety warning signs (lasting 2+ weeks):**
                    • Constant worry
                    • Irrational fear responses
                    • Physical tension and shakiness
                    • Restlessness
                    • Persistent "on-edge" feelings

                    If you notice these signs, talk to your care team. Effective treatments are available.
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "waveform.path.ecg",
                heroColor: .indigo,
                heroImage: "Education/DepressionAnxiety"
            ),
            LearnTopic(
                title: "Sleep Tips",
                content: """
                    Good sleep promotes healing and helps manage heart failure.

                    **Healthy sleep habits:**
                    • Maintain a consistent sleep schedule
                    • Avoid caffeine late in the day
                    • Try evening relaxation: yoga, mindfulness, short walks
                    • Avoid screens one hour before bed
                    • Keep your bedroom cool and dark

                    **Report to your care team:**
                    • Difficulty breathing when lying flat (orthopnea)
                    • Waking up gasping for air (nocturnal dyspnea)
                    • Snoring or suspected sleep apnea

                    If you need extra pillows to breathe comfortably at night, track how many—this helps your care team.
                    """,
                source: "European Society of Cardiology",
                heroIcon: "moon.zzz.fill",
                heroColor: .indigo,
                heroImage: "Education/SleepTips"
            )
        ]
    )

    // MARK: - Family & Caregivers

    static let familyAndCaregivers = LearnSection(
        title: "For Family & Caregivers",
        icon: "person.2.fill",
        topics: [
            LearnTopic(
                title: "How to Help",
                content: """
                    Family and friends play an important role in heart failure management.

                    **Symptom monitoring:**
                    • Watch for increased shortness of breath or mental confusion
                    • Help track daily weight—a 4-pound gain over one week may indicate fluid retention
                    • Monitor pillow usage for nighttime breathing difficulty
                    • Use acetaminophen rather than NSAIDs for pain relief

                    **Emotional support:**
                    • Acknowledge adherence to treatment plans and lifestyle changes
                    • Offer choices rather than directives
                    • Provide regular visits, calls, emails
                    • Invite participation in social events
                    • Discuss feelings of depression or anxiety openly
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "person.2.fill",
                heroColor: .orange,
                heroImage: "Education/HowToHelp"
            ),
            LearnTopic(
                title: "Warning Signs to Watch",
                content: """
                    Learn to recognize when something isn't right:

                    **Call the doctor if you notice:**
                    • Weight gain of 2+ pounds in a day or 5+ pounds in a week
                    • Increased swelling in ankles or legs
                    • More shortness of breath than usual
                    • New or worsening cough
                    • Confusion or difficulty thinking clearly
                    • Loss of appetite or nausea
                    • Increasing fatigue

                    **Call 911 if you see:**
                    • Severe shortness of breath
                    • Chest pain lasting more than 15 minutes
                    • Fainting or loss of consciousness
                    • Coughing up pink, foamy mucus
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "eye.fill",
                heroColor: .orange,
                heroImage: "Education/WarningSignsToWatch"
            ),
            LearnTopic(
                title: "Caregiver Self-Care",
                content: """
                    Taking care of yourself is essential so you can continue helping your loved one.

                    **Your well-being matters:**
                    • Utilize emotional support resources
                    • Arrange respite care when available
                    • Maintain your own sleep, exercise, and nutrition
                    • Burnout risk is real—establish a relief team of family and friends

                    **Get support:**
                    • Seek caregiver support groups
                    • Address your own depression or anxiety with a professional if needed
                    • It's okay to ask for help

                    **Conversation starters:**
                    • "What can we do to make you feel better?"
                    • "We want to make you as comfortable as possible—what should we focus on?"
                    """,
                source: "European Society of Cardiology",
                heroIcon: "heart.circle.fill",
                heroColor: .orange,
                heroImage: "Education/CaregiverSelfCare"
            )
        ]
    )

    // MARK: - Planning Ahead

    static let planningAhead = LearnSection(
        title: "Planning Ahead",
        icon: "doc.text.fill",
        topics: [
            LearnTopic(
                title: "NYHA Classes Explained",
                content: """
                    The New York Heart Association (NYHA) classification describes how heart failure affects your activity:

                    **Class I - No limitation**
                    Ordinary physical activity doesn't cause symptoms. You can do normal activities without fatigue, \
                    shortness of breath, or palpitations.

                    **Class II - Slight limitation**
                    Comfortable at rest. Ordinary activity causes some fatigue, shortness of breath, or palpitations.

                    **Class III - Marked limitation**
                    Comfortable only at rest. Less than ordinary activity causes symptoms.

                    **Class IV - Severe limitation**
                    Unable to carry on any physical activity without discomfort. Symptoms may occur even at rest.

                    Your class can change over time with treatment. Ask your doctor: "What is my NYHA class?"
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "chart.bar.fill",
                heroColor: .slate,
                heroImage: "Education/NYHAClassesExplained"
            ),
            LearnTopic(
                title: "Advance Care Planning",
                content: """
                    Planning ahead ensures your wishes are known and respected.

                    **Important documents:**
                    • **Advance Care Directive** - Guides future medical decisions
                    • **Living Will** - Expresses end-of-life wishes if you can't communicate
                    • **Healthcare Power of Attorney** - Designates someone to make decisions for you
                    • **DNR Order** - Specifies preferences for resuscitation

                    **Steps to take:**
                    • Provide copies to your healthcare team and designated decision-maker
                    • Carry a wallet card indicating your directives exist
                    • Review every few years and update if preferences change
                    • Consider consulting an elder-law attorney for legal compliance

                    **Care options:**
                    • **Palliative care** - Focuses on comfort at any disease stage
                    • **Hospice care** - For patients with approximately 6 months or less expected lifespan
                    """,
                source: "Heart Failure Society of America",
                heroIcon: "doc.text.fill",
                heroColor: .slate,
                heroImage: "Education/AdvanceCarePlanning"
            )
        ]
    )
}

// MARK: - Learn Tab Supporting Types

/// A section in the Learn tab containing multiple topics
struct LearnSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let topics: [LearnTopic]
}

/// A topic within a Learn section
struct LearnTopic: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let content: String
    let source: String
    let heroIcon: String
    let heroColor: HeroColor
    let heroImage: String?

    /// Simplified initializer that uses section defaults
    init(title: String, content: String, source: String, heroIcon: String = "heart.fill", heroColor: HeroColor = .coral, heroImage: String? = nil) {
        self.title = title
        self.content = content
        self.source = source
        self.heroIcon = heroIcon
        self.heroColor = heroColor
        self.heroImage = heroImage
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: LearnTopic, rhs: LearnTopic) -> Bool {
        lhs.id == rhs.id
    }
}

/// Color theme for topic hero images
enum HeroColor {
    case coral       // Heart/understanding topics
    case teal        // Self-care topics
    case green       // Diet/nutrition topics
    case blue        // Exercise topics
    case purple      // Medication topics
    case indigo      // Emotional health topics
    case orange      // Family/caregiver topics
    case slate       // Planning topics

    var gradient: [Color] {
        switch self {
        case .coral:
            return [Color(red: 0.95, green: 0.4, blue: 0.4), Color(red: 0.85, green: 0.25, blue: 0.35)]
        case .teal:
            return [Color(red: 0.2, green: 0.7, blue: 0.7), Color(red: 0.15, green: 0.55, blue: 0.6)]
        case .green:
            return [Color(red: 0.3, green: 0.75, blue: 0.45), Color(red: 0.2, green: 0.6, blue: 0.35)]
        case .blue:
            return [Color(red: 0.3, green: 0.55, blue: 0.9), Color(red: 0.2, green: 0.4, blue: 0.8)]
        case .purple:
            return [Color(red: 0.6, green: 0.4, blue: 0.8), Color(red: 0.45, green: 0.3, blue: 0.7)]
        case .indigo:
            return [Color(red: 0.4, green: 0.35, blue: 0.8), Color(red: 0.3, green: 0.25, blue: 0.65)]
        case .orange:
            return [Color(red: 0.95, green: 0.6, blue: 0.3), Color(red: 0.9, green: 0.45, blue: 0.2)]
        case .slate:
            return [Color(red: 0.45, green: 0.5, blue: 0.55), Color(red: 0.35, green: 0.4, blue: 0.45)]
        }
    }
}

// MARK: - Onboarding Education Content

extension EducationContent {

    enum Onboarding {
        static let whyTrackingMatters = OnboardingEducation(
            title: "Why Daily Tracking Matters",
            icon: "chart.line.uptrend.xyaxis",
            content: """
                Research shows that small changes in weight and symptoms often appear \
                weeks before a hospitalization. By tracking daily, you can catch these \
                changes early—when they're easiest to address.

                Just a few minutes each day gives you and your care team the information \
                needed to keep you feeling your best.
                """,
            source: "American Association of Heart Failure Nurses"
        )

        static let knowYourZones = OnboardingEducation(
            title: "Know Your Zones",
            icon: "circle.inset.filled",
            content: """
                The Zone system uses traffic light colors to help you respond to symptoms:

                **Green Zone**: Symptoms under control. Keep doing what you're doing.

                **Yellow Zone**: Symptoms are changing. Call your doctor.

                **Red Zone**: Medical emergency. Call 911.

                Learning your zones helps you know when to take action—and when you're doing great.
                """,
            source: "HSAG Zone Tools"
        )

        static let youAreInControl = OnboardingEducation(
            title: "You're in Control",
            icon: "hand.raised.fill",
            content: """
                Heart failure is a serious condition, but it's manageable. With the right knowledge \
                and daily attention, many people live full, active lives.

                HRTY is your partner in this journey—helping you track what matters, \
                spot changes early, and communicate clearly with your care team.

                You've got this.
                """,
            source: "Heart Failure Society of America"
        )
    }
}

/// Educational content for onboarding
struct OnboardingEducation {
    let title: String
    let icon: String
    let content: String
    let source: String
}
