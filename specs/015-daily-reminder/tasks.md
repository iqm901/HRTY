# Tasks: Daily Reminder Notification

## Notification Service
- [x] Create NotificationService class
- [x] Add method to request permission
- [x] Add method to schedule daily notification
- [x] Add method to cancel scheduled notifications
- [x] Handle permission status

## Permission Request
- [x] Request notification permission
- [x] Handle authorized status
- [x] Handle denied status gracefully
- [x] Store permission status

## Notification Scheduling
- [x] Schedule repeating daily notification
- [x] Use time from Settings
- [x] Update when time changes
- [x] Cancel when disabled

## Notification Content
- [x] Create warm, encouraging notification text
- [x] Set title: "Daily Check-in"
- [x] Set body with friendly message
- [x] Add appropriate sound (optional)

## Notification Handling
- [x] Handle notification tap
- [x] Open app to Today view
- [x] Set up UNUserNotificationCenterDelegate

## Settings Integration
- [x] Connect enable toggle to scheduling
- [x] Connect time picker to schedule update
- [x] Cancel notifications when disabled
- [x] Reschedule when time changes

## Quality Checks
- [x] Notification fires at correct time
- [x] Tapping opens Today view
- [x] Enable/disable works correctly
- [x] Time changes update schedule
- [x] App builds without errors
