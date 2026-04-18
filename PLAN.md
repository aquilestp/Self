# Fondo simple y blanco en todos los widgets del canvas


## Cambio

El fondo de todos los widgets que se colocan en el canvas pasará a ser un blanco translúcido uniforme, limpio y sin bordes. El look "glass" complejo (material blur, highlight, inner glow, borde degradado) se reemplaza por un rectángulo de color blanco semi-opaco.

## Lo que cambia visualmente

- **Fondo** → blanco con ~85% de opacidad, sin capas adicionales de color de acento
- **Bordes** → eliminados completamente (ni borde sutil ni strokeBorder)
- **Reflejos / inner glow** → eliminados
- **Sombra** → se conserva una sombra suave y ligera para que el widget flote sobre la foto
- **Esquinas redondeadas** → se mantienen igual

## Lo que NO cambia

- El export de la imagen final (lo que se guarda/comparte) sigue igual — solo afecta la vista del canvas en el editor
- El tamaño, posición y todo lo demás de los widgets permanece intacto
