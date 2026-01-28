# Spec 020: Education Integration

## Overview

Integrate educational content from authoritative heart failure sources into the HRTY app to help patients understand their condition and self-management actions. Content is layered contextually throughout the app rather than presented as a separate reference section.

## Source Document

Educational content is compiled in `/Users/imranqm/projects/claude_code/HRTY/education.md`, which includes content from:
- Heart Failure Society of America (HFSA) Patient Education Modules
- American Heart Association (AHA) Discharge Guidance
- HSAG Heart Failure Zone Tool (Traffic Light System)
- American Association of Heart Failure Nurses (AAHFN)
- European Society of Cardiology (ESC) Self-Care Recommendations

## Design Philosophy

1. **Non-intrusive** — Don't interrupt the user's flow
2. **Contextual** — Show relevant info at the right moment
3. **Optional** — Users can dig deeper if interested
4. **Warm tone** — Consistent with the app's supportive, non-alarmist voice
5. **Source-cited** — All content includes attribution

## Implementation Phases

### Phase 1: Ambient Education (COMPLETED)

**1. EducationContent.swift** — Centralized content repository
- Location: `HRTY/Models/EducationContent.swift`
- Contains all educational text organized by topic
- Includes source citations for each piece of content

**2. Section Footers**
- Weight tip in VitalSignsGridView: weighing technique guidance
- Diuretic tip in DiureticSectionView: timing recommendation

**3. Alert Card Enhancement**
- WeightAlertView now has expandable "Why this matters" section
- Shows educational context, action suggestions, and source

**4. Symptom Info Buttons**
- Info button (ⓘ) on each symptom in the check-in wizard
- Opens sheet with educational description and source

---

### Phase 2: Medication & Zone Education (COMPLETED)

**1. Medication Class Detection**
Detect medication class from name and show relevant education:

| Medication Class | Detection Keywords | Educational Content |
|------------------|-------------------|---------------------|
| ACE Inhibitors | lisinopril, enalapril, ramipril, etc. | How they help, common side effects |
| ARBs | losartan, valsartan, candesartan, etc. | Similar to ACE-I, interaction warnings |
| Beta-blockers | metoprolol, carvedilol, bisoprolol | Initial fatigue warning, long-term benefits |
| Diuretics | furosemide, bumetanide, torsemide | How they work, weight monitoring |
| SGLT2 inhibitors | dapagliflozin, empagliflozin | Newer class, now standard therapy |
| Aldosterone antagonists | spironolactone, eplerenone | Potassium monitoring |

**2. Zone-Based Alert Integration**
Map alerts to HSAG Zone Tool colors:
- Green Zone: Symptoms under control
- Yellow Zone: Symptoms changing, call doctor
- Red Zone: Emergency, call 911

**3. Trends View Chart Explanations**
Add info buttons to each chart section header explaining:
- What the metric means
- What patterns to watch for
- Normal ranges

**4. Medications to Avoid Section**
Add info section in Medications or Settings view:
- NSAIDs warning
- Cold/cough medicine caution
- Herbal supplement interactions
- Acetaminophen as safer alternative

---

### Phase 3: Dedicated Learn Tab (TODO)

**1. Structured Educational Content**
Full "Learn" tab with expandable topics:
```
Learn About Heart Failure
├── Understanding Heart Failure
│   ├── What is heart failure?
│   ├── Common causes
│   └── Ejection fraction explained
├── Daily Self-Care
│   ├── Why weigh daily?
│   ├── Recognizing warning signs
│   └── The Zone system (Green/Yellow/Red)
├── Diet & Sodium
│   ├── Why sodium matters
│   ├── Reading food labels
│   ├── Seasoning alternatives
│   └── Restaurant tips
├── Exercise & Activity
│   ├── Safe activity levels
│   ├── Warm-up and cool-down
│   └── When to stop
├── Medications
│   ├── How your medications help
│   ├── Common side effects
│   └── Medications to avoid
├── Emotional Health
│   ├── Common feelings
│   ├── Signs of depression/anxiety
│   └── Sleep tips
├── For Family & Caregivers
│   ├── How to help
│   ├── Warning signs to watch
│   └── Caregiver self-care
└── Planning Ahead
    ├── NYHA classes explained
    └── Advance care planning
```

**2. Onboarding Enhancement**
Optional educational module during onboarding:
- "Why daily tracking matters"
- "Know your zones"
- "You're in control"

---

## New Components Needed

### HRTInfoButton
Small ⓘ button that triggers a sheet or popover.

### HRTEducationSheet
Reusable sheet with title, body, source citation, "Got it" button.

### HRTExpandableEducation
Collapsible section for inline education.

---

## Files Created/Modified

### Phase 1 (Completed)
- `HRTY/Models/EducationContent.swift` (new)
- `HRTY/Views/VitalSignsGridView.swift` (modified)
- `HRTY/Views/DiureticSectionView.swift` (modified)
- `HRTY/Views/WeightAlertView.swift` (modified)
- `HRTY/Views/SymptomCheckIn/SymptomStepView.swift` (modified)

### Phase 2 (Planned)
- `HRTY/Models/EducationContent.swift` (extend with medication content)
- `HRTY/Views/MedicationsView.swift` or `MedicationRowView.swift`
- `HRTY/Views/TrendsView.swift`
- `HRTY/Views/WeightAlertView.swift` (zone integration)

### Phase 3 (Planned)
- `HRTY/Views/LearnView.swift` (new)
- `HRTY/Views/Onboarding/` (extend)
- `HRTY/ContentView.swift` (add Learn tab)

---

## Content Mapping Reference

See `/Users/imranqm/projects/claude_code/HRTY/education.md` for full source content.

Key mappings:
- Weight monitoring → AAHFN, HFSA Module 4
- Symptoms → HFSA Modules 1, 4
- Medications → HFSA Module 3
- Diet/Sodium → HFSA Module 2, AHA
- Exercise → HFSA Module 5, ESC
- Emotional health → HFSA Module 6, ESC
- Zone system → HSAG Zone Tools
- Alert thresholds → AAHFN, ESC
