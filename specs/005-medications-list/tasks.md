# Tasks: Medications List Management

## ViewModel Setup
- [ ] Create MedicationsViewModel with @Observable
- [ ] Add property for medications list
- [ ] Add method to add new medication
- [ ] Add method to update existing medication
- [ ] Add method to delete medication (with confirmation state)
- [ ] Add sorting: diuretics first, then alphabetically

## List View
- [ ] Update MedicationsView with actual medication list
- [ ] Create MedicationRowView component
- [ ] Display medication name, dosage, unit
- [ ] Display schedule if present
- [ ] Add diuretic badge/indicator
- [ ] Add empty state when no medications
- [ ] Add swipe-to-delete gesture

## Add Medication
- [ ] Create AddMedicationView sheet
- [ ] Add form fields: name, dosage, unit, schedule
- [ ] Add diuretic toggle
- [ ] Add form validation (name and dosage required)
- [ ] Add Save and Cancel buttons
- [ ] Wire up to ViewModel save method

## Edit Medication
- [ ] Create EditMedicationView sheet (or reuse Add form)
- [ ] Pre-populate form with existing values
- [ ] Allow updating all fields
- [ ] Wire up to ViewModel update method

## Delete Medication
- [ ] Add delete confirmation alert
- [ ] Implement soft delete (isActive = false)
- [ ] Remove from visible list after delete

## Navigation
- [ ] Add "+" button to navigation bar
- [ ] Present add form as sheet
- [ ] Present edit form on row tap

## Accessibility
- [ ] Add accessibility labels for medication rows
- [ ] Add accessibility labels for form fields
- [ ] Add accessibility hint for diuretic indicator
- [ ] Ensure VoiceOver works with swipe actions

## Quality Checks
- [ ] Medications list displays correctly
- [ ] Add, edit, delete all work
- [ ] Data persists across app restarts
- [ ] Diuretics are visually distinguished
- [ ] Form validation prevents empty submissions
- [ ] App builds without errors
