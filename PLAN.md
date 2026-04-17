# Nuevo widget "Name Stats" — nombre de actividad + indicadores

## Diseño

Widget centrado con 3 zonas inspirado en la foto:

- **Arriba:** fecha y hora en tipografía serif pequeña (ej. "Today at 6:55 AM")
- **Centro:** nombre de la actividad (ej. "Fondo") en serif bold muy grande — elemento hero
- **Abajo:** fila de columnas de stats (Distancia, Pace, Tiempo, Elevación) con la etiqueta encima del valor

Color blanco por defecto. Soporte glass. Compatible con todos los palettes existentes.

---

## Cambios

### 1 – Nuevo tipo de widget

- Se agrega `nameStats = "Name Stats"` al enum de tipos de widgets
- Icono: `person.text.rectangle.fill`
- Soporte de glass activado

### 2 – Nuevos campos en el widget

Se agregan 5 campos al modelo de widget guardado:

- `nameStatsUnitFilter` (KM / MI)
- `nameStatsShowDistance` (on/off)
- `nameStatsShowPace` (on/off)
- `nameStatsShowTime` (on/off)
- `nameStatsShowElevation` (on/off)

### 3 – Vista del widget

Nuevo archivo de extensión con la vista `nameStatsWidget`:

- Hora en serif ligero arriba centrado
- Nombre de actividad en serif bold grande centrado (escala automáticamente si es largo)
- Columnas de stats debajo separadas por divisores verticales finos, cada una con etiqueta serif encima y valor serif italic abajo
- `.conditionalGlass()` igual que los demás widgets

### 4 – Panel de personalización

Nueva sección en `PaletteSelectorView` visible solo cuando el widget activo es `nameStats`:

- Toggle KM ↔ MI
- Toggle visibilidad de Distance, Pace, Time, Elevation (iconos de regla, velocímetro, reloj, montaña)

### 5 – Miniatura en el drawer

Se agrega la preview pequeña del widget en el drawer: fecha pequeña + nombre de actividad + stats mini en serif

### 6 – Integración completa

- Aparece en el drawer como cualquier otro widget (popular/recents)
- Todos los gestos, arrastre, escala, rotación funcionan igual
- Color inicial: blanco

