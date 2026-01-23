# Tasks: TodayView Vital Signs & Symptom Sub-tabs

## Data Models
- [x] Create VitalSignsEntry model (or extend DailyEntry)
- [x] Add blood pressure fields (systolic, diastolic)
- [x] Add oxygen saturation field
- [x] Add timestamps for each vital
- [x] Set up relationships with DailyEntry

## HealthKit Integration
- [x] Add blood pressure systolic fetch to HealthKitService
- [x] Add blood pressure diastolic fetch to HealthKitService
- [x] Add oxygen saturation fetch to HealthKitService
- [x] Handle authorization for new data types
- [x] Handle cases where data unavailable

## TodayView Restructure
- [x] Add segmented Picker at top of TodayView
- [x] Create state for selected tab
- [x] Conditionally render tab content based on selection
- [x] Extract symptom logging to SymptomManagementTabView
- [x] Create VitalSignsTabView for vitals content

## Vital Signs Tab UI
- [x] Create weight entry section (migrate existing)
- [x] Create BloodPressureEntryView component
- [x] Create OxygenSaturationEntryView component
- [x] Display heart rate section (migrate existing)
- [x] Add timing recommendation text
- [x] Add HealthKit import buttons for each vital
- [x] Add manual entry fields for each vital

## Blood Pressure Entry
- [x] Create two-field entry (systolic/diastolic)
- [x] Add validation (reasonable ranges)
- [x] Add HealthKit import button
- [x] Display last reading time
- [x] Calculate and store MAP

## Oxygen Saturation Entry
- [x] Create percentage entry field
- [x] Add validation (70-100% range)
- [x] Add HealthKit import button
- [x] Display last reading time

## ViewModel Updates
- [x] Add blood pressure state to TodayViewModel
- [x] Add oxygen saturation state to TodayViewModel
- [x] Add save methods for new vitals
- [x] Add HealthKit import methods for new vitals
- [x] Add validation methods for new vitals

## Alert Service
- [x] Create VitalSignsAlertService (or extend existing)
- [x] Add SpO2 < 90% alert check
- [x] Add systolic BP < 90 mmHg alert check
- [x] Add MAP < 60 mmHg alert check
- [x] Update HR < 40 bpm alert (may exist)
- [x] Wire alerts to TodayViewModel

## Move Diuretic Tracking
- [x] Remove diureticSection from TodayView
- [x] Add diuretic dose logging section to MedicationsView
- [x] Move dose logging logic to MedicationsViewModel
- [x] Ensure existing dose data still accessible
- [x] Update MedicationsView UI

## Quality Checks
- [ ] All vitals save correctly
- [ ] HealthKit imports work for all vitals
- [ ] Alerts trigger at correct thresholds
- [ ] Diuretic logging works from MedicationsView
- [ ] App builds without errors
- [ ] Accessibility (VoiceOver) works on all new components
- [ ] Dynamic Type sizing correct
