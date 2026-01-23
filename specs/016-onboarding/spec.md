# Feature: Onboarding Flow

## Overview
Guide new users through initial app setup including permissions and first medication entry.

## User Story
As a new user, I want guidance on setting up the app so I can start tracking quickly.

## Requirements

### Onboarding Steps
1. Welcome screen explaining app purpose
2. HealthKit permission request with explanation
3. Notification permission request
4. Prompt to add first medication(s)
5. Complete to Today view

### Behavior
- Onboarding only shown once (on first launch)
- Can be skipped but permissions may be needed later
- Each step has clear explanation of why permission needed

## Acceptance Criteria
- [ ] Welcome screen explaining app purpose
- [ ] HealthKit permission request with explanation
- [ ] Notification permission request
- [ ] Prompt to add first medication(s)
- [ ] Onboarding completes to Today view
- [ ] Onboarding only shown once

## UI/UX Notes
- Clean, welcoming design
- Brief explanations (not overwhelming)
- Clear "Continue" / "Skip" options
- Progress indicator (dots or steps)
- Warm, supportive tone

## Technical Notes
- Create OnboardingView with page-style navigation
- Use @AppStorage for "hasCompletedOnboarding" flag
- Check flag on app launch
- Handle permission requests inline
- Navigate to ContentView on completion
