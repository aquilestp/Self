# Fix BVT stat gesture performance (freeze during drag/rotation)

## Problem

The "Blurred Vertical" stat freezes/stutters during drag and rotation gestures on the canvas. Every gesture frame triggers a full re-render of the BVT widget content, which is expensive due to DateFormatter creation, complex effects (Noise, Glitch, Echo), and lack of rasterization.

## Fixes

### 1. Cache DateFormatters as static properties

- Move the two `DateFormatter` instances out of the computed property and into static constants
- DateFormatter creation is very expensive — currently 2 are created **every frame** during gestures (~60/sec)

### 2. Add `.drawingGroup()` to the BVT widget

- Rasterizes the entire BVT widget into a single GPU layer
- During gestures, only the offset/scale/rotation transform changes — the rasterized content stays cached
- This is the single biggest performance win

### 3. Optimize the Noise effect

- Reduce random particle count from 300 to 120
- Use a fixed seed-based pattern instead of fully random positions each frame
- This prevents the Canvas from regenerating 300 random rects every gesture frame

### 4. Make `StatWidgetContentView` conform to `Equatable`

- All its sub-properties already conform to Equatable (ActivityHighlight, WidgetColorStyle, WeeklyKmData, MonthlyKmData, enums, Bools)
- Adding Equatable lets SwiftUI skip re-rendering when only `dragOffset` changes in the parent — the content hasn't changed, only the position

### 5. Pre-compute `textContent` once for multi-reference effects

- Effects like Echo (5 references), Glitch (4 layers) re-evaluate `textContent` multiple times
- Wrap in `.drawingGroup()` so each reference reuses the rasterized result instead of re-laying out the full VStack+ForEach

