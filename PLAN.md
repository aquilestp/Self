# Nuevo stat "WhatsApp Message" — burbuja de chat

## Descripción

Un nuevo stat que simula una burbuja de mensaje de WhatsApp, idéntica al screenshot: fondo verde oscuro, texto blanco, hora de la actividad, y doble check azul.

---

## Features

- **Texto fijo editable**: el usuario puede escribir su propio mensaje (por defecto: "My coach would be proud")
- **Hora real**: muestra la hora de inicio de la actividad tomada de Strava (ej: "9:54 PM")
- **Doble check azul**: siempre visible, estilo WhatsApp (leído)
- **Fondo verde WhatsApp**: color fijo `#075E54` para el fondo de la burbuja, fiel al original
- **Esquina tipo WhatsApp**: burbuja con esquinas redondeadas y la "cola" triangular en la esquina inferior derecha

---

## Diseño

- Fondo de burbuja: verde oscuro WhatsApp (`#075E54` o similar `#1B7B5A`)
- Texto del mensaje: blanco, tamaño ~16pt, alineado a la izquierda
- Hora: texto más pequeño en verde claro/gris, a la derecha del mensaje
- Doble check: ícono azul (`checkmark` doble) al lado de la hora
- Bordes redondeados con `cornerRadius: 18`
- Cola triangular estilo WhatsApp en la esquina inferior derecha
- Padding interno natural tipo WhatsApp

---

## Interacción en el editor

- Al hacer tap en el stat en el canvas, se abre un campo de texto para editar el mensaje
- El campo de texto se muestra como parte del palette selector existente
- No necesita controles de visibilidad adicionales (siempre muestra: mensaje + hora + checks)

---

## Cambios

- Nuevo caso `whatsappMessage` en el listado de stats disponibles
- Nueva propiedad `whatsappText` en el widget para almacenar el texto editable
- Nueva vista del widget con la burbuja completa
- Nueva miniatura en el drawer mostrando la burbuja en miniatura
- Botón de edición de texto en el editor cuando el stat está seleccionado

