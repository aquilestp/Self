# Demo mode sin Supabase — actividades hardcodeadas

## Qué cambia

El botón **"Try Demo"** ya no depende de Supabase ni de ninguna conexión. Al tocarlo, entra directamente a la app y muestra actividades de carrera ya listas, sin login ni red.

---

## Funcionalidades

- **Demo instantáneo**: tocar "Try Demo" entra al app en menos de un segundo, sin llamadas de red ni autenticación
- **Actividades de carrera precargadas**: ~7 carreras realistas con distancias, tiempos, ritmos y elevación variados
- **Perfil "Demo User"**: el saludo superior muestra "Demo User" como nombre
- **Sin error de conexión**: se elimina el mensaje "Demo unavailable — check your connection" para siempre
- **Flujo de salida limpio**: cerrar sesión en modo demo regresa a la pantalla de login sin afectar nada en Supabase

---

## Qué se elimina

- La llamada a Supabase en el botón "Try Demo" (era la causa del error)
- La dependencia de que exista el usuario `test@selfsport.app` en la base de datos
- La carga desde caché de Supabase en modo demo (`loadFromCacheOnly`)

---

## Cómo funciona internamente

1. **Botón "Try Demo"** → activa modo demo localmente sin red
2. **Perfil falso** → crea "Demo User" en memoria, sin tocar Supabase
3. **Actividades hardcodeadas** → 7 carreras cargadas directamente desde el código del app, visibles de inmediato
4. **Strava desconectado** en demo → no muestra el botón de conectar, solo las carreras demo

