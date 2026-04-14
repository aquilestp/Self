# Arreglar Push Notifications — Agregar columna y corregir endpoint

## Problema encontrado

La columna `apns_token` **no existe** en la tabla `strava_tokens` de Supabase. Esto causa que:
1. El token del dispositivo nunca se guarda
2. El webhook nunca envía la notificación push (porque el token es siempre vacío)

Además, el endpoint de APNs usa la URL de **producción**, pero tu app está instalada como build de desarrollo, lo cual requiere el endpoint **sandbox**.

## Pasos para arreglar

### Paso 1 — Agregar columna en Supabase (lo haces tú manualmente)
Ve al **SQL Editor** de Supabase y ejecuta:
```sql
ALTER TABLE strava_tokens ADD COLUMN IF NOT EXISTS apns_token TEXT;
```

### Paso 2 — Corregir endpoint de APNs en la Edge Function
Cambiar la URL de `api.push.apple.com` a `api.sandbox.push.apple.com` en la función `strava-webhook`, ya que tu app usa build de desarrollo.

> **Nota:** Cuando publiques en TestFlight/App Store, deberás cambiar a `api.push.apple.com`.

### Paso 3 — Verificar que el token se sincroniza
Después de los cambios anteriores, la app debería:
1. Registrar el device token al abrir
2. Guardarlo en la columna `apns_token` de `strava_tokens`
3. El webhook lo lee y envía la push al endpoint sandbox correctamente