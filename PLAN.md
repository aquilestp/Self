# Consolidar métodos de conexión en un solo card secundario


## Qué cambia

La pantalla de inicio pasa de tener 4 cards en el carrusel (Create a post + Strava + COROS + Garmin) a tener **solo 2 cards del mismo tamaño**, limpios y con jerarquía clara.

## Cards resultantes

- **Card 1 — "Create a post"** (sin cambios): el mismo card actual, sin tocar nada.
- **Card 2 — "Bring your activities"**: nuevo card secundario del mismo tamaño. Tono más oscuro y sutil para señalar que es una opción secundaria. Incluirá un icono representativo, un título como *"Bring your activities"* y una descripción corta invitando a conectar Strava, COROS o Garmin. Botón de acción que abre el sheet.

## Sheet de conexión

Al tocar el segundo card se abre un **bottom sheet** (sin cambiar de pantalla) con los 3 métodos de conexión:

- **Strava** — con su botón de conectar activo (funcionalidad existente)
- **COROS** — marcado como *Coming soon* (funcionalidad existente)
- **Garmin** — marcado como *Coming soon* (funcionalidad existente)

El sheet tendrá un diseño limpio con filas verticales, cada una con el color de marca de cada servicio, igual que los cards actuales pero en formato compacto de lista dentro del modal.

## Lo que desaparece

Los 3 cards individuales de Strava, COROS y Garmin del carrusel horizontal dejan de mostrarse directamente — ahora viven dentro del sheet.
