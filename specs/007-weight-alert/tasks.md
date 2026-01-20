# Tasks: Weight Alert Logic

## Alert Constants
- [ ] Define weight alert thresholds as constants
- [ ] 24-hour threshold: 2.0 lbs
- [ ] 7-day threshold: 5.0 lbs
- [ ] Store in central location (e.g., AlertConstants)

## Alert Logic
- [ ] Create weight alert check method in ViewModel
- [ ] Implement 24-hour weight change calculation
- [ ] Implement 7-day weight change calculation
- [ ] Trigger alert check when weight is saved
- [ ] Prevent duplicate alerts for same condition same day

## Alert Messages
- [ ] Create warm, supportive 24-hour alert message
- [ ] Create warm, supportive 7-day alert message
- [ ] Include actual weight change values in message
- [ ] Ensure messages are non-alarmist

## AlertEvent Persistence
- [ ] Create AlertEvent when alert triggers
- [ ] Set appropriate AlertType (weightGain24h, weightGain7d)
- [ ] Store alert message and timestamp
- [ ] Link to relevant DailyEntry
- [ ] Query for unacknowledged alerts

## UI Components
- [ ] Create WeightAlertView card/banner component
- [ ] Display alert message prominently
- [ ] Add dismiss/acknowledge button
- [ ] Use warm color scheme (amber, not red)
- [ ] Add appropriate icon (info or heart)

## TodayView Integration
- [ ] Add alert display area at top of TodayView
- [ ] Show active unacknowledged weight alerts
- [ ] Handle alert dismissal (mark acknowledged)
- [ ] Refresh alerts when view appears

## Accessibility
- [ ] Add accessibility label for alert banner
- [ ] Announce alert via VoiceOver when shown
- [ ] Ensure dismiss button is accessible
- [ ] Use appropriate accessibility traits

## Quality Checks
- [ ] 24-hour alert triggers correctly at ≥2 lbs
- [ ] 7-day alert triggers correctly at ≥5 lbs
- [ ] Alert messages are warm and supportive
- [ ] Alerts persist to data store
- [ ] Dismiss functionality works
- [ ] App builds without errors
