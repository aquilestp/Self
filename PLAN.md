# Widget unificado: Moving + Elapsed en uno solo

Reemplazo los dos widgets actuales (Moving Clean y Elapsed Clean) por un único widget de tiempo con diseño tipo Apple Activity.

**Diseño propuesto (estilo Apple)**
- Un anillo doble concéntrico: el anillo exterior representa el tiempo total (elapsed) al 100%, el anillo interior muestra el porcentaje de tiempo en movimiento (moving) relativo al total.
- Ícono central minimalista (timer) dentro de los anillos.
- Debajo de los anillos, dos líneas de datos alineadas y jerarquizadas:
  - Tiempo en movimiento, grande y destacado, con etiqueta "MOVING".
  - Tiempo total más pequeño y sutil, con etiqueta "ELAPSED".
  - Si hubo pausas, se muestra el tiempo pausado como dato secundario.
- Mantiene los mismos colores, paletas (Classic/Neon/Aesthetic) y efecto glass que los widgets existentes.

**Lo que el usuario verá**
- En el selector de widgets desaparecen "Moving Clean" y "Elapsed Clean".
- Aparece un nuevo widget llamado "Time" (reloj + timer) que muestra ambos tiempos juntos.
- Al colocarlo sobre la foto, se ve cuánto tiempo estuvo moviéndose el atleta, cuánto duró la actividad total y, si aplica, el tiempo pausado — todo en un solo bloque compacto.

**Alcance técnico**
- Se elimina `movingTimeClean` y `elapsedTimeClean` del enum de widgets y se agrega un nuevo caso `timeCombined`.
- Se crea la vista del widget combinado con los dos anillos y el layout descrito.
- Se actualizan las mini-previews del editor para el nuevo tipo.
- Los proyectos/plantillas existentes que referencien los tipos viejos quedan cubiertos por el reemplazo (la tabla está vacía según confirmaste antes, y los widgets se regeneran al editar).