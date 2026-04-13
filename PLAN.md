# Cambiar números de los 5 widgets a letra ancha (expanded) con italic

**Cambio**

Los números de los 5 widgets actualmente usan estilo **condensado** (estrecho). Se cambiarán a estilo **expandido** (ancho) como en la imagen de referencia "14.7 KM", manteniendo italic y peso heavy/black.

**Widgets afectados:**
1. Weekly KM (THIS WEEK)
2. Last Week KM (LAST WEEK)
3. Monthly KM (THIS MONTH)
4. Last Month KM (LAST MONTH)
5. Elevation Gain

**Ajustes:**
- Cambiar `.width(.condensed)` → `.width(.expanded)` en los 5 números grandes
- Reducir ligeramente el tamaño de fuente (de 28→24 en los 4 de KM, de 36→30 en elevation) para que el texto expandido quepa sin desbordar el widget
- Agregar `minimumScaleFactor` donde no exista para evitar overflow
- Mismos cambios en las mini previews del editor (drawer)
- Las áreas de gesto no se verán afectadas porque el texto mantiene `lineLimit(1)` y scale factor