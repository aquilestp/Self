# Fix activity name overflow in widget drawer previews


**Problem**
When an activity has a long name (e.g. "Evening Weight Training"), the mini widget previews in the drawer break their layout because the activity title text has no truncation limit — it wraps onto multiple lines and pushes other stats out of alignment.

**Fix**
Two small changes in the widget mini-preview file:

- [x] **`miniStat` helper** — add `lineLimit(1)` to the value text so any stat value (including activity title used as "TYPE") is always capped to a single line with `...` truncation
- [x] **Stack widget case** — add `lineLimit(1)` to the value text in the `HStack` rows so "Activity: Evening Weight Tra..." stays on one line and doesn't push adjacent content out of alignment

**Result**
All widget thumbnails in the drawer will maintain their correct layout regardless of how long the activity name is. Long names will show as "Evening Weight Tra..." cleanly.
