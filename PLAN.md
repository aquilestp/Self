# Arreglar notificaciones push y restaurar notificaciones locales

**Problemas encontrados:**

1. **Las notificaciones internas (locales) fueron eliminadas** — En un cambio anterior se quitó el código que enviaba notificaciones locales cuando se detectaban actividades nuevas vía webhook. Por eso ya no llegan ni siquiera las internas.
2. **El token de notificaciones no se guarda en la base de datos** — `syncAPNsToken` usa UPDATE que no hace nada si la fila no existe todavía (después de desconectar/reconectar Strava). Necesita usar UPSERT.
3. **No hay reintento al volver al primer plano** — Si el token no se guardó, no hay un mecanismo agresivo de reintento.

---

**Cambios en la app:**

1. [x] **Restaurar notificaciones locales** — Volver a agregar el envío de notificaciones locales en el servicio de polling cuando se detectan actividades nuevas. Esto garantiza que siempre lleguen notificaciones aunque el push externo falle.
2. [x] **Cambiar `syncAPNsToken` de UPDATE a UPSERT** — Para que funcione incluso si la fila no existe todavía en la tabla. Así el token siempre se guarda correctamente.
3. [x] **Agregar reintento más agresivo** — Después de conectar Strava, reintentar la sincronización del token 5 veces con 3 segundos entre cada intento. También reintentar cada vez que la app vuelve al primer plano.

---

**Edge function actualizada (para que copies y hagas deploy en Supabase):**

1. [x] **Intentar AMBOS entornos de APNs** — La edge function intentará enviar primero al servidor de producción, y si falla con "BadDeviceToken", reintentará con el servidor sandbox. Esto cubre tanto builds de TestFlight como de desarrollo.
2. [x] **Mejor manejo de errores** — Logs más detallados en cada paso para diagnosticar si hay problemas con la firma JWT, el token, o la conexión con Apple.

