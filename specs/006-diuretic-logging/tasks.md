# Tasks: Today View - Diuretic Logging

## ViewModel Extension
- [x] Add diuretic medications list to TodayViewModel (filtered)
- [x] Add today's diuretic doses property
- [x] Add method to log standard dose (quick entry)
- [x] Add method to log custom dose (with amount, extra flag)
- [x] Add method to fetch doses for specific medication today

## UI Components
- [x] Create DiureticSectionView for Today view
- [x] Create DiureticRowView for each diuretic medication
- [x] Display medication name and standard dosage
- [x] Show "Log Standard Dose" button
- [x] Show "Log Custom Dose" option
- [x] Display today's logged doses with timestamps

## Custom Dose Entry
- [x] Create CustomDoseSheet for logging non-standard doses
- [x] Add dosage amount field (pre-filled, editable)
- [x] Add "Extra Dose" toggle
- [x] Add time picker (default to now)
- [x] Add Save and Cancel buttons

## Today's Doses Display
- [x] Show logged doses under each medication
- [x] Display timestamp in friendly format
- [x] Display dosage amount
- [x] Show "extra" badge for extra doses
- [x] Allow deleting logged doses (swipe or button)

## TodayView Integration
- [x] Add diuretic section to TodayView
- [x] Position after symptoms section
- [x] Add section header
- [x] Handle empty state (no diuretics configured)
- [x] Link to Medications tab if no diuretics

## Data Persistence
- [x] Create DiureticDose linked to DailyEntry
- [x] Link DiureticDose to Medication
- [x] Save dose with timestamp and extra flag
- [x] Query today's doses on view appear

## Accessibility
- [x] Add accessibility labels for diuretic rows
- [x] Add accessibility labels for dose timestamps
- [x] Add accessibility hint for extra dose indicator
- [x] Ensure VoiceOver announces logged doses

## Quality Checks
- [x] Diuretic list displays correctly
- [x] Standard dose logging works
- [x] Custom dose logging works
- [x] Extra dose flag saves correctly
- [x] Multiple doses per day supported
- [x] Data persists across app restarts
- [x] App builds without errors
