# Feature: Today View - Diuretic Logging

## Overview
Enable patients to log when they take their diuretic medications on the Today view. This tracks medication adherence and allows logging of extra doses when needed.

## User Story
As a patient, I want to log when I take my diuretics so I can track my medication adherence and note when I take extra doses.

## Requirements

### Functional Requirements
1. Shows list of diuretic medications (from Medications list where isDiuretic = true)
2. Log dose taken with actual dosage amount
3. Mark dose as "extra dose" if outside normal schedule
4. Multiple doses per day supported
5. Shows doses already logged today

### Diuretic Dose Fields
- **Medication**: Selected from diuretic medications list
- **Dosage Amount**: Numeric (pre-filled from medication, editable)
- **Timestamp**: Auto-set to now (or allow adjustment)
- **Is Extra Dose**: Toggle for unscheduled doses

### UI Components
- Diuretic section on Today view
- List of diuretic medications with "Log Dose" button
- Logged doses display for today
- Extra dose toggle in logging flow
- Empty state when no diuretics configured

### Display Requirements
- Show each diuretic medication
- Show standard dosage for reference
- Show doses already logged today with timestamps
- Visual indicator for extra doses
- Running count of doses per medication today

## Acceptance Criteria
- [ ] Shows list of diuretic medications from medication list
- [ ] Log dose taken with actual dosage amount
- [ ] Mark dose as 'extra dose' if outside normal schedule
- [ ] Multiple doses per day supported
- [ ] Shows doses already logged today

## UI/UX Notes
- Keep logging quick (one tap for standard dose)
- "Log Standard Dose" button for quick entry
- "Log Custom Dose" for different amount or extra dose
- Show timestamp in friendly format ("8:30 AM")
- Extra doses shown with distinct styling (badge/color)
- If no diuretics configured, show message linking to Medications tab

### Example Display
```
Furosemide 40 mg
  Today: 8:30 AM (40 mg) | 2:15 PM (40 mg, extra)
  [Log Standard Dose]

Spironolactone 25 mg
  Today: 8:30 AM (25 mg)
  [Log Standard Dose]
```

## Technical Notes
- Use DiureticDose model from feature 002
- Filter medications where isDiuretic = true
- Extend TodayViewModel for diuretic logging
- Link DiureticDose to today's DailyEntry
- Query today's doses for display
- Use sheet for custom dose entry
