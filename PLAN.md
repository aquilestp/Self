# Medalla Ancestral — Nuevo stat dorado con grabados y laureles

## Features

- **Nuevo tipo de stat "Ancestral Medal"** disponible en el selector de stats del editor de fotos
- **Distancia dinámica** grabada en el centro con efecto de oro antiguo profundo
- **Corona de laureles** decorativa alrededor del borde interior con estrellas ornamentales
- **Texto curvado** "✦ ANCESTRAL ACHIEVEMENT ✦" en el arco superior y la fecha en el arco inferior
- **Controles de personalización** iguales a Golden Arch: toggle KM/MI, mostrar/ocultar pace y tiempo
- **Texto grabado** con gradiente dorado (#D4AF37 → #8A6623) y sombras que simulan profundidad en metal
- **Tipografía serif** para mantener la estética mística y antigua
- **Optimización GPU** con `.drawingGroup()` para renderizado fluido en el canvas

## Design

- **Forma circular** con múltiples anillos concéntricos de oro antiguo brillante
- **Anillo exterior** con gradiente angular dorado que simula un borde metálico torneado
- **Corona de laureles** dibujada con hojas doradas simétricas usando `Path` personalizado
- **Estrellas decorativas** pequeñas distribuidas entre las hojas de laurel
- **Centro** con gradiente radial dorado brillante → oro antiguo oscuro
- **Número de distancia** grande en fuente serif con gradiente lineal oro/bronce y sombra de grabado
- **Unidad (KM/MI)** en tracking expandido debajo de la distancia
- **Pace y tiempo** opcionales debajo del bloque central, en fuente serif delgada
- **Banner de fecha** en la parte inferior con forma de pergamino dorado
- **Sin ícono central** — solo el número grande como elemento protagonista
- **Efecto de patina** sutil con capas de opacidad que dan aspecto envejecido
- **Diferenciación visual** clara respecto a Golden Arch: laureles en vez de puntos, anillos más gruesos, texto serif en vez de compressed

## Screens / Changes

1. **Selector de stats** — Aparece un nuevo botón "Ancestral" con ícono de corona en la lista de stats disponibles
2. **Canvas del editor** — La medalla se renderiza como widget arrastrable y redimensionable
3. **Panel de controles** — Al seleccionar la medalla: toggle KM/MI, toggle pace, toggle tiempo (igual que Golden Arch)
4. **Mini preview** — Miniatura circular dorada con laureles simplificados en el carrusel de stats
