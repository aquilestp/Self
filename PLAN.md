# Arreglar textos del badge: "MY FIRST" con más estilo, pace/time sin sobreposición con "FINISHER"


## Problemas identificados

1. **"MY FIRST"** — las estrellas (★) están muy cerca del borde del anillo, se recortan visualmente
2. **Pace y Time** — se sobreponen con el texto curvo "FINISHER" en la parte inferior
3. **"MY FIRST"** necesita más estilo/presencia

## Cambios

### Texto curvo "★ MY FIRST ★"
- Reducir el radio del texto curvo para alejarlo del borde exterior (de 67pt a ~60pt)
- Reducir el arco de extensión para que las letras no lleguen tan al borde lateral
- Aumentar ligeramente el tamaño de fuente para darle más presencia y protagonismo

### Texto curvo "— FINISHER —"
- Mover más hacia abajo (mayor radio) para separarlo del contenido central
- Reducir el arco para que quede más compacto en la parte baja

### Pace y Time
- Moverlos justo debajo de la fecha (banner) pero por encima de la zona del texto curvo "FINISHER"
- Reducir ligeramente el tamaño para que quepan sin conflicto
- Ajustar el offset vertical del VStack central para centrar mejor todo el contenido

### Ajuste general del VStack central
- Recalcular los espaciados internos para que todo el contenido (runner icon → distancia → unidad → fecha → pace/time) quede centrado sin invadir las zonas de texto curvo superior e inferior
