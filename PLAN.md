# Barra inferior fija con Atrás y Continue en el grid de fotos

## Cambios

### Barra inferior fija

- Se reemplaza el botón "Continue" flotante actual y el nav bar superior por una **barra inferior fija** que siempre está visible
- Dos botones lado a lado:

### Botón "Atrás" (izquierda)

- Icono `chevron.left` con el mismo estilo visual del editor: 18pt semibold, blanco, fondo `white 12%`, esquinas redondeadas (cornerRadius 18), tamaño 56×56

### Botón "Continue" (derecha)

- Ocupa el espacio restante, mismo alto (56pt), fondo blanco con texto negro, esquinas redondeadas (cornerRadius 18)
- **Cuando no hay foto seleccionada**: opacidad reducida (~0.35), deshabilitado — se ve "apagado"
- **Cuando hay foto seleccionada**: se activa con opacidad completa y es clickeable

### Se elimina

- El nav bar superior actual (título "Select your pic" + botón Back) se elimina ya que la navegación ahora vive en la barra inferior

