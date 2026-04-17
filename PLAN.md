# Drawer grid: 3 columnas → 2 columnas con thumbnails proporcionales


## Qué cambia

### Grid: de 3 → 2 columnas
- Ambos estados del drawer (abierto/compacto y expandido) pasan de 3 columnas a **2 columnas**
- Los dos widgets que hoy abarcan las 3 columnas completas (`fullBanner` y `fullBannerBottom`) seguirán abarcando **todo el ancho** — ya funcionan así por diseño, no requieren cambio lógico

### Tamaños proporcionales
- Los thumbnails de widget pasan de **80px → 106px** de alto (mantiene la misma proporción visual al ser más anchos)
- El thumbnail de texto "Aa" sube igual: **80px → 106px**
- Los full-width thumbnails pasan de **94px → 110px** para mantener la jerarquía

### Estado compacto (drawer abierto)
- Actualmente muestra `text + 5 widgets` = 6 ítems en 3 cols = **2 filas**
- Con 2 cols, 6 ítems darían 3 filas — se ajusta el número visible a `text + 3 widgets` = 4 ítems = **2 filas limpias**, manteniendo la compacidad del estado inicial
- Se actualiza el `maxHeight` para acomodar las 2 filas más altas + los full-width

### Estado expandido (drawer expandido)
- Muestra **todos los widgets** en grid de 2 cols — sin cambio en la cantidad, solo en la distribución
- Los full-width siguen al final del scroll, abarcando todo el ancho

## Lo que NO cambia (lógica intacta)
- Sorting por **Popular** (por popularidad → índice original como desempate)
- Sorting por **Recents** (por fecha de uso reciente → fallback a popularidad si sin historial)
- **Animaciones** de transición entre estados del drawer (`.snappy`, `.spring`)
- **Drag gesture** con umbrales `.open` ↔ `.expanded` ↔ `.collapsed`
- Pills de tabs (Popular / Recents) con sus highlights y hápticos
- Estado activo de cada widget (`scaleEffect`, colores de fondo y borde)
