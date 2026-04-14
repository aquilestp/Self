# Rediseño completo del sistema de sincronización del APNs token

**Problema raíz**

- El token de notificaciones push (APNs) nunca llega a la base de datos
- El sistema actual depende de que el token esté disponible en un momento específico — si no lo está, se pierde
- No hay forma de saber si el dispositivo realmente obtuvo el token de Apple o si falló silenciosamente

**Solución: Sistema reactivo de sincronización**

En vez de intentar sincronizar el token en momentos específicos, el nuevo sistema lo sincronizará automáticamente **cada vez que ambas condiciones se cumplan**: el token existe Y hay una fila en la base de datos.

1. **Observador reactivo del token** — Cuando Apple devuelve el token de notificaciones push, el sistema intentará guardarlo en la base de datos inmediatamente. Si no puede (porque el usuario no está logueado o no hay fila), lo guarda localmente y lo reintenta después.
2. **Sincronización en cada escritura a la base de datos** — Cada vez que se crea o actualiza la fila de Strava en la base de datos, se incluye el token de notificaciones si está disponible. Esto cubre el caso donde el token llegó primero.
3. **Sincronización después del login** — Cuando el usuario inicia sesión (con Apple o Google), el sistema sincroniza el token inmediatamente.
4. **Sincronización después de conectar Strava** — Después de la conexión con Strava, se espera hasta 20 segundos (con reintentos) para asegurar que el token se guarde.
5. **Re-registro proactivo** — Cada vez que la app vuelve al primer plano, se le pide a Apple que devuelva el token de nuevo (por si falló antes).
6. **Logs de diagnóstico visibles** — Se agregan logs extensos para saber exactamente:
  - Si Apple devolvió el token o si falló (y por qué)
  - Si la sesión de Supabase existe cuando se intenta sincronizar
  - Si la fila de strava_tokens existe
  - El resultado de cada intento de sincronización

