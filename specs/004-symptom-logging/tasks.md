# Tasks: Today View - Symptom Logging

## ViewModel Extension
- [ ] Add symptoms property to TodayViewModel
- [ ] Add method to load existing symptoms for today
- [ ] Add method to update symptom severity
- [ ] Add method to save all symptoms to DailyEntry
- [ ] Ensure symptoms default to severity 1 for new entries

## UI Components
- [ ] Create SymptomRowView component (reusable)
- [ ] Add 1-5 severity selector buttons
- [ ] Highlight selected severity visually
- [ ] Add color coding for severity levels (subtle)
- [ ] Add patient-friendly symptom labels

## TodayView Integration
- [ ] Add symptoms section to TodayView
- [ ] Display all 8 symptoms in scrollable list
- [ ] Wire up severity selection to ViewModel
- [ ] Add section header for symptoms area
- [ ] Ensure proper spacing and layout

## Data Persistence
- [ ] Create SymptomEntry objects for each symptom
- [ ] Link SymptomEntry to today's DailyEntry
- [ ] Save symptoms when severity changes (or on explicit save)
- [ ] Load existing symptoms when view appears

## Accessibility
- [ ] Add accessibility labels for each symptom
- [ ] Add accessibility labels for severity buttons
- [ ] Ensure VoiceOver announces severity changes
- [ ] Add accessibility hints explaining the scale

## Quality Checks
- [ ] All 8 symptoms display correctly
- [ ] Severity selection works for all symptoms
- [ ] Data persists across app restarts
- [ ] Defaults to 1 for new entries
- [ ] App builds without errors
