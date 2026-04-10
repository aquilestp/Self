# Mantener Self AI, Location y Add Text ocultos al soltar un stat

**Problema actual:**
Cuando sueltas un stat después de arrastrarlo, hay un breve flash (0.3 segundos) donde los botones de "Self AI", "Location" y el botón de agregar texto aparecen antes de que se abra el editor circular.

**Solución:**

- **Ocultar inmediatamente al soltar:** Al momento de soltar el stat, se marca de inmediato cuál widget se va a editar, evitando que los 3 botones parpadeen
- **Unificar la lógica:** Usar una sola condición (`paletteTargetWidgetId != nil`) para controlar la visibilidad de los 3 elementos (Self AI, Location, Add Text), eliminando duplicación
- **Simplificar el flujo:** El delay de 0.3s solo aplica a la animación de entrada de los botones circulares, pero la ocultación de los otros elementos es instantánea

**Resultado:** Transición limpia — al soltar el stat, Self AI, Location y Add Text se mantienen ocultos mientras los controles de edición aparecen suavemente