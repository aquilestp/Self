# Glass más premium estilo iOS Control Center


## Mejoras al efecto glass de los widgets

### Qué se mejora (solo en `DraggableStatWidget.swift`)

**En el canvas (vista en vivo):**
- **Blur más fuerte**: Cambio de `ultraThinMaterial` → `thinMaterial`, que produce un desenfoque más intenso y opaco, idéntico al que usa el Centro de Control de iOS
- **Highlight especular**: Gradiente blanco sutil en el borde superior (de blanco semi-opaco → transparente), simula la luz rebotando en el vidrio
- **Borde con gradiente**: El stroke deja de ser uniforme y pasa a ser un gradiente angular (más brillante en la esquina superior-izquierda, más sutil abajo), como el reflejo de vidrio real
- **Inner glow**: Segundo overlay interior muy tenue en blanco para dar sensación de profundidad dentro del card
- **Sombra refinada**: Mayor radio (`20pt`) con desplazamiento vertical (`8pt`) para más elevación

**En el export (Instagram / galería):**
- El fondo exportado sube de opacidad (`0.30 → 0.60`) para compensar la ausencia de blur real en el renderizado y lograr que visualmente se vea igual que en el canvas
- Se aplica el mismo highlight especular y el mismo borde con gradiente que se ven en vivo
- Paleta neon y aesthetic mantienen sus reglas actuales, pero también reciben el highlight y el borde mejorado

### Resultado esperado
Un widget glass que se percibe como una placa de vidrio esmerilado flotando sobre la foto — con profundidad, luz y desenfoque — tanto al editarlo como al exportarlo a Instagram.
