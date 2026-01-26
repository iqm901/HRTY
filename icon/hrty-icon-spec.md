# HRTY App Icon Specification

## Design Summary
A minimalist, organic app icon for a heart failure management application called "HRTY" (evoking "hearty").

## Visual Description
- **Shape**: iOS-standard squircle (rounded square with rx/ry of ~22.5% of width)
- **Background**: Heart pink (#f26680)
- **Mark**: A single continuous white stroke forming an abstract open loop
- **Style**: The loop subtly suggests a heart shape but remains abstract — open at the top with two "arms" that curve inward without touching, and a soft, rounded bottom (not pointed)
- **Stroke**: White (#ffffff), 36px weight (on 512px canvas), round caps and joins
- **Feeling**: Soft, settled, accepting, connected — "okay to not be perfect"

## Technical Specs
- Canvas: 512x512px (scalable SVG)
- Corner radius: 115px (iOS standard)
- Background: #f26680
- Stroke: #ffffff, 36px width
- No fill on the loop — stroke only

## SVG Path
```svg
<path d="
  M 256 378
  C 178 368, 120 310, 120 238
  C 120 168, 172 120, 240 120
  C 282 120, 314 145, 326 180
  C 338 145, 372 125, 410 165
  C 442 200, 432 268, 390 310
  C 348 352, 298 370, 256 378
" fill="none" stroke="#ffffff" stroke-width="36" stroke-linecap="round" stroke-linejoin="round"/>
```

## Design Rationale
- **Connection**: The continuous loop represents the bond between patient and care team
- **Acceptance**: The soft bottom and open top suggest grace, not perfection
- **Organic flow**: Inspired by Airbnb's Bélo — warm, human, layered with meaning
- **Clinical appropriateness**: Calm, reassuring, professional without being cold
