# Tasks: HealthKit Weight Import

## Project Configuration
- [ ] Add HealthKit capability to project
- [ ] Add HealthKit usage description to Info.plist
- [ ] Import HealthKit framework

## HealthKit Service
- [ ] Create HealthKitService class
- [ ] Add method to check HealthKit availability
- [ ] Add method to request authorization
- [ ] Add method to fetch latest weight
- [ ] Handle authorization status

## Authorization Flow
- [ ] Request read permission for bodyMass
- [ ] Handle authorization denied gracefully
- [ ] Store authorization status
- [ ] Don't repeatedly prompt if denied

## Weight Import
- [ ] Fetch most recent weight from HealthKit
- [ ] Include timestamp with weight
- [ ] Convert units if needed (to lbs)
- [ ] Handle no data available case

## TodayView Integration
- [ ] Add "Import from Health" button
- [ ] Show HealthKit weight when available
- [ ] Display timestamp of imported weight
- [ ] Allow editing imported value
- [ ] Maintain manual entry as fallback

## ViewModel Updates
- [ ] Add HealthKit state to TodayViewModel
- [ ] Add import action
- [ ] Handle async fetch
- [ ] Update weight field with imported value

## Error Handling
- [ ] Handle HealthKit not available
- [ ] Handle authorization denied
- [ ] Handle no weight data
- [ ] Show appropriate user messages

## Quality Checks
- [ ] Authorization request works
- [ ] Weight imports correctly
- [ ] Manual entry still works
- [ ] Graceful degradation without HealthKit
- [ ] App builds without errors
