# Reescribir VerticalSnapPicker usando ScrollView nativo (como TextStyleCarousel)

## Problema

El `VerticalSnapPicker` usa un gesto manual (`DragGesture`) para simular el scroll, lo que se siente rígido y artificial. El `TextStyleCarousel` se siente fluido porque usa el `ScrollView` nativo de SwiftUI, que delega toda la física (inercia, momentum, bounce) al sistema.

## Solución

Reescribir el `VerticalSnapPicker` para usar **exactamente el mismo patrón** que `TextStyleCarousel`, pero en vertical:

### Cambios técnicos

- **Reemplazar `DragGesture` manual** → `ScrollView(.vertical)` nativo
- **Usar `.scrollTargetBehavior(.viewAligned)`** — snap automático al item más cercano
- **Usar `.scrollPosition(id:)`** — tracking nativo del item centrado
- **Usar `.contentMargins(.vertical, ...)`** — centrar el primer/último item
- **Usar `.scrollTargetLayout()`** en el contenedor interior
- **Mantener haptics con `.sensoryFeedback(.impact, trigger:)`** en el `onChange` del ID scrolleado
- **Mantener la misma interfaz pública** (`items`, `selectedItem`, `onSelect`, `rowContent`) para no romper nada

### Resultado esperado

- **Momentum natural** — un swipe fuerte recorre varios items antes de detenerse
- **Bounce elástico** en los bordes (nativo del sistema)
- **Deceleration suave** idéntica al `TextStyleCarousel`
- **Haptic al cambiar de item** — impacto medio al pasar por cada uno
- Sin cambios en ninguna otra vista que use `VerticalSnapPicker`
