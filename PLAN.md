# Corregir sincronización del token APNs en strava_tokens

## Problema
Cada vez que se sincronizan los tokens de Strava (al conectar, refrescar token, etc.), el campo `apns_token` se sobreescribe con NULL porque no se incluye en los datos del upsert. Esto causa que la edge function no pueda enviar push notifications.

## Solución

**Cambio 1: Preservar el `apns_token` al sincronizar tokens de Strava**
- Antes de hacer upsert de tokens de Strava, leer la fila existente para obtener el `apns_token` actual
- Incluir el `apns_token` existente en el upsert para no perderlo
- Si hay un `deviceToken` en memoria (NotificationService.shared), usar ese como respaldo

**Cambio 2: Re-sincronizar el `apns_token` después de conectar Strava**
- Después de cada `syncTokens`, si hay un token APNs disponible en memoria, llamar también a `syncAPNsToken` para asegurar que no se pierda

Esto garantiza que el campo `apns_token` siempre tenga valor en la tabla, y la edge function podrá enviar la push notification al dispositivo bloqueado.