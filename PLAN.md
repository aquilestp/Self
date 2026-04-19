# Unificar el drawer en un solo estado abierto, más alto

Ahora mismo el drawer de widgets tiene tres estados (cerrado, medio, expandido) y el más alto llega al 75% de la pantalla. Voy a dejar solo dos estados: cerrado y abierto, donde "abierto" es aún más alto que el máximo actual.

**Cambios**

- Eliminar el estado intermedio del drawer: al tocar o arrastrar hacia arriba, pasa directo a un único estado abierto.
- Subir la altura máxima del drawer abierto (de ~75% a ~88% de la pantalla) para que se sienta más presente y quepan más widgets visibles de una.
- Mostrar siempre la grilla completa con scroll (ya no hay vista compacta intermedia).
- Ajustar el gesto de arrastre: arrastrar hacia abajo lo cierra; ya no hay paso intermedio.
- Mantener intacto el orden de los widgets, el fondo translúcido y los tamaños de cada card que ya quedaron bien.

