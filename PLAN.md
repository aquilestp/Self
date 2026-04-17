# Route Dist widget — opacidad completa y sin divisores


## Cambios en `StatWidgetContentView+RouteAndTime.swift`

**3 ajustes puntuales en `routeDistanceWidget`:**

- **Trazado de ruta** — quitar la opacidad parcial (`0.92`) → opacidad completa
- **Etiquetas de indicadores** (ELEV, TIME, KPH/MPH) — quitar la opacidad parcial (`0.45`) → opacidad completa
- **Valores de indicadores** — quitar la opacidad parcial (`0.85`) → opacidad completa
- **Unidad de distancia** (KM/MI) — quitar la opacidad parcial (`0.75`) → opacidad completa
- **Líneas divisoras** entre indicadores — eliminar el `Rectangle()` separador completamente
