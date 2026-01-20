import Foundation
import SwiftData

@Observable
final class TodayViewModel {
    // MARK: - Weight Input
    var weightInput: String = ""
    var validationError: String?
    var showSaveSuccess: Bool = false

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

    var weightChangeColor: WeightChangeColor {
        guard let change = weightChange else { return .neutral }

        if change > 0.05 {
            return .warning // Weight gain - amber
        } else if change < -0.05 {
            return .neutral // Weight loss - neutral
        } else {
            return .success // No change - green
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
}

// MARK: - Supporting Types
enum WeightChangeColor {
    case warning  // Weight gain - amber
    case neutral  // Weight loss - gray/neutral
    case success  // No change - green
}
