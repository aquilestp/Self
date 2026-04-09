# Arreglar el video del onboarding con streaming directo

## Problema
El video en el paso 2 del onboarding no carga porque la app intenta descargar el archivo completo antes de reproducirlo, y eso falla en el simulador.

## Solución
Cambiar la estrategia de reproducción: en vez de descargar el archivo completo primero, reproducir el video directamente desde la URL (streaming). Esto es como cuando ves un video en una web — empieza a reproducir mientras se descarga en segundo plano.

## Cambios
- **Streaming directo**: El video empezará a reproducir apenas tenga suficiente buffer, sin esperar a que se descargue completo
- **Precarga mejorada**: Se empezará a preparar el video desde que la app se abre (antes de que llegues al paso 2)
- **Fallback con reintentos**: Si el streaming falla, se reintentará automáticamente hasta 3 veces
- **Misma apariencia**: El frame del iPhone con su diseño actual se mantiene exactamente igual — solo cambia cómo se carga el video por debajo