# Ajustes visuales al widget NameStats

## Cambios al widget de Nombre + Indicadores

### Indicadores inferiores más grandes y armónicos

- Etiquetas (Distance, Pace, Time, Elevation): de tamaño 9 → **12**, con más tracking
- Valores: de tamaño 16 → **22**, ligeramente más peso para mejor presencia visual
- Espaciado interno entre etiqueta y valor: de 4 → **6**
- Espaciado superior antes de los indicadores: de 18 → **22**

### Eliminar líneas divisoras

- Se eliminan los `Rectangle` separadores de 0.5px entre columnas
- Los indicadores quedan distribuidos con espacio libre (HStack con spacing natural)

### Fecha más grande

- Tamaño de fuente de la fecha: de 11 → **13**

### Indicadores sin opacidad (blancos por defecto)

- Etiquetas de indicadores: se elimina la opacidad 0.55 → **opacidad completa**
- La fecha: **opacidad completa**

