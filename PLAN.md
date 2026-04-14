# Fix stats drawer widget text alignment — left padding + right truncation

## Problem

Widgets that use a horizontal scale effect (`x: 1.5`) with `anchor: .center` push content equally to the left **and** right. This shoves text behind the left border of the tile, breaking left alignment. The fix is surgical — change the anchor and guard every title line.

## Changes

### 1 · `EditorMiniPreviews.swift` — 4 widgets with scale effect

For **titleCard**, **bold**, **impact**, and **poster**:

- Change `scaleEffect(x: 1.5, y: 1.0, anchor: .center)` → `scaleEffect(x: 1.5, y: 1.0, anchor: .leading)`  
Scale now expands **only to the right**; the left edge stays pinned to the tile border
- Add `.padding(.leading, 6)` to each of those `VStack`s so there is always a visible gap between the left border and the first character
- Add `.truncationMode(.tail)` to every `Text(activity.title…)` that is missing it (some already have `lineLimit(1)` but no explicit tail mode)

### 2 · `EditorMiniPreviews.swift` — `.stack` widget

The `HStack` row that shows `"Activity" / activity.title` already has `lineLimit(1)`, but `minimumScaleFactor(0.6)` lets it shrink instead of truncating. Remove `minimumScaleFactor` from the **value** text and add `.truncationMode(.tail)` so long names show `"..."` instead of squishing.

### 3 · `EditorDrawerView.swift` — thumbnail containers

Inside `widgetThumbnail` and `fullWidthThumbnail`, change the inner `VStack` alignment to `.leading` and add `.padding(.leading, 8)` so every mini-preview that is naturally left-aligned (distance, distPace, etc.) also gets the consistent left gap without relying on each individual preview to handle it.

## Result

- Text always starts with visible space from the left border
- Long activity names truncate with `"..."` flush to the right border
- No content escapes the tile on either side

