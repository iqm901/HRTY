# HRTY Project Structure Analysis

**Generated:** January 30, 2026
**Total Files:** 144 Swift files (app) + 22 tests

---

## Current Structure Overview

```
HRTY/
├── Views/           73 files (39 root + 34 in subfolders)
├── Models/          31 files (all at root)
├── Services/        19 files (all at root)
├── ViewModels/       9 files
├── DesignSystem/     9 files (3 tokens + 6 components)
├── Managers/         1 file
├── Data/             1 file (BundledFoods.json)
├── Fonts/            1 file (Nunito-SemiBold.ttf)
└── Root files        2 files (ContentView, HRTYApp)
```

---

## What's Working Well ✅

1. **Clear separation of concerns** - Views, ViewModels, Models, Services properly isolated
2. **Feature-based grouping for complex areas** - Sodium/, MyHeart/, Onboarding/ are well-organized
3. **Established design system** - Centralized colors, spacing, typography in DesignSystem/
4. **Modern Swift patterns** - Using `@Observable`, `@Environment`, async/await
5. **Protocol-based services** - Good testability foundation (DiureticDoseServiceProtocol, HealthKitServiceProtocol)

---

## Issues & Recommendations

### 🔴 High Priority

#### 1. Inconsistent Service Naming

**Problem:** Some services don't follow the `Service` suffix convention, making them hard to discover.

| Current Name | Recommended Name |
|--------------|------------------|
| `LocalProductDatabase` | `LocalProductDatabaseService` |
| `SodiumRepository` | `SodiumRepositoryService` |
| `PDFGenerator` | `PDFGeneratorService` |
| `NutritionLabelParser` | `NutritionLabelParserService` |

#### 2. Giant Model Files

**Problem:** Large files are hard to navigate and maintain.

| File | Lines | Recommendation |
|------|-------|----------------|
| `OtherMedication.swift` | 2,714 | Split by drug category into separate files |
| `EducationContent.swift` | 1,507 | Move content to JSON, keep only Swift types |

#### 3. Flat Models Folder (31 files)

**Problem:** No logical grouping makes files hard to find.

**Recommended subfolders:**
- `Models/Core/` - DailyEntry, Medication, SymptomEntry, AlertEvent
- `Models/VitalSigns/` - HeartRateReading, BloodPressureReading, OxygenSaturationReading
- `Models/Medications/` - CardiovascularMedication, OtherMedication, HeartFailureMedication
- `Models/Constants/` - AlertConstants, SodiumConstants, AppStorageKeys
- `Models/SodiumTracking/` - SodiumEntry, SodiumTemplate, BundledFoodItem

#### 4. Flat Services Folder (19 files)

**Problem:** Mixed domains make navigation difficult.

**Recommended subfolders:**
- `Services/Alerts/` - WeightAlertService, SymptomAlertService, VitalSignsAlertService, HeartRateAlertService, DizzinessBPAlertService
- `Services/Medications/` - DiureticDoseService, MedicationHistoryService, MedicationChangeAnalysisService, MedicationConflictService, MedicationAvoidService
- `Services/SodiumTracking/` - SodiumRepository, BundledFoodDatabaseService, LocalProductDatabase, NutritionLabelParser
- `Services/External/` - HealthKitService, NotificationService, PDFGenerator, PhotoService

---

### 🟡 Medium Priority

#### 5. Mixed Views at Root Level

**Problem:** 39 view files at root level; unclear which are screens vs. components.

**Recommendation:** Separate into:
- `Views/Screens/` - Top-level tab views (TodayView, TrendsView, MedicationsView, etc.)
- `Views/Components/` - Reusable components (DiureticRowView, MedicationRowView, SymptomRowView)

#### 6. Test Organization Doesn't Mirror Source

**Problem:** 18 test files at root, only 1 subfolder (SodiumTracking/).

**Recommendation:** Create subfolders matching source:
- `HRTYTests/Alerts/`
- `HRTYTests/Services/`
- `HRTYTests/ViewModels/`

#### 7. Manager vs Service Confusion

**Problem:** `Managers/` folder has only `DiureticDoseManager.swift`, but `DiureticDoseService` exists in Services/.

**Recommendation:** Either:
- Move DiureticDoseManager to Services/ for consistency, OR
- Document when to use Manager vs Service pattern

---

### 🟢 Low Priority

#### 8. Consider Dependency Injection Container

Services currently use singletons (`NotificationService.shared`). A DI container would improve testability at scale.

#### 9. Add Folder README Files

Document each major folder's purpose for new contributors.

---

## Recommended Target Structure

```
HRTY/
├── Views/
│   ├── Screens/              # Top-level tab views
│   │   ├── TodayView.swift
│   │   ├── TrendsView.swift
│   │   ├── MedicationsView.swift
│   │   ├── ExportView.swift
│   │   └── SettingsView.swift
│   ├── Components/           # Reusable view components
│   │   ├── DiureticRowView.swift
│   │   ├── MedicationRowView.swift
│   │   └── SymptomRowView.swift
│   ├── Sodium/               # Feature module (already organized)
│   ├── MyHeart/              # Feature module (already organized)
│   ├── Onboarding/           # Feature module (already organized)
│   └── SymptomCheckIn/       # Feature module (already organized)
│
├── Models/
│   ├── Core/
│   │   ├── DailyEntry.swift
│   │   ├── Medication.swift
│   │   ├── SymptomEntry.swift
│   │   └── AlertEvent.swift
│   ├── VitalSigns/
│   │   ├── HeartRateReading.swift
│   │   ├── BloodPressureReading.swift
│   │   └── OxygenSaturationReading.swift
│   ├── Medications/
│   │   ├── CardiovascularMedication.swift
│   │   ├── HeartFailureMedication.swift
│   │   └── OtherMedications/     # Split the 2,714 line file
│   ├── Constants/
│   │   ├── AlertConstants.swift
│   │   ├── SodiumConstants.swift
│   │   └── AppStorageKeys.swift
│   └── SodiumTracking/
│       ├── SodiumEntry.swift
│       └── SodiumTemplate.swift
│
├── Services/
│   ├── Alerts/
│   │   ├── WeightAlertService.swift
│   │   ├── SymptomAlertService.swift
│   │   └── VitalSignsAlertService.swift
│   ├── Medications/
│   │   ├── DiureticDoseService.swift
│   │   ├── MedicationHistoryService.swift
│   │   └── MedicationConflictService.swift
│   ├── SodiumTracking/
│   │   ├── SodiumRepositoryService.swift
│   │   └── BundledFoodDatabaseService.swift
│   └── External/
│       ├── HealthKitService.swift
│       ├── NotificationService.swift
│       └── PDFGeneratorService.swift
│
├── ViewModels/               # Keep flat (only 9 files)
│
├── DesignSystem/             # Already well-organized
│   ├── Components/
│   ├── HRTColors.swift
│   ├── HRTSpacing.swift
│   └── HRTTypography.swift
│
├── Data/
└── Fonts/
```

---

## Quick Wins Checklist

- [ ] Rename 4 services for naming consistency
- [ ] Create `Services/Alerts/` subfolder and move alert services
- [ ] Create `Models/Constants/` subfolder and move constant files
- [ ] Split `OtherMedication.swift` into smaller files
- [ ] Move education content data to JSON file

---

## Best Practices Assessment

| Criteria | Status | Notes |
|----------|--------|-------|
| MVVM/Feature separation | ✅ Good | Clear view/viewmodel/service layers |
| SwiftUI patterns | ✅ Modern | Uses @Observable, @Environment, async/await |
| Scalability | 🟡 Medium | Large files need splitting |
| Discoverability | 🟡 Medium | Inconsistent naming hurts findability |
| Test structure | 🟡 Medium | Tests exist but don't mirror source |
| Dependency injection | 🟡 Medium | Mostly singletons |
| Naming consistency | 🟡 Medium | Service suffix inconsistent |
| File sizes | 🔴 Poor | 2 files over 1,500 lines |
| Documentation | ✅ Good | CLAUDE.md provides guidance |
