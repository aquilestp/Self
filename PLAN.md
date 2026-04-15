# Captura de pantalla real en vez de re-renderizar — imagen exportada 100% idéntica al canvas

## Problema actual

Cuando exportas a Instagram o guardas en la galería, los fondos translúcidos (glass/blur) de los widgets se ven más oscuros o diferentes porque el sistema actual reconstruye la vista desde cero y no puede reproducir el efecto blur real.

## Nueva solución

En vez de reconstruir la imagen, vamos a **tomar una foto directa de lo que se ve en pantalla** — capturando los píxeles exactos del canvas incluyendo todos los efectos visuales.

### Cómo funciona

- Se agrega un "ancla de captura" invisible al canvas que permite acceder a la vista real en pantalla
- Al exportar, se ocultan temporalmente los botones y controles del editor (drawer, botón de texto, guías, etc.)
- Se toma una captura de los píxeles reales del canvas — esto incluye blur, materiales, sombras, todo exactamente como se ve
- Se escala la captura a alta resolución (1080×1920) para que se vea nítida en Instagram y en la galería
- Se restauran los controles del editor

### Resultado

- El fondo translúcido de los widgets se verá **idéntico** en la foto exportada
- Los filtros, colores, efectos — todo se exportará tal cual aparece en el editor
- Se elimina la necesidad de colores sólidos de fallback para la exportación
- Compatible con todos los estilos de widget (normal, neon, aesthetic)

