# Tasks: Trends View - Weight Chart

## ViewModel Setup
- [x] Create TrendsViewModel with @Observable
- [x] Add property for 30-day weight data
- [x] Add computed property for weight change summary
- [x] Query DailyEntry for date range

## Chart Implementation
- [x] Import Swift Charts framework
- [x] Create WeightChartView component
- [x] Configure LineMark for weight data
- [x] Set up X-axis with date labels
- [x] Set up Y-axis with weight values
- [x] Handle missing days (gaps, not interpolation)

## Summary Display
- [x] Show current/latest weight
- [x] Calculate 30-day weight change
- [x] Display change with +/- indicator
- [x] Show date range for chart

## TrendsView Integration
- [x] Update TrendsView with chart
- [x] Add section header for weight
- [x] Handle empty state (no data)
- [x] Add loading state if needed

## Accessibility
- [x] Add accessibility label for chart
- [x] Provide text summary for VoiceOver users
- [x] Ensure chart data is accessible

## Quality Checks
- [x] Chart displays correctly with data
- [x] Missing days show as gaps
- [x] Summary calculations are accurate
- [x] Empty state displays properly
- [x] App builds without errors
- [x] Unit tests for TrendsViewModel (added by QA Engineer - iteration 3)
