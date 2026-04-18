# Loading de IA con partículas flotantes y texto dinámico


## Qué cambia

El estado de carga al aplicar un estilo de IA pasará de un simple círculo pulsante centrado a una experiencia que cubre **toda la pantalla** con movimiento elegante.

## Diseño

- **Fondo:** overlay oscuro translúcido que cubre toda la pantalla, igual que ahora pero preparado para las partículas
- **Partículas flotantes:** ~20 pequeñas chispas/estrellas (puntos blancos de diferentes tamaños) que aparecen aleatoriamente en distintos puntos de la pantalla y suben suavemente hasta desvanecerse — cada una con velocidad y posición horizontal distintas para que el efecto se sienta vivo en toda la pantalla
- **Icono central:** el sparkles ✦ se hace más grande (40pt) con un glow/halo blanco pulsante alrededor, más prominente que ahora
- **Texto cíclico:** debajo del icono, el texto cambia automáticamente cada ~2 segundos entre:
  - *"Analyzing image..."*
  - *"Applying style..."*
  - *"Finishing touches..."*
  — con una transición suave de fade entre cada frase
- **Tipografía:** misma familia que ahora, limpia y en blanco

## Lo que NO cambia
- El comportamiento (cancel, accept, discard) sigue igual
- La pantalla de revisión post-generación no se toca
- La duración real de carga depende de la API, esto es solo visual
