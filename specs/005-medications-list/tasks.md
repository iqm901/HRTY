# Tasks: Medications List Management

## ViewModel Setup
- [x] Create MedicationsViewModel with @Observable
- [x] Add property for medications list
- [x] Add method to add new medication
- [x] Add method to update existing medication
- [x] Add method to delete medication (with confirmation state)
- [x] Add sorting: diuretics first, then alphabetically

## List View
- [x] Update MedicationsView with actual medication list
- [x] Create MedicationRowView component
- [x] Display medication name, dosage, unit
- [x] Display schedule if present
- [x] Add diuretic badge/indicator
- [x] Add empty state when no medications
- [x] Add swipe-to-delete gesture

## Add Medication
- [x] Create AddMedicationView sheet
- [x] Add form fields: name, dosage, unit, schedule
- [x] Add diuretic toggle
- [x] Add form validation (name and dosage required)
- [x] Add Save and Cancel buttons
- [x] Wire up to ViewModel save method

## Edit Medication
- [x] Create EditMedicationView sheet (or reuse Add form)
- [x] Pre-populate form with existing values
- [x] Allow updating all fields
- [x] Wire up to ViewModel update method

## Delete Medication
- [x] Add delete confirmation alert
- [x] Implement soft delete (isActive = false)
- [x] Remove from visible list after delete

## Navigation
- [x] Add "+" button to navigation bar
- [x] Present add form as sheet
- [x] Present edit form on row tap

## Accessibility
- [x] Add accessibility labels for medication rows
- [x] Add accessibility labels for form fields
- [x] Add accessibility hint for diuretic indicator
- [x] Ensure VoiceOver works with swipe actions

## Quality Checks
- [x] Medications list displays correctly
- [x] Add, edit, delete all work
- [x] Data persists across app restarts
- [x] Diuretics are visually distinguished
- [x] Form validation prevents empty submissions
- [x] App builds without errors
