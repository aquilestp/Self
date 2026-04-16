# Botón "Try Demo" con actividades pre-cargadas

## Qué hace esto

Un botón **"Try Demo"** visible en la pantalla de login que entra automáticamente a la app usando una cuenta demo de Supabase, mostrando las actividades pre-cargadas (las de Aquiles) sin necesidad de conectar Strava ni Coros.

---

## Flujo del reviewer

1. Toca **"Try Demo"** en la pantalla de login
2. La app se autentica silenciosamente con la cuenta demo (sin que el reviewer escriba nada)
3. Entra directo al dashboard con las actividades ya cargadas
4. Puede explorar toda la app normalmente

---

## Cambios en la app

### Pantalla de Login

- Nuevo botón **"Try Demo"** visible debajo de "Sign in with Apple" y "Continue with Google"
- Estilo sutil (borde blanco semitransparente, texto blanco) — no compite con los CTAs principales
- Muestra un spinner mientras autentica

### Lógica de autenticación

- Toca el botón → llama `signInWithEmail` con las credenciales demo hardcodeadas: `test@selfsport.app` / `testingselfapp7`
- Si falla por red, muestra error claro: "Demo unavailable — check your connection"

### Carga de actividades sin Strava

- En modo demo, el dashboard carga las actividades directamente desde Supabase (la caché) sin requerir conexión a Strava
- El feed muestra las actividades de la cuenta demo normalmente
- Los botones de "Connect Strava" siguen visibles pero no son necesarios para navegar

---

## Qué necesitas hacer en Supabase (una vez)

> **Requisito previo — sin esto el botón no funciona:**
>
> 1. En Supabase → Authentication → Email: **desactivar "Confirm email"** (o confirmar manualmente la cuenta `test@selfsport.app`)
> 2. Verificar que la tabla `strava_activities` tenga filas con el `user_id` de esa cuenta (las actividades de Aquiles)

---

## Notas para App Store Review

En el campo "Review Notes" de App Store Connect escribirías:

> *"Tap 'Try Demo' on the login screen to access a demo account with pre-loaded activities. No account creation required."*

