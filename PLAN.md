# Corregir el canvas para que no se solape con el Dynamic Island

**Problema actual:** El canvas del editor se extiende detrás del Dynamic Island, causando que el contenido quede tapado/cortado por este.

**Referencia:** El canvas debe empezar justo debajo del Dynamic Island/status bar, con un pequeño espacio negro entre ambos (tal como se ve en la foto de referencia).

**Cambios:**

- **Canvas respeta el área segura superior:** El canvas dejará de extenderse detrás del Dynamic Island y empezará justo debajo de él
- **Fondo negro sigue detrás del Dynamic Island:** El fondo negro se mantiene extendido hasta el tope de la pantalla para que el área del status bar se vea limpia
- **Overlay de botones alineado con el canvas:** Los botones superiores (Self ai, Location, back, menú) se mantienen correctamente posicionados dentro del canvas
- **Sin cambios en la parte inferior:** La barra de compartir y los controles inferiores no se afectan

