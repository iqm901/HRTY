# Feature: HealthKit Weight Import

## Overview
Allow patients to import their weight from Apple Health instead of entering it manually, reducing daily entry burden.

## User Story
As a patient, I want to import my weight from Apple Health so I don't have to enter it manually.

## Requirements

### HealthKit Integration
- Request read-only authorization for body mass
- Fetch most recent weight from HealthKit
- Display weight with timestamp
- User can override with manual entry

### Authorization Flow
- Request permission on first use
- Handle denied permission gracefully
- Don't block app if HealthKit unavailable

### Import Flow
- "Import from Health" button on Today view
- Show most recent HealthKit weight
- User confirms or edits before saving
- Manual entry always available as fallback

## Acceptance Criteria
- [ ] Request HealthKit authorization for body mass (read-only)
- [ ] Option to import today's weight from HealthKit
- [ ] Shows most recent HealthKit weight with timestamp
- [ ] User can override with manual entry
- [ ] Graceful handling if HealthKit unavailable

## UI/UX Notes
- "Import from Health" button near weight input
- Show HealthKit weight with timestamp
- Clear indication this is imported data
- Easy to edit/override imported value
- Handle devices without HealthKit (older iPads)

## Technical Notes
- Import HealthKit framework
- Request HKQuantityTypeIdentifier.bodyMass (read)
- Use HKHealthStore for queries
- Add HealthKit capability to project
- Add usage description to Info.plist
- Create HealthKitService for all HK operations
