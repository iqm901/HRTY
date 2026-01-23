# Tasks: PDF Export

## ViewModel Setup
- [x] Create ExportViewModel with @Observable
- [x] Add patient identifier property (optional)
- [x] Add date range properties
- [x] Add PDF generation state (loading, success, error)

## PDF Generation
- [x] Create PDFGenerator service
- [x] Set up UIGraphicsPDFRenderer
- [x] Define page layout and margins
- [x] Add header with title and date range

## PDF Content Sections
- [x] Add patient identifier section (if provided)
- [x] Render weight trend chart as image
- [x] Add weight summary statistics
- [x] Render symptom trends
- [x] Add diuretic dosing history table
- [x] Add alert events list
- [x] Add footer disclaimer

## Chart Rendering
- [x] Convert Swift Charts to images
- [x] Size appropriately for PDF
- [x] Maintain readability when printed

## ExportView UI
- [x] Update ExportView with generation UI
- [x] Add patient identifier input field
- [x] Add "Generate PDF" button
- [x] Show loading indicator
- [x] Display success message

## Share Sheet
- [x] Present UIActivityViewController
- [x] Pass generated PDF data
- [x] Handle share completion

## Accessibility
- [x] Add accessibility labels to controls
- [x] Announce generation status

## Quality Checks
- [x] PDF generates successfully
- [x] All sections render correctly
- [x] Share sheet opens with PDF
- [x] Disclaimer is present
- [x] App builds without errors

## Review Cycle Progress
- Iteration 0: Code Reviewer - [completed] - Renamed PDFDocument to PDFShareItem to avoid naming conflict with PDFKit
- Iteration 1: System Architect - [completed] - Extracted shared WeightDataPoint and SymptomDataPoint to Models/TrendDataPoints.swift
- Iteration 2: Frontend Designer - [completed] - Added Dynamic Type support and UI animations
- Iteration 3: QA Engineer - [completed] - Added unit tests for ExportViewModel, PDFGenerationState, and export data structures
- Iteration 4: Project Manager - [completed] - Verified all acceptance criteria met, all tasks complete, build and tests pass
- Iteration 5: Business Analyst - [completed] - Softened PDF messaging from clinical "Alert Events" to patient-friendly "Items to Discuss"
- Iteration 6: Code Reviewer - [pending]
- Iteration 7: System Architect - [completed] - Extracted shared WeightDataPoint and SymptomDataPoint to Models/TrendDataPoints.swift
