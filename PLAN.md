# Nuevo widget "City Activity" (ej: Medellín Run)

## Descripción

Un nuevo stat widget inspirado en el pantallazo: muestra la ciudad de la actividad + tipo de actividad como título grande en serif, con fecha/hora y tres columnas de stats (Distancia, Pace, Tiempo).

## Diseño

- **Título principal**: "{Ciudad} {Tipo}" en serif bold grande — ej. "Medellín Run", "Medellín Ride", "Medellín Strength"
- **Subtítulo fecha/hora**: "Today at 6:32 AM" — serif regular, opacidad reducida
- **Tres columnas de stats**: Distance · Pace · Time con etiqueta pequeña arriba y valor italic serif abajo
- **Fuente**: serif (misma familia que otros widgets del app)
- **Fondo**: soporte completo para glass translúcido + colores igual que todos los demás widgets

## Mapeo de tipos de actividad

- `Run`, `VirtualRun` → **Run**
- `Ride`, `VirtualRide`, `EBikeRide` → **Ride**
- `WeightTraining`, `Workout`, `Crossfit` → **Strength**
- `Walk` → **Walk**
- `Swim` → **Swim**
- Otros → nombre directo

## Ciudad

- Viene del detalle de la actividad Strava (campo `location_city`), igual que los widgets de Splits y Best Efforts
- Si la ciudad no está disponible en Strava: muestra solo el tipo (ej. "Morning Run")

## Unidades

- Switchable km / mi — usa el mismo componente de filtro de unidades que los demás widgets

## Cambios

1. `**PhotoEditorEnums.swift**` — Agregar `case cityActivity = "City Activity"` con icono `"mappin.circle.fill"`, marcar como `requiresDetail: true`
2. `**PhotoEditorEnums.swift**` — Agregar `cityActivityUnitFilter: SplitsUnitFilter = .km` a `PlacedWidget`
3. `**DraggableStatWidget.swift**` — Agregar `cityActivityUnitFilter` en `StatWidgetContentView` (campos + Equatable + switch body + widgetContent builder)
4. **Nuevo archivo `StatWidgetContentView+CityActivity.swift**` — Implementación completa del widget con diseño serif
5. `**EditorMiniPreviews.swift**` — Agregar mini preview del widget para el drawer

