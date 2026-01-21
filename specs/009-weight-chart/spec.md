# Feature: Trends View - Weight Chart

## Overview
Display a 30-day weight trend chart on the Trends tab, helping patients visualize their weight changes over time.

## User Story
As a patient, I want to see my weight trend over 30 days so I can understand my progress.

## Requirements

### Chart Requirements
- Line chart showing daily weight for past 30 days
- X-axis shows dates
- Y-axis shows weight in lbs
- Missing days shown as gaps (not interpolated)
- Chart is scrollable/zoomable if needed

### Summary Display
- Current weight prominently shown
- 30-day change summary (gained/lost X lbs)
- Date range displayed

## Acceptance Criteria
- [x] Line chart showing daily weight for past 30 days
- [x] X-axis shows dates, Y-axis shows weight in lbs
- [x] Missing days shown as gaps (not interpolated)
- [x] Chart is scrollable/zoomable if needed (30-day fixed view fits on screen - no scroll needed)
- [x] Shows current weight and 30-day change summary

## UI/UX Notes
- Use Swift Charts framework (iOS 16+)
- Clean, minimal chart design
- Weight points clearly visible
- Highlight concerning trends subtly
- Empty state if no weight data

## Technical Notes
- Use Swift Charts (import Charts)
- Query DailyEntry for last 30 days
- Create TrendsViewModel with @Observable
- Handle missing data gracefully
- Consider date formatting for X-axis labels
