# Feature: PDF Export

## Overview
Generate a PDF summary of patient data that can be shared with clinicians during visits. The PDF includes weight trends, symptom history, diuretic logs, and alerts.

## User Story
As a patient, I want to export my data as a PDF so I can share it with my clinician during visits.

## Requirements

### PDF Contents
- Patient identifier (optional)
- Date range
- 30-day weight trend chart
- Symptom severity trends
- Diuretic dosing history
- Alert events
- Footer disclaimer

### Generation
- One-tap PDF generation from Export tab
- Share sheet opens after generation
- PDF is readable and professionally formatted

### Disclaimer (Required)
> "This summary reflects patient-entered data for self-management and discussion with a clinician. It is not a medical record."

## Acceptance Criteria
- [x] One-tap PDF generation from Export tab
- [x] PDF includes: date range, 30-day weight trend, symptom trends, diuretic history, alert events
- [x] Optional patient identifier field
- [x] Footer disclaimer present
- [x] Share sheet opens after generation
- [x] PDF is readable and professionally formatted

## UI/UX Notes
- Simple "Generate PDF" button on Export tab
- Show date range being exported
- Optional patient name/ID field
- Loading indicator during generation
- Success feedback before share sheet

## Technical Notes
- Use UIGraphicsPDFRenderer for PDF creation
- Render charts as images for PDF
- Create ExportViewModel with @Observable
- Handle async generation
- Use standard share sheet (UIActivityViewController)
