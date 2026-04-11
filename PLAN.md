# Scroll vertical para cambiar texto del mensaje WhatsApp

## Cambios

Reemplazar los botones actuales de texto preset del stat WhatsApp en el panel lateral derecho con una experiencia de scroll vertical tipo "rueda/picker":

**Experiencia de selección por scroll:**
- Lista vertical de textos preset que se puede deslizar con el dedo
- El texto centrado/más cercano al centro se selecciona automáticamente al hacer scroll (sin necesidad de tocar)
- El primer texto viene seleccionado por defecto
- El texto seleccionado se ve más grande, brillante y con fondo verde WhatsApp
- Los textos alejados del centro se ven más pequeños, difuminados y translúcidos (efecto de profundidad)
- Feedback háptico sutil al cambiar de selección
- Altura limitada (~200pt) para que no ocupe toda la pantalla

**Opción de editar al final:**
- Al final de la lista de presets, aparece un ícono de lápiz (✏️) como última opción scrolleable
- Al seleccionarlo por scroll, abre el alert de edición de texto personalizado

**Animaciones:**
- Mismas animaciones de entrada/salida spring que el resto del panel
- Transición suave al cambiar entre textos mientras se hace scroll
