# Feature: HealthKit Heart Rate Import

## Overview
Import resting heart rate from Apple Health for display and trend tracking, with alerts for concerning values.

## User Story
As a patient, I want my heart rate data imported from Apple Health for trend tracking.

## Requirements

### HealthKit Integration
- Request read-only authorization for resting heart rate
- Fetch and display resting HR on Today view
- Show HR trend on Trends view

### Heart Rate Alerts
- Alert if HR < 40 bpm (persistent)
- Alert if HR > 120 bpm (persistent)
- "Persistent" = multiple readings, not single spike

### Display
- Show current/latest resting HR on Today view
- Include HR in Trends view chart
- Handle missing data gracefully

## Acceptance Criteria
- [ ] Request HealthKit authorization for resting heart rate (read-only)
- [ ] Display resting HR on Today view if available
- [ ] Heart rate alert: <40 bpm or >120 bpm persistent
- [ ] Show HR trend on Trends view

## UI/UX Notes
- Display HR with heart icon
- Show timestamp of reading
- HR alerts use same warm styling as other alerts
- Optional section (hidden if no HR data)

## Technical Notes
- Extend HealthKitService for heart rate
- Request HKQuantityTypeIdentifier.restingHeartRate
- Query for persistent abnormal values (3+ readings)
- Add HR to TrendsViewModel
- Reuse alert infrastructure from feature 007/008
