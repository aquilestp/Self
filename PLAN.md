# Pegar solo el fondo translúcido al borde derecho, no los controles

**Problema:** Al quitar el padding del componente para pegarlo al borde derecho, se movieron también todos los botones y controles al borde. Solo el fondo blanco translúcido debería estar pegado al borde derecho.

**Solución:**

- Separar el fondo translúcido del contenido de los controles
- El fondo blanco con gradiente se mantiene pegado al borde derecho de la pantalla (sin padding)
- Los botones y controles del panel recuperan un pequeño margen derecho (~12pt) para que no queden pegados al borde
- Visualmente: el fondo translúcido llega hasta el borde, pero los botones flotan con espacio respecto al borde

