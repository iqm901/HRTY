# Tasks: Symptom Severity Alert Logic

## Alert Logic
- [x] Add symptom severity check after symptoms are saved
- [x] Trigger alert when any symptom is 4 or 5
- [x] Identify which symptoms triggered the alert
- [x] Prevent duplicate alerts for same symptoms same day

## Alert Messages
- [x] Create warm, supportive symptom alert message
- [x] Include specific symptom names in message
- [x] Ensure message is non-prescriptive

## AlertEvent Persistence
- [x] Create AlertEvent for symptom alerts
- [x] Set AlertType to symptomSeverity
- [x] Store which symptoms triggered alert
- [x] Link to relevant DailyEntry

## UI Integration
- [x] Display symptom alert on Today view
- [x] Reuse or adapt WeightAlertView component
- [x] Show after symptom save completes
- [x] Handle dismiss/acknowledge

## Quality Checks
- [x] Alert triggers at severity 4 or 5
- [x] Alert message is warm and supportive
- [x] Multiple severe symptoms shown in one alert
- [x] Alert persists to data store
- [x] App builds without errors
