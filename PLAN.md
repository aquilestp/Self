# Fase 2: Centralizar Utilidades de Formateo

## Objetivo
Eliminar código duplicado de formateo de distancia, pace, duración y fechas creando un archivo de utilidades compartido. **Sin cambios visuales ni de comportamiento.**

---

## Paso 1: Crear `ActivityFormatting.swift`

- [x] Crear archivo en `Utilities/` con funciones estáticas puras
- [x] `distanceWithUnit()`, `distanceValue()`, `distanceWithUnitUpper()`, `bannerDistance()`
- [x] `paceSpaced()`, `pacePrime()`, `paceSlash()`, `paceSlashMixed()`
- [x] `splitPace()` — promovido desde función privada
- [x] `durationCompact()`, `durationExpanded()`, `durationShort()`

---

## Paso 2: Crear `CachedDateFormatters.swift`

- [x] Crear enum con formateadores estáticos cacheados
- [x] `bvtDate`, `timeShort`, `dayOfWeek`, `monthDay`, `notesDate`, `medalDate`

---

## Paso 3: Actualizar `StatWidgetContentView` en `DraggableStatWidget.swift`

- [x] `basicDistanceText` → usa `ActivityFormatting`
- [x] `basicPaceText` → usa `ActivityFormatting`
- [x] `formatDurationCompact` → delega a `ActivityFormatting`
- [x] `splitPaceString` → delega a `ActivityFormatting`
- [x] `fullBannerWidget` / `fullBannerBottomWidget` inline calcs → `ActivityFormatting`
- [x] `blurredVerticalTextWidget` inline calcs (dist, pace, duration) → `ActivityFormatting`
- [x] `notesDistanceText`, `notesPaceText` → `ActivityFormatting`
- [x] `goldenArchDistanceText`, `goldenArchPaceText` → `ActivityFormatting`
- [x] `ancestralDistanceText`, `ancestralPaceText` → `ActivityFormatting`
- [x] `splitBannerWidget` inline calcs (dist, pace, duration) → `ActivityFormatting`
- [x] `bvtDateFormatter`, `bvtTimeFormatter` → `CachedDateFormatters`
- [x] `waTimeFormatter` → `CachedDateFormatters`
- [x] `splitBannerDayFormatter`, `splitBannerDateFormatter`, `splitBannerTimeFormatter` → `CachedDateFormatters`
- [x] `notesDateText` → `CachedDateFormatters.notesDate`
- [x] `goldenArchDateText` → `CachedDateFormatters.medalDate`
- [x] `ancestralDateText` → `CachedDateFormatters.medalDate`

---

## Paso 4: Actualizar `EditorMiniPreviews.swift`

- [x] 2 instancias de `activity.distanceRaw / 1000.0` → `ActivityFormatting.distanceValue()`

---

## Build

- [x] Compilación exitosa verificada

---

## ✅ Fase 2 COMPLETADA

---
---

# Fase 3: Extraer y Deduplicar PaletteSelector

## Objetivo
Extraer la vista `paletteSelectorView` (~650 líneas) de `PhotoEditorView.swift` a su propio archivo, eliminando 30+ repeticiones del patrón `guard let id / firstIndex`. **Sin cambios visuales ni de comportamiento.**

---

## Paso 1: Crear `PaletteSelectorView.swift`

- [x] Vista independiente con props: `targetWidget`, `showPaletteSelector`, `waPresetTexts`, `updateWidget`, `resetHideTimer`
- [x] `mutate()` — centraliza el patrón repetido (find widget → animate → haptic → reset timer)
- [x] `separator(delay:)` — separador animado reutilizable
- [x] `animatedButton(delay:action:label:)` — botón con scale/opacity animados
- [x] `unitToggle()`, `visToggle()` — toggles genéricos reutilizables
- [x] `circleButton()`, `textCircleButton()`, `paletteCircleLabel()`, `fontStyleLabel()` — labels reutilizables
- [x] Secciones por tipo de widget: palette colors, glass, bestEfforts, splits, distanceWords, basicFields, boldImpact, heroStat, fullBanner, bvt, goldenArch, ancestralMedal, splitBanner, whatsapp, fontStyle

---

## Paso 2: Actualizar `PhotoEditorView.swift`

- [x] Reemplazar uso de `paletteSelectorView` por `PaletteSelectorView(...)` con closure `updateWidget`
- [x] Eliminar `paletteSelectorView` completo (~650 líneas)
- [x] Eliminar `basicUnitFilterSection()`, `unitToggleButton()`, `visibilityToggleButton()`, `bvtEffectButton()`, `fontStyleButtonLabel()` (~115 líneas)
- [x] Mantener `resetPaletteHideTimer()`, `showPaletteSelectorFor()`, `hidePaletteSelector()` en PhotoEditorView

---

## Build

- [x] Compilación exitosa verificada

---

## ✅ Fase 3 COMPLETADA

---
---

# Fase 4: Extraer Drawer y Filtros a Extensiones

## Objetivo
Extraer el drawer de stats (~190 líneas) y la lógica de filtros/overlays (~225 líneas) de `PhotoEditorView.swift` a archivos de extensión dedicados. **Sin cambios visuales ni de comportamiento.**

---

## Paso 1: Crear `EditorDrawerView.swift`

- [x] Extension con: `expandedDrawer`, `compactStatsList`, `expandedGrid`
- [x] `drawerDragGesture` — gesture completo extraído
- [x] `widgetThumbnail()`, `fullWidthThumbnail()` — thumbnails del drawer
- [x] `activeWidgetTypes`, `gridStatTypes` — computed properties

---

## Paso 2: Crear `EditorFiltersOverlay.swift`

- [x] Extension con: `filterToggles`, `filterToggleButton()`
- [x] `photoFilterDotsView`, `photoFilterLabelView`
- [x] `activeFilterOverlay()`, `filterOverlayId`
- [x] `filterDots`, `advanceFilter()`, `setFilterIndex()`
- [x] `loadDynamicCityFilters()` — async loading

---

## Paso 3: Actualizar `PhotoEditorView.swift`

- [x] Eliminar ~415 líneas de código duplicado (ahora en extensiones)
- [x] Cambiar ~18 `private` a `internal` para accesibilidad desde extensiones
- [x] PhotoEditorView: 1842 → 1430 líneas (-22%)

---

## Build

- [x] Compilación exitosa verificada

---

## ✅ Fase 4 COMPLETADA
