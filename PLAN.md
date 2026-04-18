# Registrar último acceso del usuario (last_seen_at)


## Qué se hace

Cada vez que un usuario abre la app, se guarda automáticamente la fecha y hora exacta en la base de datos. Esto permite ver cuándo fue la última vez que cada usuario usó la app.

---

## SQL (ejecutar en Supabase)

```sql
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMPTZ;
```

- Agrega la columna `last_seen_at` a la tabla `profiles`
- Es nullable (`IF NOT EXISTS` es seguro si ya existe)
- Usuarios existentes quedan con `NULL` hasta que abran la app por primera vez

---

## Cambios en el código Swift

**1. Modelo `UserProfile`**
- Agrega el campo `lastSeenAt` (mapeado a `last_seen_at`)

**2. `AuthViewModel`**
- Nueva función `updateLastSeen(userId:)` que hace un `UPDATE` en `profiles` con `last_seen_at = now()`
- Se llama en el evento `.initialSession` (cuando hay sesión activa = el usuario abrió la app)
- También se llama en `.signedIn` (cuando el usuario acaba de iniciar sesión)
- Los usuarios en modo Demo son ignorados

---

## Comportamiento esperado

| Situación | ¿Se actualiza? |
|---|---|
| Usuario abre la app con sesión activa | ✅ Sí |
| Usuario inicia sesión (Apple/Google/Email) | ✅ Sí |
| Usuario usa modo Demo | ❌ No |
| Usuario existente que aún no abre la app | `NULL` en BD |
