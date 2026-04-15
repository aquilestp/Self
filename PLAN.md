# Corregir fondo translúcido que no aparece al exportar/compartir

## Problema

Cuando se activa el fondo translúcido (glass) en un widget/stat, este se ve correctamente en la pantalla del editor, pero al guardar la foto o compartir a Instagram, el fondo no aparece.

## Causa

Al generar la imagen para exportar, el código no le pasa la opción de fondo translúcido al widget. Por eso siempre se exporta sin fondo, aunque en pantalla sí se vea.

## Solución

- Agregar el parámetro de fondo translúcido (`useGlassBackground`) a la construcción del widget dentro de la función de captura/exportación
- También agregar otros parámetros que faltan en la exportación (`notesUnitFilter`, `ancestralUnitFilter`, `ancestralShowPace`, `ancestralShowTime`) para que la imagen exportada sea idéntica a lo que se ve en pantalla

