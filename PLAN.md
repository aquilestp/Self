# Filtros de foto con swipe — Original, B&W, Dramatic

## Features

- **3 filtros de foto** siempre disponibles: Original (sin filtro), Blanco y Negro, y Dramatic
- **Cambio por swipe** — deslizar horizontalmente sobre la foto/canvas cambia entre los filtros
- **Nombre del filtro** aparece brevemente al centro del canvas al cambiar (ej: "B&W", "DRAMATIC"), se desvanece después de 1 segundo
- **Compatible con filtros de ciudad/carrera** — los filtros de foto modifican la imagen base, mientras los de ciudad/carrera siguen funcionando como overlays encima
- **Indicador de puntos** (dots) en la parte inferior del canvas mostrando qué filtro está activo
- **Persistencia visual** — el filtro se aplica también al exportar/guardar la imagen

## Design

- **Swipe fluido** con animación spring al cambiar de filtro
- **Nombre del filtro** en texto blanco con sombra, tamaño mediano, aparece centrado sobre el canvas con animación de fade in/out
- **Dots indicadores** — 3 puntos pequeños debajo de la foto, el activo en blanco sólido, los demás en blanco semitransparente
- **Haptic feedback** sutil al cambiar de filtro (selection feedback)
- Los filtros se procesan con Core Image (GPU) para rendimiento óptimo
- **B&W** usa el efecto Noir de Core Image (blanco y negro con alto contraste dramático)
- **Dramatic** usa ajustes de contraste alto, sombras profundas y highlights reducidos para un look cinematográfico intenso

## Screens / Changes

1. **Canvas del editor** — Al deslizar horizontalmente sobre la foto se cambia entre Original → B&W → Dramatic → (vuelve a Original)
2. **Label flotante** — Al cambiar filtro aparece el nombre centrado por 1 segundo y desaparece con fade
3. **Dots de filtro** — Aparecen en la parte inferior del canvas cuando hay un filtro activo (o siempre, mostrando los 3 puntos)
4. **Exportación** — Al guardar o compartir, la imagen exportada incluye el filtro aplicado
