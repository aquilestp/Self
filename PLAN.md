# Ajustar tamaño del selector de WhatsApp y ancho del stat

**Cambios:**

1. **Selector de mensajes de WhatsApp 7% más pequeño** — Reducir proporcionalmente todas las dimensiones del componente de scroll (altura de items, tamaño de fuente, padding, ancho total) en un 7%

2. **Ancho correcto del stat "Pain is temporary, PRs are forever"** — Actualmente el widget de WhatsApp usa un `maxWidth: 240` fijo que deja espacio vacío a la derecha cuando el texto es corto. Se cambiará para que el ancho se ajuste al contenido real del texto, eliminando el espacio vacío innecesario