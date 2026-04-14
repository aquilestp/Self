# Strava Webhooks + Push Notifications en tiempo real

## Plan completo en 3 fases

### Fase 1: Configurar APNs key en Supabase
- Guardar tu APNs key (.p8) como secrets en tu proyecto de Supabase con estos nombres:
  - `APNS_KEY_P8` — el contenido de tu archivo .p8
  - `APNS_KEY_ID` — el Key ID de Apple (10 caracteres)
  - `APNS_TEAM_ID` — tu Team ID de Apple Developer
  - `APNS_BUNDLE_ID` — el bundle ID de tu app (ej: `app.rork.fitlogin-mobile`)
- Esto se hace desde el dashboard de Supabase → Edge Functions → Secrets

### Fase 2: Actualizar la Edge Function del webhook
- Agregar lógica de envío de push notifications vía APNs directamente desde la Edge Function `strava-webhook`
- Cuando llega un evento `create` de una actividad:
  1. Guarda la actividad en la base de datos (ya funciona)
  2. Busca el `apns_token` del usuario en la tabla `strava_tokens`
  3. Genera un JWT firmado con la key .p8 para autenticarse con APNs
  4. Envía la push notification al dispositivo del usuario con el nombre de la actividad
- La notificación mostrará: **"Nueva actividad sincronizada"** con el nombre de la actividad como cuerpo

### Fase 3: Crear la suscripción del webhook en Strava
- Te daré el comando `curl` exacto para crear la suscripción:
  - URL del callback: la URL de tu Edge Function de Supabase
  - Verify token: `SELFSPORT_WEBHOOK_VERIFY` (ya configurado en tu código)
  - Client ID y Client Secret de Strava
- Strava enviará un GET de validación a tu Edge Function, que ya está preparada para responder con el `hub.challenge`
- Una vez validada, la suscripción queda activa y empezarás a recibir eventos en tiempo real

### Cambios en la app iOS
- Sin cambios mayores — la app ya registra el token APNs y lo sincroniza a Supabase
- El polling existente seguirá como respaldo por si la push no llega
- Cuando la push llegue, la app la mostrará como banner nativo de iOS
