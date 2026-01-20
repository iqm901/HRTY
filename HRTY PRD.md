Below is a **single, consolidated V1 design summary document** for **HRTY**, incorporating **all decisions made across this conversation**. This is written to function as a canonical reference you can share with developers, designers, collaborators, or future reviewers.

---

# **HRTY — V1 Design & Product Specification**

**Version:** 1.0 (Consolidated)  
**Status:** Fully specified, ready for implementation  
**Working name:** HRTY

---

## **1\. Product Overview**

**HRTY** is a patient-facing, offline-first iOS application designed to simplify the daily self-management of heart failure. The app consolidates core elements of heart failure care—daily weight, symptoms, diuretic use, and relevant physiologic data—into a low-burden workflow that improves patient understanding while remaining clinically legible to physicians.

The app is explicitly **not a clinical decision-making tool**. It is a **self-management tracker** intended to support patient–clinician conversations and reduce cognitive load for patients and caregivers.

---

## **2\. Target Users**

### **Primary User**

* A patient with heart failure **(HFpEF, HFmrEF, or HFrEF)**

### **Secondary User**

* A caregiver using **the patient’s phone** (V1 constraint)

### **Explicitly Out of Scope**

* Clinician-facing dashboards  
* Remote caregiver access  
* Automated clinical messaging  
* Prescriptive medical advice

---

## **3\. Core Problem Being Addressed**

Heart failure management is cognitively complex and fragmented. Patients are expected to track weight, symptoms, medications, diet, and activity, often without clear consolidation or feedback. This fragmentation increases mental burden, reduces adherence, and complicates clinical visits.

HRTY addresses this by:

* Centralizing essential daily data  
* Reducing daily interaction time to under two minutes  
* Presenting trends in a clinician-legible format  
* Supporting—but not replacing—clinical judgment

---

## **4\. Definition of Success**

### **V1 Success**

* Regular use (≥5 days/week)  
* Positive App Store reviews emphasizing simplicity and clarity  
* Real-world use of PDF exports during clinic visits

### **Long-Term (Future)**

* Pragmatic clinical trials assessing impact on HF admissions, readmissions, and mortality

---

## **5\. Platform & Runtime Environment**

* **Platform:** iOS  
* **Primary device:** iPhone  
* **Optional integration:** Apple Watch via Apple Health  
* **Architecture:** Offline-first, on-device data storage  
* **No cloud accounts or backend in V1**

---

## **6\. Clinical Scope**

### **Included**

* HFpEF, HFmrEF, HFrEF  
* Guideline-directed medical therapy (GDMT)  
* Common adjunct cardiac medications  
* Loop diuretics and thiazides  
* Blood pressure, heart rate, activity (optional)

### **Excluded**

* Echocardiogram / EF tracking  
* Non-cardiac medications (e.g., insulin, chemotherapy)  
* Anticoagulation logic  
* Diagnostic or prognostic modeling

---

## **7\. Core Daily Workflow (≤2 Minutes)**

The **daily core loop** consists of:

1. **Daily weight entry**  
2. **Symptom severity logging**  
3. **Diuretic intake logging (with dosage)**  
4. Passive alerting if thresholds are crossed  
5. Optional review of trends

---

## **8\. Data Collected**

### **Daily Check-In**

* **Weight** (manual or Apple Health import)  
* **Symptoms**, each rated on a 1–5 severity scale:  
  * Dyspnea at rest  
  * Dyspnea on exertion  
  * Orthopnea  
  * Paroxysmal nocturnal dyspnea (PND)  
  * Chest pain  
  * Dizziness  
  * Syncope  
  * Reduced urine output  
* **Diuretic intake**  
  * Medication  
  * Dosage amount  
  * Unit  
  * Extra dose flag

### **Optional / Passive Data (via Apple Health)**

* Resting heart rate  
* Heart rate variability  
* Blood pressure  
* Steps / activity

---

## **9\. Alerting & Safety Logic**

All alerts are **non-prescriptive**, patient-facing, and framed as prompts to consider contacting a clinician.

### **Weight Gain Alerts**

Triggered if:

* ≥2 lb increase in 24 hours, OR  
* ≥5 lb increase over 7 days

### **Heart Rate Alerts**

Triggered if resting HR is persistently:

* **\<40 bpm** (bradycardia), OR  
* **\>120 bpm** (tachycardia)

### **Symptom Severity Alerts**

Triggered if any symptom is logged as **4 or 5**

* In-app message advising discussion with clinician

### **Dizziness \+ Missing Blood Pressure**

If dizziness ≥3 and BP unavailable:

* Prompt to check BP manually  
* If unable, advise contacting clinician  
* Orthostatic precautions suggested

### **Explicit Guardrails**

* No treatment recommendations  
* No medication adjustments suggested  
* No diagnostic language  
* No clinician contact automation

---

## **10\. Medication Handling**

### **Onboarding**

* User uploads photo(s) of medication list or pill bottles  
* Best-effort extraction (optional in V1)  
* User manually confirms medication list

### **Validation**

* Implausible doses or schedules are **flagged**, not blocked  
* Message: “This schedule is uncommon. Please confirm with your clinician.”

### **Diuretic Logging**

* Actual dosage amounts are logged  
* Extra doses tracked as events  
* No automated dose recommendations

---

## **11\. Trends & Visualization**

### **Primary View**

* **30-day rolling trend**

### **Displays**

* Daily weight (line chart)  
* Symptom severity trends (raw, per symptom)  
* Optional markers:  
  * Extra diuretic doses  
  * Alert days

### **Design Philosophy**

* No composite “scores”  
* No dry weight defined by app  
* Clinician infers dry weight from trends

---

## **12\. Export Functionality**

### **Format**

* **One-tap PDF export**

### **Purpose**

* Shown directly to clinicians during visits

### **PDF Contents**

* Patient identifier (optional)  
* Date range  
* 30-day weight trend  
* Symptom severity trends  
* Diuretic dosing history  
* Alert events  
* Footer disclaimer:  
  “This summary reflects patient-entered data for self-management and discussion with a clinician.”

---

## **13\. Tone & UX Philosophy**

* Warm  
* Coaching  
* Reassuring  
* Restrained  
* Never alarmist  
* Never authoritative

The app supports reflection and awareness, not compliance enforcement.

---

## **14\. App Structure (V1)**

**Bottom navigation tabs:**

1. Today  
2. Trends  
3. Medications  
4. Export  
5. Settings

---

## **15\. Data Storage & Privacy**

* All data stored **on-device only**  
* No cloud sync in V1  
* Fully functional offline  
* Apple Health used as a read-only data source  
* Clear in-app privacy messaging

---

## **16\. Explicitly Out of Scope for V1**

* Remote caregiver access  
* Clinician dashboards  
* Predictive analytics  
* Risk stratification scores  
* Echo data  
* Cloud accounts or logins  
* Automated clinical escalation  
* Behavioral gamification

---

## **17\. Implementation Status**

* Product definition: **Complete**  
* Low-fidelity wireframes: **Complete**  
* SwiftUI screen mapping: **Complete**  
* Ready for:  
  * Figma build  
  * SwiftUI project scaffolding  
  * Developer handoff

---

## **18\. Summary Statement**

HRTY V1 is a deliberately constrained, safety-conscious, patient-centered heart failure self-management tool. Its strength lies not in algorithmic sophistication, but in clarity, restraint, and respect for the realities of chronic illness and clinical care.

It is designed to be *used*, not admired—and to fit naturally into real clinical conversations.

---

If you would like, I can next:

* Turn this into a **developer-facing PRD**  
* Generate a **SwiftUI starter repository structure**  
* Draft **App Store listing copy**  
* Or help you plan a **V2 roadmap** grounded in real-world usage signals

