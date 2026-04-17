# New "Route + Distance" Widget

## Features

- **New widget in the drawer** called "Route Dist" — appears in the grid alongside all other widgets, sortable by Popular/Recents
- **Route trace on top (~60% of card)** — the GPS route drawn in the selected color as a clean stroke
- **Large bold distance** displayed below the route — dominant number + unit (e.g. `18.34 MI`)
- **Three secondary stats** in a row at the bottom: elevation gain, moving time, and average speed
- **All three secondary stats can be toggled on/off** individually via the right-side customization panel (same icon-based toggle buttons as other widgets)
- **KM / MI unit toggle** in the customization panel — switches distance, speed unit, and elevation between metric and imperial
- **Color change** via the existing palette system (classic, neon, aesthetic) — defaults to white
- **Glass background toggle** available (same as other widgets)

## Design

- **Portrait card layout** — route trace fills the top portion, large number in the middle, small stats row at the bottom
- **Default color: white** — all text, route stroke, and stat labels use the selected palette color
- **Distance number** uses the same heavy compressed system font as the Bold/Impact widgets — large and impactful
- **Unit label** (MI / KM) sits right next to the number, slightly smaller
- **Secondary stats row** — three small all-caps labels above each value (e.g. `ELEV`, `TIME`, `SPEED`), values in a clean monospace-style font
- **Route stroke** uses the same style as the existing Route Clean widget but fills the available card space
- **Card outline** — no background fill on the widget itself (transparent), just the elements — compatible with glass toggle

## What Gets Updated

- New widget type added to the full list (drawer, sorting, popularity tracking)
- New customization panel section in the right-side style panel with: unit toggle (KM/MI), elevation toggle, time toggle, speed toggle
- New mini thumbnail preview in the drawer grid
- All existing widget data flows (color, glass, export) work automatically via the shared system

