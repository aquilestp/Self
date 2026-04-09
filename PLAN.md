# Ajustar pantallas de onboarding y font de elevación

**Cambios**

1. **Fondo negro en las pantallas con GIF** — Las pantallas "Connect via Strava…" (paso 2) y "Select your picture…" (paso 3) tendrán fondo completamente negro en el frame del teléfono, para que los GIFs se integren sin verse cortados

2. **Eliminar la pantalla 3 (Connect)** — Se remueve el paso "Next, bring in your activities" con las tarjetas de Strava/Garmin/COROS. El onboarding queda en 3 pasos: Intro → GIF demo → GIF share

3. **Font estilo "wide/expanded" en el número de elevación** — El número del stat de elevación usará el mismo estilo de fuente alargada/expandida que usa el widget "Wide" (el que ocupa 3 posiciones del grid). Es decir, fuente `.black` con `.width(.expanded)` y tracking negativo, dándole ese look estirado y bold