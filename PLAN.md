# Aplicar estilo elongado vertical al stat tower (derecha) en el canvas

## Cambio

Aplicar el mismo efecto de **estiramiento vertical** que ya tiene el stat de la izquierda (heroStat) al stat de la derecha (tower) en el canvas.

### Qué se hará

1. **Stat tower en el canvas** — Añadir `scaleEffect(x: 1.0, y: 2.5)` al texto principal del tower widget para que el número se vea alargado verticalmente, igual que el heroStat
2. **Ajuste de padding** — Compensar el espacio extra que genera el estiramiento para que no se solape con otros elementos

### Estado actual
- **heroStat (izquierda)** ✅ Ya tiene el estilo elongado aplicado
- **tower (derecha)** ❌ Solo tiene texto grande (tamaño 110) sin estiramiento vertical

### Resultado
Ambos stats en el canvas (izquierda y derecha) tendrán el mismo efecto de texto estirado/alargado verticalmente.