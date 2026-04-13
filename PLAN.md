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
