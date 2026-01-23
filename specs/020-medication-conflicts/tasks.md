# Feature 020: Medication Conflict Detection - Tasks

## Task 1: Data Model Changes
- [ ] Add `categoryRawValue: String?` field to Medication.swift
- [ ] Add computed property `category` to get enum from raw value
- [ ] Add `conflictBannerDismissedAt` key to AppStorageKeys.swift

## Task 2: Create MedicationConflictService
- [ ] Create MedicationConflict struct with id, type, medications, message
- [ ] Create ConflictType enum (sameClass, crossClass)
- [ ] Define protocol MedicationConflictServiceProtocol
- [ ] Implement same-class conflict detection
- [ ] Implement cross-class conflict detection (ACEi/ARB/ARNI)
- [ ] Implement `checkConflicts(newCategory:existingMedications:)` method
- [ ] Implement `findAllConflicts(in:)` method
- [ ] Ensure inactive medications are ignored
- [ ] Ensure custom medications (nil category) are ignored

## Task 3: Create MedicationConflictBanner
- [ ] Create dismissible yellow banner view
- [ ] Add warning icon and "Medication Note" title
- [ ] Add conflict message text
- [ ] Add "Verify with your care team" suggestion
- [ ] Add X button to dismiss
- [ ] Style with warm amber/yellow colors

## Task 4: Update MedicationsViewModel
- [ ] Add `detectedConflicts: [MedicationConflict]` state
- [ ] Add `showingConflictWarning: Bool` state
- [ ] Add `pendingConflictMedication` to hold medication being added
- [ ] Add computed `showConflictBanner` property
- [ ] Add computed `conflictWarningMessage` property
- [ ] Add `checkAndSaveMedication(context:)` method
- [ ] Add `confirmAddDespiteConflict(context:)` method
- [ ] Add `cancelConflictAdd()` method
- [ ] Add `dismissConflictBanner()` method
- [ ] Add `isInConflict(_:)` method
- [ ] Update `loadMedications` to check for conflicts
- [ ] Store category when saving preset medications

## Task 5: Update MedicationsView
- [ ] Add conflict banner at top of scroll view
- [ ] Add conflict warning alert
- [ ] Pass `isInConflict` to MedicationRowView

## Task 6: Update MedicationRowView
- [ ] Add `isInConflict: Bool` parameter
- [ ] Add yellow "Review" badge (similar to Diuretic badge)
- [ ] Add subtle yellow background tint for conflict rows

## Task 7: Update MedicationFormView
- [ ] Change save button to use conflict checking
- [ ] Pass through to viewModel's checkAndSaveMedication

## Task 8: Create Unit Tests
- [ ] Test same-class conflict detection (beta-blockers)
- [ ] Test same-class conflict detection (ACE inhibitors)
- [ ] Test same-class conflict detection (ARBs)
- [ ] Test same-class conflict detection (MRAs)
- [ ] Test same-class conflict detection (SGLT2i)
- [ ] Test cross-class conflict (ACEi + ARB)
- [ ] Test cross-class conflict (ACEi + ARNI)
- [ ] Test cross-class conflict (ARB + ARNI)
- [ ] Test no conflict for different classes
- [ ] Test custom medications are ignored
- [ ] Test inactive medications are ignored

## Task 9: Build and Test
- [ ] Run xcodebuild build
- [ ] Run xcodebuild test
- [ ] Manual testing scenarios:
  - Add Metoprolol, then Carvedilol (same-class)
  - Add Lisinopril, then Losartan (cross-class)
  - Add Lisinopril, then Entresto (cross-class)
  - Dismiss banner, add new conflict, verify banner reappears
