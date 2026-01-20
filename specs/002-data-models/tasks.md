# Tasks: Core Data Model Setup

## SwiftData Configuration
- [x] Add SwiftData import to project
- [x] Configure ModelContainer in HRTYApp
- [x] Add .modelContainer() modifier to ContentView

## Core Models
- [x] Create SymptomType enum with all 8 symptoms
- [x] Create AlertType enum for different alert categories
- [x] Create DailyEntry model with @Model macro
- [x] Create SymptomEntry model with relationship to DailyEntry
- [x] Create DiureticDose model with relationships
- [x] Create Medication model
- [x] Create AlertEvent model

## Relationships & Constraints
- [x] Configure @Relationship for DailyEntry -> SymptomEntry (cascade delete)
- [x] Configure @Relationship for DailyEntry -> DiureticDose (cascade delete)
- [x] Configure @Relationship for DiureticDose -> Medication
- [x] Configure @Relationship for AlertEvent -> DailyEntry (optional)
- [x] Add unique constraint logic for one DailyEntry per calendar day

## Helper Methods
- [x] Add helper to get or create DailyEntry for today
- [x] Add helper to fetch DailyEntry for a specific date
- [x] Add helper to fetch entries for date range (for trends)

## Quality Checks
- [x] All models compile without errors
- [x] App builds successfully with SwiftData
- [x] Models follow SwiftData best practices
- [x] Relationships are properly configured
- [ ] Unit tests for model creation (if test target exists)
