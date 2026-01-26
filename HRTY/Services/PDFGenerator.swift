import UIKit
import SwiftUI

/// Service responsible for generating PDF reports from export data
final class PDFGenerator {
    // MARK: - Constants

    private let pageWidth: CGFloat = 612  // US Letter width in points
    private let pageHeight: CGFloat = 792 // US Letter height in points
    private let margin: CGFloat = 50
    private let lineSpacing: CGFloat = 6

    private var contentWidth: CGFloat {
        pageWidth - (margin * 2)
    }

    // MARK: - Fonts

    private let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
    private let headingFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    private let subheadingFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    private let bodyFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    private let captionFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    private let disclaimerFont = UIFont.italicSystemFont(ofSize: 9)

    // MARK: - Colors

    private let primaryColor = UIColor.label
    private let secondaryColor = UIColor.secondaryLabel
    private let accentColor = UIColor.systemBlue
    private let alertColor = UIColor.systemOrange

    // MARK: - Public Methods

    /// Generate a PDF document from export data
    /// - Parameter data: The export data containing all patient information
    /// - Returns: PDF data
    /// - Throws: Error if PDF generation fails
    func generatePDF(from data: ExportData) throws -> Data {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextTitle as String: "HRTY Health Summary",
            kCGPDFContextCreator as String: "HRTY App"
        ]

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let pdfData = renderer.pdfData { context in
            var currentY: CGFloat = 0

            // Page 1: Header, Weight Chart, Weight Summary
            context.beginPage()
            currentY = margin

            currentY = drawHeader(at: currentY, data: data, in: context.cgContext)
            currentY += 30

            currentY = drawWeightSection(at: currentY, data: data, in: context.cgContext)

            // Continue on same page or start new page for symptoms
            if currentY > pageHeight - 250 {
                context.beginPage()
                currentY = margin
            } else {
                currentY += 20
            }

            currentY = drawSymptomSection(at: currentY, data: data, in: context.cgContext)

            // Medication changes section - may need new page
            if currentY > pageHeight - 200 {
                context.beginPage()
                currentY = margin
            } else {
                currentY += 20
            }

            currentY = drawMedicationChangesSection(at: currentY, data: data, in: context.cgContext)

            // Diuretic section - may need new page
            if currentY > pageHeight - 200 {
                context.beginPage()
                currentY = margin
            } else {
                currentY += 20
            }

            currentY = drawDiureticSection(at: currentY, data: data, in: context.cgContext)

            // Alert events section - may need new page
            if currentY > pageHeight - 200 {
                context.beginPage()
                currentY = margin
            } else {
                currentY += 20
            }

            currentY = drawAlertSection(at: currentY, data: data, in: context.cgContext)

            // Footer disclaimer on last page
            drawFooter(in: context.cgContext)
        }

        return pdfData
    }

    // MARK: - Drawing Methods

    private func drawHeader(at y: CGFloat, data: ExportData, in context: CGContext) -> CGFloat {
        var currentY = y

        // Title
        let title = "HRTY Health Summary"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: primaryColor
        ]
        let titleSize = title.size(withAttributes: titleAttributes)
        title.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttributes)
        currentY += titleSize.height + 8

        // Date range
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateRange = "\(dateFormatter.string(from: data.dateRange.start)) - \(dateFormatter.string(from: data.dateRange.end))"
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: subheadingFont,
            .foregroundColor: secondaryColor
        ]
        dateRange.draw(at: CGPoint(x: margin, y: currentY), withAttributes: dateAttributes)
        currentY += 20

        // Patient identifier if provided
        if let identifier = data.patientIdentifier {
            currentY += 4
            let identifierText = "Patient: \(identifier)"
            let identifierAttributes: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: primaryColor
            ]
            identifierText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: identifierAttributes)
            currentY += 20
        }

        // Horizontal line
        currentY += 8
        context.setStrokeColor(UIColor.separator.cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: margin, y: currentY))
        context.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
        context.strokePath()
        currentY += 8

        return currentY
    }

    private func drawWeightSection(at y: CGFloat, data: ExportData, in context: CGContext) -> CGFloat {
        var currentY = y

        // Section heading
        currentY = drawSectionHeading("Weight Trend (30 Days)", at: currentY)

        if data.weightEntries.isEmpty {
            currentY = drawEmptyState("No weight data recorded", at: currentY)
            return currentY
        }

        // Weight chart placeholder - render as a simple visualization
        currentY = drawWeightChart(at: currentY, entries: data.weightEntries, in: context)
        currentY += 16

        // Weight statistics
        currentY = drawWeightStatistics(at: currentY, entries: data.weightEntries)

        return currentY
    }

    private func drawWeightChart(at y: CGFloat, entries: [WeightDataPoint], in context: CGContext) -> CGFloat {
        let chartHeight: CGFloat = 120
        let chartWidth = contentWidth
        let chartX = margin
        let chartY = y

        // Background
        context.setFillColor(UIColor.systemGray6.cgColor)
        context.fill(CGRect(x: chartX, y: chartY, width: chartWidth, height: chartHeight))

        // Border
        context.setStrokeColor(UIColor.systemGray4.cgColor)
        context.setLineWidth(1)
        context.stroke(CGRect(x: chartX, y: chartY, width: chartWidth, height: chartHeight))

        guard entries.count > 1 else {
            // Single point - just show the value
            if let entry = entries.first {
                let text = String(format: "%.1f lbs", entry.weight)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: headingFont,
                    .foregroundColor: accentColor
                ]
                let size = text.size(withAttributes: attributes)
                text.draw(at: CGPoint(x: chartX + (chartWidth - size.width) / 2,
                                      y: chartY + (chartHeight - size.height) / 2),
                         withAttributes: attributes)
            }
            return chartY + chartHeight
        }

        // Calculate scale
        let weights = entries.map { $0.weight }
        let minWeight = (weights.min() ?? 0) - 2
        let maxWeight = (weights.max() ?? 0) + 2
        let weightRange = maxWeight - minWeight

        // Draw grid lines
        context.setStrokeColor(UIColor.systemGray4.cgColor)
        context.setLineWidth(0.5)
        for i in 0...4 {
            let gridY = chartY + CGFloat(i) * chartHeight / 4
            context.move(to: CGPoint(x: chartX, y: gridY))
            context.addLine(to: CGPoint(x: chartX + chartWidth, y: gridY))
        }
        context.strokePath()

        // Draw line chart
        context.setStrokeColor(accentColor.cgColor)
        context.setLineWidth(2)

        let pointSpacing = chartWidth / CGFloat(entries.count - 1)

        for (index, entry) in entries.enumerated() {
            let x = chartX + CGFloat(index) * pointSpacing
            let normalizedWeight = (entry.weight - minWeight) / weightRange
            let pointY = chartY + chartHeight - (CGFloat(normalizedWeight) * (chartHeight - 20)) - 10

            if index == 0 {
                context.move(to: CGPoint(x: x, y: pointY))
            } else {
                context.addLine(to: CGPoint(x: x, y: pointY))
            }
        }
        context.strokePath()

        // Draw points
        context.setFillColor(accentColor.cgColor)
        for (index, entry) in entries.enumerated() {
            let x = chartX + CGFloat(index) * pointSpacing
            let normalizedWeight = (entry.weight - minWeight) / weightRange
            let pointY = chartY + chartHeight - (CGFloat(normalizedWeight) * (chartHeight - 20)) - 10

            context.fillEllipse(in: CGRect(x: x - 3, y: pointY - 3, width: 6, height: 6))
        }

        // Y-axis labels
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: captionFont,
            .foregroundColor: secondaryColor
        ]
        let maxLabel = String(format: "%.0f", maxWeight)
        let minLabel = String(format: "%.0f", minWeight)
        maxLabel.draw(at: CGPoint(x: chartX + 4, y: chartY + 2), withAttributes: labelAttributes)
        minLabel.draw(at: CGPoint(x: chartX + 4, y: chartY + chartHeight - 14), withAttributes: labelAttributes)

        return chartY + chartHeight
    }

    private func drawWeightStatistics(at y: CGFloat, entries: [WeightDataPoint]) -> CGFloat {
        var currentY = y

        let weights = entries.map { $0.weight }
        guard let firstWeight = weights.first,
              let lastWeight = weights.last else {
            return currentY
        }

        let change = lastWeight - firstWeight
        let changeText: String
        if abs(change) < 0.1 {
            changeText = "stable"
        } else if change > 0 {
            changeText = String(format: "+%.1f lbs", change)
        } else {
            changeText = String(format: "%.1f lbs", change)
        }

        let statsText = "Current: \(String(format: "%.1f", lastWeight)) lbs  |  Starting: \(String(format: "%.1f", firstWeight)) lbs  |  Change: \(changeText)  |  Days recorded: \(entries.count)"

        let attributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: primaryColor
        ]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributedStats = NSAttributedString(string: statsText, attributes: [
            .font: bodyFont,
            .foregroundColor: primaryColor,
            .paragraphStyle: paragraphStyle
        ])

        let boundingRect = attributedStats.boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            context: nil
        )

        attributedStats.draw(in: CGRect(x: margin, y: currentY, width: contentWidth, height: boundingRect.height + 4))
        currentY += boundingRect.height + 8

        return currentY
    }

    private func drawSymptomSection(at y: CGFloat, data: ExportData, in context: CGContext) -> CGFloat {
        var currentY = y

        currentY = drawSectionHeading("Symptom Trends (30 Days)", at: currentY)

        if data.symptomEntries.isEmpty {
            currentY = drawEmptyState("No symptom data recorded", at: currentY)
            return currentY
        }

        // Group symptoms by type and show summary
        var symptomSummary: [SymptomType: (count: Int, maxSeverity: Int, avgSeverity: Double)] = [:]

        for entry in data.symptomEntries {
            if var existing = symptomSummary[entry.symptomType] {
                existing.count += 1
                existing.maxSeverity = max(existing.maxSeverity, entry.severity)
                existing.avgSeverity = (existing.avgSeverity * Double(existing.count - 1) + Double(entry.severity)) / Double(existing.count)
                symptomSummary[entry.symptomType] = existing
            } else {
                symptomSummary[entry.symptomType] = (count: 1, maxSeverity: entry.severity, avgSeverity: Double(entry.severity))
            }
        }

        // Table header
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: subheadingFont,
            .foregroundColor: primaryColor
        ]

        let col1Width: CGFloat = 200
        let col2Width: CGFloat = 80
        let col3Width: CGFloat = 80
        let col4Width: CGFloat = 80

        "Symptom".draw(at: CGPoint(x: margin, y: currentY), withAttributes: headerAttributes)
        "Days".draw(at: CGPoint(x: margin + col1Width, y: currentY), withAttributes: headerAttributes)
        "Max".draw(at: CGPoint(x: margin + col1Width + col2Width, y: currentY), withAttributes: headerAttributes)
        "Avg".draw(at: CGPoint(x: margin + col1Width + col2Width + col3Width, y: currentY), withAttributes: headerAttributes)
        currentY += 20

        // Separator line
        context.setStrokeColor(UIColor.separator.cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: margin, y: currentY))
        context.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
        context.strokePath()
        currentY += 6

        // Table rows
        let rowAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: primaryColor
        ]
        let alertAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: alertColor
        ]

        for symptomType in SymptomType.allCases {
            guard let summary = symptomSummary[symptomType] else { continue }

            let useAlertColor = summary.maxSeverity >= AlertConstants.severeSymptomThreshold
            let attrs = useAlertColor ? alertAttributes : rowAttributes

            symptomType.displayName.draw(at: CGPoint(x: margin, y: currentY), withAttributes: attrs)
            "\(summary.count)".draw(at: CGPoint(x: margin + col1Width, y: currentY), withAttributes: attrs)
            "\(summary.maxSeverity)".draw(at: CGPoint(x: margin + col1Width + col2Width, y: currentY), withAttributes: attrs)
            String(format: "%.1f", summary.avgSeverity).draw(at: CGPoint(x: margin + col1Width + col2Width + col3Width, y: currentY), withAttributes: attrs)

            currentY += 18
        }

        // Alert indicator note
        let alertCount = data.symptomEntries.filter { $0.hasAlert }.count
        if alertCount > 0 {
            currentY += 4
            let noteText = "Orange items may be helpful to discuss with your care team"
            let noteAttributes: [NSAttributedString.Key: Any] = [
                .font: captionFont,
                .foregroundColor: alertColor
            ]
            noteText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: noteAttributes)
            currentY += 16
        }

        return currentY
    }

    private func drawMedicationChangesSection(at y: CGFloat, data: ExportData, in context: CGContext) -> CGFloat {
        var currentY = y

        // Only show section if there are medication changes with observations
        let insightsWithObservations = data.medicationChangeInsights.filter { $0.hasObservations }

        guard !insightsWithObservations.isEmpty else {
            return currentY
        }

        currentY = drawSectionHeading("Medication Changes & Clinical Context", at: currentY)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        for (index, insight) in insightsWithObservations.enumerated() {
            // Check if we need a new page
            if currentY > pageHeight - 200 {
                return currentY // Let the caller handle page break
            }

            // Medication name and category
            var titleText = insight.medicationName
            if let category = insight.category {
                titleText += " (\(category.rawValue))"
            }

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: subheadingFont,
                .foregroundColor: accentColor
            ]
            titleText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttributes)
            currentY += 18

            // Change description
            let changeText = "Changed: \(dateFormatter.string(from: insight.changeDate)) — \(insight.changeDescription)"
            let changeAttributes: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: primaryColor
            ]
            changeText.draw(at: CGPoint(x: margin + 10, y: currentY), withAttributes: changeAttributes)
            currentY += 18

            // Observations header
            let obsHeaderText = "Observations in the \(MedicationChangeAnalysisService.lookbackDays) days before this change:"
            let obsHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: captionFont,
                .foregroundColor: secondaryColor
            ]
            obsHeaderText.draw(at: CGPoint(x: margin + 10, y: currentY), withAttributes: obsHeaderAttributes)
            currentY += 14

            // Individual observations
            for observation in insight.observations {
                let bulletColor: UIColor
                switch observation.severity {
                case .informational:
                    bulletColor = secondaryColor
                case .notable:
                    bulletColor = alertColor
                case .significant:
                    bulletColor = UIColor.systemRed
                }

                let bulletText = "• \(observation.description)"
                let bulletAttributes: [NSAttributedString.Key: Any] = [
                    .font: bodyFont,
                    .foregroundColor: bulletColor
                ]

                // Word wrap observation text
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byWordWrapping
                paragraphStyle.headIndent = margin + 20

                let attributedBullet = NSAttributedString(string: bulletText, attributes: [
                    .font: bodyFont,
                    .foregroundColor: bulletColor,
                    .paragraphStyle: paragraphStyle
                ])

                let bulletRect = attributedBullet.boundingRect(
                    with: CGSize(width: contentWidth - 20, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    context: nil
                )

                attributedBullet.draw(in: CGRect(x: margin + 15, y: currentY, width: contentWidth - 20, height: bulletRect.height + 2))
                currentY += bulletRect.height + 4

                // Check if we need a new page mid-observations
                if currentY > pageHeight - 100 {
                    break
                }
            }

            // Context message
            if let contextMessage = insight.contextMessage {
                currentY += 4

                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byWordWrapping

                let contextAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.italicSystemFont(ofSize: 11),
                    .foregroundColor: secondaryColor,
                    .paragraphStyle: paragraphStyle
                ]

                let attributedContext = NSAttributedString(string: contextMessage, attributes: contextAttributes)
                let contextRect = attributedContext.boundingRect(
                    with: CGSize(width: contentWidth - 20, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    context: nil
                )

                attributedContext.draw(in: CGRect(x: margin + 10, y: currentY, width: contentWidth - 20, height: contextRect.height + 2))
                currentY += contextRect.height + 8
            }

            // Add separator between medications (except for last one)
            if index < insightsWithObservations.count - 1 {
                currentY += 8
                context.setStrokeColor(UIColor.separator.cgColor)
                context.setLineWidth(0.5)
                context.move(to: CGPoint(x: margin + 20, y: currentY))
                context.addLine(to: CGPoint(x: pageWidth - margin - 20, y: currentY))
                context.strokePath()
                currentY += 12
            }
        }

        return currentY
    }

    private func drawDiureticSection(at y: CGFloat, data: ExportData, in context: CGContext) -> CGFloat {
        var currentY = y

        currentY = drawSectionHeading("Diuretic History (30 Days)", at: currentY)

        if data.diureticDoses.isEmpty {
            currentY = drawEmptyState("No diuretic doses recorded", at: currentY)
            return currentY
        }

        // Group by day
        let calendar = Calendar.current
        var dosesByDay: [Date: [DiureticDoseData]] = [:]

        for dose in data.diureticDoses {
            let day = calendar.startOfDay(for: dose.date)
            if dosesByDay[day] != nil {
                dosesByDay[day]?.append(dose)
            } else {
                dosesByDay[day] = [dose]
            }
        }

        let sortedDays = dosesByDay.keys.sorted().suffix(10) // Show last 10 days with doses

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"

        let rowAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: primaryColor
        ]

        for day in sortedDays {
            guard let doses = dosesByDay[day] else { continue }

            let dateText = dateFormatter.string(from: day)
            let doseDescriptions = doses.map { dose -> String in
                let extraNote = dose.isExtraDose ? " (extra)" : ""
                return "\(dose.medicationName) \(String(format: "%.0f", dose.dosageAmount))\(dose.unit)\(extraNote)"
            }
            let dosesText = doseDescriptions.joined(separator: ", ")

            let fullText = "\(dateText): \(dosesText)"
            fullText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: rowAttributes)
            currentY += 18

            // Check if we need a new page
            if currentY > pageHeight - 100 {
                break
            }
        }

        // Summary
        currentY += 8
        let totalDoses = data.diureticDoses.count
        let extraDoses = data.diureticDoses.filter { $0.isExtraDose }.count
        let summaryText = "Total doses: \(totalDoses)  |  Extra doses: \(extraDoses)"
        let summaryAttributes: [NSAttributedString.Key: Any] = [
            .font: captionFont,
            .foregroundColor: secondaryColor
        ]
        summaryText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: summaryAttributes)
        currentY += 16

        return currentY
    }

    private func drawAlertSection(at y: CGFloat, data: ExportData, in context: CGContext) -> CGFloat {
        var currentY = y

        currentY = drawSectionHeading("Items to Discuss (30 Days)", at: currentY)

        if data.alertEvents.isEmpty {
            currentY = drawEmptyState("No items flagged for discussion", at: currentY)
            return currentY
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"

        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: subheadingFont,
            .foregroundColor: alertColor
        ]
        let messageAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: primaryColor
        ]

        for (index, event) in data.alertEvents.enumerated() {
            if index >= 10 { break } // Limit to 10 alerts

            let dateText = "\(dateFormatter.string(from: event.date)) - \(event.alertType.displayName)"
            dateText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: dateAttributes)
            currentY += 16

            // Word wrap message
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping

            let attributedMessage = NSAttributedString(string: event.message, attributes: [
                .font: bodyFont,
                .foregroundColor: primaryColor,
                .paragraphStyle: paragraphStyle
            ])

            let messageRect = attributedMessage.boundingRect(
                with: CGSize(width: contentWidth - 20, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin],
                context: nil
            )

            attributedMessage.draw(in: CGRect(x: margin + 10, y: currentY, width: contentWidth - 20, height: messageRect.height + 4))
            currentY += messageRect.height + 12

            if currentY > pageHeight - 100 {
                break
            }
        }

        return currentY
    }

    private func drawFooter(in context: CGContext) {
        let footerY = pageHeight - margin - 30

        // Separator line
        context.setStrokeColor(UIColor.separator.cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: margin, y: footerY))
        context.addLine(to: CGPoint(x: pageWidth - margin, y: footerY))
        context.strokePath()

        // Disclaimer text
        let disclaimer = "This summary reflects patient-entered data for self-management and discussion with a clinician. It is not a medical record."

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: disclaimerFont,
            .foregroundColor: secondaryColor,
            .paragraphStyle: paragraphStyle
        ]

        let attributedDisclaimer = NSAttributedString(string: disclaimer, attributes: attributes)
        let boundingRect = attributedDisclaimer.boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            context: nil
        )

        attributedDisclaimer.draw(in: CGRect(x: margin, y: footerY + 8, width: contentWidth, height: boundingRect.height + 4))

        // Generated date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let generatedText = "Generated: \(dateFormatter.string(from: Date()))"

        let generatedAttributes: [NSAttributedString.Key: Any] = [
            .font: captionFont,
            .foregroundColor: UIColor.tertiaryLabel,
            .paragraphStyle: paragraphStyle
        ]

        let generatedSize = generatedText.size(withAttributes: generatedAttributes)
        generatedText.draw(at: CGPoint(x: pageWidth - margin - generatedSize.width, y: footerY + boundingRect.height + 12),
                          withAttributes: generatedAttributes)
    }

    // MARK: - Helper Methods

    private func drawSectionHeading(_ text: String, at y: CGFloat) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: headingFont,
            .foregroundColor: primaryColor
        ]
        text.draw(at: CGPoint(x: margin, y: y), withAttributes: attributes)
        return y + 24
    }

    private func drawEmptyState(_ text: String, at y: CGFloat) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: secondaryColor
        ]
        text.draw(at: CGPoint(x: margin, y: y), withAttributes: attributes)
        return y + 20
    }
}
