# Cargar video del onboarding desde URL remota

**Problema:** El video no carga porque el código busca un archivo local que no existe en la app. El video está disponible como URL remota.

**Solución:**

- Cambiar la carga del video para que descargue desde la URL remota (`https://r2-pub.rork.com/attachments/d1hbppe43o59ckb7fvhvb.mov`) en lugar de buscar un archivo local
- El video empezará a descargarse en segundo plano desde que se abre el onboarding (preload)
- Una vez descargado, se reproduce en loop dentro del frame del iPhone
- Se muestra el spinner de carga mientras se descarga
- Si la descarga falla (sin internet), se muestra el frame vacío sin errores molestos

