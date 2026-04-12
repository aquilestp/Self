# Cambiar font de los números a Condensed Extra Bold Italic en 5 widgets

**Cambio**

Actualizar la fuente de los números grandes en estos 5 widgets para que usen **system Condensed Extra Bold Italic** (`.system(size:weight:.heavy).width(.condensed).italic()`):

1. **Weekly KM** (42.0 - THIS WEEK)
2. **Last Week KM** (42.8 - LAST WEEK)
3. **Monthly KM** (75.5 - APR)
4. **Last Month KM** (174.4 - MAR)
5. **Elevation Gain** (73m - ELEVATION)

Se cambia tanto en los widgets principales (`DraggableStatWidget.swift`) como en las mini previews del editor (`EditorMiniPreviews.swift`).

Solo se modifica la fuente del número grande, no los labels ni otros textos.