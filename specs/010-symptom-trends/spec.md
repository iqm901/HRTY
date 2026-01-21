# Feature: Trends View - Symptom Trends

## Overview
Display symptom severity trends over 30 days on the Trends tab, allowing patients to track how their symptoms change over time.

## User Story
As a patient, I want to see how my symptoms have changed over time so I can identify patterns.

## Requirements

### Display Requirements
- Show severity trends for each symptom over 30 days
- Raw severity values displayed (1-5 scale)
- Can toggle individual symptoms on/off
- Days with alerts visually marked

### Chart Features
- Multi-line or separate mini-charts per symptom
- Clear symptom labels
- Color coding by symptom
- Date range header

## Acceptance Criteria
- [ ] Shows severity trends for each symptom over 30 days
- [ ] Raw severity values displayed (no composite scores)
- [ ] Can toggle individual symptoms on/off
- [ ] Days with alerts visually marked

## UI/UX Notes
- Consider small multiples (one mini-chart per symptom)
- Or single chart with toggleable symptom lines
- Use consistent colors per symptom type
- Keep charts readable on mobile
- Patient-friendly symptom names

## Technical Notes
- Extend TrendsViewModel for symptoms
- Query SymptomEntry for last 30 days
- Use Swift Charts with multiple series
- Consider performance with 8 symptoms × 30 days
