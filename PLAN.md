# Modal informativo de ciudad al tocar el ícono de location activo

## Cambio

Cuando el usuario ya dio permiso de ubicación y la ciudad está detectada, al tocar el ícono de `location.fill` (activo) en el canvas, aparecerá un modal informativo en lugar de no hacer nada.

## Comportamiento

- Si la ubicación **no está activa**: sigue pidiendo permiso (igual que hoy)
- Si la ubicación **ya está activa** (ícono lleno): muestra un alert con:
  - Título: **"You are in [Ciudad] 📍"**
  - Mensaje: *"Soon you'll be able to filter activities and discover events happening in your city."*
  - Botón: **"Got it"**

## Ajuste técnico

- Se agrega un nuevo estado `showCityInfoAlert`
- El botón de location, cuando `cityName != nil`, activa ese alert en vez de ignorar el tap

