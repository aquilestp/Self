# Arreglar el guardado del APNs token en la base de datos

**Problema**
- El token de notificaciones push (APNs) nunca se guarda en la base de datos
- Cuando Strava envía una actividad nueva, el servidor no puede enviar la notificación push porque no tiene el token

**Solución (3 cambios):**

1. **Guardar el token de forma más robusta** — Cuando Apple entrega el token de notificaciones, se guarda explícitamente en almacenamiento local del dispositivo (no depender del mecanismo actual que puede fallar)

2. **Siempre incluir el token al sincronizar con Strava** — Después de guardar los tokens de Strava en la base de datos (cuando la fila ya existe), hacer una actualización separada para asegurar que el token de notificaciones se guarde en esa fila

3. **Reintentar el guardado del token cuando la sesión esté lista** — Si al momento de recibir el token de Apple no hay sesión activa, guardarlo localmente y reintentarlo cuando la app detecte que el usuario ya está logueado. También reintentar cada vez que la app vuelve al primer plano.