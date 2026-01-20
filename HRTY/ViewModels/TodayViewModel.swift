import Foundation
import SwiftData

@Observable
final class TodayViewModel {
    // MARK: - Weight Input
    var weightInput: String = ""
    var validationError: String?
    var showSaveSuccess: Bool = false

    // MARK: - Symptom Input
    var symptomSeverities: [SymptomType: Int] = [:]
    var symptomSaveError: Bool = false

    // MARK: - Data State
    var todayEntry: DailyEntry?
    var yesterdayEntry: DailyEntry?

    // MARK: - Validation Constants
    static let minimumWeight: Double = 50.0
    static let maximumWeight: Double = 500.0

    // MARK: - Computed Properties
    var parsedWeight: Double? {
        Double(weightInput)
    }

    var isValidWeight: Bool {
        guard let weight = parsedWeight else { return false }
        return weight >= Self.minimumWeight && weight <= Self.maximumWeight
    }

    var previousWeight: Double? {
        yesterdayEntry?.weight
    }

    var weightChange: Double? {
        guard let current = todayEntry?.weight,
              let previous = previousWeight else {
            return nil
        }
        return current - previous
    }

    var weightChangeText: String? {
        guard let change = weightChange else { return nil }
        let absChange = abs(change)
        let formattedChange = String(format: "%.1f", absChange)

        if change > 0.05 {
            return "You're \(formattedChange) lbs heavier than yesterday"
        } else if change < -0.05 {
            return "You're \(formattedChange) lbs lighter than yesterday"
        } else {
            return "Your weight is the same as yesterday"
        }
    }

    var hasNoPreviousData: Bool {
        previousWeight == nil
    }

    var yesterdayDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return formatter.string(from: yesterday)
    }

    /// Returns true when the patient has actively engaged with symptom logging
    /// (any symptom rated above 1, indicating intentional input rather than defaults)
    var hasLoggedSymptoms: Bool {
        symptomSeverities.values.contains { $0 > 1 }
    }

    // MARK: - Methods
    func loadData(context: ModelContext) {
        let today = Date()
        todayEntry = DailyEntry.getOrCreate(for: today, in: context)

        if let existingWeight = todayEntry?.weight {
            weightInput = String(format: "%.1f", existingWeight)
        }

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        yesterdayEntry = DailyEntry.fetchForDate(yesterday, in: context)
    }

    func validateWeight() -> Bool {
        validationError = nil

        guard !weightInput.isEmpty else {
            validationError = "Please enter your weight"
            return false
        }

        guard let weight = parsedWeight else {
            validationError = "Please enter a valid number"
            return false
        }

        guard weight >= Self.minimumWeight else {
            validationError = "Weight must be at least \(Int(Self.minimumWeight)) lbs"
            return false
        }

        guard weight <= Self.maximumWeight else {
            validationError = "Weight must be less than \(Int(Self.maximumWeight)) lbs"
            return false
        }

        return true
    }

    func saveWeight(context: ModelContext) {
        guard validateWeight() else { return }
        guard let weight = parsedWeight else { return }

        if todayEntry == nil {
            todayEntry = DailyEntry.getOrCreate(for: Date(), in: context)
        }

        todayEntry?.weight = weight
        todayEntry?.updatedAt = Date()

        do {
            try context.save()
            showSaveSuccess = true

            // Auto-dismiss success message after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.showSaveSuccess = false
            }
        } catch {
            validationError = "Could not save weight. Please try again."
        }
    }

    // MARK: - Symptom Methods

    func loadSymptoms(context: ModelContext) {
        // Initialize all symptoms with default severity of 1
        for symptomType in SymptomType.allCases {
            symptomSeverities[symptomType] = 1
        }

        // Load existing symptoms from today's entry
        guard let entry = todayEntry,
              let existingSymptoms = entry.symptoms else {
            return
        }

        for symptom in existingSymptoms {
            symptomSeverities[symptom.symptomType] = symptom.severity
        }
    }

    func severity(for symptomType: SymptomType) -> Int {
        symptomSeverities[symptomType] ?? 1
    }

    func updateSeverity(_ severity: Int, for symptomType: SymptomType, context: ModelContext) {
        let clampedSeverity = min(max(severity, 1), 5)
        symptomSeverities[symptomType] = clampedSeverity

        // Ensure we have a daily entry
        if todayEntry == nil {
            todayEntry = DailyEntry.getOrCreate(for: Date(), in: context)
        }

        guard let entry = todayEntry else { return }

        // Find or create the symptom entry
        var symptoms = entry.symptoms ?? []
        if let existingIndex = symptoms.firstIndex(where: { $0.symptomType == symptomType }) {
            symptoms[existingIndex].severity = clampedSeverity
        } else {
            let newSymptom = SymptomEntry(symptomType: symptomType, severity: clampedSeverity, dailyEntry: entry)
            context.insert(newSymptom)
            symptoms.append(newSymptom)
        }

        entry.symptoms = symptoms
        entry.updatedAt = Date()

        do {
            try context.save()
            symptomSaveError = false
        } catch {
            // Track error state for potential UI indication
            // Auto-save errors are non-blocking but trackable
            symptomSaveError = true
            #if DEBUG
            print("Symptom save error: \(error.localizedDescription)")
            #endif
        }
    }
}
