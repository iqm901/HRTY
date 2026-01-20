# Feature: Core Data Model Setup

## Overview
Create the SwiftData models to persist daily entries, medications, and alerts on-device. This is the data foundation for all tracking features in HRTY.

## User Story
As a developer, I need the data model to persist daily entries, medications, and alerts on-device so that patient data is stored locally and persists across app launches.

## Requirements

### Data Models

#### DailyEntry
- `date`: Date (unique per calendar day)
- `weight`: Double? (optional, in pounds)
- `symptoms`: [SymptomEntry] (relationship)
- `diureticDoses`: [DiureticDose] (relationship)
- `createdAt`: Date
- `updatedAt`: Date

#### SymptomEntry
- `symptomType`: SymptomType (enum)
- `severity`: Int (1-5 scale, where 1=none, 5=severe)
- `dailyEntry`: DailyEntry (relationship)

#### SymptomType (Enum)
- dyspneaAtRest
- dyspneaOnExertion
- orthopnea
- pnd (Paroxysmal Nocturnal Dyspnea)
- chestPain
- dizziness
- syncope
- reducedUrineOutput

#### DiureticDose
- `medication`: Medication (relationship)
- `dosageAmount`: Double
- `timestamp`: Date
- `isExtraDose`: Bool
- `dailyEntry`: DailyEntry (relationship)

#### Medication
- `name`: String
- `dosage`: Double
- `unit`: String (mg, mcg, etc.)
- `schedule`: String (description of when to take)
- `isDiuretic`: Bool
- `isActive`: Bool
- `createdAt`: Date

#### AlertEvent
- `alertType`: AlertType (enum)
- `message`: String
- `triggeredAt`: Date
- `isAcknowledged`: Bool
- `relatedDailyEntry`: DailyEntry? (optional relationship)

### Functional Requirements
1. All models persist using SwiftData
2. Only one DailyEntry allowed per calendar day (enforced)
3. Data persists across app launches
4. Cascade delete for related entries (e.g., deleting DailyEntry deletes its symptoms)
5. Medications can be soft-deleted (isActive = false)

### Non-Functional Requirements
- No cloud sync - all data on-device only
- Models should support future HealthKit integration
- Efficient queries for 30-day trend views

## Acceptance Criteria
- [ ] SwiftData models created: DailyEntry, SymptomEntry, DiureticDose, Medication, AlertEvent
- [ ] DailyEntry contains date, weight, symptoms array, diuretic doses array
- [ ] SymptomEntry contains symptom type (enum) and severity (1-5)
- [ ] Medication contains name, dosage, unit, schedule, isDiuretic flag
- [ ] Data persists across app launches
- [ ] Only one DailyEntry per calendar day (enforced programmatically)

## Technical Notes
- Use SwiftData with @Model macro (iOS 17+)
- Use @Relationship for model associations
- Create ModelContainer in App struct
- Inject modelContext via environment
- Use .modelContainer() modifier on root view
