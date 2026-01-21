# Feature: Dizziness + BP Check Prompt

## Overview
When a patient logs significant dizziness and no blood pressure data is available from HealthKit, prompt them to check their blood pressure manually.

## User Story
As a patient logging dizziness, I want a prompt to check my blood pressure if it's not available.

## Requirements

### Trigger Conditions
- Dizziness symptom severity ≥ 3
- No recent BP data from HealthKit (last 24 hours)

### Prompt Content
- Suggest checking BP manually
- If unable to check, advise contacting clinician
- Mention orthostatic precautions (stand up slowly)

### Behavior
- Show prompt after symptoms are saved
- Dismissible
- Don't show if BP data is available

## Acceptance Criteria
- [ ] If dizziness ≥3 and no BP data from HealthKit, show prompt
- [ ] Prompt suggests checking BP manually
- [ ] If unable to check, advises contacting clinician
- [ ] Orthostatic precautions mentioned in alert

## UI/UX Notes
- Use informational card/banner style
- Warm, helpful tone (not alarming)
- Clear dismiss action
- Brief orthostatic tip included

### Example Message
> "You mentioned feeling dizzy today. If you have a blood pressure cuff, it might be helpful to take a reading. Remember to stand up slowly. If you're concerned or symptoms persist, consider reaching out to your care team."

## Technical Notes
- Extend HealthKitService to check for BP data
- Add BP to HealthKit authorization (read-only)
- Check dizziness severity after symptom save
- Query for recent BP readings
- Reuse alert banner component
