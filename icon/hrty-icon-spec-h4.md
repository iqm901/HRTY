# HRTY App Icon Specification — H4 "Warm Embrace"

## Design Summary
A minimalist, organic app icon for a heart failure management application called "HRTY" (evoking "hearty"). This version (H4) has fuller, more recognizable heart lobes while preserving the open top and soft qualities.

## Visual Description
- **Shape**: iOS-standard squircle (rounded square with rx/ry of ~22.5% of width)
- **Background**: Heart pink (#f26680)
- **Mark**: A single continuous white stroke forming an open heart loop
- **Style**: Two curves meet at center top (no traditional cleft/notch). Fuller, rounder lobes make the heart shape clearly recognizable. Soft, rounded bottom (not pointed). Open at top with arms approaching but not touching.
- **Stroke**: White (#ffffff), 36px weight (on 512px canvas), round caps and joins
- **Feeling**: Warm, embracing, connected — clearly a heart but still organic and imperfect

## Technical Specs
- Canvas: 512x512px (scalable SVG)
- Corner radius: 115px (iOS standard ~22.5%)
- Background: #f26680 (heart pink)
- Stroke: #ffffff, 36px width
- No fill on the loop — stroke only

## SVG Path
```svg
<path d="
  M 256 390
  C 165 372, 95 295, 95 205
  C 95 135, 145 100, 210 100
  C 260 100, 295 135, 315 185
  C 335 135, 375 105, 430 140
  C 480 172, 478 280, 415 340
  C 352 400, 300 392, 256 390
" fill="none" stroke="#ffffff" stroke-width="36" stroke-linecap="round" stroke-linejoin="round"/>
```

## Design Rationale
- **Connection**: The continuous loop represents the bond between patient and care team
- **Warmth**: Fuller lobes create immediate heart recognition — approachable, caring
- **Openness**: No cleft at top; two arms meet at center suggesting welcome, not closure
- **Acceptance**: Soft bottom and organic curves embody "okay to not be perfect"
- **Clinical appropriateness**: Calm, reassuring, professional healthcare aesthetic

## Comparison to E7h
- **More heart-like**: H4 is ~50% on the heart recognition spectrum vs E7h's abstract loop
- **Same qualities preserved**: Open top, soft bottom, lighter stroke weight, organic feel
- **Same colors**: Heart pink background, white stroke

## Color Reference
| Element | Hex | RGB |
|---------|-----|-----|
| Background | #f26680 | rgb(242, 102, 128) |
| Stroke | #ffffff | rgb(255, 255, 255) |
| Soft pink (alternate) | #fff5f7 | rgb(255, 245, 247) |
