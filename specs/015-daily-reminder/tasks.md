# Tasks: Daily Reminder Notification

## Notification Service
- [ ] Create NotificationService class
- [ ] Add method to request permission
- [ ] Add method to schedule daily notification
- [ ] Add method to cancel scheduled notifications
- [ ] Handle permission status

## Permission Request
- [ ] Request notification permission
- [ ] Handle authorized status
- [ ] Handle denied status gracefully
- [ ] Store permission status

## Notification Scheduling
- [ ] Schedule repeating daily notification
- [ ] Use time from Settings
- [ ] Update when time changes
- [ ] Cancel when disabled

## Notification Content
- [ ] Create warm, encouraging notification text
- [ ] Set title: "Daily Check-in"
- [ ] Set body with friendly message
- [ ] Add appropriate sound (optional)

## Notification Handling
- [ ] Handle notification tap
- [ ] Open app to Today view
- [ ] Set up UNUserNotificationCenterDelegate

## Settings Integration
- [ ] Connect enable toggle to scheduling
- [ ] Connect time picker to schedule update
- [ ] Cancel notifications when disabled
- [ ] Reschedule when time changes

## Quality Checks
- [ ] Notification fires at correct time
- [ ] Tapping opens Today view
- [ ] Enable/disable works correctly
- [ ] Time changes update schedule
- [ ] App builds without errors
