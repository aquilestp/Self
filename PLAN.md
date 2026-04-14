# Arreglar notificaciones push de Strava

**Problema detectado:**

- La app tiene el entorno de notificaciones push configurado como "development" (sandbox), pero la edge function de Supabase envía al servidor de **producción** de Apple. Esto causa que el push nunca llegue.
- Además, hay un servicio de polling que envía notificaciones locales duplicadas cuando la app está abierta — esa es la "notificación interna" que ves.

**Cambios:**

1. **Cambiar el entorno de push a producción** — para que el token APNs que el dispositivo genera sea compatible con el servidor de producción que usa la edge function
2. **Quitar la notificación local duplicada del polling** — el polling seguirá sincronizando actividades en segundo plano, pero ya no enviará una notificación local redundante (la push real desde la edge function se encargará de eso)
3. **Agregar logging mejorado** — para que puedas verificar en consola que el token APNs se está guardando correctamente en Supabase

**Resultado esperado:**

- Cuando crees una actividad en Strava, la edge function enviará un push REAL que llegará aunque el teléfono esté bloqueado
- Ya no verás la notificación interna duplicada

