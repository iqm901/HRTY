# Tasks: Trends View - Symptom Trends

## ViewModel Extension
- [x] Add symptom trend data to TrendsViewModel
- [x] Query SymptomEntry for 30-day range
- [x] Group data by symptom type
- [x] Add toggle state for each symptom

## Chart Implementation
- [x] Create SymptomTrendChart component
- [x] Display all 8 symptoms (toggleable)
- [x] Use distinct colors per symptom
- [x] Show severity scale (1-5) on Y-axis
- [x] Handle missing days appropriately

## Toggle Controls
- [x] Add symptom toggle buttons/chips
- [x] Allow hiding/showing individual symptoms
- [x] Persist toggle state during session
- [x] Default to all symptoms visible

## Alert Day Markers
- [x] Identify days with symptom alerts
- [x] Add visual marker on chart
- [x] Use subtle indicator (dot, highlight)

## TrendsView Integration
- [x] Add symptom trends section
- [x] Position below weight chart
- [x] Add section header
- [x] Handle empty state

## Accessibility
- [x] Add accessibility labels for charts
- [x] Provide text summary for VoiceOver
- [x] Make toggles accessible

## Quality Checks
- [x] All 8 symptoms can be displayed
- [x] Toggles work correctly
- [x] Alert days are marked
- [x] Performance is acceptable
- [x] App builds without errors
