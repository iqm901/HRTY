import Foundation
import SwiftData

@Observable
final class MyHeartViewModel {
    // MARK: - State

    var profile: ClinicalProfile?

    // MARK: - Sheet State

    var showingEjectionFractionEdit = false
    var showingNYHAClassEdit = false
    var showingBPTargetEdit = false
    var showingCoronaryArteriesDetail = false
    var showingHeartValvesDetail = false

    // MARK: - Ejection Fraction Form

    var ejectionFractionInput: String = ""
    var ejectionFractionDate: Date = Date()

    // MARK: - NYHA Class Form

    var selectedNYHAClass: NYHAClass?
    var nyhaClassDate: Date = Date()

    // MARK: - BP Target Form

    var targetSystolicInput: String = ""
    var targetDiastolicInput: String = ""

    // MARK: - Coronary Artery Form

    var showingCoronaryArteryEdit = false
    var selectedCoronaryArtery: CoronaryArtery?
    var arteryTypeSelection: CoronaryArteryType = .lad
    var hasBlockage = false
    var blockageSeveritySelection: BlockageSeverity?
    var hasStent = false
    var stentDate: Date = Date()
    var arteryNotes: String = ""

    // MARK: - Heart Valve Form

    var showingHeartValveEdit = false
    var selectedHeartValve: HeartValveCondition?
    var valveTypeSelection: HeartValveType = .mitral
    var problemTypeSelection: ValveProblemType?
    var valveSeveritySelection: ValveSeverity?
    var hasIntervention = false
    var interventionTypeSelection: ValveInterventionType?
    var interventionDate: Date = Date()
    var valveNotes: String = ""

    // MARK: - Validation

    var validationError: String?

    // MARK: - Loading

    @MainActor
    func loadProfile(context: ModelContext) {
        profile = ClinicalProfile.getOrCreate(in: context)
    }

    // MARK: - Ejection Fraction Methods

    func prepareEjectionFractionEdit() {
        if let ef = profile?.ejectionFraction {
            ejectionFractionInput = String(ef)
        } else {
            ejectionFractionInput = ""
        }
        ejectionFractionDate = profile?.ejectionFractionDate ?? Date()
        validationError = nil
        showingEjectionFractionEdit = true
    }

    func saveEjectionFraction(context: ModelContext) {
        guard let efValue = Int(ejectionFractionInput.trimmingCharacters(in: .whitespaces)),
              efValue >= 0, efValue <= 100 else {
            validationError = "Please enter a valid percentage (0-100)"
            return
        }

        profile?.ejectionFraction = efValue
        profile?.ejectionFractionDate = ejectionFractionDate

        do {
            try context.save()
            showingEjectionFractionEdit = false
            validationError = nil
        } catch {
            validationError = "Could not save. Please try again."
        }
    }

    func clearEjectionFraction(context: ModelContext) {
        profile?.ejectionFraction = nil
        profile?.ejectionFractionDate = nil

        do {
            try context.save()
            showingEjectionFractionEdit = false
        } catch {
            validationError = "Could not clear. Please try again."
        }
    }

    // MARK: - NYHA Class Methods

    func prepareNYHAClassEdit() {
        selectedNYHAClass = profile?.nyhaClass
        nyhaClassDate = profile?.nyhaClassDate ?? Date()
        validationError = nil
        showingNYHAClassEdit = true
    }

    func saveNYHAClass(context: ModelContext) {
        guard let nyhaClass = selectedNYHAClass else {
            validationError = "Please select a NYHA class"
            return
        }

        profile?.nyhaClass = nyhaClass
        profile?.nyhaClassDate = nyhaClassDate

        do {
            try context.save()
            showingNYHAClassEdit = false
            validationError = nil
        } catch {
            validationError = "Could not save. Please try again."
        }
    }

    func clearNYHAClass(context: ModelContext) {
        profile?.nyhaClass = nil
        profile?.nyhaClassDate = nil

        do {
            try context.save()
            showingNYHAClassEdit = false
        } catch {
            validationError = "Could not clear. Please try again."
        }
    }

    // MARK: - BP Target Methods

    func prepareBPTargetEdit() {
        if let systolic = profile?.targetSystolicBP {
            targetSystolicInput = String(systolic)
        } else {
            targetSystolicInput = ""
        }
        if let diastolic = profile?.targetDiastolicBP {
            targetDiastolicInput = String(diastolic)
        } else {
            targetDiastolicInput = ""
        }
        validationError = nil
        showingBPTargetEdit = true
    }

    func saveBPTarget(context: ModelContext) {
        let systolicTrimmed = targetSystolicInput.trimmingCharacters(in: .whitespaces)
        let diastolicTrimmed = targetDiastolicInput.trimmingCharacters(in: .whitespaces)

        guard let systolic = Int(systolicTrimmed),
              let diastolic = Int(diastolicTrimmed),
              systolic > 0, systolic < 300,
              diastolic > 0, diastolic < 200,
              systolic > diastolic else {
            validationError = "Please enter valid blood pressure values"
            return
        }

        profile?.targetSystolicBP = systolic
        profile?.targetDiastolicBP = diastolic

        do {
            try context.save()
            showingBPTargetEdit = false
            validationError = nil
        } catch {
            validationError = "Could not save. Please try again."
        }
    }

    func clearBPTarget(context: ModelContext) {
        profile?.targetSystolicBP = nil
        profile?.targetDiastolicBP = nil

        do {
            try context.save()
            showingBPTargetEdit = false
        } catch {
            validationError = "Could not clear. Please try again."
        }
    }

    // MARK: - Coronary Artery Methods

    func prepareCoronaryArteriesDetail() {
        showingCoronaryArteriesDetail = true
    }

    func prepareAddCoronaryArtery() {
        selectedCoronaryArtery = nil
        arteryTypeSelection = .lad
        hasBlockage = false
        blockageSeveritySelection = nil
        hasStent = false
        stentDate = Date()
        arteryNotes = ""
        validationError = nil
        showingCoronaryArteryEdit = true
    }

    func prepareEditCoronaryArtery(_ artery: CoronaryArtery) {
        selectedCoronaryArtery = artery
        arteryTypeSelection = artery.arteryType
        hasBlockage = artery.hasBlockage
        blockageSeveritySelection = artery.blockageSeverity
        hasStent = artery.hasStent
        stentDate = artery.stentDate ?? Date()
        arteryNotes = artery.notes ?? ""
        validationError = nil
        showingCoronaryArteryEdit = true
    }

    func saveCoronaryArtery(context: ModelContext) {
        if let existing = selectedCoronaryArtery {
            // Update existing
            existing.arteryType = arteryTypeSelection
            existing.hasBlockage = hasBlockage
            existing.blockageSeverity = hasBlockage ? blockageSeveritySelection : nil
            existing.hasStent = hasStent
            existing.stentDate = hasStent ? stentDate : nil
            existing.notes = arteryNotes.isEmpty ? nil : arteryNotes
        } else {
            // Create new
            let artery = CoronaryArtery(
                arteryType: arteryTypeSelection,
                hasBlockage: hasBlockage,
                blockageSeverity: hasBlockage ? blockageSeveritySelection : nil,
                hasStent: hasStent,
                stentDate: hasStent ? stentDate : nil,
                notes: arteryNotes.isEmpty ? nil : arteryNotes
            )
            artery.profile = profile
            context.insert(artery)

            if profile?.coronaryArteries == nil {
                profile?.coronaryArteries = []
            }
            profile?.coronaryArteries?.append(artery)
        }

        do {
            try context.save()
            showingCoronaryArteryEdit = false
            validationError = nil
        } catch {
            validationError = "Could not save. Please try again."
        }
    }

    func deleteCoronaryArtery(_ artery: CoronaryArtery, context: ModelContext) {
        profile?.coronaryArteries?.removeAll { $0.persistentModelID == artery.persistentModelID }
        context.delete(artery)

        do {
            try context.save()
        } catch {
            validationError = "Could not delete. Please try again."
        }
    }

    // MARK: - Heart Valve Methods

    func prepareHeartValvesDetail() {
        showingHeartValvesDetail = true
    }

    func prepareAddHeartValve() {
        selectedHeartValve = nil
        valveTypeSelection = .mitral
        problemTypeSelection = nil
        valveSeveritySelection = nil
        hasIntervention = false
        interventionTypeSelection = nil
        interventionDate = Date()
        valveNotes = ""
        validationError = nil
        showingHeartValveEdit = true
    }

    func prepareEditHeartValve(_ valve: HeartValveCondition) {
        selectedHeartValve = valve
        valveTypeSelection = valve.valveType
        problemTypeSelection = valve.problemType
        valveSeveritySelection = valve.severity
        hasIntervention = valve.hasIntervention
        interventionTypeSelection = valve.interventionType
        interventionDate = valve.interventionDate ?? Date()
        valveNotes = valve.notes ?? ""
        validationError = nil
        showingHeartValveEdit = true
    }

    func saveHeartValve(context: ModelContext) {
        if let existing = selectedHeartValve {
            // Update existing
            existing.valveType = valveTypeSelection
            existing.problemType = problemTypeSelection
            existing.severity = problemTypeSelection != nil ? valveSeveritySelection : nil
            existing.hasIntervention = hasIntervention
            existing.interventionType = hasIntervention ? interventionTypeSelection : nil
            existing.interventionDate = hasIntervention ? interventionDate : nil
            existing.notes = valveNotes.isEmpty ? nil : valveNotes
        } else {
            // Create new
            let valve = HeartValveCondition(
                valveType: valveTypeSelection,
                problemType: problemTypeSelection,
                severity: problemTypeSelection != nil ? valveSeveritySelection : nil,
                hasIntervention: hasIntervention,
                interventionType: hasIntervention ? interventionTypeSelection : nil,
                interventionDate: hasIntervention ? interventionDate : nil,
                notes: valveNotes.isEmpty ? nil : valveNotes
            )
            valve.profile = profile
            context.insert(valve)

            if profile?.heartValves == nil {
                profile?.heartValves = []
            }
            profile?.heartValves?.append(valve)
        }

        do {
            try context.save()
            showingHeartValveEdit = false
            validationError = nil
        } catch {
            validationError = "Could not save. Please try again."
        }
    }

    func deleteHeartValve(_ valve: HeartValveCondition, context: ModelContext) {
        profile?.heartValves?.removeAll { $0.persistentModelID == valve.persistentModelID }
        context.delete(valve)

        do {
            try context.save()
        } catch {
            validationError = "Could not delete. Please try again."
        }
    }

    // MARK: - Computed Properties

    var coronaryArteries: [CoronaryArtery] {
        profile?.sortedCoronaryArteries ?? []
    }

    var heartValves: [HeartValveCondition] {
        profile?.sortedHeartValves ?? []
    }

    var hasCoronaryArteries: Bool {
        !coronaryArteries.isEmpty
    }

    var hasHeartValves: Bool {
        !heartValves.isEmpty
    }

    /// Summary text for coronary arteries in main view
    var coronaryArteriesSummary: String {
        let arteries = coronaryArteries
        if arteries.isEmpty {
            return "No arteries recorded"
        }

        let blocked = arteries.filter { $0.hasBlockage }
        let stented = arteries.filter { $0.hasStent }

        var parts: [String] = []
        parts.append("\(arteries.count) arter\(arteries.count == 1 ? "y" : "ies") recorded")

        if !blocked.isEmpty {
            parts.append("\(blocked.count) with blockage")
        }
        if !stented.isEmpty {
            parts.append("\(stented.count) with stent")
        }

        return parts.joined(separator: " • ")
    }

    /// Summary text for heart valves in main view
    var heartValvesSummary: String {
        let valves = heartValves
        if valves.isEmpty {
            return "No valves recorded"
        }

        let withCondition = valves.filter { $0.hasCondition }
        let withIntervention = valves.filter { $0.hasIntervention }

        var parts: [String] = []
        parts.append("\(valves.count) valve\(valves.count == 1 ? "" : "s") recorded")

        if !withCondition.isEmpty {
            parts.append("\(withCondition.count) with condition")
        }
        if !withIntervention.isEmpty {
            parts.append("\(withIntervention.count) with intervention")
        }

        return parts.joined(separator: " • ")
    }

    /// Formatted EF display for main view
    var ejectionFractionDisplay: String? {
        guard let ef = profile?.ejectionFraction else { return nil }
        var display = "\(ef)%"
        if let category = profile?.efCategory {
            display += " (\(category))"
        }
        return display
    }

    /// Formatted EF date for main view
    var ejectionFractionDateDisplay: String? {
        guard let date = profile?.ejectionFractionDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "Measured: \(formatter.string(from: date))"
    }

    /// Formatted NYHA display for main view
    var nyhaClassDisplay: String? {
        guard let nyha = profile?.nyhaClass else { return nil }
        return "\(nyha.displayName) - \(nyha.shortDescription)"
    }

    /// Formatted NYHA date for main view
    var nyhaClassDateDisplay: String? {
        guard let date = profile?.nyhaClassDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "Assessed: \(formatter.string(from: date))"
    }
}
