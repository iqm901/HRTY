# Feature: Settings - Basic Preferences

## Overview
Allow users to configure basic app settings including daily reminder time, patient identifier, and view app information.

## User Story
As a user, I want to configure basic app settings so I can personalize my experience.

## Requirements

### Settings Options
1. Daily reminder notification time
2. Patient name/identifier (optional, for PDF export)
3. About section with version info
4. Privacy information explaining on-device storage

### Daily Reminder Setting
- Time picker for notification time
- Enable/disable toggle
- Default: 8:00 AM

### Patient Identifier
- Optional text field
- Used in PDF export
- Stored locally only

### About Section
- App version number
- Build number
- Brief app description

### Privacy Section
- Explain data is stored on-device only
- No cloud sync or accounts
- Data stays on patient's device

## Acceptance Criteria
- [x] Setting for daily reminder notification time
- [x] Setting for patient name/identifier (optional, for PDF)
- [x] About section with version info
- [x] Privacy information explaining on-device storage

## UI/UX Notes
- Standard iOS Settings-style list
- Group related settings
- Clear labels and descriptions
- Use system controls (DatePicker, TextField)

## Technical Notes
- Create SettingsViewModel with @Observable
- Use @AppStorage for persisting preferences
- Read app version from Bundle
- Prepare for notification scheduling (feature 015)
