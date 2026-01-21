# Tasks: Settings - Basic Preferences

## ViewModel Setup
- [ ] Create SettingsViewModel with @Observable
- [ ] Add reminder time property with @AppStorage
- [ ] Add reminder enabled property with @AppStorage
- [ ] Add patient identifier property with @AppStorage

## Reminder Settings Section
- [ ] Add reminder enable/disable toggle
- [ ] Add time picker for reminder time
- [ ] Default to 8:00 AM
- [ ] Store preferences persistently

## Patient Identifier Section
- [ ] Add text field for patient name/ID
- [ ] Make it optional (can be blank)
- [ ] Store persistently with @AppStorage
- [ ] Add clear button

## About Section
- [ ] Display app name
- [ ] Show version number from Bundle
- [ ] Show build number
- [ ] Add brief app description

## Privacy Section
- [ ] Add privacy explanation text
- [ ] Explain on-device storage
- [ ] Clarify no cloud sync
- [ ] Reassure about data privacy

## SettingsView UI
- [ ] Update SettingsView with sections
- [ ] Use Form or List with sections
- [ ] Add section headers
- [ ] Style consistently with iOS conventions

## Accessibility
- [ ] Add accessibility labels
- [ ] Ensure all controls are accessible
- [ ] Test with VoiceOver

## Quality Checks
- [ ] All settings persist across app restarts
- [ ] Time picker works correctly
- [ ] Version info displays correctly
- [ ] App builds without errors
