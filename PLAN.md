# Activity Switcher Drawer en el canvas del editor

## Features

- Nuevo botón con ícono de loop/reload (`arrow.2.circlepath`) en la barra superior del canvas, justo a la izquierda del botón de ubicación
- El botón de ubicación pasa a mostrar solo el ícono de pin (`mappin.and.ellipse`), sin texto
- Al tocar el botón de loop se abre un nuevo drawer inferior con la lista completa de actividades
- La actividad actualmente seleccionada aparece marcada con un check y resaltada visualmente
- Al tocar otra actividad: los stats/datos del canvas cambian al instante y el drawer se cierra — la foto se mantiene igual
- El drawer tiene scroll completo para ver todas las actividades disponibles

## Design

- El drawer se abre desde abajo con animación spring, mismo estilo que los drawers existentes (fondo oscuro translúcido con material)
- Cada fila de actividad muestra: ícono circular de deporte con color de acento, nombre y stats (distancia · ritmo · duración)
- La actividad activa tiene un fondo levemente iluminado y un checkmark en lugar del chevron derecho
- Fondo del drawer: `Color(white: 0.06)` con drag indicator visible para cerrar
- Drag indicator en la parte superior del drawer para poder cerrarlo deslizando hacia abajo
- Barra superior del canvas: `[Self AI] ··· Spacer ··· [loop icon] [pin icon]` — ambos botones como cápsulas compactas sin texto

## Changes

- **Top bar**: botón de ubicación → solo ícono `mappin.and.ellipse`; nuevo botón `arrow.2.circlepath` a su izquierda
- **PhotoEditorView**: recibe el arreglo de actividades y un callback para cambiar la actividad activa; agrega estado para mostrar/ocultar el nuevo drawer
- **DashboardRootView**: pasa la lista de actividades activas a `PhotoEditorView`
- **Nuevo view de drawer**: lista scrolleable de actividades con fila que destaca la seleccionada con check

