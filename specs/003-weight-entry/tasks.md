# Tasks: Today View - Weight Entry

## ViewModel Setup
- [x] Create TodayViewModel with @Observable
- [x] Add weight input property (String for TextField binding)
- [x] Add computed property for parsed weight (Double?)
- [x] Add validation logic for weight range (50-500 lbs)
- [x] Add save method that creates/updates DailyEntry

## Data Integration
- [x] Fetch or create today's DailyEntry on view appear
- [x] Fetch yesterday's DailyEntry for comparison
- [x] Calculate weight change from yesterday
- [x] Save weight to DailyEntry via SwiftData

## UI Components
- [x] Add weight input section to TodayView
- [x] Create weight TextField with decimal keyboard
- [x] Add "Save Weight" button (or auto-save)
- [x] Display previous day's weight
- [x] Display weight change with +/- indicator
- [x] Add color coding for weight change
- [x] Add validation error message display

## User Feedback
- [x] Show success feedback when weight saved
- [x] Show "First entry" message if no previous data
- [x] Add appropriate placeholder text in input field

## Accessibility
- [x] Add accessibility labels to weight input
- [x] Add accessibility hints for weight change
- [x] Ensure VoiceOver reads weight change meaningfully

## Quality Checks
- [x] Weight entry compiles without errors
- [x] App builds successfully
- [ ] Weight saves and persists across app restarts
- [ ] Validation rejects out-of-range values
- [ ] Previous day comparison works correctly
