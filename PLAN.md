# Nuevo stat "Notes" — simulación de la app Apple Notes


## Nuevo widget stat que simula un pantallazo de la app de Notas de iOS

**Inspirado en el pantallazo:** una tarjeta blanca con esquinas redondeadas que se ve exactamente como una nota abierta en la app de Notas de Apple.

---

### **Diseño**

- **Fondo blanco** con esquinas redondeadas (estilo tarjeta de Notes)
- **Barra superior:** flecha naranja/amarilla "‹" + texto "workout notes" en naranja, y a la derecha la distancia (ej: "3.0 km") con un ícono de corredor 🏃 en naranja
- **Título grande:** nombre de la actividad (ej: "Medellín Run") en negro bold, estilo título de nota
- **Subtítulo:** pace y duración debajo del título en gris, simulando el cuerpo de la nota
- **Sin opción de cambiar colores** — siempre blanco con acentos naranja/amarillo (como la app real de Notes)
- Sombra sutil para dar profundidad sobre la foto

### **Datos que muestra**
- Nombre de la actividad como título de la nota
- Distancia en la barra superior (respeta km/mi según la unidad seleccionada)
- Pace y duración como texto del cuerpo de la nota

### **Cambios técnicos**
- Se agrega un nuevo tipo de stat llamado "Notes" al catálogo existente
- Aparecerá en la grilla de stats disponibles con el ícono de nota
- No permite cambio de color (colores fijos como WhatsApp y Golden Arch)
