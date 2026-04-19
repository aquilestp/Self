# Unificar el orden de widgets entre drawer compacto y expandido

## Problema

El ordenamiento de los widgets se recalcula de forma independiente en la vista compacta y la expandida, lo que puede producir órdenes distintos si los datos de popularidad o recientes se actualizan entre renders.

## Solución

- Calcular el orden de los widgets **una sola vez** cuando el drawer abre o cuando cambia el tab (Popular / Recents).
- Guardar ese resultado en una variable de estado compartida.
- Tanto la vista compacta como la expandida leen exactamente la misma lista calculada, garantizando orden idéntico.
- El recálculo se dispara automáticamente cuando cambia el tab del drawer o los datos de popularidad/recientes.

