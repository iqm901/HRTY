# Tasks: Education Integration

## Phase 1: Ambient Education (COMPLETED)

- [x] Create `EducationContent.swift` with centralized educational text
- [x] Add weight monitoring tip footer to VitalSignsGridView
- [x] Add diuretic timing tip footer to DiureticSectionView
- [x] Enhance WeightAlertView with expandable "Why this matters" section
- [x] Add symptom info buttons to SymptomStepView with educational sheets

---

## Phase 2: Medication & Zone Education (COMPLETED)

### Medication Class Education
- [x] Add medication class detection logic (keyword matching)
- [x] Extend `EducationContent.swift` with medication class content
- [x] Add info button/section to MedicationRowView showing class-specific education
- [x] Add "Medications to Avoid" info section (NSAIDs, cold medicine, herbals)
- [x] Add adherence tips section (pill organizers, alarms, refill reminders)

### Zone-Based Alert Integration
- [x] Map alert types to HSAG zone colors (Green/Yellow/Red)
- [x] Add zone indicator or framing to alert messages
- [x] Zone-based coloring for alert cards

### Trends View Explanations
- [x] Add info button to Weight chart section header
- [x] Add info button to Heart Rate chart section header
- [x] Add info button to Blood Pressure chart section header
- [x] Add info button to Oxygen Saturation chart section header
- [x] Add info button to Symptoms chart section header
- [x] Each info button opens sheet explaining metric and patterns

---

## Phase 3: Dedicated Learn Tab (COMPLETED)

### Learn View Structure
- [x] Create `LearnView.swift` with expandable topic sections
- [x] Add "Understanding Heart Failure" section
- [x] Add "Daily Self-Care" section
- [x] Add "Diet & Sodium" section
- [x] Add "Exercise & Activity" section
- [x] Add "Medications" section
- [x] Add "Emotional Health" section
- [x] Add "For Family & Caregivers" section
- [x] Add "Planning Ahead" section

### Navigation Integration
- [x] Add Learn tab to ContentView TabView
- [x] Choose appropriate icon and label

### Onboarding Enhancement
- [x] Add optional "Why daily tracking matters" page
- [x] Add optional "Know your zones" page
- [x] Add optional "You're in control" page

---

## Reusable Components (as needed)

- [ ] Create `HRTInfoButton` component
- [ ] Create `HRTEducationSheet` component
- [ ] Create `HRTExpandableEducation` component

---

## Notes

- All educational content should cite sources
- Maintain warm, supportive tone throughout
- Education is optional/on-demand, never interrupting
- Test with VoiceOver for accessibility
