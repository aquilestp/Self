# VerticalSnapPicker: más fluido y vibraciones más fuertes

**Mejoras de fluidez:**

- Reducir la resistencia del momentum para que el scroll se sienta más libre y natural (actualmente frena demasiado rápido)
- Hacer que el highlight del item seleccionado siga tu dedo en tiempo real durante el drag, no solo cuando está quieto
- Reducir el `minimumDistance` del gesto para que responda más rápido al toque

**Mejoras de haptics (vibraciones más fuertes):**

- Cambiar de `UISelectionFeedbackGenerator` (vibración suave) a `UIImpactFeedbackGenerator` con intensidad `.medium` para cada cambio de item durante el drag — se sentirá mucho más táctil
- Al soltar el dedo y hacer snap al item final, usar una vibración `.heavy` para dar una confirmación clara
- Pre-calentar el motor háptico antes de cada vibración para que no haya delay

**Resultado esperado:**

- El scroll vertical se sentirá como el picker nativo de iOS (tipo ruleta)
- Cada item que pases con el dedo dará un "click" satisfactorio
- Al aterrizar en el item final, sentirás un golpe firme de confirmación
