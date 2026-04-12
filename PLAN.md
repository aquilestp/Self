# Mejorar fluidez, haptics y sensación del VerticalSnapPicker

## Problemas detectados

- El scroll no tiene resistencia en los bordes (se puede arrastrar infinitamente)
- El haptic solo vibra al soltar el dedo, no mientras arrastras entre opciones
- La animación de snap no se siente tan natural como antes
- Swipes rápidos y lentos se sienten igual por el clamp a ±1

## Mejoras

- **Rubber banding en los bordes** — Al arrastrar más allá del primer o último item, se aplica una resistencia progresiva (como en los scroll de iOS), haciendo que el componente "rebote" de vuelta suavemente
- **Haptic durante el arrastre** — Cada vez que el dedo cruza la frontera de un item (sin soltar), se dispara un haptic ligero. Esto da la sensación de "engranaje" como los pickers nativos de iOS
- **Snap basado en la distancia real** — En lugar de usar la predicción de velocidad limitada a ±1, se calcula el item más cercano al centro basándose en la posición real del dedo más un poco de momentum. Esto permite swipes rápidos que avanzan 2-3 items cuando tiene sentido
- **Animación spring mejorada** — Se ajusta el spring para que el snap se sienta más "crisp" y rápido, similar a un UIPickerView nativo
- **Se aplica a todos los pickers** — Como `BVTEffectScrollPicker` y `WhatsAppTextScrollPicker` ya usan `VerticalSnapPicker`, el cambio los mejora automáticamente a todos
