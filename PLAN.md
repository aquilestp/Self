# Fix City Name in City Activity Widget + Remove Stat Separators

## What's being fixed

### 1. City name now works via coordinates

Strava stopped reliably returning the city name field — it comes back empty for most activities. The fix:

- Read the activity's GPS start coordinates (which Strava still always provides)
- Reverse geocode those coordinates using Apple Maps to get the city name
- The widget will show "Medellín Run", "Bogotá Ride", etc. as intended

### 2. Remove lines between stat indicators

The vertical separator lines between Distance / Pace / Time at the bottom of the widget will be removed for a cleaner look.

## Files changed

- `**StravaActivityDetail.swift**` — add `start_latlng` coordinate field
- `**PhotoEditorView.swift**` — after loading activity detail, if city is empty, reverse geocode coordinates and store the city name
- `**DraggableStatWidget.swift**` — pass geocoded city name down to the widget renderer
- `**StatWidgetContentView+CityActivity.swift**` — use geocoded city in the title; remove vertical divider lines and the divider property

