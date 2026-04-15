# Corregir zona horaria en todos los formatters de tiempo


## Problema
Las horas se muestran incorrectas porque los formatters aplican la zona horaria del dispositivo sobre una hora que Strava ya entrega en hora local (`start_date_local`). Esto desplaza la hora mostrada.

## Solución
Fijar `timeZone = UTC (offset 0)` en el parser de fechas y en todos los formatters de display, para que la hora que se muestra sea **exactamente la misma** que Strava registró.

## Cambios

**Formatter de parseo (`StravaViewModel`)**
- Añadir `f.timeZone = TimeZone(secondsFromGMT: 0)` al `isoFormatter` para que no aplique offset al leer la fecha

**Formatters de display (`CachedDateFormatters`)**
- `timeShort` (hora `9:54 PM`) → añadir `timeZone UTC`
- `bvtDate`, `dayOfWeek`, `monthDay`, `notesDate`, `medalDate` → añadir `timeZone UTC`

**Formatter de fecha en `StravaViewModel`**
- `displayDateFormatter` → añadir `timeZone UTC`

## Resultado
La hora mostrada en todos los widgets (BVT, Banners, Novelty, CityActivity) será idéntica a la hora que Strava tiene registrada para la actividad, independientemente de la zona horaria del teléfono.
