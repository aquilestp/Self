# Fondos de widgets más blancos en el canvas


## Cambio

En el `GlassCardModifier` (que controla el fondo de todos los widgets), se ajustan dos partes:

### Canvas (vista en vivo)
- Se agrega una capa `Color.white` semitransparente sobre el fondo actual para que todos los widgets se vean más claros/blancos, manteniendo la misma opacidad general.

### Exportación (Instagram / guardar imagen)
- El fondo de exportación pasa de `Color.black.opacity(0.45)` (classic) y `Color.black.opacity(0.3)` (aesthetic) a tonos blancos equivalentes (`Color.white.opacity(0.30)` y `Color.white.opacity(0.20)`), para que el widget exportado también se vea más claro y consistente con el canvas.
- El neon mantiene su fondo oscuro oscuro característico.

**Resultado:** los widgets se ven más blancos/limpios tanto en pantalla como al exportar a Instagram, sin cambiar los niveles de opacidad.
