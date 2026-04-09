# Fix drawer to extend to the bottom edge of the screen

**Problem**

- When the drawer is open, it stops at the canvas boundary (90% of screen height), leaving a visible black empty space at the very bottom of the screen.

**Fix**

- When the drawer is in the open or expanded state, extend it so its background reaches all the way to the bottom edge of the screen (past the safe area).
- The drawer content (stat widgets grid) stays in the same position — only the background material fills the gap below.
- This is achieved by adding bottom padding to the drawer's inner content and removing the canvas height constraint on the drawer's background, so the material visually bleeds to the screen edge.
- No changes to collapsed state or bottom share bar behavior.

