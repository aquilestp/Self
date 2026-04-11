# Aplicar efecto de estiramiento vertical al stat de la izquierda (heroStat)

## Cambio

Replicar el efecto visual de **elongación/estiramiento vertical** que tiene el stat de la derecha (tower) en el stat de la izquierda (heroStat).

### Qué se modificará

1. **Stat heroStat en el canvas** — Añadir estiramiento vertical al número principal "9.8 KM" con `scaleEffect(x: 1.0, y: 2.5)` igual que el tower, más el padding inferior necesario para compensar el espacio visual
2. **Stat heroStat en el mini preview** — Aplicar el mismo efecto de estiramiento al texto principal en la vista de previsualización pequeña, para que la miniatura también refleje el estilo elongado

### Resultado visual

El stat de la izquierda mostrará el número principal (ej. "9.8 KM") con el mismo efecto de texto alargado/estirado verticalmente que tiene el stat de la derecha, manteniendo los sub-stats (PACE y TIME) con su tamaño normal debajo.
