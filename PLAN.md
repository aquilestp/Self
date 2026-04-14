# Fase 5 — Dividir DraggableStatWidget.swift en 8 archivos por familia

## Objetivo

Reducir `DraggableStatWidget.swift` de **3,269 líneas a ~800 líneas** (~75% de reducción), mejorando tiempos de compilación incremental y navegación del código.

## Estrategia

Usar **extensiones de `StatWidgetContentView**` en archivos separados — el patrón Swift nativo para dividir tipos grandes sin romcar nada. El archivo principal conserva la declaración, propiedades, `body` switch y tipos compartidos.

---

## Archivos nuevos a crear

### 1. `StatWidgetContentView+BasicWidgets.swift` (~350 líneas)

Widgets: `distance`, `distPace`, `threeStats`, `titleCard`, `stack`, `bold`, `impact`, `poster`, `heroStat`, `wide`, `tower`

- Helpers compartidos: `topRowStatColumn`, `statColumn`, `basicMetadataText`, `basicMetricItems`, `basicPaceText`

### 2. `StatWidgetContentView+RouteAndTime.swift` (~420 líneas)

Widgets: `routeClean`, `movingTimeClean`, `elapsedTimeClean`, `avgHeartRate`, `hrPulseDots`, `elevationGain`

- Helpers: `heartRateBPM`, `heartRateZone`, `efficiencyRatio`, `routeTightSize`, `elevationNumeric`

### 3. `StatWidgetContentView+Charts.swift` (~170 líneas)

Widgets: `weeklyKm`, `lastWeekKm`, `monthlyKm`, `lastMonthKm`

### 4. `StatWidgetContentView+Splits.swift` (~540 líneas)

Widgets: `splits`, `splitsTable`, `splitsFastest`, `splitsBars`

- Helpers: `splitsContent`, `splitsTableContent`, `splitsFastestContent`, `splitsBarsContent`, `splitPaceString`
- Shared helpers de loading: `detailShimmer`, `detailEmptyState`

### 5. `StatWidgetContentView+Efforts.swift` (~150 líneas)

Widgets: `bestEfforts`, `distanceWords`

- Helpers: `bestEffortsContent`, `effortDistanceLabel`, `formatEffortTime`

### 6. `StatWidgetContentView+Banners.swift` (~180 líneas)

Widgets: `fullBanner`, `fullBannerBottom`, `splitBanner`

### 7. `StatWidgetContentView+BVT.swift` (~270 líneas)

Widget: `blurredVerticalText` con todos sus efectos (glow, stroke, glitch, wave, etc.)

- Helpers: `bvtStyledLine`, `bvtStrokedLine`

### 8. `StatWidgetContentView+Novelty.swift` (~530 líneas)

Widgets: `whatsappMessage`, `notesScreenshot`, `goldenArch`, `ancestralMedal`

- Helpers: textos de formato para cada widget, `MedalBannerView`, `MedalCurvedText`, `MedalStarDots`

---

## Archivo principal `DraggableStatWidget.swift` conserva (~800 líneas)

- `SplitMix64`, `ExportEnvironmentKey`, `StatDisplayItem` (tipos auxiliares)
- Declaración completa de `StatWidgetContentView`: propiedades + `Equatable` + `body` switch
- Colores: `primaryColor`, `secondaryColor`, `tertiaryColor`, `dimColor`, `dividerColor`
- `DraggableStatWidget` struct completo
- `RouteTraceShape` shape

---

## Resultado esperado

> **Sin cambios de comportamiento** — extensiones en Swift comparten el mismo tipo, no hay cambios en la API pública ni en el uso desde `PhotoEditorView` o `WelcomeOnboardingView`.

