# Popular & Your Recents en el drawer de widgets

## Resumen

El drawer de widgets mostrará dos opciones de ordenamiento: **Popular** (por defecto) y **Your Recents**. Ambas muestran todos los widgets disponibles, solo cambia el orden en que aparecen. Los datos de popularidad se obtienen de la base de datos en tiempo real.

---

## Funcionalidad

### Tracking de uso

- Cada vez que el usuario **exporta o guarda** una imagen (compartir a Instagram Stories o guardar en la galería), se registran **todos los widgets que están en el canvas** en ese momento
- Se incrementa un contador global de popularidad por cada widget usado
- Se registra la fecha de último uso de cada widget para el usuario actual

### Tab "Popular" (por defecto)

- Muestra todos los widgets ordenados por número total de usos a nivel global (todos los usuarios de la app)
- Los widgets que nadie ha usado aparecen al final en el orden original
- Se carga al abrir el editor y se cachea en memoria durante la sesión

### Tab "Your Recents"

- Muestra todos los widgets ordenados por la fecha más reciente en que **tú** los usaste al exportar
- Los widgets que nunca has usado aparecen al final
- Si el usuario no tiene historial, se muestra automáticamente el orden de Popular con un mensaje sutil

---

## Diseño

### Selector de tabs

- Dos pills/chips minimalistas horizontales en la parte superior del drawer, debajo del handle
- Estilo: fondo translúcido con texto blanco, el pill activo tiene un fondo blanco más opaco
- Texto: "Popular" con ícono de flame, "Recents" con ícono de reloj
- Transición suave al cambiar entre tabs

### Grid de widgets

- El grid se mantiene exactamente igual visualmente, solo cambia el orden de los widgets
- Animación sutil al reordenar cuando se cambia de tab

---

## Base de datos (2 tablas nuevas en Supabase)

### Tabla `widget_popularity`

- Una fila por tipo de widget (~35 filas máximo, tabla siempre pequeña)
- Columnas: tipo de widget y contador de usos
- Se incrementa atómicamente con una función de base de datos para evitar conflictos de concurrencia
- Escala infinitamente porque la tabla nunca crece

### Tabla `user_widget_recents`

- Una fila por combinación usuario + widget (~35 filas máximo por usuario)
- Columnas: usuario, tipo de widget, fecha de último uso
- Se actualiza (upsert) cada vez que se exporta con ese widget
- Lectura rápida filtrada por usuario

---

## Flujo completo

1. Usuario abre el editor → se cargan los datos de popularidad global y recientes del usuario (en paralelo, en background)
2. El drawer muestra los widgets ordenados por "Popular" por defecto
3. Usuario puede cambiar a "Your Recents" con el pill selector
4. Usuario diseña su canvas con widgets y exporta → se registra el uso de cada widget presente en el canvas
5. El registro es fire-and-forget (no bloquea la exportación)

