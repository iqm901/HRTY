# HRTY Codebase Review
Date: 2026-01-29
Status: Complete

## Summary

HRTY is a well-architected iOS 17+ heart failure self-management app with strong foundations. The codebase demonstrates professional patterns including clean MVVM separation, protocol-based dependency injection, comprehensive test coverage (632 passing tests), and thoughtful accessibility support. The app follows its stated constraints: offline-first, no prescriptive medical advice, and coaching-tone messaging.

**Overall Assessment: Production-Ready with Minor Improvements Recommended**

| Category | Rating | Notes |
|----------|--------|-------|
| Testing | Strong | 632 tests passing, good service coverage |
| Architecture | Excellent | Clean MVVM, protocol-based DI, single responsibility |
| Reliability | Strong | Good error handling, data validation |
| Accessibility | Good | VoiceOver support, Dynamic Type consideration |
| iOS Best Practices | Excellent | Modern patterns, iOS 17+ features |
| Code Health | Good | Minor duplication, well-organized |

---

## Test Results

- [x] All tests passing (632 tests, 0 failures)
- [x] Tests run successfully on iOS 26.2 simulator

### Test Coverage by Category

| Category | Test Files | Test Cases | Coverage Quality |
|----------|-----------|------------|------------------|
| Alert Services | 5 | ~180 | Comprehensive threshold testing |
| Medications | 6 | ~150 | CRUD, conflicts, photos, history |
| Vital Signs | 3 | ~80 | Boundary conditions, validation |
| Symptoms | 4 | ~60 | Severity filtering, alerts |
| Sodium Tracking | 4 | ~50 | Repository, parsing, templates |
| Export/Settings | 3 | ~30 | Configuration, data formatting |
| Notification | 2 | ~40 | Scheduling, message quality |
| Model Tests | 5 | ~40 | Data integrity, relationships |

---

## Testing Coverage & Health

### Strengths

1. **Alert Threshold Testing**: Comprehensive boundary testing for all clinical thresholds
   - Weight alerts (2 lb/24h, 5 lb/7d)
   - Symptom severity (4-5 triggering alerts)
   - Vital signs (HR, BP, SpO2 bounds)

2. **Service Protocol Testing**: All alert services have protocol-based tests enabling mocking
   - `WeightAlertServiceTests.swift`
   - `SymptomAlertServiceTests.swift`
   - `VitalSignsAlertServiceTests.swift`

3. **Message Quality Tests**: Unusual but valuable - tests verify messaging tone
   - `NotificationMessageQualityTests` checks for warmth, brevity, non-alarmist language
   - `AlertTypeTests` validates accessibility descriptions

4. **Data Model Tests**: Thorough validation of model constraints
   - Severity clamping (1-5)
   - Date uniqueness for DailyEntry
   - Relationship integrity

### Gaps Identified

1. **TodayViewModel Lacks Unit Tests**
   - **Risk**: Core daily check-in logic untested
   - **Impact**: High - this is the primary user workflow
   - **Recommendation**: Add tests for:
     ```swift
     // Example test cases to add:
     func testLoadAllDataPopulatesEntries()
     func testStreakCalculationWithConsecutiveDays()
     func testStreakCalculationWithGap()
     func testWeightValidationRejectsOutOfRange()
     func testSaveWeightUpdatesEntry()
     ```

2. **SymptomCheckInViewModel Missing Tests**
   - **Risk**: Multi-step wizard state management untested
   - **Impact**: Medium - complex state transitions
   - **Recommendation**: Add tests for step navigation, progress persistence

3. **SodiumViewModel Partial Coverage**
   - Has `SodiumViewModelTests.swift` but limited scenarios
   - **Recommendation**: Add tests for progress calculations, color thresholds

4. **No UI Tests for Critical Flows**
   - Only one demo UI test (`MedicationCautionDemoTest.swift`)
   - **Recommendation**: Add UI tests for onboarding, daily check-in, medication add

5. **HealthKit Integration Not Testable**
   - `HealthKitService` directly uses HealthKit with no mock in tests
   - **Recommendation**: Ensure protocol (`HealthKitServiceProtocol`) is used consistently

---

## Architecture & Maintainability

### Strengths

1. **Clean MVVM Separation**
   ```
   View (SwiftUI) → ViewModel (@Observable) → Service (Protocol) → Model (@Model)
   ```
   - Views are declarative, contain minimal logic
   - ViewModels handle all state and business logic
   - Services are protocol-based for testability

2. **Protocol-Based Dependency Injection**
   ```swift
   // TodayViewModel.swift:85-92
   init(
       weightAlertService: WeightAlertServiceProtocol = WeightAlertService(),
       symptomAlertService: SymptomAlertServiceProtocol = SymptomAlertService(),
       // ... all services injectable
   )
   ```

3. **Centralized Constants**
   - `AlertConstants.swift` - all clinical thresholds in one place
   - `HRTColors.swift`, `HRTSpacing.swift`, `HRTTypography.swift` - design system tokens

4. **Shared Alert Acknowledgment**
   ```swift
   // WeightAlertService.swift:8-30
   protocol AlertAcknowledgeable {
       func acknowledgeAlert(_ alert: AlertEvent, context: ModelContext) -> Bool
   }
   // Default implementation shared across all alert services
   ```

5. **SwiftData Relationships Well-Defined**
   ```swift
   // DailyEntry.swift:11-21
   @Relationship(deleteRule: .cascade, inverse: \SymptomEntry.dailyEntry)
   var symptoms: [SymptomEntry]?
   ```

### Areas for Improvement

1. **TodayViewModel is Large** (~1160 lines)
   - Contains weight, symptoms, vitals, diuretics, HR, BP, SpO2 logic
   - **Recommendation**: Consider extracting feature-specific sub-viewmodels:
     - `WeightEntryViewModel`
     - `VitalSignsEntryViewModel`
     - Could use composition in TodayViewModel

2. **MedicationsViewModel Also Large** (~937 lines)
   - Manages CRUD, conflicts, photos, history, diuretics
   - **Recommendation**: Extract photo management to `MedicationPhotoViewModel`

3. **Notification Tab Navigation via NotificationCenter**
   ```swift
   // TodayView.swift:58
   NotificationCenter.default.post(name: .navigateToMyHeartTab, object: nil)
   ```
   - Works but less type-safe than SwiftUI navigation patterns
   - Consider using `@Environment` for tab selection if refactoring

---

## Reliability

### Strengths

1. **Data Persistence Safety**
   - `DailyEntry.getOrCreate()` pattern prevents duplicate entries
   - Unique constraint on date: `@Attribute(.unique) var date: Date`
   - Cascade delete rules prevent orphan records

2. **Error Handling in Save Operations**
   ```swift
   // TodayViewModel.swift:372-385
   do {
       try context.save()
       showSaveSuccess = true
       checkWeightAlerts(context: context)
   } catch {
       validationError = "Could not save weight. Please try again."
   }
   ```

3. **Input Validation Before Persistence**
   - Weight: 50-500 lbs validated
   - HR: 30-250 bpm validated
   - BP: systolic > diastolic validated
   - SpO2: 70-100% validated

4. **Schema Migration Recovery**
   ```swift
   // HRTYApp.swift:45-70
   // If schema migration fails, delete old store and create fresh
   // Acceptable for V1 with no cloud sync
   ```

### Potential Issues

1. **No Transaction Rollback on Partial Failures**
   - When saving multiple related objects, a failure mid-save leaves partial state
   - **Risk**: Low for V1 (offline-only, user can retry)
   - **Recommendation**: For V2, consider wrapping related saves in transactions

2. **DispatchQueue for UI Feedback Timing**
   ```swift
   // TodayViewModel.swift:380-382
   DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
       self?.showSaveSuccess = false
   }
   ```
   - Works but could be replaced with Task.sleep for modern Swift concurrency

3. **Force Unwrap in Dosage Parsing**
   ```swift
   // MedicationsViewModel.swift:228
   parts.allSatisfy { Double($0) != nil && Double($0)! > 0 }
   ```
   - Safe due to prior nil check, but could use `guard let` for clarity

---

## User Experience Code Quality

### Strengths

1. **VoiceOver Announcements**
   ```swift
   // TodayView.swift:225-262
   private func announceWeightAlertForVoiceOver() {
       guard let firstAlert = viewModel.activeWeightAlerts.first else { return }
       let announcement = "Weight alert: \(firstAlert.alertType.accessibilityDescription)"
       UIAccessibility.post(notification: .announcement, argument: announcement)
   }
   ```
   - All 5 alert types have VoiceOver announcements
   - Delayed by 0.5s to not conflict with other announcements

2. **Dynamic Type Support**
   - Uses `@Environment(\.dynamicTypeSize)` in TodayView
   - Design system uses `.hrtTitle2`, `.hrtCallout` etc. for consistent sizing

3. **Smooth Animations**
   ```swift
   // TodayView.swift:279-282
   withAnimation(.easeInOut(duration: 0.3)) {
       viewModel.acknowledgeAlert(alert, context: modelContext)
   }
   ```
   - Consistent animation curves throughout

4. **Loading States**
   ```swift
   // TodayView.swift:109-114
   .opacity(viewModel.isLoading ? 0.3 : 1.0)
   .disabled(viewModel.isLoading)
   if viewModel.isLoading {
       HRTLoadingView("Loading your data...")
   }
   ```

5. **Relative Time Formatting**
   ```swift
   // TodayViewModel.swift:417-419
   let formatter = RelativeDateTimeFormatter()
   formatter.unitsStyle = .full
   healthKitTimestampText = "from Health \(formatter.localizedString(for: weight.date, relativeTo: Date()))"
   ```

### Minor Issues

1. **Keyboard Handling Not Explicit**
   - No `@FocusState` usage found for form navigation
   - TextField keyboard dismissal relies on defaults
   - **Recommendation**: Consider adding explicit keyboard toolbar for done/next

2. **No Haptic Feedback**
   - Alert acknowledgment could benefit from haptic confirmation
   - **Recommendation**: Add `UIImpactFeedbackGenerator` for key actions

---

## iOS Best Practices

### Strengths

1. **Modern @Observable Pattern**
   ```swift
   // TodayViewModel.swift:4-5
   @Observable
   final class TodayViewModel {
   ```
   - Uses iOS 17+ `@Observable` instead of `@StateObject`
   - Simpler syntax, better performance

2. **Correct Property Wrapper Usage**
   - `@State` for view-owned mutable state
   - `@Environment(\.modelContext)` for SwiftData access
   - `@AppStorage` for simple preferences

3. **Task for Async in Views**
   ```swift
   // TodayView.swift:118-122
   .task {
       await viewModel.loadAllData(context: modelContext)
       loadCheckInProgress()
   }
   ```

4. **Weak Self in Closures**
   ```swift
   // TodayViewModel.swift:380
   DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
   ```

5. **MainActor for UI Updates**
   ```swift
   // TodayViewModel.swift:211
   @MainActor
   func loadAllData(context: ModelContext) async {
   ```

### No Issues Found

- No deprecated APIs detected
- No obvious retain cycles
- Proper use of async/await with @MainActor

---

## Code Health

### Minor Duplication

1. **Diuretic Loading Logic Duplicated**
   - Both `TodayViewModel` and `MedicationsViewModel` have identical `loadDiuretics()`, `logDose()`, `deleteDose()` methods
   - Already using shared `DiureticDoseService`, but wrapper code duplicated
   - **Recommendation**: Could extract to a shared protocol extension or mixin

2. **HealthKit Import Pattern Repeated**
   ```swift
   // Similar pattern in importWeightFromHealthKit, importBloodPressureFromHealthKit,
   // importOxygenSaturationFromHealthKit, importHeartRateFromHealthKit
   ```
   - Each has: check available → set loading → request auth → fetch → format timestamp
   - **Recommendation**: Could generify with a generic import function

3. **Validation Error Messages**
   - Each vital sign has similar validation messages
   - Consider a centralized validation message factory

### Well-Organized Patterns

1. **MARK Comments Throughout**
   ```swift
   // MARK: - Weight Input
   // MARK: - Symptom Input
   // MARK: - Weight Alert State
   ```

2. **Consistent Naming**
   - ViewModels: `TodayViewModel`, `MedicationsViewModel`
   - Services: `WeightAlertService`, `SymptomAlertService`
   - Protocols: `WeightAlertServiceProtocol`

3. **Clear File Organization**
   ```
   Models/
   ViewModels/
   Views/
   Services/
   DesignSystem/
   ```

---

## Prioritized Recommendations

### High Priority (User Impact)

1. **Add TodayViewModel Unit Tests**
   - Impact: Prevents regressions in daily check-in flow
   - Effort: Medium (2-3 hours)
   - Files: Create `HRTYTests/TodayViewModelTests.swift`

2. **Add SymptomCheckInViewModel Tests**
   - Impact: Prevents wizard state bugs
   - Effort: Low (1-2 hours)
   - Files: Create `HRTYTests/SymptomCheckInViewModelTests.swift`

### Medium Priority (Code Quality)

3. **Extract TodayViewModel into Sub-ViewModels**
   - Impact: Improves maintainability
   - Effort: High (4-6 hours)
   - Consider composition pattern

4. **Deduplicate Diuretic Dose Logic**
   - Impact: Reduces maintenance burden
   - Effort: Low (1 hour)
   - Move wrapper methods to shared extension

5. **Add Haptic Feedback for Key Actions**
   - Impact: Improved user experience
   - Effort: Low (30 mins)
   - Add to alert dismissal, save confirmations

### Low Priority (Polish)

6. **Add UI Tests for Onboarding Flow**
   - Impact: Prevents first-run experience bugs
   - Effort: Medium (2-3 hours)

7. **Replace DispatchQueue with Task.sleep**
   - Impact: Modern Swift concurrency
   - Effort: Low (1 hour)

8. **Add Keyboard Navigation with @FocusState**
   - Impact: Better form UX
   - Effort: Medium (2-3 hours)

---

## Files Reviewed

| File | Lines | Purpose | Issues |
|------|-------|---------|--------|
| `TodayViewModel.swift` | 1161 | Daily check-in logic | Large file, no tests |
| `TodayView.swift` | 444 | Daily check-in UI | Well-structured |
| `MedicationsViewModel.swift` | 937 | Medication management | Large file, good tests |
| `WeightAlertService.swift` | 215 | Weight alert logic | Excellent, fully tested |
| `AlertConstants.swift` | 130 | Clinical thresholds | Single source of truth |
| `DailyEntry.swift` | 72 | Core data model | Clean, well-designed |
| `HRTYApp.swift` | 88 | App entry point | Good migration recovery |

---

## Conclusion

The HRTY codebase is production-ready with strong architectural foundations. The main areas for improvement are:

1. Adding unit tests for the core TodayViewModel
2. Reducing view model sizes through composition
3. Minor UX enhancements (haptics, keyboard navigation)

The existing 632 tests provide good coverage of services and models. The MVVM pattern is consistently applied, and the protocol-based dependency injection enables good testability. The app follows iOS 17+ best practices and has thoughtful accessibility support.

**Recommended Next Steps:**
1. Add TodayViewModel tests (highest impact)
2. Add SymptomCheckInViewModel tests
3. Consider extracting sub-viewmodels in a future refactoring sprint

---

## Refactoring Projects (Ordered by Effort-to-Impact)

### 1. Consolidate Diuretic Dose Logic

**Effort:** Low (1-2 hours)
**Impact:** Medium (eliminates 80+ lines of duplication, reduces bugs)

#### Problem
`TodayViewModel` and `MedicationsViewModel` both have identical wrapper code for diuretic operations despite using the shared `DiureticDoseService`:

```swift
// Duplicated in both view models:
var diureticMedications: [Medication] = []
var todayDiureticDoses: [DiureticDose] = []
func doses(for medication: Medication) -> [DiureticDose]
func loadDiuretics(context:)
func logStandardDose(for:context:)
func logCustomDose(for:amount:isExtra:timestamp:context:)
func deleteDose(_:context:)
```

#### Refactoring
Create a `DiureticDoseManager` that encapsulates the state and operations:

```swift
@Observable
final class DiureticDoseManager {
    var medications: [Medication] = []
    var todayDoses: [DiureticDose] = []
    private let service: DiureticDoseServiceProtocol

    func load(context: ModelContext, dailyEntry: DailyEntry?)
    func logStandardDose(for: Medication, context: ModelContext)
    func logCustomDose(...)
    func deleteDose(...)
}
```

Then compose it into both view models:
```swift
@Observable
final class TodayViewModel {
    let diureticManager = DiureticDoseManager()
    // ...
}
```

**Files to modify:** `TodayViewModel.swift`, `MedicationsViewModel.swift`, create `DiureticDoseManager.swift`

---

### 2. Generify HealthKit Import Pattern

**Effort:** Low-Medium (2-3 hours)
**Impact:** Medium (eliminates ~200 lines of repetitive code, easier to add new vitals)

#### Problem
Four nearly identical HealthKit import methods in `TodayViewModel`:

| Method | Lines | Pattern |
|--------|-------|---------|
| `importWeightFromHealthKit()` | 35 | check → loading → auth → fetch → format |
| `importBloodPressureFromHealthKit()` | 30 | check → loading → auth → fetch → format |
| `importOxygenSaturationFromHealthKit()` | 30 | check → loading → auth → fetch → format |
| `importHeartRateFromHealthKit()` | 28 | check → loading → auth → fetch → format |

#### Refactoring
Create a generic import function with a result handler:

```swift
private func importFromHealthKit<T>(
    loadingState: ReferenceWritableKeyPath<TodayViewModel, Bool>,
    errorState: ReferenceWritableKeyPath<TodayViewModel, String?>,
    timestampState: ReferenceWritableKeyPath<TodayViewModel, String?>,
    fetch: () async -> T?,
    onSuccess: (T) -> Void,
    noDataMessage: String
) async {
    guard healthKitAvailable else {
        self[keyPath: errorState] = "HealthKit is not available"
        return
    }

    self[keyPath: loadingState] = true
    self[keyPath: errorState] = nil

    let authorized = await healthKitService.requestAuthorization()
    guard authorized else {
        self[keyPath: loadingState] = false
        self[keyPath: errorState] = "Unable to access Health data"
        return
    }

    if let result = await fetch() {
        onSuccess(result)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        // Set timestamp...
    } else {
        self[keyPath: errorState] = noDataMessage
    }

    self[keyPath: loadingState] = false
}
```

**Files to modify:** `TodayViewModel.swift`

---

### 3. Split TodayViewModel into Feature Modules

**Effort:** High (4-6 hours)
**Impact:** High (1161 lines → ~300 lines each, better testability, clearer ownership)

#### Problem
`TodayViewModel` manages 6 distinct concerns in one 1161-line file:
- Weight entry & validation
- Vital signs (BP, HR, SpO2)
- Symptom tracking
- Diuretic logging
- Alert management
- Streak calculation

#### Refactoring
Use composition to split into focused modules:

```swift
@Observable
final class TodayViewModel {
    // Composed sub-managers
    let weight = WeightEntryManager()
    let vitals = VitalSignsManager()
    let symptoms = SymptomManager()
    let diuretics = DiureticDoseManager()  // From refactor #1
    let alerts = AlertsManager()
    let streak = StreakManager()

    // Shared state
    var todayEntry: DailyEntry?
    var yesterdayEntry: DailyEntry?
    var isLoading = false

    @MainActor
    func loadAllData(context: ModelContext) async {
        isLoading = true
        loadEntries(context: context)

        weight.load(from: todayEntry, yesterday: yesterdayEntry)
        vitals.load(from: todayEntry, healthKitService: healthKitService)
        symptoms.load(from: todayEntry, context: context)
        diuretics.load(context: context, dailyEntry: todayEntry)
        await alerts.loadAll(context: context)
        streak.calculate(todayEntry: todayEntry, context: context)

        isLoading = false
    }
}
```

#### Benefits
- Each manager is independently testable
- Clear single responsibility
- Easier to reason about state
- Can add new features without growing TodayViewModel

**Files to create:**
- `WeightEntryManager.swift`
- `VitalSignsManager.swift`
- `SymptomManager.swift`
- `AlertsManager.swift`
- `StreakManager.swift`

---

### Refactoring Summary

| # | Project | Effort | Impact | Priority |
|---|---------|--------|--------|----------|
| 1 | Consolidate Diuretic Logic | 1-2 hrs | Medium | **Do first** |
| 2 | Generify HealthKit Imports | 2-3 hrs | Medium | **Do second** |
| 3 | Split TodayViewModel | 4-6 hrs | High | **Plan for sprint** |

**Recommended approach:** Complete #1 and #2 together in a single refactoring session (half day). Plan #3 as a dedicated refactoring story with proper test coverage added before restructuring.
