# Nuevo widget "Split Banner" con stats alineados izquierda/derecha

## Nuevo widget de stats inspirado en el screenshot

**Features**

- Nuevo tipo de widget seleccionable llamado "Split Banner" disponible en el grid de stats del editor
- Info del día alineada a la izquierda: día de la semana (SUNDAY), fecha corta (APR 12), hora (7:18 AM)
- Stats del run alineados a la derecha: distancia (14.6 KM), ritmo (5:25/KM), duración (1H 19M)
- Soporte para cambio entre KM y Millas
- Ancho flexible que se adapta al contenido

**Design**

- Tipografía **SF Rounded Black Italic** en mayúsculas — letras gruesas, redondeadas e inclinadas, idénticas al screenshot
- Layout horizontal con dos columnas: izquierda y derecha separadas por un espaciado amplio
- Cada columna tiene 3 líneas de texto apiladas verticalmente
- Sin labels (TIME, DIST, etc.) — solo los valores directos como en el screenshot
- Tamaño de texto grande y prominente (~18-20pt) para máximo impacto visual
- Hereda el sistema de colores del widget (primaryColor) para que se adapte al estilo del canvas
- Soporte para fondo glass cuando está activado

