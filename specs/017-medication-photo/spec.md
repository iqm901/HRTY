# Feature: Medication Photo Capture

## Overview
Allow patients to photograph their medication bottles or medication list to help with setup.

## User Story
As a patient, I want to photograph my medication list to help set up my medications.

## Requirements

### Photo Capture
- Camera access to photograph pill bottles or med list
- Photos stored locally for reference
- User manually enters medications after viewing photo
- Optional feature - can skip and enter manually

### Photo Storage
- Store photos on-device only
- View saved photos in Medications tab
- Delete photos when no longer needed

## Acceptance Criteria
- [x] Camera access to photograph pill bottles or med list
- [x] Photos stored locally for reference
- [x] User manually enters medications after viewing photo
- [x] Optional feature - can skip and enter manually

## UI/UX Notes
- "Add Photo" button on Medications tab
- Simple camera interface
- Gallery of saved medication photos
- Clear that photos are for reference only
- Not OCR/automatic extraction (manual entry)

## Technical Notes
- Use PHPickerViewController or camera
- Request camera permission
- Store photos in app documents directory
- Create MedicationPhoto model
- Consider thumbnail generation for list view
