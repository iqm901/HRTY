# Tasks: HealthKit Heart Rate Import

## HealthKit Service Extension
- [ ] Add resting heart rate to authorization request
- [ ] Add method to fetch latest resting HR
- [ ] Add method to fetch HR history (for trends)
- [ ] Add method to check for persistent abnormal HR

## Heart Rate Display (Today View)
- [ ] Add HR section to TodayView
- [ ] Display latest resting HR value
- [ ] Show timestamp of reading
- [ ] Handle no HR data gracefully
- [ ] Add heart icon

## Heart Rate Alerts
- [ ] Define HR alert thresholds (< 40, > 120 bpm)
- [ ] Check for persistent abnormal HR (3+ readings)
- [ ] Create AlertEvent for HR alerts
- [ ] Display HR alert banner
- [ ] Use warm, supportive messaging

## Trends Integration
- [ ] Add HR data to TrendsViewModel
- [ ] Create HR trend chart
- [ ] Add to Trends view
- [ ] Handle missing HR days

## ViewModel Updates
- [ ] Add HR properties to TodayViewModel
- [ ] Add HR fetch on view appear
- [ ] Handle async data loading

## Quality Checks
- [ ] HR displays correctly on Today view
- [ ] HR alerts trigger appropriately
- [ ] HR trends display on Trends view
- [ ] Graceful handling without HR data
- [ ] App builds without errors
