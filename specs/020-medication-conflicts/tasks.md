# Feature 020: Medication Conflict Detection - Tasks

## Task 1: Data Model Changes
- [x] Add `categoryRawValue: String?` field to Medication.swift
- [x] Add computed property `category` to get enum from raw value
- [x] Add `conflictBannerDismissedAt` key to AppStorageKeys.swift

## Task 2: Create MedicationConflictService
- [x] Create MedicationConflict struct with id, type, medications, message
- [x] Create ConflictType enum (sameClass, crossClass)
- [x] Define protocol MedicationConflictServiceProtocol
- [x] Implement same-class conflict detection
- [x] Implement cross-class conflict detection (ACEi/ARB/ARNI)
- [x] Implement `checkConflicts(newCategory:existingMedications:)` method
- [x] Implement `findAllConflicts(in:)` method
- [x] Ensure inactive medications are ignored
- [x] Ensure custom medications (nil category) are ignored

## Task 3: Create MedicationConflictBanner
- [x] Create dismissible yellow banner view
- [x] Add warning icon and "Medication Note" title
- [x] Add conflict message text
- [x] Add "Verify with your care team" suggestion
- [x] Add X button to dismiss
- [x] Style with warm amber/yellow colors

## Task 4: Update MedicationsViewModel
- [x] Add `detectedConflicts: [MedicationConflict]` state
- [x] Add `showingConflictWarning: Bool` state
- [x] Add `pendingConflictMedication` to hold medication being added
- [x] Add computed `showConflictBanner` property
- [x] Add computed `conflictWarningMessage` property
- [x] Add `checkAndSaveMedication(context:)` method
- [x] Add `confirmAddDespiteConflict(context:)` method
- [x] Add `cancelConflictAdd()` method
- [x] Add `dismissConflictBanner()` method
- [x] Add `isInConflict(_:)` method
- [x] Update `loadMedications` to check for conflicts
- [x] Store category when saving preset medications

## Task 5: Update MedicationsView
- [x] Add conflict banner at top of scroll view
- [x] Add conflict warning alert
- [x] Pass `isInConflict` to MedicationRowView

## Task 6: Update MedicationRowView
- [x] Add `isInConflict: Bool` parameter
- [x] Add yellow "Review" badge (similar to Diuretic badge)
- [x] Add subtle yellow background tint for conflict rows

## Task 7: Update MedicationFormView
- [x] Change save button to use conflict checking
- [x] Pass through to viewModel's checkAndSaveMedication

## Task 8: Create Unit Tests
- [x] Test same-class conflict detection (beta-blockers)
- [x] Test same-class conflict detection (ACE inhibitors)
- [x] Test same-class conflict detection (ARBs)
- [x] Test same-class conflict detection (MRAs)
- [x] Test same-class conflict detection (SGLT2i)
- [x] Test cross-class conflict (ACEi + ARB)
- [x] Test cross-class conflict (ACEi + ARNI)
- [x] Test cross-class conflict (ARB + ARNI)
- [x] Test no conflict for different classes
- [x] Test custom medications are ignored
- [x] Test inactive medications are ignored

## Task 9: Build and Test
- [x] Run xcodebuild build
- [ ] Run xcodebuild test
- [ ] Manual testing scenarios:
  - Add Metoprolol, then Carvedilol (same-class)
  - Add Lisinopril, then Losartan (cross-class)
  - Add Lisinopril, then Entresto (cross-class)
  - Dismiss banner, add new conflict, verify banner reappears
