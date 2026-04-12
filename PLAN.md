# Unificar los scroll pickers verticales en un solo componente reutilizable

## Problema actual

Existen dos componentes casi idénticos (`BVTEffectScrollPicker` y `WhatsAppTextScrollPicker`) que comparten toda la lógica de arrastre, snap, haptics y desvanecimiento por distancia. La única diferencia es el contenido visual de cada fila y dimensiones menores.

## Solución

Crear un **único componente genérico** que encapsule toda la mecánica compartida y permita personalizar solo la apariencia de cada fila desde afuera.

## Cambios

- **Nuevo componente genérico `VerticalSnapPicker`** — Contiene toda la lógica de arrastre, snap de 1 item a la vez, haptics, y efecto de desvanecimiento por distancia. Acepta una lista de items genéricos y un closure para renderizar cada fila
- **Parámetros configurables** — Ancho del picker y número de items visibles se pueden personalizar por uso (130pt para efectos BVT, 167pt para presets WhatsApp)
- **Se reemplazan ambos componentes existentes** — `BVTEffectScrollPicker` y `WhatsAppTextScrollPicker` se convierten en wrappers delgados (o se eliminan) que simplemente pasan su contenido al componente genérico
- **Misma apariencia visual** — Cada stat mantiene exactamente su diseño actual (iconos, colores, tipografía), solo cambia la implementación interna
- **Listo para futuros stats** — Si se agrega un nuevo stat con selector vertical, solo se necesita definir el contenido de la fila, sin duplicar la mecánica de scroll
