# Agregar 10 nuevos efectos visuales al stat BVT

## Features

Se agregarán **10 nuevos efectos** al stat BVT, además de los 4 existentes (Blur, Glow, Stroke, Gradient):

1. **Glitch / Chromatic Split** — Texto con capas RGB separadas con diferentes desplazamientos, efecto cyberpunk/glitch
2. **Wave / Ondulación** — Cada línea de texto con un desplazamiento horizontal sinusoidal progresivo
3. **Pixelación** — Texto con efecto de baja resolución/pixelado
4. **Blur por línea** — Algunas líneas del texto más borrosas que otras, creando profundidad
5. **Noise / Estática** — Overlay de puntos aleatorios sobre el texto tipo señal de TV
6. **Stretch** — Deformación vertical del texto (texto estirado/comprimido)
7. **Skew** — Inclinación exagerada tipo poster tipográfico
8. **Tracking** — Espaciado entre letras muy expandido
9. **Gradient Mask** — Texto que se desvanece progresivamente con un gradiente
10. **Echo / Stacked** — Múltiples copias del texto con offsets y opacidades decrecientes, efecto eco/sombra repetida

## Design

- Cada efecto tiene un icono SF Symbol representativo en el botón del editor
- Los efectos se recorren con el botón circular existente (tap para siguiente efecto)
- Los efectos Wave y Pixelación usarán Metal shaders para renderizado GPU nativo
- El efecto Noise usará Canvas de SwiftUI para generar la estática
- Los demás efectos se logran con SwiftUI puro (offsets, opacidades, blur, tracking, scaleEffect, rotation3DEffect, mask)
- Los colores de cada efecto respetan el color primario seleccionado por el usuario

## Cambios

- Se amplía el enum `BVTEffect` con los 10 nuevos casos
- Se agregan las ramas de renderizado correspondientes en el widget
- Se crean 2 archivos Metal (.metal) para los shaders de Wave y Pixelación
- Se actualiza el botón de efecto en el editor para recorrer todos los efectos
