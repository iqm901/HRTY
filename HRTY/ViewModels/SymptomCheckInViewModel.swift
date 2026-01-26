import Foundation
import SwiftData

/// View model for managing the symptom check-in wizard flow
@Observable
final class SymptomCheckInViewModel {
    // MARK: - State

    /// Current step index (0-7)
    var currentStep: Int = 0

    /// Responses for each symptom type
    var responses: [SymptomType: Int] = [:]

    /// Whether we're showing the summary screen
    var showingSummary: Bool = false

    /// Whether we're resuming from a previous incomplete check-in
    var isResuming: Bool = false

    /// Reference to the progress model for persistence
    private var progressModel: SymptomCheckInProgress?

    // MARK: - Computed Properties

    /// All symptoms in order
    var symptoms: [SymptomType] {
        SymptomType.allCases
    }

    /// Current symptom being displayed
    var currentSymptom: SymptomType? {
        guard currentStep >= 0 && currentStep < symptoms.count else { return nil }
        return symptoms[currentStep]
    }

    /// Total number of steps
    var totalSteps: Int {
        symptoms.count
    }

    /// Whether we're on the first step
    var isFirstStep: Bool {
        currentStep == 0
    }

    /// Whether we're on the last step
    var isLastStep: Bool {
        currentStep == totalSteps - 1
    }

    /// Current severity for the current symptom
    var currentSeverity: Int? {
        guard let symptom = currentSymptom else { return nil }
        return responses[symptom]
    }

    /// Number of completed responses
    var completedCount: Int {
        responses.count
    }

    /// Progress text (e.g., "3/8")
    var progressText: String {
        "\(currentStep + 1)/\(totalSteps)"
    }

    /// Progress fraction (0.0 to 1.0)
    var progressFraction: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }

    /// Whether all symptoms have been answered
    var isComplete: Bool {
        completedCount >= totalSteps
    }

    /// Whether there are any concerning severities (4-5)
    var hasConcerningSeverities: Bool {
        responses.values.contains { $0 >= 4 }
    }

    /// Symptoms with concerning severities
    var concerningSymptoms: [SymptomType] {
        responses.filter { $0.value >= 4 }.map { $0.key }
    }

    // MARK: - Methods

    /// Load from an existing progress record
    func loadFromProgress(_ progress: SymptomCheckInProgress?) {
        guard let progress else {
            reset()
            return
        }

        self.progressModel = progress
        self.currentStep = progress.currentStepIndex
        self.responses = progress.responses
        self.isResuming = progress.completedCount > 0
    }

    /// Set severity for the current symptom
    func setSeverity(_ severity: Int) {
        guard let symptom = currentSymptom else { return }
        responses[symptom] = severity
    }

    /// Move to the next step
    func nextStep() {
        if isLastStep {
            showingSummary = true
        } else {
            currentStep += 1
        }
    }

    /// Move to the previous step
    func previousStep() {
        if showingSummary {
            showingSummary = false
        } else if currentStep > 0 {
            currentStep -= 1
        }
    }

    /// Navigate to a specific step (for editing from summary)
    func goToStep(_ step: Int) {
        guard step >= 0 && step < totalSteps else { return }
        showingSummary = false
        currentStep = step
    }

    /// Navigate to a specific symptom (for editing from summary)
    func goToSymptom(_ symptom: SymptomType) {
        if let index = symptoms.firstIndex(of: symptom) {
            goToStep(index)
        }
    }

    /// Save progress for later resumption
    func saveProgress(context: ModelContext, dailyEntry: DailyEntry?) {
        let progress = progressModel ?? SymptomCheckInProgress.getOrCreateForToday(
            in: context,
            dailyEntry: dailyEntry
        )

        progress.currentStepIndex = currentStep
        progress.responses = responses
        progress.updatedAt = Date()
        progress.dailyEntry = dailyEntry

        self.progressModel = progress

        do {
            try context.save()
        } catch {
            #if DEBUG
            print("Failed to save check-in progress: \(error)")
            #endif
        }
    }

    /// Complete the check-in and save all symptoms to the daily entry
    func completeCheckIn(context: ModelContext, dailyEntry: DailyEntry?) -> Bool {
        guard let entry = dailyEntry else { return false }

        // Save all symptoms to the daily entry
        var symptoms = entry.symptoms ?? []

        for (symptomType, severity) in responses {
            if let existingIndex = symptoms.firstIndex(where: { $0.symptomType == symptomType }) {
                symptoms[existingIndex].severity = severity
            } else {
                let newSymptom = SymptomEntry(
                    symptomType: symptomType,
                    severity: severity,
                    dailyEntry: entry
                )
                context.insert(newSymptom)
                symptoms.append(newSymptom)
            }
        }

        entry.symptoms = symptoms
        entry.updatedAt = Date()

        // Delete the progress record since we're done
        if let progress = progressModel {
            context.delete(progress)
        } else if let existingProgress = SymptomCheckInProgress.fetchForToday(in: context) {
            context.delete(existingProgress)
        }

        do {
            try context.save()
            return true
        } catch {
            #if DEBUG
            print("Failed to complete check-in: \(error)")
            #endif
            return false
        }
    }

    /// Delete progress and reset
    func deleteProgress(context: ModelContext) {
        if let progress = progressModel {
            context.delete(progress)
        } else if let existingProgress = SymptomCheckInProgress.fetchForToday(in: context) {
            context.delete(existingProgress)
        }

        do {
            try context.save()
        } catch {
            #if DEBUG
            print("Failed to delete progress: \(error)")
            #endif
        }

        reset()
    }

    /// Reset to initial state
    func reset() {
        currentStep = 0
        responses = [:]
        showingSummary = false
        isResuming = false
        progressModel = nil
    }
}
