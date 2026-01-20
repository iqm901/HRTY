# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HRTY is a patient-facing, offline-first iOS application for heart failure self-management. It consolidates daily weight tracking, symptom logging, diuretic intake, and physiologic data into a low-burden workflow (under 2 minutes daily).

**Key constraints:**
- Not a clinical decision-making tool - it's a self-management tracker
- No cloud accounts or backend in V1 - all data stored on-device
- No prescriptive medical advice - alerts prompt user to contact clinician

## Tech Stack

- **Platform:** iOS (iPhone primary, Apple Watch via HealthKit optional)
- **Language:** Swift
- **UI Framework:** SwiftUI
- **Data Persistence:** Core Data (on-device only)
- **Health Integration:** HealthKit (read-only)
- **Minimum iOS:** 17.0

## Development Commands

```bash
# Open project in Xcode
open HRTY.xcodeproj

# Build from command line
xcodebuild -scheme HRTY -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests
xcodebuild test -scheme HRTY -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Architecture

### App Structure (Tab Navigation)
```
TabView
├── TodayView        # Daily check-in workflow
├── TrendsView       # 30-day rolling charts
├── MedicationsView  # Medication list management
├── ExportView       # PDF generation for clinic visits
└── SettingsView     # App preferences
```

### Data Model
```
Patient
├── DailyEntry (one per day)
│   ├── weight: Double
│   ├── symptoms: [SymptomEntry] (8 symptoms, severity 1-5)
│   └── diureticDoses: [DiureticDose]
├── Medication[]
│   ├── name, dosage, unit, schedule
│   └── isDiuretic: Bool
└── AlertEvent[]
```

### Core Features

**Daily Check-In (TodayView):**
1. Weight entry (manual or HealthKit)
2. Symptom severity logging (8 symptoms, 1-5 scale)
3. Diuretic intake with dosage

**Symptoms Tracked:**
- Dyspnea at rest, Dyspnea on exertion, Orthopnea, PND
- Chest pain, Dizziness, Syncope, Reduced urine output

**Alert Thresholds (non-prescriptive):**
- Weight: ≥2 lb/24h OR ≥5 lb/7 days
- Heart rate: <40 bpm OR >120 bpm (persistent)
- Symptom severity: Any symptom rated 4 or 5

### HealthKit Integration
Read-only access for:
- Weight (HKQuantityTypeIdentifier.bodyMass)
- Resting heart rate
- Heart rate variability
- Blood pressure
- Steps/activity

## Code Patterns

- Use `@Observable` (iOS 17+) for view models
- Use `@Environment(\.modelContext)` for Core Data access in SwiftData
- Keep views declarative; business logic in view models
- Alert messages should be warm, coaching, never alarmist
- All clinical thresholds defined as constants in a single location

## PDF Export Format

Generated PDF includes:
- Patient identifier (optional)
- Date range
- 30-day weight trend chart
- Symptom severity trends
- Diuretic dosing history
- Alert events
- Footer disclaimer about patient-entered data
