# Feature: Symptom Severity Alert Logic

## Overview
Alert patients when they log severe symptoms (severity 4 or 5), prompting them to contact their clinician. Alerts are supportive and non-prescriptive.

## User Story
As a patient, I want to be alerted when I log severe symptoms so I know to contact my clinician.

## Requirements

### Alert Threshold
- Alert triggers when ANY symptom is rated 4 or 5 (Significant or Severe)

### Alert Behavior
- Alert triggers after saving symptoms
- Alert message is warm, non-alarmist
- Advises discussing with clinician (not prescriptive)
- AlertEvent saved to data store
- Shows which symptom(s) triggered the alert

### Example Message
> "You've noted that [symptom name] is bothering you more than usual today. This is helpful information to share with your care team when you get a chance."

## Acceptance Criteria
- [x] Alert triggers if any symptom is logged as 4 or 5
- [x] Alert message advises discussing with clinician
- [x] Alert is non-prescriptive and reassuring
- [x] Alert displayed after saving symptoms
- [x] AlertEvent saved to data store

## UI/UX Notes
- Use same alert banner style as weight alerts
- Warm amber color (not alarming red)
- List specific symptoms that triggered alert
- Dismissible with "Got it" button

## Technical Notes
- Extend alert logic from feature 007
- Check symptom severities after save
- Create AlertEvent with symptomSeverity type
- Reuse WeightAlertView component (or create generic AlertBannerView)
