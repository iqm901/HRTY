# Tasks: Settings - Basic Preferences

## ViewModel Setup
- [x] Create SettingsViewModel with @Observable
- [x] Add reminder time property with @AppStorage
- [x] Add reminder enabled property with @AppStorage
- [x] Add patient identifier property with @AppStorage

## Reminder Settings Section
- [x] Add reminder enable/disable toggle
- [x] Add time picker for reminder time
- [x] Default to 8:00 AM
- [x] Store preferences persistently

## Patient Identifier Section
- [x] Add text field for patient name/ID
- [x] Make it optional (can be blank)
- [x] Store persistently with @AppStorage
- [x] Add clear button

## About Section
- [x] Display app name
- [x] Show version number from Bundle
- [x] Show build number
- [x] Add brief app description

## Privacy Section
- [x] Add privacy explanation text
- [x] Explain on-device storage
- [x] Clarify no cloud sync
- [x] Reassure about data privacy

## SettingsView UI
- [x] Update SettingsView with sections
- [x] Use Form or List with sections
- [x] Add section headers
- [x] Style consistently with iOS conventions

## Accessibility
- [x] Add accessibility labels
- [x] Ensure all controls are accessible
- [x] Test with VoiceOver

## Quality Checks
- [x] All settings persist across app restarts
- [x] Time picker works correctly
- [x] Version info displays correctly
- [x] App builds without errors
