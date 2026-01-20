# Tasks: Core Data Model Setup

## SwiftData Configuration
- [ ] Add SwiftData import to project
- [ ] Configure ModelContainer in HRTYApp
- [ ] Add .modelContainer() modifier to ContentView

## Core Models
- [ ] Create SymptomType enum with all 8 symptoms
- [ ] Create AlertType enum for different alert categories
- [ ] Create DailyEntry model with @Model macro
- [ ] Create SymptomEntry model with relationship to DailyEntry
- [ ] Create DiureticDose model with relationships
- [ ] Create Medication model
- [ ] Create AlertEvent model

## Relationships & Constraints
- [ ] Configure @Relationship for DailyEntry -> SymptomEntry (cascade delete)
- [ ] Configure @Relationship for DailyEntry -> DiureticDose (cascade delete)
- [ ] Configure @Relationship for DiureticDose -> Medication
- [ ] Configure @Relationship for AlertEvent -> DailyEntry (optional)
- [ ] Add unique constraint logic for one DailyEntry per calendar day

## Helper Methods
- [ ] Add helper to get or create DailyEntry for today
- [ ] Add helper to fetch DailyEntry for a specific date
- [ ] Add helper to fetch entries for date range (for trends)

## Quality Checks
- [ ] All models compile without errors
- [ ] App builds successfully with SwiftData
- [ ] Models follow SwiftData best practices
- [ ] Relationships are properly configured
- [ ] Unit tests for model creation (if test target exists)
