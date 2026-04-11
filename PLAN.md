# Permitir ocultar Pace y Time en el stat heroStat

## Cambio

El stat que muestra el número grande elongado con "PACE" y "TIME" debajo (heroStat) actualmente los muestra siempre fijos. Se añadirá la opción de ocultar/mostrar cada uno individualmente, igual que en otros stats.

### Qué se hará

1. **Botones de visibilidad en el editor** — Al seleccionar el heroStat en el canvas, aparecerán los botones de ojo para ocultar/mostrar "Pace" (icono velocímetro) y "Time" (icono reloj), igual que en los stats bold/impact
2. **El stat respeta la configuración** — Si se oculta Pace, desaparece del heroStat. Si se oculta Time, desaparece. Si se ocultan ambos, no se muestra la fila inferior de datos

