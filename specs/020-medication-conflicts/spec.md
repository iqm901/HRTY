# Feature 020: Medication Conflict Detection

## Overview

Add medication conflict detection to warn patients when they have duplicate medications within therapeutic classes (e.g., two beta-blockers) or mutually exclusive combinations (e.g., ACE inhibitor + ARB). Show alerts when adding conflicting medications and display a dismissible yellow banner on the Medications tab.

## Problem Statement

Patients with heart failure often take multiple medications, and certain combinations are typically avoided due to drug interactions or therapeutic overlap:
- Having multiple medications in the same class (e.g., two beta-blockers)
- Combining ACE inhibitors with ARBs or ARNIs

While this app is not a clinical decision-making tool, providing a gentle notification helps patients be aware of potential medication overlaps to discuss with their care team.

## Conflict Rules

| Class | Rule | Examples |
|-------|------|----------|
| Beta-blockers | Only one | carvedilol, metoprolol, bisoprolol, atenolol, nebivolol, propranolol |
| ACE inhibitors | Only one; conflicts with ARB/ARNI | lisinopril, enalapril, ramipril, benazepril, quinapril, captopril |
| ARBs | Only one; conflicts with ACEi/ARNI | losartan, valsartan, candesartan, irbesartan, telmisartan, olmesartan |
| ARNIs | Only one; conflicts with ACEi/ARB | sacubitril/valsartan (Entresto) |
| MRAs | Only one | spironolactone, eplerenone |
| SGLT2 inhibitors | Only one | empagliflozin, dapagliflozin, canagliflozin, ertugliflozin, sotagliflozin |

**Cross-class conflicts:** ACEi + ARB, ACEi + ARNI, ARB + ARNI

## User Experience

### On Add
When a user attempts to add a medication that conflicts with an existing one:
1. Alert dialog appears with title "Before You Add"
2. Message explains the conflict in warm, non-alarmist language
3. Two options: "Cancel" and "Add Anyway"
4. User can proceed if they choose

### Persistent Conflicts
If conflicts exist in the medication list:
1. Yellow dismissible banner appears at top of Medications tab
2. Banner explains conflicts and suggests verifying with care team
3. User can dismiss banner with X button
4. Banner reappears only when new conflicts are detected

### Visual Indicators
- Medications in conflict show yellow "Review" badge
- Subtle yellow background tint on conflicting medication rows

## Technical Design

### New Files
- `HRTY/Services/MedicationConflictService.swift` - Conflict detection logic
- `HRTY/Views/MedicationConflictBanner.swift` - Dismissible yellow banner
- `HRTYTests/MedicationConflictServiceTests.swift` - Unit tests

### Modified Files
- `HRTY/Models/Medication.swift` - Add categoryRawValue field
- `HRTY/Models/AppStorageKeys.swift` - Add conflictBannerDismissedAt key
- `HRTY/ViewModels/MedicationsViewModel.swift` - Add conflict state and methods
- `HRTY/Views/MedicationsView.swift` - Add banner and alert
- `HRTY/Views/MedicationRowView.swift` - Add conflict badge
- `HRTY/Views/MedicationFormView.swift` - Use conflict checking on save

## Acceptance Criteria

1. Same-class conflicts detected (e.g., two beta-blockers)
2. Cross-class conflicts detected (ACEi+ARB, ACEi+ARNI, ARB+ARNI)
3. Alert shown when adding conflicting medication
4. User can "Add Anyway" to proceed
5. Yellow banner shown when conflicts exist
6. Banner can be dismissed
7. Banner reappears when new conflicts added
8. Custom medications (no category) are ignored
9. Inactive medications are ignored
10. All messaging is warm and non-alarmist

## Non-Goals

- Do not block users from adding medications
- Do not provide medical advice
- Do not check dosages or other interactions
- Do not integrate with external drug databases
