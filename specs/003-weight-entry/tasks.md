# Tasks: Today View - Weight Entry

## ViewModel Setup
- [ ] Create TodayViewModel with @Observable
- [ ] Add weight input property (String for TextField binding)
- [ ] Add computed property for parsed weight (Double?)
- [ ] Add validation logic for weight range (50-500 lbs)
- [ ] Add save method that creates/updates DailyEntry

## Data Integration
- [ ] Fetch or create today's DailyEntry on view appear
- [ ] Fetch yesterday's DailyEntry for comparison
- [ ] Calculate weight change from yesterday
- [ ] Save weight to DailyEntry via SwiftData

## UI Components
- [ ] Add weight input section to TodayView
- [ ] Create weight TextField with decimal keyboard
- [ ] Add "Save Weight" button (or auto-save)
- [ ] Display previous day's weight
- [ ] Display weight change with +/- indicator
- [ ] Add color coding for weight change
- [ ] Add validation error message display

## User Feedback
- [ ] Show success feedback when weight saved
- [ ] Show "First entry" message if no previous data
- [ ] Add appropriate placeholder text in input field

## Accessibility
- [ ] Add accessibility labels to weight input
- [ ] Add accessibility hints for weight change
- [ ] Ensure VoiceOver reads weight change meaningfully

## Quality Checks
- [ ] Weight entry compiles without errors
- [ ] App builds successfully
- [ ] Weight saves and persists across app restarts
- [ ] Validation rejects out-of-range values
- [ ] Previous day comparison works correctly
