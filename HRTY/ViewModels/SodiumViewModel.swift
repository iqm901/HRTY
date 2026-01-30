import Foundation
import SwiftData
import SwiftUI

@Observable
final class SodiumViewModel {

    // MARK: - State

    var todayEntries: [SodiumEntry] = []
    var todayTotalMg: Int = 0
    var templates: [SodiumTemplate] = []
    var frequentTemplates: [SodiumTemplate] = []

    // MARK: - Form State

    var nameInput: String = ""
    var sodiumInput: String = ""
    var servingInput: String = ""
    var selectedCategory: TemplateCategory = .other

    // MARK: - Sheet Presentation

    var showingAddSheet = false
    var showingTemplateEditor = false
    var showingBarcodeScannerSheet = false
    var showingLabelScannerSheet = false
    var showingHistoryView = false
    var showingFoodSearchView = false

    // MARK: - Template Editing

    var editingTemplate: SodiumTemplate?

    // MARK: - Messages

    var entryAddedMessage: String?
    var errorMessage: String?
    var showSaveAsTemplatePrompt = false
    var lastAddedEntry: SodiumEntry?

    // MARK: - Selected Date (for history)

    var selectedDate: Date = Date()

    // MARK: - Services

    private let repository: SodiumRepositoryProtocol

    // MARK: - Initialization

    init(repository: SodiumRepositoryProtocol = SodiumRepository()) {
        self.repository = repository
    }

    // MARK: - Computed Properties

    var progressPercent: Double {
        SodiumConstants.progressPercent(current: todayTotalMg)
    }

    var progressColor: Color {
        SodiumConstants.progressColor(for: progressPercent)
    }

    var remainingMg: Int {
        max(0, SodiumConstants.dailyLimitMg - todayTotalMg)
    }

    var isOverLimit: Bool {
        todayTotalMg >= SodiumConstants.dailyLimitMg
    }

    var statusMessage: String {
        SodiumConstants.statusMessage(for: progressPercent)
    }

    var formattedTotal: String {
        SodiumConstants.formatSodiumWithLimit(todayTotalMg)
    }

    var formattedRemaining: String {
        SodiumConstants.formatRemaining(remainingMg)
    }

    var isFormValid: Bool {
        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return false }
        guard let sodium = Int(sodiumInput), sodium > 0 else { return false }
        return true
    }

    var parsedSodiumAmount: Int? {
        Int(sodiumInput)
    }

    // MARK: - Data Loading

    func loadData(context: ModelContext) {
        todayEntries = repository.fetchTodayEntries(context: context)
        todayTotalMg = repository.getTodayTotal(context: context)
        templates = repository.fetchTemplates(context: context)
        frequentTemplates = repository.fetchFrequentTemplates(limit: 8, context: context)
    }

    func loadEntriesForDate(_ date: Date, context: ModelContext) {
        selectedDate = date
        todayEntries = repository.fetchEntriesForDate(date, context: context)
        todayTotalMg = todayEntries.reduce(0) { $0 + $1.sodiumMg }
    }

    // MARK: - Entry Operations

    func addEntry(context: ModelContext) {
        guard isFormValid else {
            errorMessage = "Please enter a valid name and sodium amount"
            return
        }

        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        let trimmedServing = servingInput.trimmingCharacters(in: .whitespaces)
        guard let sodiumMg = parsedSodiumAmount else { return }

        if let entry = repository.addEntry(
            name: trimmedName,
            sodiumMg: sodiumMg,
            servingSize: trimmedServing.isEmpty ? nil : trimmedServing,
            source: .manual,
            barcode: nil,
            templateId: nil,
            bundledFoodId: nil,
            context: context
        ) {
            lastAddedEntry = entry
            entryAddedMessage = "\(trimmedName) logged"
            loadData(context: context)
            showSaveAsTemplatePrompt = true
        } else {
            errorMessage = "Could not save entry. Please try again."
        }
    }

    func addQuickEntry(name: String = "Quick Add", sodiumMg: Int, context: ModelContext) {
        if repository.addEntry(
            name: name,
            sodiumMg: sodiumMg,
            servingSize: nil,
            source: .manual,
            barcode: nil,
            templateId: nil,
            bundledFoodId: nil,
            context: context
        ) != nil {
            entryAddedMessage = "+\(SodiumConstants.formatSodium(sodiumMg))"
            loadData(context: context)
        }
    }

    func deleteEntry(_ entry: SodiumEntry, context: ModelContext) {
        if repository.deleteEntry(entry, context: context) {
            loadData(context: context)
        } else {
            errorMessage = "Could not delete entry. Please try again."
        }
    }

    func addFromTemplate(_ template: SodiumTemplate, context: ModelContext) {
        if let entry = repository.addEntryFromTemplate(template, context: context) {
            entryAddedMessage = "\(entry.name) logged"
            loadData(context: context)
        } else {
            errorMessage = "Could not log entry. Please try again."
        }
    }

    // MARK: - Template Operations

    func saveAsTemplate(context: ModelContext) {
        guard let entry = lastAddedEntry else { return }

        if repository.saveAsTemplate(
            name: entry.name,
            sodiumMg: entry.sodiumMg,
            servingSize: entry.servingSize,
            category: selectedCategory,
            barcode: entry.barcode,
            context: context
        ) != nil {
            entryAddedMessage = "\(entry.name) saved as template"
            loadData(context: context)
        }

        showSaveAsTemplatePrompt = false
        lastAddedEntry = nil
    }

    func saveTemplate(context: ModelContext) {
        guard isFormValid else {
            errorMessage = "Please enter a valid name and sodium amount"
            return
        }

        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        let trimmedServing = servingInput.trimmingCharacters(in: .whitespaces)
        guard let sodiumMg = parsedSodiumAmount else { return }

        if let template = editingTemplate {
            // Update existing template
            template.name = trimmedName
            template.sodiumMg = sodiumMg
            template.servingSize = trimmedServing.isEmpty ? nil : trimmedServing
            template.category = selectedCategory

            do {
                try context.save()
                entryAddedMessage = "Template updated"
                loadData(context: context)
            } catch {
                errorMessage = "Could not update template. Please try again."
            }
        } else {
            // Create new template
            if repository.saveAsTemplate(
                name: trimmedName,
                sodiumMg: sodiumMg,
                servingSize: trimmedServing.isEmpty ? nil : trimmedServing,
                category: selectedCategory,
                barcode: nil,
                context: context
            ) != nil {
                entryAddedMessage = "\(trimmedName) saved as template"
                loadData(context: context)
            } else {
                errorMessage = "Could not save template. Please try again."
            }
        }
    }

    func deleteTemplate(_ template: SodiumTemplate, context: ModelContext) {
        if repository.deleteTemplate(template, context: context) {
            loadData(context: context)
        } else {
            errorMessage = "Could not delete template. Please try again."
        }
    }

    func archiveTemplate(_ template: SodiumTemplate, context: ModelContext) {
        if repository.archiveTemplate(template, context: context) {
            loadData(context: context)
        } else {
            errorMessage = "Could not archive template. Please try again."
        }
    }

    // MARK: - Form Management

    func resetForm() {
        nameInput = ""
        sodiumInput = ""
        servingInput = ""
        selectedCategory = .other
        editingTemplate = nil
        errorMessage = nil
    }

    func prepareForAdd() {
        resetForm()
        showingAddSheet = true
    }

    func prepareForTemplateEdit(_ template: SodiumTemplate) {
        editingTemplate = template
        nameInput = template.name
        sodiumInput = String(template.sodiumMg)
        servingInput = template.servingSize ?? ""
        selectedCategory = template.category
        showingTemplateEditor = true
    }

    func prepareForNewTemplate() {
        resetForm()
        showingTemplateEditor = true
    }

    // MARK: - Barcode/OCR Entry

    func addFromBarcode(name: String, sodiumMg: Int, servingSize: String?, barcode: String, context: ModelContext) {
        if let entry = repository.addEntry(
            name: name,
            sodiumMg: sodiumMg,
            servingSize: servingSize,
            source: .barcode,
            barcode: barcode,
            templateId: nil,
            bundledFoodId: nil,
            context: context
        ) {
            lastAddedEntry = entry
            entryAddedMessage = "\(name) logged"
            loadData(context: context)
            showSaveAsTemplatePrompt = true
        }
    }

    func addFromOCR(sodiumMg: Int, context: ModelContext) {
        // Name will be set via form after OCR extraction
        nameInput = "Scanned Item"
        sodiumInput = String(sodiumMg)
        showingAddSheet = true
    }

    func addFromBundledFood(_ food: BundledFoodItem, context: ModelContext) {
        if repository.addEntry(
            name: food.displayName,
            sodiumMg: food.sodiumMg,
            servingSize: food.servingSize,
            source: .template,
            barcode: nil,
            templateId: nil,
            bundledFoodId: food.id,
            context: context
        ) != nil {
            entryAddedMessage = "\(food.name) logged"
            loadData(context: context)
        }
    }

    // MARK: - Message Clearing

    func clearEntryAddedMessage() {
        entryAddedMessage = nil
    }

    func clearErrorMessage() {
        errorMessage = nil
    }

    func dismissSaveAsTemplatePrompt() {
        showSaveAsTemplatePrompt = false
        lastAddedEntry = nil
    }
}
