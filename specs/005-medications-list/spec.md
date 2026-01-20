# Feature: Medications List Management

## Overview
Enable patients to add, edit, and manage their medications on the Medications tab. Diuretics are specially flagged as they're tracked separately for daily dose logging.

## User Story
As a patient, I want to add and manage my medications so I can track what I'm taking and log my diuretic doses daily.

## Requirements

### Functional Requirements
1. Add medication with name, dosage amount, unit, and schedule
2. Mark medication as diuretic (toggle)
3. List all medications on Medications tab
4. Edit existing medication
5. Delete medication with confirmation
6. Diuretics visually distinguished in list

### Medication Fields
- **Name** (required): Drug name (e.g., "Furosemide", "Lisinopril")
- **Dosage** (required): Numeric amount (e.g., 40)
- **Unit** (required): mg, mcg, mL, etc.
- **Schedule** (optional): When to take (e.g., "Morning", "Twice daily")
- **Is Diuretic** (toggle): Flag for diuretic medications

### UI Components
- Medications list view (main tab)
- Add medication sheet/form
- Edit medication sheet/form
- Delete confirmation alert
- Empty state when no medications

### List Display
- Show medication name prominently
- Show dosage with unit (e.g., "40 mg")
- Show schedule if provided
- Diuretics marked with badge or icon
- Swipe to delete (with confirmation)
- Tap to edit

## Acceptance Criteria
- [ ] Add medication with name, dosage amount, unit, and schedule
- [ ] Mark medication as diuretic (checkbox/toggle)
- [ ] List all medications on Medications tab
- [ ] Edit existing medication
- [ ] Delete medication with confirmation
- [ ] Diuretics visually distinguished in list

## UI/UX Notes
- Use standard iOS list patterns
- Add button in navigation bar or prominent position
- Diuretic badge: pill icon or "Diuretic" label in accent color
- Form validation: name and dosage required
- Schedule field is optional (free text)
- Consider picker for common units (mg, mcg, mL)
- Empty state: friendly message encouraging adding medications

### Example Medications
- Furosemide 40 mg - Morning (Diuretic)
- Lisinopril 10 mg - Morning
- Metoprolol 25 mg - Twice daily
- Spironolactone 25 mg - Morning (Diuretic)

## Technical Notes
- Use Medication model from feature 002
- Create MedicationsViewModel with @Observable
- Use @Query to fetch all active medications
- Soft delete (set isActive = false) vs hard delete
- Sort: diuretics first, then alphabetically
- Use sheet presentation for add/edit forms
