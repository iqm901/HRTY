# Feature: Today View - Weight Entry

## Overview
Enable patients to log their daily weight on the Today view. This is a core daily check-in task that takes under 30 seconds and provides immediate feedback on weight changes.

## User Story
As a patient, I want to log my daily weight so I can track changes over time and identify concerning trends early.

## Requirements

### Functional Requirements
1. Weight input field accepts decimal values in pounds
2. Weight is saved to today's DailyEntry (creates one if doesn't exist)
3. Shows previous day's weight for reference
4. Shows weight change from yesterday (+ or - lbs)
5. Input validates reasonable weight range (50-500 lbs)
6. Clear visual feedback when weight is saved

### UI Components
- Weight input field (decimal keyboard)
- "Save" or auto-save on input completion
- Previous weight display with date
- Weight change indicator (+/- with color coding)
- Validation error message area

### Weight Change Display
- Positive change (gained): Show in amber/warning color
- Negative change (lost): Show in neutral color
- No change: Show in green/success color
- No previous data: Show "First entry" message

### Non-Functional Requirements
- Input should be quick (under 10 seconds)
- Auto-focus on weight field when view appears
- Support for decimal values (e.g., 185.5 lbs)
- Persist immediately to SwiftData

## Acceptance Criteria
- [ ] Weight input field accepts decimal values in pounds
- [ ] Weight is saved to today's DailyEntry
- [ ] Shows previous day's weight for reference
- [ ] Shows weight change from yesterday (+ or - lbs)
- [ ] Input validates reasonable weight range (50-500 lbs)
- [ ] Clear feedback when weight is saved successfully

## UI/UX Notes
- Keep the interface simple and uncluttered
- Large, easy-to-tap input field (accessibility)
- Weight change should be prominent but not alarming
- Use warm, encouraging language (not clinical)
- Example: "You're 2.0 lbs lighter than yesterday" vs "Weight decreased by 2.0 lbs"

## Technical Notes
- Use @Query to fetch today's DailyEntry
- Use DailyEntry helper methods from feature 002
- Bind TextField to weight value
- Use .keyboardType(.decimalPad) for input
- Validate on save, not on every keystroke
- Create ViewModel for business logic (@Observable)
