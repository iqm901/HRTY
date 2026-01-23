# Feature: TodayView Vital Signs & Symptom Sub-tabs

## Overview
Restructure TodayView into two sub-tabs for better organization: "Vital Signs" for daily vital measurements and "Symptom Management" for symptom severity tracking.

## User Story
As a heart failure patient, I want to track my complete vital signs (weight, blood pressure, heart rate, oxygen saturation) in one organized place so I can monitor my health and share comprehensive data with my clinician.

## Requirements

### Tab Structure
- Segmented control at top of TodayView with two options
- "Vital Signs" tab (default/first tab)
- "Symptom Management" tab
- Smooth transition between tabs

### Vital Signs Tab
Four vital measurements, each with:
- HealthKit import button (when available)
- Manual entry fallback
- Display of last recorded time
- Validation and storage

**Vitals to Track:**
1. **Weight** (existing) - lbs, range 50-500
2. **Blood Pressure** - Systolic/Diastolic mmHg (e.g., 120/80)
3. **Heart Rate** (existing) - bpm, read from HealthKit
4. **Oxygen Saturation** - %, range 70-100

**Timing Recommendation:**
- Display gentle reminder: "For best results, check your vitals at the same time each day, ideally 2 hours after taking blood pressure medications."

### Symptom Management Tab
- Keep existing 8-symptom severity logging (1-5 scale)
- No changes to symptom tracking functionality
- Extract to separate view component

### Diuretic Tracking Removal
- Remove diuretic section from TodayView entirely
- Move dose logging to MedicationsView

### New Alerts
| Condition | Threshold | Message |
|-----------|-----------|---------|
| Low Oxygen | SpO2 < 90% | "Your oxygen level is low. Please contact your care team." |
| Low Blood Pressure | Systolic < 90 mmHg | "Your blood pressure is low. Please contact your care team." |
| Low MAP | MAP < 60 mmHg | "Your blood pressure is low. Please contact your care team." |
| Low Heart Rate | HR < 40 bpm | "Your heart rate is low. Please contact your care team." |

*MAP = DBP + (SBP - DBP) / 3*

## Acceptance Criteria
- [x] TodayView shows segmented control with "Vital Signs" and "Symptom Management"
- [x] Vital Signs tab displays weight, BP, HR, and SpO2 entry
- [x] All vitals support HealthKit import where available
- [x] All vitals support manual entry
- [x] Blood pressure captures both systolic and diastolic
- [x] Oxygen saturation entry with validation (70-100%)
- [x] Timing recommendation displayed on Vital Signs tab
- [x] Symptom Management tab shows existing symptom logging
- [x] Diuretic tracking removed from TodayView
- [x] Diuretic logging added to MedicationsView
- [x] Alert triggers for SpO2 < 90%
- [x] Alert triggers for systolic BP < 90 mmHg
- [x] Alert triggers for MAP < 60 mmHg
- [x] Alert triggers for HR < 40 bpm
- [x] All data persists correctly

## Implementation Notes

> **Architecture Note:** Heart rate alerts (HR < 40 bpm) are handled by the existing `HeartRateAlertService`, while new vital signs alerts (SpO2, BP, MAP) are handled by `VitalSignsAlertService`. This separation keeps the alert services focused and maintains the existing heart rate monitoring infrastructure.

## UI/UX Notes
- Segmented control should use system styling
- Keep warm, non-alarmist messaging
- Timing recommendation should be subtle, not prominent
- Entry fields should be accessible (VoiceOver, Dynamic Type)
- Show clear labels with units (mmHg, %, bpm, lbs)

## Technical Notes
- Use existing `@Observable` pattern for view models
- Extend HealthKitService with BP and SpO2 queries
- Create VitalSignsEntry model or extend DailyEntry
- MAP calculation: MAP = diastolic + (systolic - diastolic) / 3
- HealthKit types: HKQuantityType.bloodPressureSystolic, .bloodPressureDiastolic, .oxygenSaturation
