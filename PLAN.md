# Fix widget drawer thumbnail centering


## Problem
The drawer thumbnail wrapper was changed to use left-alignment and a leading-only padding to prevent long activity names from overflowing. This has a side effect: widgets with short or no activity name text are also stuck to the left.

## Fix
In both the regular thumbnail and full-width thumbnail:

- Change the outer `VStack` from `alignment: .leading` → no alignment (center by default)
- Change `.frame(maxWidth: .infinity, alignment: .leading)` → `.frame(maxWidth: .infinity)` (center by default)
- Change `.padding(.leading, 8)` → `.padding(.horizontal, 8)` (symmetric padding)

This way:
- **Long activity name** → the text inside the mini preview still has `lineLimit(1)` + `.truncationMode(.tail)`, so it truncates. The content is rendered left-aligned *within itself* (each mini preview defines its own internal alignment), but centered within the card.
- **Short activity name or no name** → the content is naturally centered in the card.

No changes to the mini preview content itself — only the wrapper alignment in the two thumbnail builder functions is changed.
