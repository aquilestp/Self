# Rediseñar stat Golden Arch como medalla circular tipo badge conmemorativo


## Lo que se hará

Transformar el stat "Golden Arch" de su forma actual (arco con pilares) a una **medalla circular premium** inspirada en la foto de referencia — una medalla dorada redonda con texto curvo, anillos decorativos, silueta de corredor, y fecha.

### Diseño de la medalla circular

- **Forma**: Círculo completo (~170pt diámetro) reemplazando la forma de arco
- **Borde exterior**: Anillo dorado grueso con gradiente metálico (borde elevado)
- **Segundo anillo interior**: Línea decorativa fina dorada oscura separando el borde del cuerpo
- **Cuerpo**: Relleno dorado con gradiente que simula metal pulido
- **Texto curvo superior**: "★ MY FIRST ★" siguiendo el arco superior de la medalla (texto embebido negro)
- **Distancia central grande**: Número grande (ej. "5.0") en negro con peso heavy
- **Unidad debajo**: "KM" o "MI" en tracking expandido
- **Banner/cinta central**: Pequeña cinta decorativa con la fecha de la actividad
- **Silueta de corredor**: Ícono `figure.run` centrado como decoración
- **Texto curvo inferior**: "- ¡LOGRADO! -" o "FINISHER" siguiendo el arco inferior
- **Estrellas decorativas**: Pequeñas estrellas doradas oscuras como separadores
- **Sub-métricas** (pace y tiempo): Debajo de la distancia, separadas por punto medio

### Detalles técnicos del estilo

- Todos los colores fijos (dorado/negro) — sin cambio de color permitido
- Texto embebido en negro sobre superficie dorada
- Sombras sutiles para dar profundidad y sensación 3D
- Gradiente metálico con highlights para simular metal real
- El texto curvo se logra con Canvas o transformaciones rotacionales

### Archivos que se modificarán

- El stat principal (widget grande en el editor de fotos)
- La miniatura de preview del stat
- Se reemplaza `MedalShape` por una forma circular con anillos
