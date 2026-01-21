# Tasks: Trends View - Weight Chart

## ViewModel Setup
- [ ] Create TrendsViewModel with @Observable
- [ ] Add property for 30-day weight data
- [ ] Add computed property for weight change summary
- [ ] Query DailyEntry for date range

## Chart Implementation
- [ ] Import Swift Charts framework
- [ ] Create WeightChartView component
- [ ] Configure LineMark for weight data
- [ ] Set up X-axis with date labels
- [ ] Set up Y-axis with weight values
- [ ] Handle missing days (gaps, not interpolation)

## Summary Display
- [ ] Show current/latest weight
- [ ] Calculate 30-day weight change
- [ ] Display change with +/- indicator
- [ ] Show date range for chart

## TrendsView Integration
- [ ] Update TrendsView with chart
- [ ] Add section header for weight
- [ ] Handle empty state (no data)
- [ ] Add loading state if needed

## Accessibility
- [ ] Add accessibility label for chart
- [ ] Provide text summary for VoiceOver users
- [ ] Ensure chart data is accessible

## Quality Checks
- [ ] Chart displays correctly with data
- [ ] Missing days show as gaps
- [ ] Summary calculations are accurate
- [ ] Empty state displays properly
- [ ] App builds without errors
