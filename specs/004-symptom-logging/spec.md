# Feature: Today View - Symptom Logging

## Overview
Enable patients to log their daily symptoms on the Today view using a 1-5 severity scale. This is part of the daily check-in workflow and should take under 60 seconds.

## User Story
As a patient, I want to rate my symptoms on a 1-5 scale so I can track how I'm feeling and identify patterns over time.

## Requirements

### Symptoms to Track (8 total)
1. **Dyspnea at rest** - Shortness of breath while resting
2. **Dyspnea on exertion** - Shortness of breath during activity
3. **Orthopnea** - Difficulty breathing when lying flat
4. **PND** - Paroxysmal Nocturnal Dyspnea (waking up short of breath)
5. **Chest pain** - Any chest discomfort
6. **Dizziness** - Feeling lightheaded or unsteady
7. **Syncope** - Fainting or near-fainting episodes
8. **Reduced urine output** - Noticeably less urination than normal

### Severity Scale
- **1** = None (no symptom)
- **2** = Mild
- **3** = Moderate
- **4** = Significant (triggers alert consideration)
- **5** = Severe (triggers alert consideration)

### Functional Requirements
1. Display all 8 symptoms with clear, patient-friendly labels
2. Each symptom has a 1-5 severity selector
3. Symptoms save to today's DailyEntry
4. Clear visual indication of selected severity
5. Defaults to 1 (none) for new entries
6. Changes auto-save or have explicit save button

### Non-Functional Requirements
- Quick entry (under 60 seconds for all 8 symptoms)
- Tappable severity buttons (not sliders)
- Works with VoiceOver
- Scrollable if needed on smaller screens

## Acceptance Criteria
- [x] Displays all 8 symptoms with patient-friendly names
- [x] Each symptom has 1-5 severity selector
- [x] Symptoms save to today's DailyEntry
- [x] Clear visual indication of selected severity
- [x] Defaults to 1 (none) for new entries
- [x] Severity selection is intuitive and quick

## UI/UX Notes
- Use horizontal button row for 1-5 selection (like a rating)
- Highlight selected severity clearly (filled vs outlined)
- Use color gradient: 1=green, 3=yellow, 5=red (subtle, not alarming)
- Patient-friendly symptom names (not medical jargon)
- Group related symptoms if helpful (breathing issues together)
- Consider collapsible sections for long list

### Patient-Friendly Labels
- "Shortness of breath at rest" (not "Dyspnea at rest")
- "Shortness of breath with activity" (not "Dyspnea on exertion")
- "Trouble breathing lying down" (not "Orthopnea")
- "Waking up short of breath" (not "PND")
- "Chest discomfort"
- "Dizziness or lightheadedness"
- "Fainting or near-fainting"
- "Less urination than usual"

## Technical Notes
- Extend TodayViewModel to handle symptoms
- Create SymptomEntry objects linked to DailyEntry
- Use SymptomType enum from feature 002
- Consider a reusable SymptomRow component
- Bind severity selection to ViewModel
