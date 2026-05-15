# PetApp Design System & Superprompt

This document contains the exact design tokens, layout rules, and animation curves for the PetApp project. Use these for all future UI modifications to maintain pixel-perfect consistency.

## 1. Global Button (`AppMaterialButton`)
The primary action button used throughout the application.

- **Height:** 56px (Large)
- **Shape:** Pill-shaped (Border Radius: 999)
- **Primary Fill:** `#7F67CB`
- **Border Stroke:** `#BFB3E5` (Width: 0.5pt)
- **Typography:** `Label/md`
  - Font Size: 16pt
  - Weight: Semi-Bold (600)
  - Line Height: 20pt (`height: 20/16`)
  - Letter Spacing: -0.34
- **Layout:**
  - Gap (Icon to Label): 4px
  - Horizontal Padding: 16px (inner)
- **Shadow:**
  - Outer: Black (alpha 0.1), Blur 10, Offset (0, 4)

## 2. Onboarding Screen Layout
Standard margins and spacing for onboarding and simple full-screen views.

- **Horizontal Margins:** 10px (Left and Right)
- **Bottom Margin:** 54px (From button bottom to screen edge)
- **Top Spacing:** 80px (From top edge to heading)
- **Heading Styling:**
  - Style: `AppTypography.h5`
  - Color: Black
  - Weight: Semi-Bold (600)
- **Sub-heading Styling:**
  - Style: `AppTypography.bodySm`
  - Color: `Colors.grey[600]`
  - Gap (Heading to Sub): 12px

## 3. Pop Animation (`PetPopOverlay`)
The "Pop" effect when selecting a pet or showing a big modal.

- **Total Duration:** 2000ms (Medium Speed)
- **Entrance Phase:** 40% of duration (800ms)
  - Curve: `Curves.easeOutBack`
  - Scale: 0.0 → 1.15
- **Stay Phase:** 40% of duration (800ms)
  - Scale: Static at 1.15
- **Exit Phase:** 20% of duration (400ms)
  - Curve: `Curves.easeOut` (Fade transition)

## 4. Interactive Components (`PetCard`)
Rules for interactive selection cards.

- **Press Feedback:** Shrink to `0.95` scale over 100ms (`Curves.easeInOut`)
- **Selection Animation:** 
  - Scale: `1.2` pop-out
  - Curve: `Curves.elasticOut` (Spring bounce)
  - Duration: 500ms
- **Selected State:** 
  - Background Color: `#EBE6FF` (Soft Lavender)
  - Selection Glow: Soft primary shadow (Blur 15, Spread 2)
  - Haptic Feedback: `lightImpact()` on tap

## 5. Global Colors
- **Primary Color:** `#7F67CB`
- **Accent/Stroke:** `#BFB3E5`
- **Background Grey:** `#F5F5F5`
- **Text Black:** `#000000`

## 6. Technical Implementation Details

### Waveform Flow Logic (The "Wavy" Flow)
To create the professional "flowing" effect during playback, we use a shifting list logic:
- **Update Frequency:** `50ms` (Timer-based).
- **Logic:** `newList.removeAt(0); newList.add(randomValue);`
- **Effect:** This shifts all existing bars to the left and adds a new one on the right, creating a seamless "flowing" motion that visualizes the audio stream.

### Mic Listening State (Transitions)
When the user taps/holds the Mic button to speak:
- **Button Morph:** `AnimatedContainer` switches background from `Colors.white` to `AppColors.primaryColor` over `300ms`.
- **Pulse Circle:** An outer `AnimatedContainer` expands slightly and changes color to a low-opacity primary purple.
- **Waveform Appearance:** A `300ms` `AnimatedOpacity` fade-in for the waveform bar at the bottom.
- **Dynamic Color:** The waveform bar color lerps between `primary.withOpacity(0.4)` and `primary` based on the real-time volume intensity.

### Morphing Replay Bar
- **Logic:** Uses an `Obx` to switch between an `Icon` (Idle) and a `CustomPaint` (Playing).
- **Morph Duration:** `400ms` for color and shape transitions.
- **State Sync:** Connected to `AudioPlayer.onPlayerComplete` to automatically return to the "Refresh" state.
