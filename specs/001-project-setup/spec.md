# Feature: Project Setup & Tab Navigation

## Overview
Create the foundational Xcode project structure with SwiftUI lifecycle and implement the main tab-based navigation for the HRTY heart failure self-management app.

## User Story
As a user, I want to navigate between the five main sections of the app using a tab bar so I can easily access different features.

## Requirements

### Functional Requirements
1. Xcode project created with SwiftUI App lifecycle
2. Minimum deployment target set to iOS 17.0
3. TabView with 5 tabs providing navigation to main app sections
4. Each tab displays appropriate SF Symbol icon
5. Tab selection persists during app session

### Non-Functional Requirements
- App launches without errors on iOS 17+ simulators
- Tab switching is instantaneous
- Icons are clearly visible in both light and dark mode

## Acceptance Criteria
- [ ] Xcode project created with SwiftUI lifecycle (no UIKit AppDelegate)
- [ ] Minimum deployment target iOS 17.0 configured in project settings
- [ ] TabView with 5 tabs: Today, Trends, Medications, Export, Settings
- [ ] Each tab has appropriate SF Symbol icon
- [ ] Tab selection persists during app session (no unexpected resets)
- [ ] App builds successfully on iOS Simulator
- [ ] Placeholder views exist for each tab

## UI/UX Notes
- Tab bar should use system default styling
- Icons should be intuitive:
  - Today: `checkmark.circle` or `heart.text.square`
  - Trends: `chart.line.uptrend.xyaxis`
  - Medications: `pills`
  - Export: `square.and.arrow.up`
  - Settings: `gear`
- Labels should be concise and clear

## Technical Notes
- Use SwiftUI `@main` App struct
- Use native SwiftUI `TabView` with `tabItem` modifiers
- Create separate View files for each tab (placeholder content initially)
- Follow iOS 17+ patterns (no deprecated APIs)
