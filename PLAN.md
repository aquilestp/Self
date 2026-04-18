# Sistema de actualización controlable desde Supabase


## Qué se construirá

Un sistema de notificación de actualizaciones completamente controlable desde Supabase, que muestra un modal con las novedades de la app cuando esté marcado como activo.

---

## Supabase — Tabla `app_updates`

Se crea manualmente en el dashboard de Supabase con esta estructura:

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | int (PK) | Siempre 1 (singleton) |
| `is_active` | boolean | ON/OFF del modal — palanca principal |
| `title` | text | Título del modal (ej: "What's New ✨") |
| `subtitle` | text | Subtítulo opcional (ej: "Version 2.1") |
| `items` | text[] | Array de 1 a 4 bullets de texto |

Para activarlo: cambia `is_active = true`. Para desactivarlo: `false`. Los bullets se editan directamente en el campo `items`.

---

## Comportamiento

- **Cuándo aparece:** Cuando el usuario está en la pantalla de actividades y Supabase tiene `is_active = true`
- **Si toca "Later":** No vuelve a aparecer hasta el día siguiente (guardado localmente)
- **Si toca "Update":** Abre directamente la página de la app en el App Store
- **Lógica inteligente:** Si el usuario ya lo vio hoy, no lo vuelve a ver aunque la DB diga activo

---

## Diseño del modal

- **Fondo oscuro** igual al modal de notificaciones (`Color(white: 0.06)`)
- **Ícono de estrella/sparkles** con animación de aparición suave
- **Título grande** (texto de la DB)
- **Subtítulo** secundario (texto de la DB)
- **Bullets de texto** en un bloque limpio — entre 1 y 4 ítems, cada uno con un checkmark o punto decorativo
- **Botón "Update Now"** — blanco sólido, full width, abre App Store
- **Botón "Later"** — texto gris sutil debajo

---

## Piezas que se crean

- **Modelo `AppUpdateConfig`** — estructura de datos que mapea la tabla de Supabase
- **Servicio `AppUpdateService`** — consulta la tabla `app_updates` en Supabase
- **Vista `AppUpdateSheet`** — el modal fullscreen con el diseño descrito
- **Integración en `DashboardRootView`** — se dispara después del primer cargado de actividades, respetando la lógica de "mostrar solo una vez por día"
