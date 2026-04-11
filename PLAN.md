# Área de gesto dinámica y estable para el stat BVT

## Problema

Cada variación de estilo del stat BVT tiene un tamaño de layout diferente (blur añade padding, glitch expande con offsets, glow tiene sombras fuera del frame, etc.). Esto causa que el área táctil cambie de tamaño al cambiar de estilo, pudiendo quedar muy pequeña o desalineada respecto a lo que el usuario ve.

## Solución: Contenedor de gesto normalizado

Un enfoque elegante y mínimo en 2 partes:

### 1. Medir el contenido base una sola vez

- Se mide el tamaño del `textContent` base (el VStack de líneas de texto) **antes** de aplicar cualquier efecto visual
- Este tamaño base es estable — solo cambia si cambian los datos o campos visibles, nunca por el efecto

### 2. Envolver el resultado en un contenedor de tamaño mínimo garantizado

- Después de aplicar el efecto (blur, glow, glitch, etc.), el resultado se envuelve en un contenedor invisible que tiene como tamaño mínimo el del texto base + un margen generoso fijo (ej. 20pt por lado)
- Esto asegura que:
  - Efectos que reducen el área (glow sin padding) siguen teniendo un área de gesto amplia
  - Efectos que expanden el área (glitch, wave) mantienen su tamaño natural si es mayor
  - La transición entre estilos no genera saltos bruscos en el área táctil
  - El usuario siempre puede tocar, arrastrar y hacer pinch sobre lo que ve

### Resultado esperado

- Sin importar la variación de estilo activa, el stat siempre será fácil de mover, escalar y rotar
- No hay cambios visuales — solo se estabiliza el área de interacción
- El cambio es interno al `blurredVerticalTextWidget` — no afecta ningún otro stat ni la arquitectura de gestos existente

