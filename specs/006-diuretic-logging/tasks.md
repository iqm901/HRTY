# Tasks: Today View - Diuretic Logging

## ViewModel Extension
- [ ] Add diuretic medications list to TodayViewModel (filtered)
- [ ] Add today's diuretic doses property
- [ ] Add method to log standard dose (quick entry)
- [ ] Add method to log custom dose (with amount, extra flag)
- [ ] Add method to fetch doses for specific medication today

## UI Components
- [ ] Create DiureticSectionView for Today view
- [ ] Create DiureticRowView for each diuretic medication
- [ ] Display medication name and standard dosage
- [ ] Show "Log Standard Dose" button
- [ ] Show "Log Custom Dose" option
- [ ] Display today's logged doses with timestamps

## Custom Dose Entry
- [ ] Create CustomDoseSheet for logging non-standard doses
- [ ] Add dosage amount field (pre-filled, editable)
- [ ] Add "Extra Dose" toggle
- [ ] Add time picker (default to now)
- [ ] Add Save and Cancel buttons

## Today's Doses Display
- [ ] Show logged doses under each medication
- [ ] Display timestamp in friendly format
- [ ] Display dosage amount
- [ ] Show "extra" badge for extra doses
- [ ] Allow deleting logged doses (swipe or button)

## TodayView Integration
- [ ] Add diuretic section to TodayView
- [ ] Position after symptoms section
- [ ] Add section header
- [ ] Handle empty state (no diuretics configured)
- [ ] Link to Medications tab if no diuretics

## Data Persistence
- [ ] Create DiureticDose linked to DailyEntry
- [ ] Link DiureticDose to Medication
- [ ] Save dose with timestamp and extra flag
- [ ] Query today's doses on view appear

## Accessibility
- [ ] Add accessibility labels for diuretic rows
- [ ] Add accessibility labels for dose timestamps
- [ ] Add accessibility hint for extra dose indicator
- [ ] Ensure VoiceOver announces logged doses

## Quality Checks
- [ ] Diuretic list displays correctly
- [ ] Standard dose logging works
- [ ] Custom dose logging works
- [ ] Extra dose flag saves correctly
- [ ] Multiple doses per day supported
- [ ] Data persists across app restarts
- [ ] App builds without errors
