# Tasks: HealthKit Heart Rate Import

## HealthKit Service Extension
- [x] Add resting heart rate to authorization request
- [x] Add method to fetch latest resting HR
- [x] Add method to fetch HR history (for trends)
- [x] Add method to check for persistent abnormal HR

## Heart Rate Display (Today View)
- [x] Add HR section to TodayView
- [x] Display latest resting HR value
- [x] Show timestamp of reading
- [x] Handle no HR data gracefully
- [x] Add heart icon

## Heart Rate Alerts
- [x] Define HR alert thresholds (< 40, > 120 bpm)
- [x] Check for persistent abnormal HR (3+ readings)
- [x] Create AlertEvent for HR alerts
- [x] Display HR alert banner
- [x] Use warm, supportive messaging

## Trends Integration
- [x] Add HR data to TrendsViewModel
- [x] Create HR trend chart
- [x] Add to Trends view
- [x] Handle missing HR days

## ViewModel Updates
- [x] Add HR properties to TodayViewModel
- [x] Add HR fetch on view appear
- [x] Handle async data loading

## Quality Checks
- [x] HR displays correctly on Today view
- [x] HR alerts trigger appropriately
- [x] HR trends display on Trends view
- [x] Graceful handling without HR data
- [x] App builds without errors

---

## Feature Completion Summary

**Implementation completed by:** Code Reviewer Persona (Iteration 1)

### Files Created:
- `HRTY/Services/HealthKitService.swift` - HealthKit integration service with heart rate fetching
- `HRTY/Services/HeartRateAlertService.swift` - Heart rate alert checking and creation
- `HRTY/Views/HeartRateSectionView.swift` - Heart rate display component for Today view
- `HRTY/Views/HeartRateTrendChart.swift` - Heart rate trend chart for Trends view

### Files Modified:
- `HRTY/Models/TrendDataPoints.swift` - Added HeartRateDataPoint structure
- `HRTY/ViewModels/TodayViewModel.swift` - Added heart rate state and loading methods
- `HRTY/ViewModels/TrendsViewModel.swift` - Added heart rate trend data loading
- `HRTY/Views/TodayView.swift` - Added heart rate section and alerts
- `HRTY/Views/TrendsView.swift` - Added heart rate trends section

### Key Features:
1. **HealthKit Integration**: Read-only access to resting heart rate data
2. **Today View Display**: Shows latest resting HR with timestamp and heart icon
3. **Alert System**: Detects persistent abnormal HR (<40 or >120 bpm for 3+ readings)
4. **Trend Visualization**: 30-day heart rate chart with threshold markers
5. **Accessibility**: Full VoiceOver support and Dynamic Type compatibility
6. **Graceful Degradation**: Handles missing data and HealthKit unavailability
