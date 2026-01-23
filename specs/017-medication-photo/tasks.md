# Tasks: Medication Photo Capture

## Camera Service
- [x] Create CameraService or PhotoService
- [x] Request camera permission
- [x] Handle permission denied
- [x] Implement photo capture

## Photo Storage
- [x] Create MedicationPhoto model (or simple file storage)
- [x] Save photos to documents directory
- [x] Generate thumbnails for list view
- [x] Implement photo deletion

## UI Components
- [x] Add "Add Photo" button to MedicationsView
- [x] Create camera/photo picker view
- [x] Create photo gallery view
- [x] Add photo viewer (full screen)
- [x] Add delete option for photos

## MedicationsView Integration
- [x] Add photo section to Medications tab
- [x] Show thumbnail gallery of photos
- [x] Tap to view full photo
- [x] Handle empty state (no photos)

## Permissions
- [x] Request camera permission when needed
- [x] Handle denied permission gracefully
- [x] Show explanation for why photos help

## Quality Checks
- [x] Photo capture works
- [x] Photos save correctly
- [x] Photos display in gallery
- [x] Delete functionality works
- [x] App builds without errors

---

## Completion Summary

**Status:** ✅ COMPLETE
**Last Verified:** Iteration 16 (2026-01-21)

### Implementation Files
| Component | File |
|-----------|------|
| Model | `HRTY/Models/MedicationPhoto.swift` |
| Service | `HRTY/Services/PhotoService.swift` |
| ViewModel | `HRTY/ViewModels/MedicationsViewModel.swift` |
| Capture View | `HRTY/Views/MedicationPhotoCaptureView.swift` |
| Gallery View | `HRTY/Views/MedicationPhotoGalleryView.swift` |
| Viewer View | `HRTY/Views/MedicationPhotoViewerView.swift` |
| Integration | `HRTY/Views/MedicationsView.swift` |

### Test Coverage
| Test File | Photo Tests |
|-----------|-------------|
| `MedicationPhotoTests.swift` | 31 tests |
| `MedicationsViewModelTests.swift` | 12 tests |

### Quality Attributes
- Thread safety: `@MainActor` on UI-updating methods
- Accessibility: VoiceOver, Dynamic Type, Reduce Motion
- Messaging: Patient-friendly, non-alarmist
- Architecture: Protocol-based dependency injection
