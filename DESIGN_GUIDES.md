# PetApp Screen Design Guidelines

This document provides the standard patterns and spacing rules to maintain design consistency across all screens in the PetApp project. Use these to guide AI generation or manual development.

## 🏗 Architecture Pattern
Follow the **Feature-First GetX Architecture**:
- Place all screen-related files in `lib/modules/[feature_name]/`.
- Required structure:
  - `views/`: The UI files.
  - `controllers/`: Business logic.
  - `services/`: API/Backend calls.
  - `bindings/`: Dependency injection for `AppPages`.

## 🖼 Layout & Scaffold Configuration
Always use `AppScaffold` as the root widget.

### Edge-to-Edge Backgrounds
To achieve a full-screen background gradient (no white gaps):
1. Set `useSafeArea: false` in `AppScaffold`.
2. Wrap the `body` in a `Stack`.
3. Use `Positioned.fill` for the background gradient.
4. Use `SafeArea(bottom: false)` for the content overlay.

```dart
AppScaffold(
  useSafeArea: false,
  systemNavigationBarIconBrightness: Brightness.light,
  body: Stack(
    children: [
      Positioned.fill(child: _buildBackgroundGradient()),
      SafeArea(
        bottom: false, 
        child: Column(children: [...]),
      ),
    ],
  ),
)
```

## 📐 Spacing & Measurements
Always use the `R` helper for responsiveness: `R.height(value)` and `R.width(value)`.

### Global Spacing Rules:
- **Horizontal Screen Padding**: `R.width(20)`
- **Footer Link Gap**: `R.width(15.6)` (between text and the separator dot).
- **Separator Dot Size**: `width: 4.5`, `height: 4.5`.
- **Footer to Home Indicator Gap**: `R.height(34)`.
- **Bottom-most Padding**: `R.height(8)` (below the home indicator).

## 🖱 Manual Home Indicator Handle
Every screen must include a manual home indicator handle at the absolute bottom of the main layout column:

```dart
Center(
  child: Container(
    width: R.width(134),
    height: R.height(5),
    decoration: BoxDecoration(
      color: Colors.white, // or Colors.black based on brightness
      borderRadius: BorderRadius.circular(10),
    ),
  ),
),
SizedBox(height: R.height(8)), // Final bottom buffer
```

## 🎨 UI Component Specifics
- **Border Radius**: Use `12.0` (Radius/radius-12) for cards and inputs.
- **Border Width**: 
  - Standard: `1.0`.
  - Focused/Selected (Stroke-md): `2.0`.
- **Typography**: 
  - Use `AppTypography` constants.
  - Footer links: `AppTypography.overlineXxs` with `letterSpacing: 0.2` and `FontWeight.bold`.

## 🛠 AI Prompting Instructions
When asking an AI to create a new screen, include this instruction:
> "Please build the [Screen Name] following the patterns in `DESIGN_GUIDES.md`. Use an edge-to-edge `AppScaffold` with a manual home indicator handle centered at the bottom, exactly 34px below the footer content. Ensure all spacing uses the `R` responsive helper."
