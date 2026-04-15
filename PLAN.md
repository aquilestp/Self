# Desactivar animaciones solo al exportar imagen

**Cambio**

Cuando se exporta la foto (a Instagram Stories o al guardar en la galería), los elementos de la interfaz que se ocultan (botones, selectores) lo hacen con animación, lo que causa un retraso antes de capturar la imagen.

**Ajuste**

- Al iniciar la captura del canvas, desactivar temporalmente **todas** las animaciones del sistema para que los elementos se oculten de forma instantánea (sin transición visible)
- Una vez tomada la captura, restaurar las animaciones al estado normal
- Las animaciones durante el uso normal de la app (arrastrar widgets, abrir menús, etc.) se mantienen exactamente igual

