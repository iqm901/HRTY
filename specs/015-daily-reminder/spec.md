# Feature: Daily Reminder Notification

## Overview
Send a local notification at the user's configured time to remind them to complete their daily check-in.

## User Story
As a patient, I want a daily reminder to complete my check-in so I don't forget.

## Requirements

### Notification Behavior
- Local notification at user-configured time (from Settings)
- Notification text is warm and encouraging
- Tapping notification opens Today view
- Can disable notifications in Settings

### Notification Content
- Title: "Daily Check-in"
- Body: Warm, encouraging message
- Example: "Ready for your daily check-in? Just a quick moment to log how you're feeling today."

## Acceptance Criteria
- [x] Local notification at user-configured time
- [x] Notification text is warm and encouraging
- [x] Tapping notification opens Today view
- [x] Can disable notifications in Settings

## UI/UX Notes
- Request notification permission
- Handle permission denied gracefully
- Notification should feel helpful, not nagging
- Respect user's time preferences

## Technical Notes
- Use UNUserNotificationCenter
- Schedule repeating daily notification
- Update schedule when time changes in Settings
- Handle notification tap (open to Today)
- Add notification permission request
