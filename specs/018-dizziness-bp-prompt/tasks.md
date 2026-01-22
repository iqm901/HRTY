# Tasks: Dizziness + BP Check Prompt

## HealthKit BP Integration
- [x] Add blood pressure to HealthKit authorization
- [x] Add method to fetch recent BP readings
- [x] Check for BP data in last 24 hours
- [x] Handle no BP data case

## Prompt Logic
- [x] Check dizziness severity after symptom save
- [x] Trigger if dizziness ≥ 3
- [x] Check for recent BP data
- [x] Only show prompt if no BP available

## Prompt Content
- [x] Create warm, helpful prompt message
- [x] Suggest manual BP check
- [x] Include orthostatic precaution tip
- [x] Mention contacting clinician option

## UI Component
- [x] Create BP prompt banner/card
- [x] Use consistent styling with other alerts
- [x] Add dismiss button
- [x] Show after symptom save

## TodayView Integration
- [x] Add BP prompt display area
- [x] Show when conditions met
- [x] Handle dismissal
- [x] Don't show if BP data exists

## Quality Checks
- [x] Prompt shows at dizziness ≥ 3
- [x] Prompt doesn't show if BP available
- [x] Message is warm and helpful
- [x] Dismiss works correctly
- [x] App builds without errors

## Implementation Summary
All tasks completed in iteration 1 (System Architect review pending).

### Files Created
- `HRTY/Services/DizzinessBPAlertService.swift` - New service for handling dizziness BP check prompts

### Files Modified
- `HRTY/Services/HealthKitService.swift` - Added BP authorization and `hasRecentBloodPressureReading()` method
- `HRTY/Models/AlertType.swift` - Added `dizzinessBPCheck` case
- `HRTY/Models/AlertConstants.swift` - Added `dizzinessBPPromptThreshold` and `bloodPressureLookbackHours`
- `HRTY/Views/WeightAlertView.swift` - Added blood pressure category label
- `HRTY/ViewModels/TodayViewModel.swift` - Integrated dizziness BP alert service
- `HRTY/Views/TodayView.swift` - Added dizziness BP alert display and VoiceOver support
