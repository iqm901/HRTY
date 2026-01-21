# Tasks: Symptom Severity Alert Logic

## Alert Logic
- [ ] Add symptom severity check after symptoms are saved
- [ ] Trigger alert when any symptom is 4 or 5
- [ ] Identify which symptoms triggered the alert
- [ ] Prevent duplicate alerts for same symptoms same day

## Alert Messages
- [ ] Create warm, supportive symptom alert message
- [ ] Include specific symptom names in message
- [ ] Ensure message is non-prescriptive

## AlertEvent Persistence
- [ ] Create AlertEvent for symptom alerts
- [ ] Set AlertType to symptomSeverity
- [ ] Store which symptoms triggered alert
- [ ] Link to relevant DailyEntry

## UI Integration
- [ ] Display symptom alert on Today view
- [ ] Reuse or adapt WeightAlertView component
- [ ] Show after symptom save completes
- [ ] Handle dismiss/acknowledge

## Quality Checks
- [ ] Alert triggers at severity 4 or 5
- [ ] Alert message is warm and supportive
- [ ] Multiple severe symptoms shown in one alert
- [ ] Alert persists to data store
- [ ] App builds without errors
