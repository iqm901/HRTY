# Tasks: Onboarding Flow

## Onboarding State
- [ ] Add @AppStorage flag for onboarding completion
- [ ] Check flag on app launch
- [ ] Show onboarding if not completed
- [ ] Set flag when onboarding completes

## Welcome Screen
- [ ] Create welcome page view
- [ ] Add app logo/icon
- [ ] Add brief app description
- [ ] Explain purpose (self-management, not medical advice)
- [ ] Add "Get Started" button

## HealthKit Permission Page
- [ ] Create HealthKit permission page
- [ ] Explain why HealthKit access helps
- [ ] Add "Allow" button to request permission
- [ ] Add "Skip" option
- [ ] Handle permission result

## Notification Permission Page
- [ ] Create notification permission page
- [ ] Explain daily reminder benefit
- [ ] Add "Allow" button to request permission
- [ ] Add "Skip" option
- [ ] Handle permission result

## Medication Setup Page
- [ ] Create medication prompt page
- [ ] Explain importance of medication list
- [ ] Add "Add Medications" button
- [ ] Add "Skip for Now" option
- [ ] Open medication form if chosen

## Navigation
- [ ] Create OnboardingContainerView
- [ ] Add page-style navigation (TabView with PageTabViewStyle)
- [ ] Add progress indicator
- [ ] Handle completion navigation to Today view

## Quality Checks
- [ ] Onboarding only shows once
- [ ] All permission requests work
- [ ] Can skip any step
- [ ] Completes to Today view
- [ ] App builds without errors
