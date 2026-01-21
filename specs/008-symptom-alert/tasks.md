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

---

## Iteration History

### Iteration 1 - System Architect
- Reviewed file structure and dependencies
- Identified code duplication in alert acknowledgment
- Extracted `AlertAcknowledgeable` protocol with default implementation
- Both `WeightAlertServiceProtocol` and `SymptomAlertServiceProtocol` now inherit from it
- Build passes, tests pass

### Iteration 2 - Frontend Designer
- Reviewed UI/UX for symptom alert feature
- Checked SwiftUI best practices and accessibility support
- Found accessibility bug: `WeightAlertView` always announced "Weight alert" for VoiceOver
- Fixed accessibility labels to be context-aware for all alert types (symptom, weight, heart rate)
- Added Symptom Alert preview to WeightAlertView for testing
- Build passes

### Iteration 3 - QA Engineer
- Ran all tests - 100% pass rate
- Identified missing test coverage for SymptomAlertService
- Created comprehensive unit tests in SymptomAlertServiceTests.swift (27 new tests):
  - SymptomAlertServiceTests: Threshold boundary tests (severity 1-5)
  - SymptomAlertMessageTests: Message formatting validation
  - SevereSymptomAlertTypeTests: AlertType.severeSymptom tests
  - SevereSymptomAlertEventTests: AlertEvent tests with warm/non-alarmist message validation
  - SymptomSeverityFilteringTests: Filtering logic for severe symptoms (>= 4)
- All 27 new tests pass
- Build passes
- Tests pass
