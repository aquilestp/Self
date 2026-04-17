# Move "Add Text" from floating button to the stats drawer

## What changes

### Remove the floating text button

- The circular "textformat" button that floats on the right side of the canvas is removed entirely.

### Add a "Text" card inside the drawer

- A new card labeled **"Text"** (with an "Aa" preview) is added to the stats grid in the drawer — first position, so it's always easy to find.
- It looks and feels exactly like the other stat cards: same size, same highlight when active, same tap feedback.
- Tapping it adds a new text element to the canvas every time (can be tapped multiple times for multiple text layers — same behavior as before).
- The card shows as "active" (highlighted border) whenever at least one text has been placed on the canvas.
- When tapped, the keyboard opens automatically with the style toolbar above it — same flow as before, just triggered from the drawer instead of the floating button.
- The card appears in both the compact (peek) and expanded grid views of the drawer.

