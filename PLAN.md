# Glass gradient background for font style picker


## What changes

The font style scroll picker's background will go from a uniform dark panel to a **directional glass effect**:

**Background gradient (left → right):**
- **Left edge (inner / toward the photo):** fully transparent — the material blur shows through cleanly, revealing the photo behind it
- **Right edge (outer / screen edge):** solid dark (~60% black) — anchors the panel visually at the edge

**Glass layer:** the existing `ultraThinMaterial` blur is kept underneath, so the transparent left side genuinely shows a frosted-glass view of whatever is behind it.

**Border:** the stroke around the panel also fades — nearly invisible on the left, slightly more visible on the right — so the whole component feels like it's emerging from the photo rather than sitting on top of it.
