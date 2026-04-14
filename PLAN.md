# Arreglar definitivamente el guardado del APNs token

**Problema raíz**
- Al desconectar Strava, se borra la fila completa de la base de datos
- Al reconectar, `syncAPNsToken` usa UPDATE que no hace nada si la fila no existe aún
- No hay ningún mecanismo que sincronice el token DESPUÉS de que Strava se conecte exitosamente

**Solución (4 cambios concretos):**

1. **Cargar el token de UserDefaults al iniciar** — Cuando la app arranca, el servicio de notificaciones carga automáticamente el token guardado previamente en la memoria, para que esté disponible inmediatamente

2. **Después de conectar Strava, forzar la sincronización del token** — Justo después de guardar los tokens de Strava en la base de datos, esperar 2 segundos (para dar tiempo a que Apple devuelva el token si es la primera vez) y luego sincronizar el token de notificaciones. También forzar que Apple re-entregue el token de notificaciones

3. **Hacer la sincronización del token más agresiva** — Si el primer intento falla (porque el token aún no llegó), reintentar automáticamente 3 veces con esperas de 3 segundos entre cada intento

4. **Agregar logs claros** — Imprimir en consola exactamente qué está pasando en cada paso para poder diagnosticar si el problema persiste