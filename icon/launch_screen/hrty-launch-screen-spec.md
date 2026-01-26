# HRTY Launch Screen Specification — Version H

## Design Summary
A clean, warm launch screen for the HRTY heart failure management app. Features the bare H4 icon (no background box) above the app name with an uppercase tagline, all on a heart pink background.

## Visual Description
- **Background**: Solid heart pink (#f26680)
- **Icon**: H4 open heart loop, white stroke only (no squircle background)
- **Typography**: Varela Round
- **Layout**: Vertically centered, icon above text

## Color Palette
| Element | Hex | RGB |
|---------|-----|-----|
| Background | #f26680 | rgb(242, 102, 128) |
| Icon stroke | #ffffff | rgb(255, 255, 255) |
| App name | #ffffff | rgb(255, 255, 255) |
| Tagline | rgba(255,255,255,0.85) | rgb(255, 255, 255) @ 85% opacity |

## Typography
| Element | Font | Size | Weight | Letter Spacing |
|---------|------|------|--------|----------------|
| App name "HRTY" | Varela Round | 38px | Regular (400) | 8px |
| Tagline | Varela Round | 10px | Regular (400) | 2px |

**Note**: Tagline is uppercase: "YOUR HEART HEALTH COMPANION"

## Layout Specifications (Relative)
For a scalable, centered layout that works on all iPhone sizes:

```
┌─────────────────────────┐
│                         │
│                         │
│                         │
│         [ICON]          │  ← Vertically centered as a group
│        100x100          │
│                         │
│      28px spacing       │
│                         │
│         HRTY            │  ← 38px, letter-spacing: 8px
│                         │
│      10px spacing       │
│                         │
│  YOUR HEART HEALTH...   │  ← 10px, letter-spacing: 2px
│                         │
│                         │
│                         │
└─────────────────────────┘
```

## Spacing
- Icon to app name: 28px
- App name to tagline: 10px
- All elements horizontally centered
- Group vertically centered in viewport

## Icon SVG Path
```svg
<path d="M 256 390 C 165 372, 95 295, 95 205 C 95 135, 145 100, 210 100 C 260 100, 295 135, 315 185 C 335 135, 375 105, 430 140 C 480 172, 478 280, 415 340 C 352 400, 300 392, 256 390" 
  fill="none" 
  stroke="#ffffff" 
  stroke-width="36" 
  stroke-linecap="round" 
  stroke-linejoin="round"/>
```

## iOS Implementation (LaunchScreen.storyboard)

### Option 1: Storyboard with Constraints
1. Set view background color to #f26680
2. Add UIImageView for icon (export icon as PDF or SVG)
3. Add UILabel for "HRTY"
4. Add UILabel for tagline
5. Embed in a UIStackView with:
   - Axis: Vertical
   - Alignment: Center
   - Spacing: Custom (28px after icon, 10px after name)
6. Center the stack view in the safe area

### Option 2: Single Image Asset
Export the full launch screen as a PDF at 1x scale. iOS will scale appropriately.

### Font Installation
Varela Round is a Google Font. For iOS:
1. Download from fonts.google.com/specimen/Varela+Round
2. Add .ttf file to Xcode project
3. Add to Info.plist under "Fonts provided by application"
4. Reference as "VarelaRound-Regular"

## Asset Checklist
- [ ] Icon exported as PDF (vector) for Xcode
- [ ] Varela Round font added to project
- [ ] LaunchScreen.storyboard configured
- [ ] Background color set to #f26680
- [ ] Test on multiple device sizes

## Scaling Guidance
| Device | Icon Size | App Name | Tagline |
|--------|-----------|----------|---------|
| iPhone SE | 80px | 32px | 9px |
| iPhone 14 | 100px | 38px | 10px |
| iPhone 14 Pro Max | 110px | 42px | 11px |

*Or use Auto Layout constraints to maintain proportions automatically.*
