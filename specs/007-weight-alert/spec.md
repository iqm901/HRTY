# Feature: Weight Alert Logic

## Overview
Implement alert logic that notifies patients when their weight increases significantly, prompting them to contact their clinician. Alerts are informational and supportive, never prescriptive or alarmist.

## User Story
As a patient, I want to be alerted when my weight increases significantly so I can contact my clinician and discuss my symptoms.

## Requirements

### Alert Thresholds
1. **24-Hour Alert**: Weight increases ≥2 lbs in 24 hours
2. **7-Day Alert**: Weight increases ≥5 lbs over 7 days

### Alert Behavior
- Alert triggers when weight is saved (after validation)
- Alert message is warm, non-alarmist, supportive
- Alert suggests contacting clinician (not prescriptive)
- Alert displayed prominently on Today view
- AlertEvent saved to data store for history
- Same alert type doesn't repeat if already shown today

### Alert Message Guidelines
- Use warm, coaching tone
- Never use alarming language ("danger", "emergency", "immediately")
- Frame as information to share with care team
- Acknowledge patient's effort in tracking

### Example Messages
**24-Hour Alert:**
> "Your weight has increased by [X] lbs since yesterday. This is good information to share with your care team. Consider reaching out to discuss."

**7-Day Alert:**
> "Over the past week, your weight has increased by [X] lbs. Your clinician may want to know about this trend. It might be a good time to check in with them."

## Acceptance Criteria
- [x] Alert triggers if weight increases ≥2 lbs in 24 hours
- [x] Alert triggers if weight increases ≥5 lbs over 7 days
- [x] Alert message is warm, non-alarmist, suggests contacting clinician
- [x] Alert displayed prominently on Today view
- [x] AlertEvent saved to data store

## UI/UX Notes
- Display alert in a card/banner at top of Today view
- Use warm amber/yellow color (not red/alarming)
- Include dismiss button
- Show relevant weight values in message
- Icon: info or heart icon (not warning triangle)
- Alert should not block other interactions

### Alert Card Design
- Rounded corners, subtle border
- Warm background color (light amber/peach)
- Clear, readable text
- "Dismiss" or "Got it" button
- Optional "Learn More" link (future)

## Technical Notes
- Create AlertService or extend TodayViewModel
- Check thresholds when weight is saved
- Query last 7 days of weight data
- Use AlertEvent model from feature 002
- Store alert type, message, timestamp
- Mark alert as acknowledged when dismissed
- Constants for thresholds (easy to adjust)
