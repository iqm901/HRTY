import Foundation
import SwiftData
import SwiftUI

/// State representing the PDF generation process
enum PDFGenerationState: Equatable {
    case idle
    case loading
    case success(Data)
    case error(String)
}

/// Data structure containing all export data for PDF generation
struct ExportData {
    let dateRange: (start: Date, end: Date)
    let patientIdentifier: String?
    let weightEntries: [WeightDataPoint]
    let symptomEntries: [SymptomDataPoint]
    let diureticDoses: [DiureticDoseData]
    let alertEvents: [AlertEventData]
}

/// Simplified diuretic dose data for export
struct DiureticDoseData: Identifiable {
    let id = UUID()
    let date: Date
    let medicationName: String
    let dosageAmount: Double
    let unit: String
    let isExtraDose: Bool
}

/// Simplified alert event data for export
struct AlertEventData: Identifiable {
    let id = UUID()
    let date: Date
    let alertType: AlertType
    let message: String
}

@Observable
final class ExportViewModel {
    // MARK: - Properties

    /// Patient identifier from Settings (shared via @AppStorage)
    @ObservationIgnored
    @AppStorage(AppStorageKeys.patientIdentifier) var patientIdentifier: String = ""

    var generationState: PDFGenerationState = .idle
    var showShareSheet: Bool = false

    // MARK: - Computed Properties

    /// Start date of export range (30 days ago)
    var startDate: Date {
        Calendar.current.date(byAdding: .day, value: -29, to: Date()) ?? Date()
    }

    /// End date of export range (today)
    var endDate: Date {
        Date()
    }

    /// Formatted date range string for display
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    /// Whether a PDF is currently being generated
    var isGenerating: Bool {
        if case .loading = generationState {
            return true
        }
        return false
    }

    /// Whether generation was successful
    var didSucceed: Bool {
        if case .success = generationState {
            return true
        }
        return false
    }

    /// The generated PDF data, if available
    var pdfData: Data? {
        if case .success(let data) = generationState {
            return data
        }
        return nil
    }

    /// Error message if generation failed
    var errorMessage: String? {
        if case .error(let message) = generationState {
            return message
        }
        return nil
    }

    /// Optional patient identifier for PDF (nil if empty)
    var patientIdentifierForExport: String? {
        let trimmed = patientIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - Methods

    /// Generate PDF with data from the context
    func generatePDF(context: ModelContext) {
        generationState = .loading

        // Gather all data for export
        let exportData = gatherExportData(context: context)

        // Generate PDF
        let generator = PDFGenerator()
        do {
            let pdfData = try generator.generatePDF(from: exportData)
            generationState = .success(pdfData)
            showShareSheet = true
        } catch {
            generationState = .error("Unable to create PDF. Please try again.")
        }
    }

    /// Reset generation state
    func reset() {
        generationState = .idle
        showShareSheet = false
    }

    // MARK: - Private Methods

    private func gatherExportData(context: ModelContext) -> ExportData {
        let entries = DailyEntry.fetchForDateRange(from: startDate, to: endDate, in: context)

        // Weight entries
        let weightEntries = entries
            .compactMap { entry -> WeightDataPoint? in
                guard let weight = entry.weight else { return nil }
                return WeightDataPoint(date: entry.date, weight: weight)
            }
            .sorted { $0.date < $1.date }

        // Symptom entries
        var symptomEntries: [SymptomDataPoint] = []
        for entry in entries {
            guard let symptoms = entry.symptoms else { continue }
            for symptom in symptoms {
                let hasAlert = symptom.severity >= AlertConstants.severeSymptomThreshold
                symptomEntries.append(SymptomDataPoint(
                    date: entry.date,
                    symptomType: symptom.symptomType,
                    severity: symptom.severity,
                    hasAlert: hasAlert
                ))
            }
        }
        symptomEntries.sort { $0.date < $1.date }

        // Diuretic doses
        var diureticDoses: [DiureticDoseData] = []
        for entry in entries {
            guard let doses = entry.diureticDoses else { continue }
            for dose in doses {
                diureticDoses.append(DiureticDoseData(
                    date: dose.timestamp,
                    medicationName: dose.medication?.name ?? "Unknown",
                    dosageAmount: dose.dosageAmount,
                    unit: dose.medication?.unit ?? "mg",
                    isExtraDose: dose.isExtraDose
                ))
            }
        }
        diureticDoses.sort { $0.date < $1.date }

        // Alert events
        var alertEvents: [AlertEventData] = []
        for entry in entries {
            guard let events = entry.alertEvents else { continue }
            for event in events {
                alertEvents.append(AlertEventData(
                    date: event.triggeredAt,
                    alertType: event.alertType,
                    message: event.message
                ))
            }
        }
        alertEvents.sort { $0.date < $1.date }

        return ExportData(
            dateRange: (startDate, endDate),
            patientIdentifier: patientIdentifierForExport,
            weightEntries: weightEntries,
            symptomEntries: symptomEntries,
            diureticDoses: diureticDoses,
            alertEvents: alertEvents
        )
    }
}
