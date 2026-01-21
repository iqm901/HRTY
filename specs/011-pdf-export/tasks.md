# Tasks: PDF Export

## ViewModel Setup
- [ ] Create ExportViewModel with @Observable
- [ ] Add patient identifier property (optional)
- [ ] Add date range properties
- [ ] Add PDF generation state (loading, success, error)

## PDF Generation
- [ ] Create PDFGenerator service
- [ ] Set up UIGraphicsPDFRenderer
- [ ] Define page layout and margins
- [ ] Add header with title and date range

## PDF Content Sections
- [ ] Add patient identifier section (if provided)
- [ ] Render weight trend chart as image
- [ ] Add weight summary statistics
- [ ] Render symptom trends
- [ ] Add diuretic dosing history table
- [ ] Add alert events list
- [ ] Add footer disclaimer

## Chart Rendering
- [ ] Convert Swift Charts to images
- [ ] Size appropriately for PDF
- [ ] Maintain readability when printed

## ExportView UI
- [ ] Update ExportView with generation UI
- [ ] Add patient identifier input field
- [ ] Add "Generate PDF" button
- [ ] Show loading indicator
- [ ] Display success message

## Share Sheet
- [ ] Present UIActivityViewController
- [ ] Pass generated PDF data
- [ ] Handle share completion

## Accessibility
- [ ] Add accessibility labels to controls
- [ ] Announce generation status

## Quality Checks
- [ ] PDF generates successfully
- [ ] All sections render correctly
- [ ] Share sheet opens with PDF
- [ ] Disclaimer is present
- [ ] App builds without errors
