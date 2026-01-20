# Tasks: Today View - Symptom Logging

## ViewModel Extension
- [x] Add symptoms property to TodayViewModel
- [x] Add method to load existing symptoms for today
- [x] Add method to update symptom severity
- [x] Add method to save all symptoms to DailyEntry
- [x] Ensure symptoms default to severity 1 for new entries

## UI Components
- [x] Create SymptomRowView component (reusable)
- [x] Add 1-5 severity selector buttons
- [x] Highlight selected severity visually
- [x] Add color coding for severity levels (subtle)
- [x] Add patient-friendly symptom labels

## TodayView Integration
- [x] Add symptoms section to TodayView
- [x] Display all 8 symptoms in scrollable list
- [x] Wire up severity selection to ViewModel
- [x] Add section header for symptoms area
- [x] Ensure proper spacing and layout

## Data Persistence
- [x] Create SymptomEntry objects for each symptom
- [x] Link SymptomEntry to today's DailyEntry
- [x] Save symptoms when severity changes (or on explicit save)
- [x] Load existing symptoms when view appears

## Accessibility
- [x] Add accessibility labels for each symptom
- [x] Add accessibility labels for severity buttons
- [x] Ensure VoiceOver announces severity changes
- [x] Add accessibility hints explaining the scale

## Quality Checks
- [x] All 8 symptoms display correctly
- [x] Severity selection works for all symptoms
- [ ] Data persists across app restarts
- [x] Defaults to 1 for new entries
- [x] App builds without errors
