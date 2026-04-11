# Nuevo stat "Blurred Vertical Text" — listado vertical de datos de actividad

## Descripción
Un nuevo stat tipo lista vertical que muestra todos los datos clave de la actividad apilados, con tipografía pesada (SF Pro Rounded Black), alineado a la izquierda, todo en mayúsculas. Similar al diseño del screenshot compartido.

---

## Líneas de datos (cada una se puede ocultar individualmente)
1. **Fecha** — APR 10, 2026
2. **Hora** — 5:49 AM
3. **Ubicación** — MEDELLÍN, ANTIOQUIA (ciudad + región de Strava)
4. **Distancia** — 9.8 KM
5. **Pace** — 5:17/KM
6. **Tiempo** — 52M 0S
7. **Elevación** — 37 M
8. **Calorías** — 785 CAL (requiere detalle de actividad)
9. **BPM** — 171 BPM (frecuencia cardíaca promedio)

---

## Diseño
- Tipografía: **SF Pro Rounded Black** — la más parecida al screenshot, pesada y con terminales redondeados
- Todo en **mayúsculas**
- Alineación a la **izquierda**
- Sin fondo ni bordes — solo el texto apilado con espaciado compacto entre líneas
- Color del texto sigue el **sistema de color del widget** (como los demás stats)
- Tamaño de fuente grande (~20-24pt) para que se vea impactante

---

## Cambios necesarios
- **Nuevo tipo de stat** llamado "Blurred Vertical Text" en el drawer con ícono de lista
- **Ubicación de Strava**: agregar campos `location_city` y `location_state` al modelo de detalle, para que se muestre la ciudad y región
- **Calorías**: usar el campo `calories` del detalle de actividad (ya existe en el modelo)
- **Controles de visibilidad**: cada línea tiene toggle individual en el editor (fecha, hora, ubicación, distancia, pace, tiempo, elevación, calorías, BPM)
- El stat aparece en el **drawer** como opción seleccionable
- Respeta el selector de **unidades** (KM/MI) para distancia y pace
