# Tasks: Weight Alert Logic

## Alert Constants
- [x] Define weight alert thresholds as constants
- [x] 24-hour threshold: 2.0 lbs
- [x] 7-day threshold: 5.0 lbs
- [x] Store in central location (e.g., AlertConstants)

## Alert Logic
- [x] Create weight alert check method in ViewModel
- [x] Implement 24-hour weight change calculation
- [x] Implement 7-day weight change calculation
- [x] Trigger alert check when weight is saved
- [x] Prevent duplicate alerts for same condition same day

## Alert Messages
- [x] Create warm, supportive 24-hour alert message
- [x] Create warm, supportive 7-day alert message
- [x] Include actual weight change values in message
- [x] Ensure messages are non-alarmist

## AlertEvent Persistence
- [x] Create AlertEvent when alert triggers
- [x] Set appropriate AlertType (weightGain24h, weightGain7d)
- [x] Store alert message and timestamp
- [x] Link to relevant DailyEntry
- [x] Query for unacknowledged alerts

## UI Components
- [x] Create WeightAlertView card/banner component
- [x] Display alert message prominently
- [x] Add dismiss/acknowledge button
- [x] Use warm color scheme (amber, not red)
- [x] Add appropriate icon (info or heart)

## TodayView Integration
- [x] Add alert display area at top of TodayView
- [x] Show active unacknowledged weight alerts
- [x] Handle alert dismissal (mark acknowledged)
- [x] Refresh alerts when view appears

## Accessibility
- [x] Add accessibility label for alert banner
- [x] Announce alert via VoiceOver when shown
- [x] Ensure dismiss button is accessible
- [x] Use appropriate accessibility traits

## Quality Checks
- [x] 24-hour alert triggers correctly at ≥2 lbs
- [x] 7-day alert triggers correctly at ≥5 lbs
- [x] Alert messages are warm and supportive
- [x] Alerts persist to data store
- [x] Dismiss functionality works
- [x] App builds without errors

## Test Coverage (WeightAlertTests.swift)
- [x] Alert threshold values (24h = 2.0 lbs, 7d = 5.0 lbs)
- [x] Weight validation bounds (50-500 lbs)
- [x] Boundary conditions (exact threshold, above, below)
- [x] Weight loss does not trigger alerts
- [x] Both thresholds exceeded simultaneously
- [x] AlertType display names and accessibility descriptions
- [x] AlertEvent initialization and acknowledgement
- [x] Warm/supportive language verification (no alarmist words)
- [x] Weight change text formatting
