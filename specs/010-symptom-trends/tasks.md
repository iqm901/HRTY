# Tasks: Trends View - Symptom Trends

## ViewModel Extension
- [ ] Add symptom trend data to TrendsViewModel
- [ ] Query SymptomEntry for 30-day range
- [ ] Group data by symptom type
- [ ] Add toggle state for each symptom

## Chart Implementation
- [ ] Create SymptomTrendChart component
- [ ] Display all 8 symptoms (toggleable)
- [ ] Use distinct colors per symptom
- [ ] Show severity scale (1-5) on Y-axis
- [ ] Handle missing days appropriately

## Toggle Controls
- [ ] Add symptom toggle buttons/chips
- [ ] Allow hiding/showing individual symptoms
- [ ] Persist toggle state during session
- [ ] Default to all symptoms visible

## Alert Day Markers
- [ ] Identify days with symptom alerts
- [ ] Add visual marker on chart
- [ ] Use subtle indicator (dot, highlight)

## TrendsView Integration
- [ ] Add symptom trends section
- [ ] Position below weight chart
- [ ] Add section header
- [ ] Handle empty state

## Accessibility
- [ ] Add accessibility labels for charts
- [ ] Provide text summary for VoiceOver
- [ ] Make toggles accessible

## Quality Checks
- [ ] All 8 symptoms can be displayed
- [ ] Toggles work correctly
- [ ] Alert days are marked
- [ ] Performance is acceptable
- [ ] App builds without errors
